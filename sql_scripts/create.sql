CREATE SCHEMA IF NOT EXISTS sutk;

DROP TABLE IF EXISTS sutk.departments CASCADE;
CREATE TABLE sutk.departments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    phone CHAR(16) CHECK(phone LIKE '+7(___)___-__-__'),
    email VARCHAR(50) CHECK(email LIKE '%_@__%.__%')
);

DROP TABLE IF EXISTS sutk.workers CASCADE;
CREATE TABLE sutk.workers (
    id SERIAL PRIMARY KEY,
    department_id INTEGER REFERENCES sutk.departments(id),
    name VARCHAR(20) NOT NULL,
    surname VARCHAR(20) NOT NULL,
    middle_name VARCHAR(20)
);

DROP TABLE IF EXISTS sutk.clients CASCADE;
CREATE TABLE sutk.clients (
    id SERIAL PRIMARY KEY,
    worker_id INTEGER REFERENCES sutk.workers(id),
    company VARCHAR(50) UNIQUE,
    contact_name VARCHAR(65) NOT NULL,
    phone CHAR(16) CHECK(phone LIKE '+7(___)___-__-__')
);

DROP TABLE IF EXISTS sutk.addresses CASCADE;
CREATE TABLE sutk.addresses (
    client_id INTEGER REFERENCES sutk.clients(id),
    address VARCHAR(200) NOT NULL,
    from_date TIMESTAMP DEFAULT NOW(),
    to_date TIMESTAMP DEFAULT '5999-01-01 00:00:00'
);

DROP TABLE IF EXISTS sutk.orders CASCADE;
CREATE TABLE sutk.orders (
    id SERIAL PRIMARY KEY,
    client_id INTEGER REFERENCES sutk.clients(id),
    description TEXT,
    delivery BOOLEAN NOT NULL,
	order_date TIMESTAMP DEFAULT NOW()
);

DROP TABLE IF EXISTS sutk.step_names CASCADE;
CREATE TABLE sutk.step_names (
    id SERIAL PRIMARY KEY,
    name VARCHAR(15) NOT NULL
);

DROP TABLE IF EXISTS sutk.steps CASCADE;
CREATE TABLE sutk.steps (
    worker_id INTEGER REFERENCES sutk.workers(id),
    order_id INTEGER REFERENCES sutk.orders(id),
    step_id INTEGER REFERENCES sutk.step_names(id),
    from_date DATE DEFAULT CURRENT_DATE,
    to_date DATE,
    CONSTRAINT step_combination UNIQUE (worker_id, order_id, step_id)
);

DROP TABLE IF EXISTS sutk.products CASCADE;
CREATE TABLE sutk.products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    quality VARCHAR(50),
    description TEXT,
    price NUMERIC(10, 2) NOT NULL CHECK(price >= 0),
    available INTEGER NOT NULL CHECK(available >= 0),
    weight NUMERIC(10, 3) NOT NULL CHECK(weight >= 0)
);

DROP TABLE IF EXISTS sutk.ordered_products CASCADE;
CREATE TABLE sutk.ordered_products (
    order_id INTEGER REFERENCES sutk.orders(id),
    product_id INTEGER REFERENCES sutk.products(id),
    count INTEGER NOT NULL CHECK(count > 0),
    CONSTRAINT order_combination UNIQUE (order_id, product_id)
);