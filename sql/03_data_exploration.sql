-- =====================================================
-- 03_data_exploration.sql
-- Exploración y validación inicial de datos
-- =====================================================

-- 1. NÚMERO DE REGISTROS POR TABLA

SELECT 'customers' AS table_name, COUNT(*) AS total_rows
FROM customers

UNION ALL

SELECT 'categories', COUNT(*)
FROM categories

UNION ALL

SELECT 'products', COUNT(*)
FROM products

UNION ALL

SELECT 'orders', COUNT(*)
FROM orders

UNION ALL

SELECT 'order_items', COUNT(*)
FROM order_items

UNION ALL

SELECT 'payments', COUNT(*)
FROM payments

UNION ALL

SELECT 'shipments', COUNT(*)
FROM shipments;

-- =====================================================
-- 2. VALIDACIÓN DE CALIDAD DE DATOS
-- =====================================================

-- 2.1 Correos duplicados
SELECT
    email,
    COUNT(*) AS total
FROM customers
GROUP BY email
HAVING COUNT(*) > 1;

-- 2.2 Valores nulos importantes
SELECT
    COUNT(*) FILTER (WHERE first_name IS NULL) AS null_first_name,
    COUNT(*) FILTER (WHERE email IS NULL) AS null_email,
    COUNT(*) FILTER (WHERE signup_date IS NULL) AS null_signup_date
FROM customers;

-- 2.3 Pedidos realizados antes del registro del cliente
SELECT
    COUNT(*) AS invalid_orders
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.order_date < c.signup_date;

-- 2.4 Order items sin pedido o producto válido
SELECT
    COUNT(*) AS orphan_order_items
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE o.order_id IS NULL
   OR p.product_id IS NULL;