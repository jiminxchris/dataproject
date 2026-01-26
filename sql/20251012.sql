CREATE DATABASE my_shop;

--DROP DATABASE my_shop;

--use sample; -- postgresql에서 지원하지 않음

CREATE TABLE sample(
	product_id int PRIMARY KEY,
	name varchar(100),
	price int,
	stock_quantity int,
	release_date date
);

--DESC sample; -- 지원안됨, DBeaver에서는 데이블을 선택해서 확인

--SHOW tables;
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public' -- 원하는 스키마 이름으로 변경
  AND table_type = 'BASE TABLE';

SELECT table_name
FROM information_schema.tables
WHERE table_type = 'BASE TABLE';

SELECT datname FROM pg_database;

-----------------------------
INSERT INTO sample (product_id, name, price, stock_quantity, release_date)
VALUES (1, '프리미엄 청바지', 59900, 100, '2025-06-11');

SELECT * FROM sample;

UPDATE sample
SET price = 40000
WHERE product_id = 1;

SELECT * FROM sample;

DELETE FROM sample
 WHERE product_id = 1;

SELECT * FROM sample;

DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    address VARCHAR(255) NOT NULL,
    join_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price INT NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT '주문접수',
    CONSTRAINT fk_orders_customers FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),
    CONSTRAINT fk_orders_products FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);

-- 이건 mysql
--INSERT INTO customers VALUES (NULL, '강감찬', 'kang@example.com',
--'hashed_password_123', '서울시 관악구', '2025-06-11 10:30:00');
--INSERT INTO customers VALUES (NULL, '이순신', 'lee@example.com',
--'hashed_password_123', '서울시 관악구', '2025-06-12 10:30:00');

INSERT INTO customers (name, email, password, address, join_date)
VALUES ('강감찬', 'kang@example.com', 'hashed_password_123', '서울시 관악구', '2025-06-11 10:30:00');

INSERT INTO customers (name, email, password, address, join_date)
VALUES ('이순신', 'lee@example.com', 'hashed_password_123', '서울시 관악구', '2025-06-12 10:30:00');

-- 원하는 특정 열만 골라서 데이터 추가하기

INSERT INTO customers (name, email, password, address)
VALUES ('세종대왕', 'sejong@example.com', 'hashed_password_456', '서울시 종로구');


INSERT INTO products (name, price, stock_quantity)
VALUES ('베이직 반팔 티셔츠', 19900, 200);
INSERT INTO products (name, price, stock_quantity)
VALUES ('초록색 긴팔 티셔츠', 30000, 50);

-- 한번에 등록하기
INSERT INTO products (name, price, stock_quantity) VALUES
('검정 양말', 5000, 100),
('갈색 양말', 5000, 150),
('흰색 양말', 5000, 200);

-- 수정
SELECT * FROM products
WHERE product_id = 1;

SELECT * FROM products;

UPDATE products
SET price = 9800, stock_quantity = 580
WHERE product_id = 1;

SELECT * FROM products
WHERE product_id = 1;

UPDATE products
SET price = 990; -- WHERE product_id = 1; -- 실수로 생략

--SELECT @@SQL_SAFE_UPDATES;

UPDATE products
SET price = 980
WHERE name = '베이직 반팔 티셔츠'; -- name 컬럼을 사용했다.

DELETE FROM customers;

SHOW config_file;

-- 제약조건을 확인하기 위해 테이블 비우기
-- PostgreSQL에서는 시퀀스를 초기화하기 위한 별도의 명령어를 사용해야 합니다.
--TRUNCATE TABLE products, customers, orders CASCADE; 
TRUNCATE TABLE products, customers, orders RESTART IDENTITY CASCADE;

-- `name` 열을 빼고 INSERT를 시도한다.
INSERT INTO customers (email, password, address)
VALUES ('noname@example.com', 'password123', '서울시 마포구');

INSERT INTO customers (name, email, password, address)
VALUES ('강감찬', 'kang@example.com', 'new_password_789', '서울시 강남구');

-- 'kang@example.com'은 이미 '강감찬' 고객이 사용 중인 이메일이다.
INSERT INTO customers (name, email, password, address)
VALUES ('홍길동', 'kang@example.com', 'new_password_123', '서울시 송파구');

INSERT INTO products (name, price, stock_quantity)
VALUES ('베이직 반팔 티셔츠', 19900, 200);

-- 1번 고객이 1번 상품을 1개 주문한다.
INSERT INTO orders (customer_id, product_id, quantity)
VALUES (1, 1, 1);

SELECT * FROM orders;

-- 존재하지 않는 999번 고객이 1번 상품을 1개 주문하려고 시도한다.
INSERT INTO orders (customer_id, product_id, quantity)
VALUES (999, 1, 1);

DELETE FROM products
WHERE product_id=1;

DELETE FROM orders
WHERE order_id=1;

SELECT * FROM products
WHERE product_id=1;
delete FROM orders
WHERE product_id=1;
