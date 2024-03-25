## Папка с расположенными sql скриптами

__create.sql__ - файл с командами для создания схемы `sutk` и расположенных внутри таблиц:
  - `sutk.departments`
  - `sutk.workers`
  - `sutk.clients`
  - `sutk.addresses`
  - `sutk.orders`
  - `sutk.step_names`
  - `sutk.steps`
  - `sutk.products`
  - `sutk.ordered_products`

__insert.sql__ - файл с командами для заполнения таблиц схемы `sutk`:
  - Более 30 строк в таблицы-связки `sutk.steps` и `sutk.ordered_products`
  - Более 15 строк в значащие таблицы `sutk.workers`, `sutk.clients`, `sutk.orders`, `sutk.products`
  - Более 30 строк в таблицу с версионными данными `sutk.addresses`