-- Analytics validation queries used during the project.

-- Top reordered products
SELECT 
    p.product_name,
    COUNT(*) AS reorder_count
FROM instacart_retail_db.order_products op
JOIN instacart_retail_db.products p
    ON op.product_id = p.product_id
WHERE op.reordered = 1
GROUP BY p.product_name
ORDER BY reorder_count DESC
LIMIT 20;

-- Department demand
SELECT 
    d.department,
    COUNT(*) AS total_purchases
FROM instacart_retail_db.order_products op
JOIN instacart_retail_db.products p
    ON op.product_id = p.product_id
JOIN instacart_retail_db.departments d
    ON p.department_id = d.department_id
GROUP BY d.department
ORDER BY total_purchases DESC;

-- Peak order hours
SELECT 
    order_hour_of_day,
    COUNT(*) AS total_orders
FROM instacart_retail_db.orders
GROUP BY order_hour_of_day
ORDER BY total_orders DESC;

-- Average basket size
SELECT 
    AVG(product_count) AS avg_basket_size
FROM (
    SELECT 
        order_id,
        COUNT(product_id) AS product_count
    FROM instacart_retail_db.order_products
    GROUP BY order_id
) t;
