-- Beginner to Intermediate Tasks

-- CRUD Operations
-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES("978-1-60129-456-2", "To Kill a Mockingbird", "Classic", 6.00, "yes", "Harper Lee", "J.B. Lippincott & Co.");
SELECT * FROM books;

-- Task 2: Update an Existing Member's Address
UPDATE members
SET member_address = "989 high NZ"
WHERE member_id = "C101";
SELECT * FROM members;

-- Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
DELETE FROM issue_status
WHERE issued_id = "IS121";
SELECT * FROM issue_status;

-- Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.
SELECT * FROM issue_status
WHERE issued_emp_id = "E101";

-- Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.
SELECT issued_emp_id, count(*) AS total_books_issued
FROM issue_status
GROUP BY issued_emp_id
HAVING count(*) > 1;

-- CTAS (Create Table As Select)
-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt
CREATE TABLE book_issued_count AS
SELECT b.isbn, b.book_title, count(i.issued_id) as total_count
FROM books b
JOIN issue_status i
ON b.isbn = i.issued_book_isbn
GROUP BY b.isbn, b.book_title
ORDER BY total_count;
SELECT * FROM book_issued_count;

-- Data Analysis & Findings
-- Task 7. Retrieve All Books in a Specific Category, Retrieve books in "Classic" Category
SELECT * FROM books
WHERE category = "Classic";

-- Task 8: Find Total Rental Income by Category
SELECT b.category, SUM(b.rental_price) AS total_revenue
FROM books b
JOIN issue_status i
ON b.isbn = i.issued_book_isbn
GROUP BY b.category
ORDER BY total_revenue DESC;

-- Task 9: List Members Who Registered in the Last 4 years
SELECT * FROM members
WHERE date >= CURRENT_DATE() - INTERVAL 4 YEAR;

-- Task 10: List Employees with Their Branch Manager's Name and their branch details
SELECT e1.emp_id, e1.emp_name, b.*, e2.emp_name
FROM employees e1
JOIN branch b
ON e1.branch_id = b.branch_id
JOIN employees e2
ON b.manager_id = e2.emp_id
ORDER BY e1.emp_id;

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:
CREATE TABLE high_value_books AS
SELECT * FROM books
WHERE rental_price > 7.00;
SELECT * FROM high_value_books;

-- Task 12: Retrieve the List of Books Not Yet Returned
SELECT i.issued_id, i.issued_book_isbn, i.issued_book_name, i.issued_member_id
FROM return_status r
RIGHT JOIN issue_status i
ON r.issued_id = i.issued_id
WHERE r.return_id IS NULL
ORDER BY i.issued_id;