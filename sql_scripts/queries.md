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

#### Результат

| client_name                  | total_price |
|------------------------------|------------:|
| "123 Инк." Александр Петров  |   608234.95 |
| "Компания ABC" Иван Иванов   |   580715.00 |
| Мария Васильева              |   485070.00 |
| "OOO "XYZ"" Елена Смирнова   |   453300.00 |
| "Смит и Ко." Ольга Белова    |   419320.00 |


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

#### Результат

|  client_id  | client_name                 | orders_cnt |
|-------------|-----------------------------|------------|
|  3          | "123 Инк." Александр Петров |  3         |
|  5          | Мария Васильева             |  3         |
|  4          | "Смит и Ко." Ольга Белова   |  3         |
|  2          | "OOO "XYZ"" Елена Смирнова  |  3         |
|  1          | "Компания ABC" Иван Иванов  |  3         |

### Узнать на каких стадиях находятся все заказы клиента

```sql
SELECT
    orders.order_id AS order_id,
    tps.name AS status,
    order_statuses.from_date AS start_date
FROM sutk.order_statuses AS order_statuses
JOIN sutk.orders AS orders ON order_statuses.order_id = orders.order_id
JOIN sutk.clients AS clients ON orders.client_id = clients.client_id
JOIN sutk.status_types AS tps ON order_statuses.status_id = tps.status_id
WHERE to_date IS NULL
    AND clients.client_id = 2;
```

#### Результат

| order_id   | status             | start_date   |
|------------|--------------------|--------------|
|  5         |    "Сбор заказа"   | "2024-03-28" |
|  6         | "Проверка заказа"  | "2024-03-29" |

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

#### Результат

| order_id   | address                     | start_date   |
|------------|-----------------------------|--------------|
|  7         | "Second Address for User 3" | "2024-03-27" |
|  1         | "First Address for User 1"  | "2024-03-29" |

### Для каждого продукта узнать сколько осталось незабронированных штук на складе

```sql
SELECT
    products.product_id,
    products.name,
    products.available - COALESCE(cl_products.not_available, 0) AS free
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
```

#### Результат

| product_id |            name            | free |
|------------|----------------------------|------|
|     1      | Лист горячекатаный         |  87  |
|     2      | Уголок стальной            |  80  |
|     3      | Труба квадратная           |  40  |
|     4      | Балка двутавровая          |  40  |
|     5      | Проволока сварочная        | 100  |
|     6      | Лист оцинкованный          |  43  |
|     7      | Труба круглая              |  64  |
|     8      | Швеллер гнутый             |  90  |
|     9      | Полоса стальная            | 110  |
|    10      | Арматура строительная      |  85  |
|    11      | Труба прямоугольная        |  48  |
|    12      | Уголок нержавеющий         |  71  |
|    13      | Лента прокатанная          |  90  |
|    14      | Труба электросварная       |  38  |
|    15      | Полоса нержавеющая         |  84  |
|    16      | Сталь круглая              |  60  |
|    17      | Уголок гнутый              | 100  |
|    18      | Швеллер гнутый             |  80  |
|    19      | Проволока горячекатаная    | 103  |
|    20      | Стальной штампованный лист |  62  |
|    21      | Труба спирально-навивная   |  42  |
|    22      | Полоса оцинкованная        |  76  |
|    23      | Уголок широкополочный      |  85  |
|    24      | Труба оцинкованная         |  40  |
|    25      | Проволока нержавеющая      | 102  |

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

#### Результат

|     worker_name             |     contact_phone      |           client                          |
|-----------------------------|------------------------|-------------------------------------------|
| Александра Федорова         |    +7(222)333-44-57    | Роман Волков                              |
| Александра Федорова         |    +7(222)333-44-56    | "Глобальные Инновации" Анна Иванова       |
| Анна Сидорова Александровна |  +7(555)666-77-89      | "Корпорация Видение" Алексей Федоров      |
| Анна Сидорова Александровна |  +7(333)444-55-67      | Кирилл Михайлов                           |
| Анна Сидорова Александровна |  +7(333)444-55-68      | Виктория Сергеева                         |
| Дмитрий Соколов Павлович    |  +7(333)444-55-69      | "Будущие Технологии" Максим Степанов      |
| Екатерина Иванова Юрьевна   |  +7(333)444-55-66      | "123 Инк." Александр Петров               |
| Елена Козлова Викторовна    |  +7(444)555-66-80      | "ТехПро" Юлия Николаева                   |
| Елена Козлова Викторовна    |  +7(444)555-66-77      | "Смит и Ко." Ольга Белова                 |
| Елена Козлова Викторовна    |  +7(444)555-66-78      | "Яркое Будущее" Татьяна Егорова           |
| Елена Козлова Викторовна    |  +7(444)555-66-79      | "Золотые Врата" Игорь Васильев            |
| Иван Иванов Иванович        |    +7(111)222-33-46    | "Умные Технологии" Наталья Попова         |
| Иван Иванов Иванович        |    +7(111)222-33-47    | Павел Лебедев                             |
| Иван Иванов Иванович        |    +7(111)222-33-45    | "Технологические Решения" Дмитрий Соколов |
| Наталья Андреева Васильевна | +7(555)666-77-90       | "Динамичные Дизайны" Алёна Петрова        |
| Петр Петров                 |    +7(222)333-44-55    | "OOO "XYZ"" Елена Смирнова                |
| Петр Петров                 |    +7(222)333-44-58    | Светлана Козлова                          |
| Петр Петров                 |    +7(111)222-33-44    | "Компания ABC" Иван Иванов                |
| Сергей Морозов Игоревич     |  +7(555)666-77-88      | Мария Васильева                           |

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

#### Результат

| worker_name               | department_name   | phone               | email                 |
|----------------------------|-------------------|---------------------|-----------------------|
| "Елена Козлова Викторовна" | "Отдел поддержки" |	"+7(444)444-44-44" | "support@example.com" |

### Найти общий вес и стоимость заказа, имеющего sutk.orders.order_id = 1

```sql
SELECT
    SUM(products.price * ordered.count) AS total_price,
    SUM(products.weight * ordered.count) AS total_weight
FROM sutk.ordered_products AS ordered
JOIN sutk.products AS products ON products.product_id = ordered.product_id
WHERE ordered.order_id = 1;
```

#### Результат

| total_price | total_weight |
|-------------|--------------|
| 120685.00   | 1.180        |

### Сколько машин грузоподъемностью в полтонны нужно для доставки заказа

```sql
SELECT
	SUM(products.weight * ordered.count) AS total_weight,
    CEIL(SUM(products.weight * ordered.count) / 0.5) AS cars
FROM sutk.ordered_products AS ordered
JOIN sutk.products AS products ON products.product_id = ordered.product_id
WHERE ordered.order_id = 1;
```

#### Результат

| total_weight | cars |
|--------------|------|
| 1.180        | 3    |

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

#### Результат по состоянию на 29 марта

| client_name                            | address                           |
|----------------------------------------|-----------------------------------|
| 123 Инк. Александр Петров              | Second Address for User 3         |
| Мария Васильева                        | Second Address for User 5         |
| Глобальные Инновации Анна Иванова      | Second Address for User 7         |
| Яркое Будущее Татьяна Егорова          | First Address for User 9          |
| Умные Технологии Наталья Попова        | First Address for User 11         |
| Динамичные Дизайны Алёна Петрова       | First Address for User 15         |
| ТехПро Юлия Николаева                  | First Address for User 19         |
| Компания ABC Иван Иванов               | Third Address for User 1          |
| Роман Волков                           | NULL                              |
| Корпорация Видение Алексей Федоров     | NULL                              |
| Будущие Технологии Максим Степанов     | NULL                              |
| OOO "XYZ" Елена Смирнова               | NULL                              |
| Кирилл Михайлов                        | NULL                              |
| Технологические Решения Дмитрий Соколов| NULL                              |
| Павел Лебедев                          | NULL                              |
| Смит и Ко. Ольга Белова                | NULL                              |
| Золотые Врата Игорь Васильев           | NULL                              |