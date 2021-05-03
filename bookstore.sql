
--  Create the structure for the tables
CREATE TABLE customers	(
	customer_id		INTEGER			GENERATED ALWAYS AS IDENTITY	PRIMARY KEY,
	first_name		VARCHAR(100)	NOT NULL,
	last_name		VARCHAR(100)	NOT NULL,
	email_address	VARCHAR(300)	NULL,
	home_phone		VARCHAR(100)	NULL,
	city			VARCHAR(50)		NULL,
	state_name		VARCHAR(50)		NULL,
	years_old		INTEGER			NULL
);

CREATE TABLE books	(
	book_id				INTEGER			GENERATED ALWAYS AS IDENTITY	PRIMARY KEY,
	title				VARCHAR(100)	NOT NULL,
	author				VARCHAR(100)	NOT NULL,
	original_language	VARCHAR(50)		NOT NULL,
	first_published		INTEGER			NULL,
	sales_in_millions	DECIMAL(8,2)	NULL,
	price				DECIMAL(8,2)	NULL
);

CREATE TABLE orders	(
	order_id		INTEGER			GENERATED ALWAYS AS IDENTITY	PRIMARY KEY,
	customer_id		INTEGER			NOT NULL,
	book_id			INTEGER			NOT NULL,
	quantity		INTEGER			NOT NULL,
	price_base		DECIMAL(8,2)	NOT NULL,
	order_date		DATE			NOT NULL,
	ship_date		DATE			NULL
);







-- Import data into the tables
COPY customers 
FROM 'customers.txt' -- put in th path to the .txt file
DELIMITER ',' 
CSV HEADER;

COPY books 
FROM 'books.txt' -- put in th path to the .txt file
DELIMITER ',' 
CSV HEADER;

COPY orders 
FROM 'orders.txt' -- put in th path to the .txt file
DELIMITER ',' 
CSV HEADER;







-- create indexes for the tables
CREATE INDEX books_author_idx ON books (author);
CREATE INDEX books_title_idx ON books (title);






-- look at the first 10 rows in each table; customers, orders, and books 
SELECT *
FROM customers
LIMIT 10;

SELECT *
FROM orders
LIMIT 10;

SELECT *
FROM books
LIMIT 10;










-- Examine the indexes that already exist on the three tables customers, books and orders
SELECT *
FROM pg_Indexes
WHERE tablename = 'customers';

SELECT *
FROM pg_Indexes
WHERE tablename = 'books';

SELECT *
FROM pg_Indexes
WHERE tablename = 'orders';











-- EXAMINE THE EFFECTS ON TIME WITH AND WITHOUT AN INDEX

-- WITHOUT INDEX, delete any previous indexes
EXPLAIN ANALYZE
SELECT customer_id, quantity
FROM orders
WHERE quantity > 18;
-- Planning Time: 0.083 ms
-- Execution Time: 9.377 ms

-- Now creating index 
CREATE INDEX orders_quantity_idx 
ON orders (
    customer_id, 
    quantity
);

-- WITH INDEX
EXPLAIN ANALYZE
SELECT customer_id, quantity
FROM orders
WHERE quantity > 18;
-- Planning Time: 1.469 ms
-- Execution Time: 6.424 ms



-- ANOTHER EXAMPLE
EXPLAIN ANALYZE
SELECT quantity, price_base
FROM orders
WHERE quantity * price_base > 100;
-- Planning Time: 0.099 ms
-- Execution Time: 36.095 ms

CREATE INDEX orders_quantity_price_idx 
ON orders ((quantity * price_base));


EXPLAIN ANALYZE
SELECT quantity, price_base
FROM orders
WHERE quantity * price_base > 100;
-- Planning Time: 1.624 ms
-- Execution Time: 19.991 ms











-- EXAMINE THE EFFECTS ON TIME WITH AND WITHOUR A PRIMARY KEY
-- Without primary key, delete and previous primary key
EXPLAIN ANALYZE
SELECT customer_id
FROM customers
WHERE customer_id > 5000;
-- Planning Time: 0.147 ms
-- Execution Time: 13.190 ms

-- Let’s create that primary key now.
ALTER TABLE customers
  ADD CONSTRAINT customers_pkey
    PRIMARY KEY (customer_id);
--

-- With primary key
EXPLAIN ANALYZE
SELECT customer_id
FROM customers
WHERE customer_id > 5000;
-- Planning Time: 1.424 ms
-- Execution Time: 12.400 ms















-- Use EXPLAIN ANALYZE to check the runtime of a query searching for the 
-- original_language, title, and sales_in_millions from the books table 
-- that have an original_language of 'French'
EXPLAIN ANALYZE 
SELECT original_language, title, sales_in_millions
FROM books
WHERE original_language = 'French';
-- Planning Time: 0.086 ms
-- Execution Time: 0.052 ms


-- get the size of the books table
SELECT pg_size_pretty (pg_total_relation_size('books'));
-- size: 56 kB


-- Your translation team needs a list of the language they are written in, book titles, 
-- and the number of copies sold to see if it is worth the time and money in translating these books. 
-- Create an index
CREATE INDEX books_translation_idx 
ON books (
    original_language, 
    title, 
    sales_in_millions
);


-- compare the runtime and size with our index
EXPLAIN ANALYZE 
SELECT original_language, title, sales_in_millions
FROM books
WHERE original_language = 'French';
-- Planning Time: 1.406 ms
-- Execution Time: 0.051 ms









-- Build a multicolumn index
CREATE INDEX customer_book_id_idx ON orders(customer_id, book_id);

CREATE INDEX customer_book_id_quantity_idx ON orders(customer_id, book_id, quantity);

CREATE INDEX books_author_title_idx ON books (author, title);

-- Delete the multicolumn index 
DROP INDEX IF EXISTS books_translation_idx;









-- Using CLUSTER to speed up query time
-- https://www.postgresql.org/docs/9.1/sql-cluster.html
CLUSTER customers USING customers_pkey;
CLUSTER customers;

-- you can query the first 10 rows of the customers table again 
-- to see the table organized by the primary key.
SELECT *
FROM customers
LIMIT 10;









-- Load all of their orders into your orders table with a bulk copy
COPY orders 
FROM 'C:\Users\smhaq\OneDrive\Minhaj Documents\Career\SQL\Codecademy\PostgreSQL\Projects\BookStoreIndex\orders_add.txt' 
DELIMITER ',' 
CSV HEADER;
-- TIME TAKEN: 708 ms





































