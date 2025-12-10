-- Inserting additional data to perform advanced SQL operations

-- Inserting data into issue_status table
INSERT INTO issue_status(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
VALUES
('IS151', 'C118', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL 24 DAY,  '978-0-553-29698-2', 'E108'),
('IS152', 'C119', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL 13 DAY,  '978-0-553-29698-2', 'E109'),
('IS153', 'C106', 'Pride and Prejudice', CURRENT_DATE - INTERVAL 7 DAY,  '978-0-14-143951-8', 'E107'),
('IS154', 'C105', 'The Road', CURRENT_DATE - INTERVAL 32 DAY,  '978-0-375-50167-0', 'E101');

-- Adding new column in return_status
ALTER TABLE return_status
ADD Column book_quality VARCHAR(15) DEFAULT('Good');

UPDATE return_status
SET book_quality = 'Damaged'
WHERE issued_id IN ('IS113', 'IS115', 'IS116', 'IS120');

UPDATE return_status
SET return_date = return_date + INTERVAL 19 MONTH
WHERE issued_id >= "IS106";

select * FROM return_status;

UPDATE issue_status
SET issued_date = issued_date + INTERVAL 19 MONTH
WHERE YEAR(issued_date) = 2024;

select * from issue_status;

-- updating books table
WITH due_books AS (
	SELECT DISTINCT iss.issued_book_isbn as isbn
    FROM issue_status iss
    LEFT JOIN return_status re
    ON iss.issued_id = re.issued_id
    WHERE re.return_date IS NULL
)
UPDATE books
SET status = "no"
WHERE isbn IN (SELECT isbn FROM due_books);

SELECT re.return_id, re.issued_id, iss.issued_member_id, re.book_quality
FROM return_status re
JOIN issue_status iss
ON re.issued_id = iss.issued_id
WHERE re.return_id is not null
order by iss.issued_member_id; 