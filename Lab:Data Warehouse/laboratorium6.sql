BEGIN;
CREATE SCHEMA olap;

SET search_path TO olap;

CREATE SEQUENCE customerId;
CREATE SEQUENCE productId;
CREATE SEQUENCE addresseeId;

CREATE TABLE customer_dim (
    customer_key SERIAL PRIMARY KEY,
    idcustomer VARCHAR(10),
    name VARCHAR(40),
    city VARCHAR(40),
    zip CHAR(6),
    address VARCHAR(40),
    email VARCHAR(40),
    phone VARCHAR(16),
    fax VARCHAR(16),
    nip CHAR(13),
    regon CHAR(9)
);


CREATE TABLE product_dim (
    product_key SERIAL PRIMARY KEY,
    idproduct CHAR(5),
    name VARCHAR(40),
    description VARCHAR(100),
    price NUMERIC(7,2),
    min INTEGER,
    available INTEGER
);

CREATE TABLE addressee_dim (
    address_key SERIAL PRIMARY KEY,
    idaddressee integer,
    name varchar(40),
    city varchar(40),
    zip char(6),
    address varchar(60)
);

CREATE TABLE date_dim (
    date_key SERIAL PRIMARY KEY,
    date DATE,
    day INT,
    month INT,
    year INT,
    quarter INT
);

CREATE TABLE orders_fact (
    order_key SERIAL PRIMARY KEY,
    idorder INTEGER,
    customer_key INTEGER,
    product_key INTEGER,
    address_key INTEGER,
    date_key INTEGER,
    price NUMERIC,
    paid BOOLEAN,
    comments VARCHAR(200),
    FOREIGN KEY (customer_key) REFERENCES customer_dim(customer_key),
    FOREIGN KEY (product_key) REFERENCES product_dim(product_key),
    FOREIGN KEY (address_key) REFERENCES addressee_dim(address_key),
    FOREIGN KEY (date_key) REFERENCES date_dim(date_key)
);

INSERT INTO customer_dim (idcustomer, name, city, zip, address, email, phone, fax, nip, regon)
SELECT DISTINCT idcustomer, name, city, zip, address, email, phone, fax, nip, regon FROM lab06.customer;

INSERT INTO product_dim (idproduct, name, description, price, min, available)
SELECT DISTINCT idproduct, name, description, price, min, available FROM lab06.product;

INSERT INTO addressee_dim (idaddressee, name, city, zip, address)
SELECT DISTINCT idaddressee, name, city, zip, address FROM lab06.addressee;

INSERT INTO date_dim (date, day, month, year, quarter)
SELECT DISTINCT date,
    EXTRACT(DAY FROM date),
    EXTRACT(MONTH FROM date),
    EXTRACT(YEAR FROM date),
    EXTRACT(QUARTER FROM date)
FROM lab06.orders;



INSERT INTO orders_fact (idorder, customer_key, product_key, address_key, date_key, price, paid, comments)
SELECT 
    o.idorder,
    dc.customer_key,
    dp.product_key,
    da.address_key,
    dt.date_key,
    o.price,
    o.paid,
    o.comments
FROM 
    lab06.orders o
JOIN customer_dim dc ON o.idcustomer = dc.idcustomer
JOIN product_dim dp ON o.idproduct = dp.idproduct
JOIN addressee_dim da ON o.idaddressee = da.idaddressee
JOIN date_dim dt ON o.date = dt.date;

SELECT
    t.year,
    t.month,
    SUM(f.price) AS total_sales
FROM
    orders_fact f
JOIN
    date_dim t ON f.date_key = t.date_key
WHERE
    t.year = 2016
GROUP BY
    t.year, t.month
ORDER BY
    t.month;
    
COMMIT;