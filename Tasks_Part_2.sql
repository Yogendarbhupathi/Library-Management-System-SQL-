-- Advanced SQL Operations

/*
Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/
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

/*
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
*/
-- Stored Procedure
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

/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, 
the number of books returned, and the total revenue generated from book rentals.
*/
-- Using Common Table Expression
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

/*
Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members 
containing members who have issued at least one book in the last 2 months.
*/
CREATE TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN (
	SELECT DISTINCT issued_member_id
    FROM issue_status
    WHERE issued_date >= CURRENT_DATE - INTERVAL 2 MONTH
);

SELECT * FROM active_members;

/*
Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues.
Display the employee name, number of books processed, and their branch.
*/
SELECT e.emp_name, COUNT(iss.issued_id) AS total_books_issued, b.branch_id, b.manager_id
FROM employees e
JOIN issue_status iss
ON e.emp_id = iss.issued_emp_id
JOIN branch b
ON e.branch_id = b.branch_id
GROUP BY e.emp_name, b.branch_id, b.manager_id
ORDER BY total_books_issued DESC
LIMIT 3;

/*
Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. 
Display the member name, member ID, and the number of times they've issued damaged books.
*/
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

/*
Task 19: Stored Procedure Objective: 
Create a stored procedure to manage the status of books in a library system. 
Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
The procedure should first check if the book is available (status = 'yes'). 
If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
*/
-- Stored Procedure
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

/*
Task 20: Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.
Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. 
The table should include: The number of overdue books. The total fines, with each day's fine calculated at $0.50. 
The number of books issued by each member. The resulting table should show: Member ID Number of overdue books Total fines
*/
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