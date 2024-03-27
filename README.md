<h1 style="font-weight: bold; font-size: 24px;">База данных для поставщиков и покупателей металлопродукции и металлопроката</h1>

## Содержание

- [Содержание](#содержание)
- [Прототип](#прототип)
  - [Средне-Уральская трубная компания](#средне-уральская-трубная-компания)
- [Концептуальное проектирование](#концептуальное-проектирование)
  - [Предметная область: продажа металлопродукции](#предметная-область-продажа-металлопродукции)
  - [Не детализированные сущности](#не-детализированные-сущности)
  - [Сущности связаны следующим образом](#сущности-связаны-следующим-образом)
  - [Схема модели](#схема-модели)
- [Логическое проектирование](#логическое-проектирование)
  - [Нормальная форма](#нормальная-форма)
  - [Версионирование](#версионирование)
  - [Схема модели](#схема-модели-1)
- [Физическое проектирование](#физическое-проектирование)
  - [Таблица: departments](#таблица-departments)
  - [Таблица: workers](#таблица-workers)
  - [Таблица: clients](#таблица-clients)
  - [Таблица: addresses](#таблица-addresses)
  - [Таблица: orders](#таблица-orders)
  - [Таблица: step\_names](#таблица-step_names)
  - [Таблица: steps](#таблица-steps)
  - [Таблица: products](#таблица-products)
  - [Таблица: ordered\_products](#таблица-ordered_products)
- [Реализация базы данных](#реализация-базы-данных)

## Прототип

### Средне-Уральская трубная компания

Сайт-визитка на гитхабе - [github](https://github.com/IgorFandre/golang-website)

Посмотреть запущенный сайт можно по [ссылке](https://sutk-igorfandre.amvera.io/).

## Концептуальное проектирование

### Предметная область: продажа металлопродукции

### Не детализированные сущности
1. `Сотрудники` (с информацией: ID сотрудника, имя, фамилия, отчество, отдел)
2. `Департаменты` (с информацией: ID департамента, название, контактный телефон, контактная почта)
3. `Клиенты` (с информацией: ID клиента, название компании, контактное лицо, контактный телефон, ID менеджера, работающего с клиентом, адрес)
4. `Заказы` (с информацией: ID заказа, описание, товары, дата заказа, флаг самовывоза)
5. `Этапы заказов` (с информацией: ID этапа, ID заказа, исполнитель, даты начала и конца этапа)
6. `Продукты` (с информацией: ID товара, название, качество товара (номер ГОСТа), описание, цена единицы товара, количество на складе, вес единицы товара)

### Сущности связаны следующим образом
1. В каждом департаменте не менее одного сотрудника (**один ко многим**).
2. На каждом этапе у заказа свой работник-исполнитель. Работник одновременно может брать этапы разных заказов (**один ко многим**).
3. У каждого клиента по одному менеджеру, привязанному к нему. Один менеджер может работать с несколькими клиентами (**один ко многим**).
4. У каждого заказа несколько этапов, обрабатываемых в определенном порядке (**один ко многим**).
5. Каждый заказ связан с одним клиентом, у клиента может быть много заказов (**один ко многим**).
6. Каждый заказ содержит товары и каждый товар может быть в нескольких заказах (**многие ко многим**).

### Схема модели
![alt text](./src/entity_concept_map.png)


## Логическое проектирование

### Нормальная форма

Модель находится в __3 нормальной форме__:

1. Атрибуты преобразованы к атомарным
   - Каждая ячейка хранит только одно значение
   - В колонках данные одного типа
   - Все записи отличаются друг от друга
2. Все неключевые атрибуты зависят от первичного ключа
3. Никакие колонки не зависят друг от друга

### Версионирование

В логической модели мы поддерживаем версионность адресов клиентов и для каждого заказа берем именно тот адрес, который был у него на момент заказа. Наш выбор - __SCD типа 2__, для которого мы заводим отдельную таблицу addresses, в которой храним id клиента и время начала и конца использования адреса.

### Схема модели

![alt text](./src/logic_map.png)


## Физическое проектирование

### Таблица: departments
- `department_id`: SERIAL
  - Primary Key
- `name`: VARCHAR(50) 
  - NOT NULL
- `phone`: CHAR(16)
  - phone LIKE '+7(\_ \_ \_)\_ \_ \_-\_ \_-\_ \_'
- `email`: VARCHAR(50)
  - email LIKE '%\_@\_ \_%.\_ \_%'

### Таблица: workers
- `worker_id`: SERIAL
  - **Primary Key**
- `department_id`: INTEGER
  - **Foreign Key** --> departments.department_id
- `name`: VARCHAR(20)
  - NOT NULL
- `surname`: VARCHAR(20)
  - NOT NULL
- `middle_name`: VARCHAR(20)

### Таблица: clients
- `client_id`: SERIAL
  - **Primary Key**
- `worker_id`: INTEGER
  - **Foreign Key** --> workers.worker_id
- `company`: VARCHAR(50) 
  - UNIQUE
- `contact_name`: VARCHAR(65) 
  - NOT NULL
- `contact_phone`: CHAR(16)
  - contact_phone LIKE '+7(\_ \_ \_)\_ \_ \_-\_ \_-\_ \_'

### Таблица: addresses
- `client_id`: INTEGER 
  - **Foreign Key** --> clients.client_id
- `address`: VARCHAR(200)
  - NOT NULL
- `from_date`: TIMESTAMP
  - DEFAULT NOW()
- `to_date`: TIMESTAMP
  - DEFAULT '5999-01-01 00:00:00'

### Таблица: orders
- `order_id`: SERIAL
  - **Primary Key**
- `client_id`: INTEGER
  - **Foreign Key** --> clients.client_id
- `description`: TEXT
- `delivery`: BOOLEAN 
  - NOT NULL
- `order_date`: TIMESTAMP 
  - DEFAULT NOW()

### Таблица: step_names
- `step_id`: SERIAL
  - **Primary Key**
- `name`: VARCHAR(15)
  - NOT NULL

### Таблица: steps
- `worker_id`: INTEGER
  - **Foreign Key** --> workers.worker_id
- `order_id`: INTEGER
  - **Foreign Key** --> orders.order_id
- `step_id`: INTEGER
  - **Foreign Key** --> step_names.step_id
- `from_date`: DATE
  - DEFAULT CURRENT_DATE
- `to_date`: DATE
- CONSTRAINT `step_combination`: UNIQUE (worker_id, order_id, step_id)

### Таблица: products
- `product_id`: SERIAL
  - **Primary Key**
- `name`: VARCHAR(50)
  - NOT NULL
- `quality`: VARCHAR(50)
- `description`: TEXT
- `price`: NUMERIC(10, 2)
  - NOT NULL 
  - price >= 0
- `available`: INTEGER
  - NOT NULL 
  - available >= 0
- `weight`: NUMERIC(10, 3)
  - NOT NULL 
  - weight >= 0

### Таблица: ordered_products
- `order_id`: INTEGER
  - **Foreign Key** --> orders.order_id
- `product_id`: INTEGER
  - **Foreign Key** --> products.product_id
- `count`: INTEGER
  - NOT NULL 
  - count > 0
- CONSTRAINT `order_combination`: UNIQUE (order_id, product_id)


## Реализация базы данных

1) **[Cоздание базы данных](./sql_scripts/create.sql)**

2) **[Заполнение базы данных](./sql_scripts/insert.sql)**

3) **[Примеры запросов к базе данных](./sql_scripts/queries.md)**