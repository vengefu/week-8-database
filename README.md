# Week-8-assignment
# Task Management API

A simple CRUD API for managing tasks and users, built with FastAPI and MySQL.

## Features

- User management (create, read)
- Task management (create, read, update, delete)
- List all tasks for a user
- Secure password hashing

## Setup

1. Clone the repository
2. Install dependencies: `pip install -r requirements.txt`
3. Set up MySQL database:
   - Create a database named `task_manager`
   - Run the SQL script in `database/setup.sql`
4. Create a `.env` file with your database credentials:
5. Run the application: `uvicorn api.main:app --reload`

## API Documentation

After starting the server, visit `http://localhost:8000/docs` for interactive API documentation.

