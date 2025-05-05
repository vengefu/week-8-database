-- Task Management System Database
-- Created by [Your Name] on [Date]

DROP DATABASE IF EXISTS task_manager;
CREATE DATABASE task_manager;
USE task_manager;

-- Create users table
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT 'System users who can create and manage tasks';

-- Create tasks table
CREATE TABLE tasks (
    task_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    status ENUM('pending', 'in_progress', 'completed') DEFAULT 'pending',
    priority ENUM('low', 'medium', 'high') DEFAULT 'medium',
    due_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) COMMENT 'Tasks created by users';

-- Insert sample data
INSERT INTO users (username, email, password_hash, first_name, last_name) VALUES
('johndoe', 'john.doe@example.com', '$2a$10$xJwL5v5Jz5U5Jz5U5Jz5UOeJz5U5Jz5U5Jz5U5Jz5U5Jz5U5Jz5U', 'John', 'Doe'),
('janedoe', 'jane.doe@example.com', '$2a$10$xJwL5v5Jz5U5Jz5U5Jz5UOeJz5U5Jz5U5Jz5U5Jz5U5Jz5U5Jz5U', 'Jane', 'Doe'),
('bobsmith', 'bob.smith@example.com', '$2a$10$xJwL5v5Jz5U5Jz5U5Jz5UOeJz5U5Jz5U5Jz5U5Jz5U5Jz5U5Jz5U', 'Bob', 'Smith');

-- Insert tasks
INSERT INTO tasks (user_id, title, description, status, priority, due_date) VALUES
(1, 'Complete project', 'Finish the task management system project', 'in_progress', 'high', '2023-12-15'),
(1, 'Buy groceries', 'Milk, eggs, bread, and fruits', 'pending', 'medium', '2023-12-10'),
(2, 'Schedule meeting', 'Team meeting for project review', 'completed', 'high', '2023-12-05'),
(3, 'Update resume', 'Add recent job experience and skills', 'pending', 'low', '2023-12-20'),
(2, 'Read book', 'Finish reading "Clean Code"', 'in_progress', 'medium', '2023-12-25');