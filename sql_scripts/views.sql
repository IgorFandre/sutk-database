-- Представление физических лиц
DROP VIEW IF EXISTS sutk.physical_entities CASCADE;
CREATE VIEW sutk.physical_entities AS
WITH curr_addresses AS (
    SELECT
        clients.client_id,
        addresses.address
    FROM sutk.clients AS clients
    LEFT JOIN sutk.addresses AS addresses ON clients.client_id = addresses.client_id
    WHERE NOW() BETWEEN addresses.from_date AND addresses.to_date
        OR addresses.from_date IS NULL
)
SELECT
    c.client_id,
    c.contact_name AS client_name,
    c.contact_phone AS client_phone,
    CASE
        WHEN w.middle_name IS NOT NULL THEN
            w.name || ' ' || w.surname || ' ' || w.middle_name
        ELSE
            w.name || ' ' || w.surname
    END AS manager_name,
    adr.address as current_address
FROM sutk.clients AS c
JOIN curr_addresses AS adr ON adr.client_id = c.client_id
JOIN sutk.workers as w ON c.worker_id = w.worker_id
WHERE company IS NULL;


-- Представление юридических лиц
DROP VIEW IF EXISTS sutk.legal_entities CASCADE;
CREATE VIEW sutk.legal_entities AS
WITH curr_addresses AS (
    SELECT
        clients.client_id,
        addresses.address
    FROM sutk.clients AS clients
    LEFT JOIN sutk.addresses AS addresses ON clients.client_id = addresses.client_id
    WHERE NOW() BETWEEN addresses.from_date AND addresses.to_date
        OR addresses.from_date IS NULL
)
SELECT
    c.client_id,
    c.company,
    c.contact_name AS client_name,
    c.contact_phone AS client_phone,
    CASE
        WHEN w.middle_name IS NOT NULL THEN
            w.name || ' ' || w.surname || ' ' || w.middle_name
        ELSE
            w.name || ' ' || w.surname
    END AS manager_name,
    adr.address as current_address
FROM sutk.clients AS c
JOIN curr_addresses AS adr ON adr.client_id = c.client_id
JOIN sutk.workers as w ON c.worker_id = w.worker_id
WHERE company IS NOT NULL;


-- Представление запасов на складе
DROP VIEW IF EXISTS sutk.storage CASCADE;
CREATE VIEW sutk.storage AS
SELECT
    products.product_id,
    products.name,
    products.available,
    CAST(COALESCE(cl_products.not_available, 0) AS INTEGER) AS booked,
    CAST(products.available - COALESCE(cl_products.not_available, 0) AS INTEGER) AS free
FROM sutk.products AS products
LEFT JOIN (
    SELECT
        ord_products.product_id,
        SUM(ord_products.count) as not_available
    FROM sutk.ordered_products AS ord_products
    JOIN sutk.orders AS orders ON ord_products.order_id = orders.order_id
    JOIN sutk.order_statuses AS statuses ON orders.order_id = statuses.order_id
    WHERE statuses.to_date IS NULL
    GROUP BY ord_products.product_id
) AS cl_products ON products.product_id = cl_products.product_id;


-- Представление обработки заказов
DROP VIEW IF EXISTS sutk.orders_progress CASCADE;
CREATE VIEW sutk.orders_progress AS
SELECT
    ord.order_id AS order_id,
    CASE
        WHEN cl.company IS NOT NULL THEN
            '"' || cl.company || '" ' || cl.contact_name
        ELSE
            cl.contact_name
    END AS client_name,
    tps.name AS status,
    ord_stat.from_date AS status_date,
    ord.order_date
FROM sutk.order_statuses AS ord_stat
JOIN sutk.orders AS ord ON ord_stat.order_id = ord.order_id
JOIN sutk.clients AS cl ON ord.client_id = cl.client_id
JOIN sutk.status_types AS tps ON ord_stat.status_id = tps.status_id
WHERE to_date IS NULL;