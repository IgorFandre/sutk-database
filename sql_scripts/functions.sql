-- Example of usage:
-- SELECT * FROM delivery_info(1, CAST(0.5 AS NUMERIC(10, 3)), CAST(1000 AS NUMERIC(10, 2)));
CREATE OR REPLACE FUNCTION delivery_info(
    IN ord_id INTEGER,
    IN possible_weight NUMERIC(10, 3),
    IN one_car_cost NUMERIC(10, 2),
    OUT total_weight NUMERIC(10, 3),
    OUT required_cars INTEGER,
    OUT delivery_cost NUMERIC(10, 2)
)
AS $$
DECLARE
    delivery_flag BOOLEAN;
BEGIN
    SELECT delivery
    INTO delivery_flag
    FROM sutk.orders
    WHERE order_id = ord_id;

    IF NOT delivery_flag THEN
        RAISE EXCEPTION 'No delivery for order_id %', ord_id;
    END IF;

    SELECT
        SUM(products.weight * ordered.count),
        CEIL(SUM(products.weight * ordered.count) / possible_weight),
        CEIL(SUM(products.weight * ordered.count) / possible_weight) * one_car_cost
    INTO
        total_weight,
        required_cars,
        delivery_cost
    FROM sutk.ordered_products AS ordered
    JOIN sutk.products AS products ON products.product_id = ordered.product_id
    WHERE ordered.order_id = ord_id;

    IF total_weight IS NULL THEN
        RAISE EXCEPTION 'No products found for order_id %', ord_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Example of usage:
-- SELECT total_order_cost(9);
CREATE OR REPLACE FUNCTION total_order_cost(
    IN ord_id INTEGER,
    IN possible_weight NUMERIC(10, 3) DEFAULT NULL,
    IN one_car_cost NUMERIC(10, 2) DEFAULT NULL,
    OUT total_cost NUMERIC(10, 2)
)
AS $$
DECLARE
    total_weights NUMERIC(10, 3);
    required_cars INTEGER;
    delivery_cost NUMERIC(10, 2);
BEGIN
    SELECT
        SUM(products.price * ordered.count)
    INTO
        total_cost
    FROM sutk.ordered_products AS ordered
    JOIN sutk.products AS products ON products.product_id = ordered.product_id
    WHERE ordered.order_id = ord_id;

    IF total_cost IS NULL THEN
        RAISE EXCEPTION 'No products found for order_id %', ord_id;
    END IF;

    IF possible_weight IS NULL THEN
        RETURN;
    END IF;

    BEGIN
        SELECT *
        INTO total_weights, required_cars, delivery_cost
        FROM delivery_info(
            ord_id, possible_weight, one_car_cost
        );
        EXCEPTION
            WHEN OTHERS THEN
                RETURN;
    END;

    total_cost = total_cost + delivery_cost;

END;
$$ LANGUAGE plpgsql;