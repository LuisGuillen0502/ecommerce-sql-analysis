-- =====================================================
-- 05_customer_analysis.sql
-- Análisis de comportamiento y valor de clientes
-- =====================================================

-- 1. FRECUENCIA DE COMPRA POR CLIENTE

WITH customer_orders AS (

    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,

        COUNT(DISTINCT o.order_id) AS total_orders,

        ROUND(
            SUM(
                oi.quantity
                * oi.unit_price
                * (1 - oi.discount_pct / 100)
            ),
            2
        ) AS total_spent

    FROM customers c

    LEFT JOIN orders o
        ON c.customer_id = o.customer_id
        AND o.order_status <> 'Cancelled'

    LEFT JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name
)

SELECT
    COUNT(*) AS total_customers,

    COUNT(*) FILTER (
        WHERE total_orders = 1
    ) AS one_time_customers,

    COUNT(*) FILTER (
        WHERE total_orders > 1
    ) AS repeat_customers,

    ROUND(
        COUNT(*) FILTER (
            WHERE total_orders > 1
        )::NUMERIC
        /
        NULLIF(COUNT(*), 0)
        * 100,
        2
    ) AS repeat_customer_pct,

    ROUND(
        AVG(total_orders),
        2
    ) AS avg_orders_per_customer,

    ROUND(
        AVG(total_spent),
        2
    ) AS avg_customer_value

FROM customer_orders;


-- =====================================================
-- 2. SEGMENTACIÓN DE CLIENTES
-- =====================================================

WITH customer_metrics AS (

    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        c.region,
        c.acquisition_channel,

        COUNT(DISTINCT o.order_id) AS total_orders,

        ROUND(
            COALESCE(
                SUM(
                    oi.quantity
                    * oi.unit_price
                    * (1 - oi.discount_pct / 100)
                ),
                0
            ),
            2
        ) AS total_spent

    FROM customers c

    LEFT JOIN orders o
        ON c.customer_id = o.customer_id
        AND o.order_status <> 'Cancelled'

    LEFT JOIN order_items oi
        ON o.order_id = oi.order_id

    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name,
        c.region,
        c.acquisition_channel
),

segmented_customers AS (

    SELECT
        *,

        CASE
            WHEN total_orders >= 7 THEN 'VIP'
            WHEN total_orders >= 5 THEN 'High Value'
            WHEN total_orders >= 3 THEN 'Regular'
            ELSE 'Occasional'
        END AS customer_segment

    FROM customer_metrics
)

SELECT
    customer_segment,
    COUNT(*) AS customers,

    ROUND(
        AVG(total_orders),
        2
    ) AS avg_orders,

    ROUND(
        AVG(total_spent),
        2
    ) AS avg_customer_value,

    ROUND(
        SUM(total_spent),
        2
    ) AS segment_sales

FROM segmented_customers

GROUP BY customer_segment

ORDER BY segment_sales DESC;


-- =====================================================
-- 3. TOP 10 CLIENTES Y CONCENTRACIÓN DE VENTAS
-- =====================================================

WITH customer_value AS (

    SELECT
        c.customer_id,

        c.first_name || ' ' || c.last_name AS customer_name,

        c.region,

        COUNT(DISTINCT o.order_id) AS total_orders,

        ROUND(
            SUM(
                oi.quantity
                * oi.unit_price
                * (1 - oi.discount_pct / 100)
            ),
            2
        ) AS total_spent

    FROM customers c

    JOIN orders o
        ON c.customer_id = o.customer_id

    JOIN order_items oi
        ON o.order_id = oi.order_id

    WHERE o.order_status <> 'Cancelled'

    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name,
        c.region
),

ranked_customers AS (

    SELECT
        *,

        ROW_NUMBER() OVER (
            ORDER BY total_spent DESC
        ) AS customer_rank,

        ROUND(
            total_spent
            /
            SUM(total_spent) OVER ()
            * 100,
            2
        ) AS sales_share_pct

    FROM customer_value
)

SELECT
    customer_rank,
    customer_id,
    customer_name,
    region,
    total_orders,
    total_spent,
    sales_share_pct
FROM ranked_customers
WHERE customer_rank <= 10
ORDER BY customer_rank;


-- =====================================================
-- 4. PARTICIPACIÓN DE LOS TOP 10 CLIENTES
-- =====================================================

WITH customer_value AS (

    SELECT
        c.customer_id,

        ROUND(
            SUM(
                oi.quantity
                * oi.unit_price
                * (1 - oi.discount_pct / 100)
            ),
            2
        ) AS total_spent

    FROM customers c

    JOIN orders o
        ON c.customer_id = o.customer_id

    JOIN order_items oi
        ON o.order_id = oi.order_id

    WHERE o.order_status <> 'Cancelled'

    GROUP BY c.customer_id
),

ranked_customers AS (

    SELECT
        customer_id,
        total_spent,

        ROW_NUMBER() OVER (
            ORDER BY total_spent DESC
        ) AS customer_rank,

        SUM(total_spent) OVER () AS total_company_sales

    FROM customer_value
)

SELECT
    ROUND(
        SUM(total_spent),
        2
    ) AS top_10_sales,

    ROUND(
        MAX(total_company_sales),
        2
    ) AS total_sales,

    ROUND(
        SUM(total_spent)
        /
        MAX(total_company_sales)
        * 100,
        2
    ) AS top_10_sales_share_pct

FROM ranked_customers

WHERE customer_rank <= 10;

-- =====================================================
-- 5. VENTAS POR REGIÓN
-- =====================================================

SELECT
    c.region,

    COUNT(DISTINCT c.customer_id) AS customers,

    COUNT(DISTINCT o.order_id) AS orders,

    ROUND(
        SUM(
            oi.quantity
            * oi.unit_price
            * (1 - oi.discount_pct / 100)
        ),
        2
    ) AS net_sales,

    ROUND(
        SUM(
            oi.quantity
            * oi.unit_price
            * (1 - oi.discount_pct / 100)
        )
        /
        COUNT(DISTINCT c.customer_id),
        2
    ) AS sales_per_customer

FROM customers c

JOIN orders o
    ON c.customer_id = o.customer_id

JOIN order_items oi
    ON o.order_id = oi.order_id

WHERE o.order_status <> 'Cancelled'

GROUP BY c.region

ORDER BY net_sales DESC;

-- =====================================================
-- 6. VENTAS POR CANAL DE ADQUISICIÓN
-- =====================================================

SELECT
    c.acquisition_channel,

    COUNT(DISTINCT c.customer_id) AS customers,

    COUNT(DISTINCT o.order_id) AS orders,

    ROUND(
        SUM(
            oi.quantity
            * oi.unit_price
            * (1 - oi.discount_pct / 100)
        ),
        2
    ) AS net_sales,

    ROUND(
        SUM(
            oi.quantity
            * oi.unit_price
            * (1 - oi.discount_pct / 100)
        )
        /
        COUNT(DISTINCT c.customer_id),
        2
    ) AS sales_per_customer

FROM customers c

JOIN orders o
    ON c.customer_id = o.customer_id

JOIN order_items oi
    ON o.order_id = oi.order_id

WHERE o.order_status <> 'Cancelled'

GROUP BY c.acquisition_channel

ORDER BY net_sales DESC;

-- =====================================================
-- 06_operations_analysis.sql
-- Análisis de envíos y desempeño operativo
-- =====================================================

-- 1. DESEMPEÑO POR PAQUETERÍA
-- Solo pedidos ya entregados para calcular tiempo real de entrega.

SELECT
    s.shipping_company,

    COUNT(*) AS delivered_shipments,

    ROUND(
        AVG(
            s.delivery_date - s.shipment_date
        ),
        2
    ) AS avg_transit_days,

    ROUND(
        AVG(s.shipping_cost),
        2
    ) AS avg_shipping_cost,

    ROUND(
        SUM(s.shipping_cost),
        2
    ) AS total_shipping_cost

FROM shipments s

WHERE s.shipping_status = 'Delivered'
  AND s.delivery_date IS NOT NULL
  AND s.shipment_date IS NOT NULL

GROUP BY
    s.shipping_company

ORDER BY
    avg_transit_days ASC;

-- =====================================================
-- 2. CUMPLIMIENTO DE SLA POR PAQUETERÍA
-- SLA: entrega en 3 días de tránsito o menos
-- =====================================================

SELECT
    shipping_company,

    COUNT(*) AS delivered_shipments,

    COUNT(*) FILTER (
        WHERE delivery_date - shipment_date <= 3
    ) AS on_time_shipments,

    COUNT(*) FILTER (
        WHERE delivery_date - shipment_date > 3
    ) AS late_shipments,

    ROUND(
        COUNT(*) FILTER (
            WHERE delivery_date - shipment_date <= 3
        )::NUMERIC
        /
        COUNT(*)
        * 100,
        2
    ) AS on_time_rate_pct

FROM shipments

WHERE shipping_status = 'Delivered'
  AND delivery_date IS NOT NULL
  AND shipment_date IS NOT NULL

GROUP BY shipping_company

ORDER BY on_time_rate_pct DESC;

-- =====================================================
-- 3. ESTADO GENERAL DE PEDIDOS
-- =====================================================

SELECT
    order_status,

    COUNT(*) AS orders,

    ROUND(
        COUNT(*)::NUMERIC
        /
        SUM(COUNT(*)) OVER ()
        * 100,
        2
    ) AS order_share_pct

FROM orders

GROUP BY order_status

ORDER BY orders DESC;

-- =====================================================
-- 4. TASA DE CANCELACIÓN
-- =====================================================

SELECT
    COUNT(*) AS total_orders,

    COUNT(*) FILTER (
        WHERE order_status = 'Cancelled'
    ) AS cancelled_orders,

    ROUND(
        COUNT(*) FILTER (
            WHERE order_status = 'Cancelled'
        )::NUMERIC
        /
        COUNT(*)
        * 100,
        2
    ) AS cancellation_rate_pct

FROM orders;