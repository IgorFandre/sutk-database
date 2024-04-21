CREATE OR REPLACE PROCEDURE update_address(
    cl_id INTEGER,
    new_address VARCHAR(200),
    new_address_date DATE DEFAULT NOW()
)
AS $$
BEGIN
    UPDATE sutk.addresses
    SET to_date = new_address_date
    WHERE client_id = cl_id
        AND new_address_date BETWEEN from_date AND to_date;

    INSERT INTO sutk.addresses (client_id, address, from_date)
    VALUES (cl_id, new_address, new_address_date);
END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE delete_all_client_info(
    clear_client_id INTEGER
)
AS $$
BEGIN
    DELETE FROM sutk.addresses
    WHERE client_id = clear_client_id;

    DELETE FROM sutk.order_statuses
    WHERE order_id IN (SELECT order_id FROM sutk.orders WHERE client_id = clear_client_id);

    DELETE FROM sutk.ordered_products
    WHERE order_id IN (SELECT order_id FROM sutk.orders WHERE client_id = clear_client_id);

    DELETE FROM sutk.orders
    WHERE client_id = clear_client_id;

    DELETE FROM sutk.clients WHERE client_id = clear_client_id;
END;
$$
LANGUAGE plpgsql;