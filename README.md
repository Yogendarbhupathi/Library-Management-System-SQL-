# Library Management System using SQL 

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `library_project`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

<img width="770" height="350" alt="image" src="https://github.com/user-attachments/assets/11a18c8d-1b9c-4183-b8f8-7c962279709d" />

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup
![ERD](https://github.com/najirh/Library-System-Management---P2/blob/main/library_erd.png)

- **Database Creation**: Created a database named `library_project`.
- **Table Creation**: Created tables for branch, employees, members, books, issued status and return status. Each table includes relevant columns and relationships.

```sql
-- Library Management System Project

USE library_project;

-- Creating and inserting data into branch table
CREATE TABLE branch(
    branch_id VARCHAR(10) PRIMARY KEY,
    manager_id VARCHAR(10),
    branch_address VARCHAR(30),
    contact_no VARCHAR(15)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/branch.csv'
INTO TABLE branch
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- Creating and inserting data into employees table
CREATE TABLE employees (
    emp_id VARCHAR(10) PRIMARY KEY,
    emp_name VARCHAR(30),
    position VARCHAR(30),
    salary DECIMAL(10, 2),
    branch_id VARCHAR(10),
    FOREIGN KEY (branch_id) REFERENCES branch(branch_id)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/employees.csv'
INTO TABLE employees
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- Creating and inserting data into books table
CREATE TABLE books(
    isbn VARCHAR(30) PRIMARY KEY,
    book_title VARCHAR(80),
    category VARCHAR(30),
    rental_price DECIMAL(10, 2),
    status VARCHAR(10),
    author VARCHAR(30),
    publisher VARCHAR(30)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/books.csv'
INTO TABLE books
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- Creating and inserting data into members table
CREATE TABLE members(
    member_id VARCHAR(10) PRIMARY KEY,
    member_name VARCHAR(80),
    member_address VARCHAR(30),
    date DATE
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/members.csv'
INTO TABLE members
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- Creating and inserting data into issue_status table
CREATE TABLE issue_status(
    issued_id VARCHAR(10) PRIMARY KEY,
    issued_member_id VARCHAR(30),
    issued_book_name VARCHAR(80),
    issued_date DATE,
    issued_book_isbn VARCHAR(50),
    issued_emp_id VARCHAR(10),
    FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
    FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn),
    FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/issued_status.csv'
INTO TABLE issue_status
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- Creating and inserting data into return_status table
CREATE TABLE return_status(
    return_id VARCHAR(10) PRIMARY KEY,
    issued_id VARCHAR(10),
    return_book_name VARCHAR(80),
    return_date DATE,
    return_book_isbn VARCHAR(50),
    FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/return_status.csv'
INTO TABLE return_status
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES("978-1-60129-456-2", "To Kill a Mockingbird", "Classic", 6.00, "yes", "Harper Lee", "J.B. Lippincott & Co.");
SELECT * FROM books;
```
**Task 2: Update an Existing Member's Address**

```sql
UPDATE members
SET member_address = "989 high NZ"
WHERE member_id = "C101";
```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
DELETE FROM issue_status
WHERE issued_id = "IS121";
```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
SELECT * FROM issue_status
WHERE issued_emp_id = "E101";
```


**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
SELECT issued_emp_id, count(*) AS total_books_issued
FROM issue_status
GROUP BY issued_emp_id
HAVING count(*) > 1;
```

### 3. CTAS (Create Table As Select)

**Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
CREATE TABLE book_issued_count AS
SELECT b.isbn, b.book_title, count(i.issued_id) as total_count
FROM books b
JOIN issue_status i
ON b.isbn = i.issued_book_isbn
GROUP BY b.isbn, b.book_title
ORDER BY total_count;
SELECT * FROM book_issued_count;
```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

**Task 7. Retrieve All Books in a Specific Category**:

```sql
SELECT * FROM books
WHERE category = "Classic";
```

**Task 8: Find Total Rental Income by Category**:

```sql
SELECT b.category, SUM(b.rental_price) AS total_revenue
FROM books b
JOIN issue_status i
ON b.isbn = i.issued_book_isbn
GROUP BY b.category
ORDER BY total_revenue DESC;
```

**Task 9. List Members Who Registered in the Last 4 years**:
```sql
SELECT * FROM members
WHERE date >= CURRENT_DATE() - INTERVAL 4 YEAR;
```

**Task 10. List Employees with Their Branch Manager's Name and their branch details**:

```sql
SELECT e1.emp_id, e1.emp_name, b.*, e2.emp_name
FROM employees e1
JOIN branch b
ON e1.branch_id = b.branch_id
JOIN employees e2
ON b.manager_id = e2.emp_id
ORDER BY e1.emp_id;
```

**Task 11. Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
CREATE TABLE high_value_books AS
SELECT * FROM books
WHERE rental_price > 7.00;
```

**Task 12: Retrieve the List of Books Not Yet Returned**:
```sql
SELECT i.issued_id, i.issued_book_isbn, i.issued_book_name, i.issued_member_id
FROM return_status r
RIGHT JOIN issue_status i
ON r.issued_id = i.issued_id
WHERE r.return_id IS NULL
ORDER BY i.issued_id;
```

## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
SELECT m.member_id, m.member_name, iss.issued_book_name as book_title, iss.issued_date,
            DATEDIFF(CURRENT_DATE(), iss.issued_date) as Days_overdue
FROM issue_status iss
JOIN members m
ON iss.issued_member_id = m.member_id
LEFT JOIN return_status re
ON iss.issued_id = re.issued_id
WHERE re.return_date IS NULL AND 
            DATEDIFF(CURRENT_DATE(), iss.issued_date) > 30
ORDER BY m.member_id;
```


**Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).


```sql
DELIMITER //
DROP PROCEDURE IF EXISTS add_return_records;
//
CREATE PROCEDURE add_return_records(
    IN p_return_id VARCHAR(10),
    IN p_issued_id VARCHAR(10),
    IN p_book_quality VARCHAR(10)
)
BEGIN
    DECLARE v_isbn VARCHAR(50);
    DECLARE v_book_title VARCHAR(80);
    
    INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
    VALUES (p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);
    
    SELECT issued_book_isbn, issued_book_name
    INTO v_isbn, v_book_title
    FROM issue_status
    WHERE issued_id = p_issued_id
    LIMIT 1;
    
    UPDATE books
    SET status = "yes"
    WHERE isbn = v_isbn;
    
    SELECT CONCAT("Thank you for returning book", v_book_title) AS message;
END;
//
DELIMITER ;

-- Testing procedure add_return_records
CALL add_return_records("RS119", "IS124", "Good");

SELECT * FROM return_status
WHERE issued_id = "IS124";

SELECT * FROM books
WHERE isbn = "978-0-06-025492-6";

```



**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
WITH branch_summary AS (
	SELECT b.branch_id, b.manager_id,
            COUNT(iss.issued_id) AS total_books_issued,
            COUNT(re.return_id) AS total_books_retured,
            SUM(bo.rental_price) AS total_revenue
    FROM branch b
    JOIN employees e
    ON b.branch_id = e.branch_id
    JOIN issue_status iss
    ON e.emp_id = iss.issued_emp_id
    LEFT JOIN return_status re
    ON iss.issued_id = re.issued_id
    JOIN books bo
    ON iss.issued_book_isbn = bo.isbn
    GROUP BY b.branch_id, b.manager_id
    ORDER BY b.branch_id
)
SELECT * FROM branch_summary;
```

**Task 16: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

```sql
CREATE TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN (
    SELECT DISTINCT issued_member_id
    FROM issue_status
    WHERE issued_date >= CURRENT_DATE - INTERVAL 2 MONTH
);

SELECT * FROM active_members;
```


**Task 17: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
SELECT e.emp_name, COUNT(iss.issued_id) AS total_books_issued, b.branch_id, b.manager_id
FROM employees e
JOIN issue_status iss
ON e.emp_id = iss.issued_emp_id
JOIN branch b
ON e.branch_id = b.branch_id
GROUP BY e.emp_name, b.branch_id, b.manager_id
ORDER BY total_books_issued DESC
LIMIT 3;
```

**Task 18: Identify Members Issuing High-Risk Books**  
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.    

```sql
SELECT m.member_name, m.member_id, COUNT(re.return_id) as no_of_damaged_books
FROM members m
JOIN issue_status iss
ON iss.issued_member_id = m.member_id
JOIN return_status re
ON iss.issued_id = re.issued_id
WHERE re.return_id IS NOT NULL AND
            re.book_quality = "Damaged"
GROUP BY m.member_name, m.member_id
HAVING no_of_damaged_books > 2
ORDER BY no_of_damaged_books;
```


**Task 19: Stored Procedure**
Objective:
Create a stored procedure to manage the status of books in a library system.
Description:
Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql
DELIMITER //
DROP PROCEDURE If EXISTS issue_book;
//
CREATE PROCEDURE issue_book(
    IN p_issued_id VARCHAR(10), 
    IN p_issued_member_id VARCHAR(30), 
    IN p_issued_book_isbn VARCHAR(30), 
    IN p_issued_emp_id VARCHAR(10)
)
BEGIN
    DECLARE v_status VARCHAR(10);
    
    SELECT status 
    INTO v_status
    FROM books
    WHERE isbn = p_issued_book_isbn;
    
	CASE
		WHEN v_status = "yes" THEN
			INSERT INTO issue_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
			VALUES
			(p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

			UPDATE books
                                    SET status = 'no'
			WHERE isbn = p_issued_book_isbn;

			SELECT CONCAT("Book records added successfully for book isbn :", p_issued_book_isbn) AS message;
		ELSE
			SELECT CONCAT("Sorry to inform you, the book you have requested is unavailable: ", p_issued_book_isbn) AS message;
	END CASE;
END;
//
DELIMITER ;

-- Testing procedure issue_book
-- Issuing avalible book
CALL issue_book('IS155', 'C108', '978-0-09-957807-9', 'E104');

-- Issuing unavalible book
CALL issue_book('IS155', 'C108', '978-0-7432-4722-5', 'E104');
```



**Task 20: Create Table As Select (CTAS)**
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines

```sql
CREATE TABLE overdue_fines AS
WITH due_books AS (
	SELECT m.member_id, iss.issued_id, DATEDIFF(CURRENT_DATE, iss.issued_date) AS due_days,
                        (DATEDIFF(CURRENT_DATE, iss.issued_date) - 30) * 0.5 AS fine
	FROM members m
    JOIN issue_status iss
    ON m.member_id = iss.issued_member_id
    LEFT JOIN return_status re
    ON iss.issued_id = re.issued_id
    WHERE re.return_id IS NULL AND
            DATEDIFF(CURRENT_DATE, iss.issued_date) > 30
)
SELECT member_id,
            COUNT(issued_id) AS no_of_overdue_books,
            SUM(fine) AS total_fine
FROM due_books
GROUP BY member_id
ORDER BY member_id;

SELECT * FROM overdue_fines;
```


## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.


