-- Индексы в таблице sutk.clients
CREATE INDEX idx_clients_worker_id ON sutk.clients(worker_id);

-- Индексы в таблице sutk.addresses
CREATE INDEX idx_addresses_client_id ON sutk.addresses(client_id);
CREATE INDEX idx_addresses_date ON sutk.addresses(from_date, to_date);

-- Индексы в таблице sutk.orders
CREATE INDEX idx_orders_client_id ON sutk.orders(client_id);

-- Индексы в таблице sutk.order_statuses
CREATE INDEX idx_order_statuses_worker_id ON sutk.order_statuses(worker_id);
CREATE INDEX idx_order_statuses_order_id ON sutk.order_statuses(order_id);
CREATE INDEX idx_order_statuses_status_id ON sutk.order_statuses(status_id);

-- Индексы в таблице sutk.ordered_products
CREATE INDEX idx_ordered_products_order_id ON sutk.ordered_products(order_id);