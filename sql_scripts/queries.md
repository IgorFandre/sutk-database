# Запросы к базе данных

### Составить топ-5 клиентов по количеству потраченных денег на заказы

```sql
SELECT
    CASE
        WHEN clients.company IS NOT NULL THEN
            '"' || clients.company || '" ' || clients.contact_name
        ELSE
            clients.contact_name
	END AS client_name,
    SUM(products.price * ordered.count) AS total_price
FROM sutk.ordered_products AS ordered
JOIN sutk.products AS products ON products.product_id = ordered.product_id
JOIN sutk.orders AS orders ON ordered.order_id = orders.order_id
JOIN sutk.clients AS clients ON orders.client_id = clients.client_id
GROUP BY clients.client_id
ORDER BY total_price DESC
LIMIT 5;
```

### Получить список клиентов, у которых было суммарное количество заказов более среднего по клиентам

```sql
SELECT
	cl.client_id AS client_id,
	CASE
        WHEN cl.company IS NOT NULL THEN
            '"' || cl.company || '" ' || cl.contact_name
        ELSE
            cl.contact_name
	END AS client_name,
	COUNT(ord.order_id) as orders_cnt
FROM sutk.orders AS ord
JOIN  sutk.clients AS cl ON ord.client_id = cl.client_id
GROUP BY cl.client_id
HAVING COUNT(ord.order_id) > (
    SELECT AVG(orders_cnt)
    FROM (
        SELECT COUNT(sutk.orders.order_id) as orders_cnt
        FROM sutk.orders
        GROUP BY client_id
    ) AS cnt_orders
);
```

### Узнать на каких стадиях находятся все заказы клиента

```sql
SELECT
    orders.order_id AS order_id,
    types.name AS step,
    order_statuses.from_date AS start_date
FROM sutk.order_statuses AS order_statuses
JOIN sutk.orders AS orders ON order_statuses.order_id = orders.order_id
JOIN sutk.clients AS clients ON orders.client_id = clients.client_id
JOIN sutk.status_types AS types ON order_statuses.status_id = types.status_id
WHERE to_date IS NULL
    AND clients.client_id = 2;
```

### Узнать адрес, на который нужно доставлять заказ для всех заказов, ожидающих доставки. Заказы, дольше всего ожидающие доставки, располагаем сверху.

```sql
SELECT
    orders.order_id AS order_id,
    addresses.address,
    order_statuses.from_date
FROM sutk.order_statuses AS order_statuses
JOIN sutk.orders AS orders ON order_statuses.order_id = orders.order_id
JOIN sutk.addresses AS addresses ON orders.client_id = addresses.client_id
WHERE order_statuses.status_id = 4
	AND order_statuses.to_date IS NULL
	AND (orders.order_date BETWEEN addresses.from_date AND addresses.to_date)
ORDER BY order_statuses.from_date;
```

### Для каждого продукта узнать сколько осталось незабронированных штук на складе

```sql
SELECT
    products.product_id,
    products.name,
    products.available - COALESCE(cl_products.not_available, 0) AS free
FROM sutk.products AS products
LEFT JOIN (
    SELECT product_id, SUM(count) as not_available
    FROM sutk.ordered_products
    GROUP BY product_id
) AS cl_products ON products.product_id = cl_products.product_id;
```

### Каждому сотруднику, обслуживающему клиентов, составить список телефонов его клиентов, на которые он должен позвонить и предложить старые трубы со склада по скидке

```sql
SELECT
    CASE
        WHEN workers.middle_name IS NOT NULL THEN
            workers.name || ' ' || workers.surname || ' ' || workers.middle_name
        ELSE
            workers.name || ' ' || workers.surname
    END AS worker_name,
    clients.contact_phone,
    CASE
        WHEN clients.company IS NOT NULL THEN
            '"' || clients.company || '" ' || clients.contact_name
        ELSE
            clients.contact_name
	END AS client
FROM sutk.clients as clients
JOIN sutk.workers as workers ON clients.worker_id = workers.worker_id
ORDER BY worker_name;
```

### Для компании клиента "Смит и Ко." вывести контакты, по которым можно связаться с привязанным к ним менеджером

```sql
SELECT
    CASE
        WHEN w.middle_name IS NOT NULL THEN
            w.name || ' ' || w.surname || ' ' || w.middle_name
        ELSE
            w.name || ' ' || w.surname
    END AS worker_name,
    dep.name as department_name,
    dep.phone,
    dep.email
FROM sutk.clients AS cl
JOIN sutk.workers AS w ON w.worker_id = cl.worker_id
JOIN sutk.departments AS dep ON w.department_id = dep.department_id
WHERE cl.company = 'Смит и Ко.';
```

### Найти общий вес и стоимость заказа, имеющего sutk.orders.order_id = 1

```sql
SELECT
    SUM(products.price * ordered.count) AS total_price,
    SUM(products.weight * ordered.count) AS total_weight
FROM sutk.ordered_products AS ordered
JOIN sutk.products AS products ON products.product_id = ordered.product_id
WHERE ordered.order_id = 1;
```

### Сколько машин грузоподъемностью в полтонны нужно для доставки заказа

```sql
SELECT
	SUM(products.weight * ordered.count) AS total_weight,
    CEIL(SUM(products.weight * ordered.count) / 0.5) AS cars
FROM sutk.ordered_products AS ordered
JOIN sutk.products AS products ON products.product_id = ordered.product_id
WHERE ordered.order_id = 1;
```

### Вывести актуальные адреса для клиентов, если адреса нет, то просто выводим NULL

```sql
SELECT
    CASE
        WHEN clients.company IS NOT NULL THEN
            '"' || clients.company || '" ' || clients.contact_name
        ELSE
            clients.contact_name
	END AS client_name,
    addresses.address
FROM sutk.clients AS clients
LEFT JOIN sutk.addresses AS addresses ON clients.client_id = addresses.client_id
WHERE NOW() BETWEEN addresses.from_date AND addresses.to_date
    OR addresses.from_date IS NULL;
```