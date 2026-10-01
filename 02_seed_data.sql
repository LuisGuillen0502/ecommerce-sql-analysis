-- =====================================================
-- 02_seed_data.sql
-- Datos de prueba para E-commerce SQL Analysis
-- =====================================================

-- 1. CATEGORÍAS
INSERT INTO categories (category_name, description)
VALUES
('Tecnología', 'Dispositivos y accesorios tecnológicos'),
('Hogar', 'Productos para cocina y hogar'),
('Belleza', 'Cuidado personal y belleza'),
('Deportes', 'Artículos deportivos y fitness'),
('Moda', 'Ropa y accesorios'),
('Papelería', 'Artículos de oficina y estudio'),
('Mascotas', 'Productos para perros y gatos'),
('Alimentos y Bebidas', 'Alimentos, bebidas y productos gourmet');

SELECT *
FROM categories
ORDER BY category_id;

-- 2. PRODUCTOS
INSERT INTO products (
    product_name,
    category_id,
    unit_price,
    unit_cost,
    stock_quantity,
    supplier,
    active
)
VALUES
('Audífonos Bluetooth', 1, 899.00, 520.00, 80, 'TechNova', TRUE),
('Smartwatch Fit', 1, 1499.00, 870.00, 55, 'TechNova', TRUE),
('Teclado Mecánico', 1, 1299.00, 760.00, 45, 'Digital Core', TRUE),
('Bocina Portátil', 1, 799.00, 460.00, 70, 'SoundPeak', TRUE),

('Cafetera Compacta', 2, 1199.00, 690.00, 35, 'Casa Viva', TRUE),
('Lámpara LED', 2, 549.00, 250.00, 90, 'Casa Viva', TRUE),
('Organizador Modular', 2, 399.00, 170.00, 120, 'HomeFlex', TRUE),
('Set de Sartenes', 2, 1599.00, 980.00, 30, 'Kitchen Pro', TRUE),

('Kit Skincare', 3, 899.00, 390.00, 65, 'GlowLab', TRUE),
('Secadora Compacta', 3, 1099.00, 620.00, 40, 'BeautyTech', TRUE),
('Perfume Urbano', 3, 1299.00, 510.00, 50, 'Essenza', TRUE),
('Set de Brochas', 3, 449.00, 160.00, 100, 'GlowLab', TRUE),

('Tapete Yoga', 4, 649.00, 290.00, 75, 'Active Life', TRUE),
('Mancuernas Ajustables', 4, 1899.00, 1180.00, 25, 'FitGear', TRUE),
('Botella Deportiva', 4, 349.00, 120.00, 140, 'Active Life', TRUE),
('Banda de Resistencia', 4, 299.00, 95.00, 160, 'FitGear', TRUE),

('Mochila Urbana', 5, 999.00, 460.00, 60, 'Urban Wear', TRUE),
('Gorra Minimal', 5, 449.00, 170.00, 100, 'Urban Wear', TRUE),
('Sudadera Essential', 5, 899.00, 410.00, 70, 'North Street', TRUE),
('Bolsa Crossbody', 5, 749.00, 300.00, 85, 'North Street', TRUE),

('Cuaderno Premium', 6, 249.00, 80.00, 200, 'PaperLab', TRUE),
('Plumas Gel Pack', 6, 179.00, 55.00, 220, 'PaperLab', TRUE),
('Planner Semanal', 6, 329.00, 110.00, 150, 'Organiza+', TRUE),

('Cama para Mascota', 7, 999.00, 520.00, 45, 'PetHome', TRUE),
('Juguete Interactivo', 7, 399.00, 150.00, 110, 'PetJoy', TRUE),
('Bowl Antiderrame', 7, 349.00, 125.00, 130, 'PetHome', TRUE),
('Snacks Naturales', 7, 229.00, 85.00, 180, 'PetJoy', TRUE),

('Café Premium 500g', 8, 329.00, 145.00, 140, 'Origen MX', TRUE),
('Té Artesanal', 8, 219.00, 80.00, 160, 'Origen MX', TRUE),
('Caja Gourmet', 8, 749.00, 390.00, 60, 'Sabores MX', TRUE);

SELECT
    product_id,
    product_name,
    category_id,
    unit_price,
    unit_cost,
    ROUND(
        ((unit_price - unit_cost) / unit_price) * 100,
        2
    ) AS margin_pct
FROM products
ORDER BY product_id;

-- 3. CLIENTES
INSERT INTO customers (
    first_name,
    last_name,
    email,
    city,
    state,
    region,
    country,
    signup_date,
    acquisition_channel
)
SELECT
    (ARRAY[
        'Luis','Ana','Carlos','Sofía','Diego',
        'Valeria','Miguel','Fernanda','Jorge','Camila',
        'Andrés','Mariana','Daniel','Regina','Eduardo',
        'Natalia','Alejandro','Paola','Ricardo','Ximena'
    ])[((g - 1) % 20) + 1] AS first_name,

    (ARRAY[
        'García','Martínez','López','Hernández','González',
        'Ramírez','Torres','Flores','Rivera','Morales',
        'Vargas','Castro','Ortiz','Mendoza','Ruiz',
        'Navarro','Rojas','Medina','Sánchez','Cruz'
    ])[((g * 3 - 1) % 20) + 1] AS last_name,

    'cliente' || LPAD(g::TEXT, 3, '0') || '@email.com' AS email,

    CASE ((g - 1) % 10)
        WHEN 0 THEN 'León'
        WHEN 1 THEN 'Querétaro'
        WHEN 2 THEN 'Aguascalientes'
        WHEN 3 THEN 'Guadalajara'
        WHEN 4 THEN 'Morelia'
        WHEN 5 THEN 'Ciudad de México'
        WHEN 6 THEN 'Puebla'
        WHEN 7 THEN 'Monterrey'
        WHEN 8 THEN 'Saltillo'
        WHEN 9 THEN 'Mérida'
    END AS city,

    CASE ((g - 1) % 10)
        WHEN 0 THEN 'Guanajuato'
        WHEN 1 THEN 'Querétaro'
        WHEN 2 THEN 'Aguascalientes'
        WHEN 3 THEN 'Jalisco'
        WHEN 4 THEN 'Michoacán'
        WHEN 5 THEN 'Ciudad de México'
        WHEN 6 THEN 'Puebla'
        WHEN 7 THEN 'Nuevo León'
        WHEN 8 THEN 'Coahuila'
        WHEN 9 THEN 'Yucatán'
    END AS state,

    CASE ((g - 1) % 10)
        WHEN 0 THEN 'Bajío'
        WHEN 1 THEN 'Bajío'
        WHEN 2 THEN 'Bajío'
        WHEN 3 THEN 'Occidente'
        WHEN 4 THEN 'Occidente'
        WHEN 5 THEN 'Centro'
        WHEN 6 THEN 'Centro'
        WHEN 7 THEN 'Norte'
        WHEN 8 THEN 'Norte'
        WHEN 9 THEN 'Sureste'
    END AS region,

    'Mexico',

    DATE '2025-01-01' + ((g * 5) % 540) AS signup_date,

    CASE ((g - 1) % 5)
        WHEN 0 THEN 'Instagram'
        WHEN 1 THEN 'Google'
        WHEN 2 THEN 'Facebook'
        WHEN 3 THEN 'Referido'
        WHEN 4 THEN 'Orgánico'
    END AS acquisition_channel

FROM generate_series(1, 100) AS g

ON CONFLICT (email) DO NOTHING;

SELECT COUNT(*) AS total_customers
FROM customers;

SELECT
    customer_id,
    first_name,
    last_name,
    city,
    region,
    signup_date,
    acquisition_channel
FROM customers
ORDER BY customer_id
LIMIT 20;

-- 4. PEDIDOS
WITH generated_orders AS (
    SELECT
        c.customer_id,

        c.signup_date
        + (
            7
            + (((g - 1) / 100) * 55)
            + ((c.customer_id * 7) % 25)
          )::INT AS order_date,

        g
    FROM generate_series(1, 500) AS g
    JOIN customers c
        ON c.customer_id = ((g - 1) % 100) + 1
)

INSERT INTO orders (
    customer_id,
    order_date,
    order_status,
    sales_channel,
    payment_method
)

SELECT
    customer_id,
    order_date,

    CASE
        WHEN order_date >= DATE '2026-09-15' THEN 'Processing'
        WHEN g % 13 = 0 THEN 'Cancelled'
        WHEN g % 7 = 0 THEN 'Shipped'
        ELSE 'Delivered'
    END AS order_status,

    CASE (g % 5)
        WHEN 0 THEN 'Website'
        WHEN 1 THEN 'App'
        WHEN 2 THEN 'Marketplace'
        WHEN 3 THEN 'Instagram'
        WHEN 4 THEN 'Tienda física'
    END AS sales_channel,

    CASE (g % 4)
        WHEN 0 THEN 'Credit Card'
        WHEN 1 THEN 'Debit Card'
        WHEN 2 THEN 'PayPal'
        WHEN 3 THEN 'Bank Transfer'
    END AS payment_method

FROM generated_orders

WHERE order_date <= DATE '2026-09-30'
  AND NOT EXISTS (
      SELECT 1
      FROM orders
  );

SELECT
    COUNT(*) AS total_orders,
    MIN(order_date) AS first_order,
    MAX(order_date) AS last_order
FROM orders;

SELECT
    order_status,
    COUNT(*) AS total
FROM orders
GROUP BY order_status
ORDER BY total DESC;

-- 5. DETALLE DE PEDIDOS
INSERT INTO order_items (
    order_id,
    product_id,
    quantity,
    unit_price,
    unit_cost,
    discount_pct
)

SELECT
    o.order_id,

    ((o.order_id * 3 + item_pos * 7 - 1) % 30) + 1
        AS product_id,

    ((o.order_id + item_pos) % 4) + 1
        AS quantity,

    p.unit_price,

    p.unit_cost,

    CASE
        WHEN (o.order_id + item_pos) % 17 = 0 THEN 20
        WHEN (o.order_id + item_pos) % 11 = 0 THEN 15
        WHEN (o.order_id + item_pos) % 7 = 0 THEN 10
        ELSE 0
    END AS discount_pct

FROM orders o

CROSS JOIN LATERAL
    generate_series(
        1,
        1 + (o.order_id % 4)
    ) AS item_pos

JOIN products p
    ON p.product_id =
       ((o.order_id * 3 + item_pos * 7 - 1) % 30) + 1

WHERE NOT EXISTS (
    SELECT 1
    FROM order_items
);

SELECT
    COUNT(*) AS total_order_items,
    SUM(quantity) AS total_units
FROM order_items;

SELECT
    ROUND(
        SUM(
            quantity
            * unit_price
            * (1 - discount_pct / 100)
        ),
        2
    ) AS gross_sales
FROM order_items;

-- 6. PAGOS
INSERT INTO payments (
    order_id,
    payment_date,
    payment_method,
    payment_status,
    amount
)

SELECT
    o.order_id,
    o.order_date AS payment_date,
    o.payment_method,

    CASE
        WHEN o.order_status = 'Cancelled' THEN 'Refunded'
        WHEN o.order_status = 'Processing' THEN 'Pending'
        ELSE 'Paid'
    END AS payment_status,

    ROUND(
        SUM(
            oi.quantity
            * oi.unit_price
            * (1 - oi.discount_pct / 100)
        ),
        2
    ) AS amount

FROM orders o
JOIN order_items oi
    ON oi.order_id = o.order_id

GROUP BY
    o.order_id,
    o.order_date,
    o.payment_method,
    o.order_status

HAVING NOT EXISTS (
    SELECT 1
    FROM payments
);

SELECT
    payment_status,
    COUNT(*) AS payments,
    ROUND(SUM(amount), 2) AS amount
FROM payments
GROUP BY payment_status
ORDER BY amount DESC;

-- 7. ENVÍOS
INSERT INTO shipments (
    order_id,
    shipment_date,
    delivery_date,
    shipping_company,
    shipping_status,
    shipping_cost
)

SELECT
    o.order_id,

    CASE
        WHEN o.order_status = 'Processing'
            THEN NULL
        ELSE o.order_date + 2
    END AS shipment_date,

    CASE
        WHEN o.order_status = 'Delivered'
            THEN o.order_date + (3 + (o.order_id % 5))::INT
        ELSE NULL
    END AS delivery_date,

    CASE (o.order_id % 4)
        WHEN 0 THEN 'DHL'
        WHEN 1 THEN 'FedEx'
        WHEN 2 THEN 'Estafeta'
        WHEN 3 THEN 'Paquetexpress'
    END AS shipping_company,

    CASE
        WHEN o.order_status = 'Processing' THEN 'Preparing'
        WHEN o.order_status = 'Shipped' THEN 'In Transit'
        WHEN o.order_status = 'Delivered' THEN 'Delivered'
    END AS shipping_status,

    CASE (o.order_id % 4)
        WHEN 0 THEN 0
        WHEN 1 THEN 69
        WHEN 2 THEN 89
        WHEN 3 THEN 119
    END AS shipping_cost

FROM orders o

WHERE o.order_status <> 'Cancelled'
  AND NOT EXISTS (
      SELECT 1
      FROM shipments
  );

SELECT
    shipping_status,
    COUNT(*) AS shipments
FROM shipments
GROUP BY shipping_status
ORDER BY shipments DESC;