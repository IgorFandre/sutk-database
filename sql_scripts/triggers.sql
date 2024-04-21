-- Проверка при брони, что количество свободных элементов на складе достаточно
CREATE OR REPLACE FUNCTION check_product_availability()
RETURNS TRIGGER
AS $$
DECLARE
    count_check INTEGER;
BEGIN
    IF TG_OP = 'UPDATE' THEN
        count_check = NEW.count - OLD.count;
    ELSE
        count_check = NEW.count;
    END IF;

    IF count_check > (
                SELECT s.available
                FROM sutk.storage s
                WHERE NEW.product_id = s.product_id
            ) THEN
        RAISE EXCEPTION 'Not enough products available';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_product_availability_trigger
BEFORE INSERT OR UPDATE ON sutk.ordered_products
FOR EACH ROW
EXECUTE FUNCTION check_product_availability();


-- Автоматическое вычитание доступного со скалада
CREATE OR REPLACE FUNCTION decrement_storage()
RETURNS TRIGGER
AS $$
DECLARE
    row RECORD;
BEGIN
    IF NEW.status_id NOT IN (3, 4) THEN
        RETURN NEW;
    END IF;

    FOR row IN (
        SELECT product_id, count
        FROM sutk.ordered_products
        WHERE order_id = NEW.order_id
    )
        LOOP
            UPDATE sutk.products
            SET available = available - row.count
            WHERE product_id = row.product_id;
        END LOOP;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER change_order_status_trigger
BEFORE UPDATE ON sutk.order_statuses
FOR EACH ROW
WHEN (NEW.to_date IS NOT NULL AND OLD.to_date IS NULL)
EXECUTE FUNCTION decrement_storage();


-- Автоматическое удаления продуктов заказа при удалении заказа
CREATE OR REPLACE FUNCTION delete_related_ordered_products()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM sutk.ordered_products
    WHERE order_id = OLD.order_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER delete_related_ordered_products_trigger
AFTER DELETE ON sutk.orders
FOR EACH ROW
EXECUTE FUNCTION delete_related_ordered_products();