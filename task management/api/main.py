# task_manager/api/main.py
from fastapi import FastAPI, HTTPException, Depends, status
from pydantic import BaseModel
from typing import List, Optional
import mysql.connector
from mysql.connector import Error
from passlib.context import CryptContext
from datetime import date
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Initialize FastAPI
app = FastAPI(
    title="Task Management API",
    description="A simple CRUD API for managing tasks",
    version="1.0.0",
)

# Password hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Database configuration
def get_db_connection():
    try:
        connection = mysql.connector.connect(
            host=os.getenv("DB_HOST", "localhost"),
            user=os.getenv("DB_USER", "root"),
            password=os.getenv("DB_PASSWORD", ""),
            database=os.getenv("DB_NAME", "task_manager")
        )
        return connection
    except Error as e:
        print(f"Error connecting to MySQL: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Database connection failed"
        )

# Models
class UserBase(BaseModel):
    username: str
    email: str
    first_name: Optional[str] = None
    last_name: Optional[str] = None

class UserCreate(UserBase):
    password: str

class User(UserBase):
    user_id: int
    created_at: str
    updated_at: str

    class Config:
        from_attributes = True

class TaskBase(BaseModel):
    title: str
    description: Optional[str] = None
    status: Optional[str] = "pending"
    priority: Optional[str] = "medium"
    due_date: Optional[date] = None

class TaskCreate(TaskBase):
    pass

class Task(TaskBase):
    task_id: int
    user_id: int
    created_at: str
    updated_at: str

    class Config:
        from_attributes = True

# Helper functions
def verify_password(plain_password: str, hashed_password: str):
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password: str):
    return pwd_context.hash(password)

# User CRUD operations
@app.post("/users/", response_model=User, status_code=status.HTTP_201_CREATED)
def create_user(user: UserCreate):
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)
    
    # Check if username or email already exists
    cursor.execute("SELECT * FROM users WHERE username = %s OR email = %s", 
                  (user.username, user.email))
    existing_user = cursor.fetchone()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Username or email already registered"
        )
    
    # Hash the password
    hashed_password = get_password_hash(user.password)
    
    # Insert new user
    cursor.execute(
        """
        INSERT INTO users (username, email, password_hash, first_name, last_name)
        VALUES (%s, %s, %s, %s, %s)
        """,
        (user.username, user.email, hashed_password, user.first_name, user.last_name)
    )
    connection.commit()
    
    # Get the newly created user
    user_id = cursor.lastrowid
    cursor.execute("SELECT * FROM users WHERE user_id = %s", (user_id,))
    new_user = cursor.fetchone()
    
    cursor.close()
    connection.close()
    
    return new_user

@app.get("/users/{user_id}", response_model=User)
def read_user(user_id: int):
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)
    
    cursor.execute("SELECT * FROM users WHERE user_id = %s", (user_id,))
    user = cursor.fetchone()
    
    cursor.close()
    connection.close()
    
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    
    return user

# Task CRUD operations
@app.post("/tasks/", response_model=Task, status_code=status.HTTP_201_CREATED)
def create_task(task: TaskCreate, user_id: int):
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)
    
    # Check if user exists
    cursor.execute("SELECT * FROM users WHERE user_id = %s", (user_id,))
    if cursor.fetchone() is None:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Insert new task
    cursor.execute(
        """
        INSERT INTO tasks (user_id, title, description, status, priority, due_date)
        VALUES (%s, %s, %s, %s, %s, %s)
        """,
        (user_id, task.title, task.description, task.status, task.priority, task.due_date)
    )
    connection.commit()
    
    # Get the newly created task
    task_id = cursor.lastrowid
    cursor.execute("SELECT * FROM tasks WHERE task_id = %s", (task_id,))
    new_task = cursor.fetchone()
    
    cursor.close()
    connection.close()
    
    return new_task

@app.get("/tasks/{task_id}", response_model=Task)
def read_task(task_id: int):
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)
    
    cursor.execute("SELECT * FROM tasks WHERE task_id = %s", (task_id,))
    task = cursor.fetchone()
    
    cursor.close()
    connection.close()
    
    if task is None:
        raise HTTPException(status_code=404, detail="Task not found")
    
    return task

@app.get("/users/{user_id}/tasks", response_model=List[Task])
def read_user_tasks(user_id: int):
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)
    
    # Check if user exists
    cursor.execute("SELECT * FROM users WHERE user_id = %s", (user_id,))
    if cursor.fetchone() is None:
        raise HTTPException(status_code=404, detail="User not found")
    
    cursor.execute("SELECT * FROM tasks WHERE user_id = %s", (user_id,))
    tasks = cursor.fetchall()
    
    cursor.close()
    connection.close()
    
    return tasks

@app.put("/tasks/{task_id}", response_model=Task)
def update_task(task_id: int, task: TaskCreate):
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)
    
    # Check if task exists
    cursor.execute("SELECT * FROM tasks WHERE task_id = %s", (task_id,))
    existing_task = cursor.fetchone()
    if existing_task is None:
        raise HTTPException(status_code=404, detail="Task not found")
    
    # Update task
    cursor.execute(
        """
        UPDATE tasks 
        SET title = %s, description = %s, status = %s, priority = %s, due_date = %s
        WHERE task_id = %s
        """,
        (task.title, task.description, task.status, task.priority, task.due_date, task_id)
    )
    connection.commit()
    
    # Get the updated task
    cursor.execute("SELECT * FROM tasks WHERE task_id = %s", (task_id,))
    updated_task = cursor.fetchone()
    
    cursor.close()
    connection.close()
    
    return updated_task

@app.delete("/tasks/{task_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_task(task_id: int):
    connection = get_db_connection()
    cursor = connection.cursor()
    
    # Check if task exists
    cursor.execute("SELECT * FROM tasks WHERE task_id = %s", (task_id,))
    if cursor.fetchone() is None:
        raise HTTPException(status_code=404, detail="Task not found")
    
    # Delete task
    cursor.execute("DELETE FROM tasks WHERE task_id = %s", (task_id,))
    connection.commit()
    
    cursor.close()
    connection.close()
    
    return None