/* 
INFO 430: Database Design and Management 
Project Deliverable 4: Data Manipulation and Deriving Useful Information from the Database
Project Topic: Spotify Database
Students: Evonne La & Megan Chiang
Due Date: Friday, May 3, 2024
*/


/*
For this deliverable, each student will generate the following:

- Write the SQL code to create three (3) stored procedures, one to insert a row of data into a given table, another for updating data, and the third one for deleting a row of data.
- Write the SQL code to create two (2) triggers; one should be an AFTER trigger (either insert, update, or Delete) and the other should be an INSTEAD OF trigger (again, either insert, update, or delete).  The two should use different actions (e.g., if the first one is insert, then the second one should be either update or delete).
- Write the SQL code to create one (1) computed columns (https://docs.microsoft.com/en-us/sql/relational-databases/tables/specify-computed-columns-in-a-table?view=sql-server-ver16Links to an external site.)
- Write the SQL code to create two (2) different complex queries. One of these queries should use a stored procedure that takes given inputs and returns the expected output.

Here is a breakdown of what is expected of you:
- Correct use of parameters, variables, error handling, and explicit transaction.
- Correct the use of computed columns.
- Correct use of several components below (note: you query may not contain all these components. However, it is expected that your query is of considerable complexity):
    - multiple JOIN statements
    - leveraging OUTPUT parameters
    - declaring/populating variables
    - including error-handling
    - TOP command with ORDER BY
    - use of subqueries, or common table expressions, or temporary tables
    - aggregate function(s) (COUNT, AVG, SUM, MIN, MAX)
    - GROUP BY | HAVING.
*/