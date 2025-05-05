-- Library Management System Database
-- Created by [Your Name] on [Date]

-- Create database
DROP DATABASE IF EXISTS library_management;
CREATE DATABASE library_management;
USE library_management;

-- Create authors table
CREATE TABLE authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE,
    nationality VARCHAR(50),
    biography TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT full_name_unique UNIQUE (first_name, last_name)
) COMMENT 'Stores information about book authors';

-- Create categories table
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) COMMENT 'Book categories/genres';

-- Create books table
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    isbn VARCHAR(20) NOT NULL UNIQUE COMMENT 'International Standard Book Number',
    title VARCHAR(100) NOT NULL,
    publisher VARCHAR(100),
    publication_date DATE,
    edition VARCHAR(20),
    language VARCHAR(30) DEFAULT 'English',
    page_count INT,
    description TEXT,
    available_copies INT NOT NULL DEFAULT 1,
    total_copies INT NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_copies CHECK (available_copies <= total_copies AND available_copies >= 0)
) COMMENT 'Stores information about books in the library';

-- Create book_authors junction table (many-to-many relationship)
CREATE TABLE book_authors (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) COMMENT 'Links books to their authors (many-to-many relationship)';

-- Create book_categories junction table (many-to-many relationship)
CREATE TABLE book_categories (
    book_id INT NOT NULL,
    category_id INT NOT NULL,
    PRIMARY KEY (book_id, category_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) COMMENT 'Links books to their categories (many-to-many relationship)';

-- Create borrowers table
CREATE TABLE borrowers (
    borrower_id INT AUTO_INCREMENT PRIMARY KEY,
    library_card_number VARCHAR(20) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    address TEXT,
    membership_date DATE NOT NULL,
    membership_expiry_date DATE NOT NULL,
    status ENUM('active', 'expired', 'suspended') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_membership_dates CHECK (membership_expiry_date > membership_date)
) COMMENT 'Library members who can borrow books';

-- Create loans table
CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    borrower_id INT NOT NULL,
    loan_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE,
    status ENUM('active', 'returned', 'overdue') DEFAULT 'active',
    fine_amount DECIMAL(10, 2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE RESTRICT,
    FOREIGN KEY (borrower_id) REFERENCES borrowers(borrower_id) ON DELETE RESTRICT,
    CONSTRAINT chk_loan_dates CHECK (due_date > loan_date AND (return_date IS NULL OR return_date >= loan_date))
) COMMENT 'Tracks book borrowing history';

-- Insert sample data

-- Insert authors
INSERT INTO authors (first_name, last_name, birth_date, nationality) VALUES
('J.K.', 'Rowling', '1965-07-31', 'British'),
('George', 'Orwell', '1903-06-25', 'British'),
('Harper', 'Lee', '1926-04-28', 'American'),
('J.R.R.', 'Tolkien', '1892-01-03', 'British'),
('Agatha', 'Christie', '1890-09-15', 'British');

-- Insert categories
INSERT INTO categories (name, description) VALUES
('Fantasy', 'Fiction with magical or supernatural elements'),
('Dystopian', 'Fiction about oppressive societies'),
('Classic', 'Works of enduring quality and recognition'),
('Mystery', 'Fiction involving solving a crime or puzzle'),
('Adventure', 'Exciting, risky, or dangerous experiences');

-- Insert books
INSERT INTO books (isbn, title, publisher, publication_date, edition, language, page_count, description, available_copies, total_copies) VALUES
('9780439554930', 'Harry Potter and the Philosopher''s Stone', 'Bloomsbury', '1997-06-26', '1st', 'English', 223, 'First book in the Harry Potter series', 3, 5),
('9780451524935', '1984', 'Secker & Warburg', '1949-06-08', '1st', 'English', 328, 'Dystopian novel about totalitarianism', 2, 3),
('9780061120084', 'To Kill a Mockingbird', 'J. B. Lippincott & Co.', '1960-07-11', '1st', 'English', 281, 'Novel about racial injustice in the American South', 1, 2),
('9780261102354', 'The Lord of the Rings', 'Allen & Unwin', '1954-07-29', '2nd', 'English', 1178, 'Epic high fantasy novel', 4, 6),
('9780007113804', 'Murder on the Orient Express', 'Collins Crime Club', '1934-01-01', '1st', 'English', 256, 'Detective novel featuring Hercule Poirot', 2, 3);

-- Link books to authors
INSERT INTO book_authors (book_id, author_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);

-- Link books to categories
INSERT INTO book_categories (book_id, category_id) VALUES
(1, 1), (1, 5),  -- Harry Potter is Fantasy and Adventure
(2, 2), (2, 3),  -- 1984 is Dystopian and Classic
(3, 3),          -- To Kill a Mockingbird is Classic
(4, 1), (4, 5),  -- Lord of the Rings is Fantasy and Adventure
(5, 4);          -- Murder on the Orient Express is Mystery

-- Insert borrowers
INSERT INTO borrowers (library_card_number, first_name, last_name, email, phone, address, membership_date, membership_expiry_date, status) VALUES
('LC1001', 'John', 'Smith', 'john.smith@email.com', '555-0101', '123 Main St, Anytown, USA', '2023-01-15', '2024-01-15', 'active'),
('LC1002', 'Emily', 'Johnson', 'emily.j@email.com', '555-0102', '456 Oak Ave, Somewhere, USA', '2023-02-20', '2024-02-20', 'active'),
('LC1003', 'Michael', 'Williams', 'michael.w@email.com', '555-0103', '789 Pine Rd, Nowhere, USA', '2023-03-10', '2024-03-10', 'suspended'),
('LC1004', 'Sarah', 'Brown', 'sarah.b@email.com', '555-0104', '321 Elm St, Anywhere, USA', '2023-01-05', '2024-01-05', 'active'),
('LC1005', 'David', 'Jones', 'david.j@email.com', '555-0105', '654 Maple Dr, Everywhere, USA', '2023-04-01', '2024-04-01', 'expired');

-- Insert loans
INSERT INTO loans (book_id, borrower_id, loan_date, due_date, return_date, status, fine_amount) VALUES
(1, 1, '2023-06-01', '2023-06-15', '2023-06-14', 'returned', 0.00),
(2, 2, '2023-06-05', '2023-06-19', NULL, 'overdue', 5.50),
(3, 3, '2023-06-10', '2023-06-24', '2023-06-25', 'returned', 1.00),
(4, 4, '2023-06-15', '2023-06-29', NULL, 'active', 0.00),
(5, 5, '2023-05-20', '2023-06-03', '2023-06-10', 'returned', 7.00);