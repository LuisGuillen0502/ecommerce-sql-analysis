-- =====================================================
-- 04_sales_analysis.sql
-- Análisis comercial y desempeño de ventas
-- =====================================================

-- 1. KPIs GENERALES DE VENTAS
-- Se excluyen pedidos cancelados.

SELECT
    COUNT(DISTINCT o.order_id) AS valid_orders,

    SUM(oi.quantity) AS units_sold,

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
            * oi.unit_cost
        ),
        2
    ) AS total_cost,

    ROUND(
        SUM(
            oi.quantity
            * (
                oi.unit_price
                * (1 - oi.discount_pct / 100)
                - oi.unit_cost
            )
        ),
        2
    ) AS gross_profit,

    ROUND(
        SUM(
            oi.quantity
            * (
                oi.unit_price
                * (1 - oi.discount_pct / 100)
                - oi.unit_cost
            )
        )
        /
        NULLIF(
            SUM(
                oi.quantity
                * oi.unit_price
                * (1 - oi.discount_pct / 100)
            ),
            0
        )
        * 100,
        2
    ) AS gross_margin_pct,

    ROUND(
        SUM(
            oi.quantity
            * oi.unit_price
            * (1 - oi.discount_pct / 100)
        )
        /
        COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value

FROM orders o

JOIN order_items oi
    ON o.order_id = oi.order_id

WHERE o.order_status <> 'Cancelled';

-- =====================================================
-- 2. EVOLUCIÓN MENSUAL DE VENTAS
-- =====================================================

SELECT
    DATE_TRUNC('month', o.order_date)::DATE AS month,

    COUNT(DISTINCT o.order_id) AS orders,

    SUM(oi.quantity) AS units_sold,

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
            * (
                oi.unit_price
                * (1 - oi.discount_pct / 100)
                - oi.unit_cost
            )
        ),
        2
    ) AS gross_profit,

    ROUND(
        SUM(
            oi.quantity
            * (
                oi.unit_price
                * (1 - oi.discount_pct / 100)
                - oi.unit_cost
            )
        )
        /
        NULLIF(
            SUM(
                oi.quantity
                * oi.unit_price
                * (1 - oi.discount_pct / 100)
            ),
            0
        )
        * 100,
        2
    ) AS gross_margin_pct

FROM orders o

JOIN order_items oi
    ON o.order_id = oi.order_id

WHERE o.order_status <> 'Cancelled'

GROUP BY
    DATE_TRUNC('month', o.order_date)

ORDER BY
    month;

-- =====================================================
-- 3. CRECIMIENTO DE VENTAS MES CONTRA MES
-- =====================================================

WITH monthly_sales AS (

    SELECT
        DATE_TRUNC('month', o.order_date)::DATE AS month,

        ROUND(
            SUM(
                oi.quantity
                * oi.unit_price
                * (1 - oi.discount_pct / 100)
            ),
            2
        ) AS net_sales

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    WHERE o.order_status <> 'Cancelled'

    GROUP BY
        DATE_TRUNC('month', o.order_date)
)

SELECT
    month,
    net_sales,

    LAG(net_sales) OVER (
        ORDER BY month
    ) AS previous_month_sales,

    ROUND(
        (
            net_sales
            - LAG(net_sales) OVER (ORDER BY month)
        )
        /
        NULLIF(
            LAG(net_sales) OVER (ORDER BY month),
            0
        )
        * 100,
        2
    ) AS mom_growth_pct

FROM monthly_sales

ORDER BY month;

-- =====================================================
-- 4. MESES DESTACADOS DEL NEGOCIO
-- =====================================================

WITH monthly_sales AS (

    SELECT
        DATE_TRUNC('month', o.order_date)::DATE AS month,

        ROUND(
            SUM(
                oi.quantity
                * oi.unit_price
                * (1 - oi.discount_pct / 100)
            ),
            2
        ) AS net_sales

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    WHERE o.order_status <> 'Cancelled'

    GROUP BY
        DATE_TRUNC('month', o.order_date)
),

monthly_growth AS (

    SELECT
        month,
        net_sales,

        ROUND(
            (
                net_sales
                - LAG(net_sales) OVER (ORDER BY month)
            )
            /
            NULLIF(
                LAG(net_sales) OVER (ORDER BY month),
                0
            )
            * 100,
            2
        ) AS mom_growth_pct

    FROM monthly_sales
),

ranked_months AS (

    SELECT
        month,
        net_sales,
        mom_growth_pct,

        ROW_NUMBER() OVER (
            ORDER BY net_sales DESC
        ) AS rank_best_sales,

        ROW_NUMBER() OVER (
            ORDER BY net_sales ASC
        ) AS rank_worst_sales,

        ROW_NUMBER() OVER (
            ORDER BY mom_growth_pct DESC NULLS LAST
        ) AS rank_best_growth,

        ROW_NUMBER() OVER (
            ORDER BY mom_growth_pct ASC NULLS LAST
        ) AS rank_worst_growth

    FROM monthly_growth
)

SELECT
    'Best sales month' AS insight,
    month,
    net_sales,
    mom_growth_pct
FROM ranked_months
WHERE rank_best_sales = 1

UNION ALL

SELECT
    'Lowest sales month',
    month,
    net_sales,
    mom_growth_pct
FROM ranked_months
WHERE rank_worst_sales = 1

UNION ALL

SELECT
    'Highest MoM growth',
    month,
    net_sales,
    mom_growth_pct
FROM ranked_months
WHERE rank_best_growth = 1

UNION ALL

SELECT
    'Largest MoM decline',
    month,
    net_sales,
    mom_growth_pct
FROM ranked_months
WHERE rank_worst_growth = 1;

-- =====================================================
-- 5. DESEMPEÑO POR CANAL DE VENTA
-- =====================================================

SELECT
    o.sales_channel,

    COUNT(DISTINCT o.order_id) AS orders,

    SUM(oi.quantity) AS units_sold,

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
            * (
                oi.unit_price
                * (1 - oi.discount_pct / 100)
                - oi.unit_cost
            )
        ),
        2
    ) AS gross_profit,

    ROUND(
        SUM(
            oi.quantity
            * (
                oi.unit_price
                * (1 - oi.discount_pct / 100)
                - oi.unit_cost
            )
        )
        /
        NULLIF(
            SUM(
                oi.quantity
                * oi.unit_price
                * (1 - oi.discount_pct / 100)
            ),
            0
        )
        * 100,
        2
    ) AS gross_margin_pct,

    ROUND(
        SUM(
            oi.quantity
            * oi.unit_price
            * (1 - oi.discount_pct / 100)
        )
        /
        COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value

FROM orders o

JOIN order_items oi
    ON o.order_id = oi.order_id

WHERE o.order_status <> 'Cancelled'

GROUP BY
    o.sales_channel

ORDER BY
    net_sales DESC;

-- =====================================================
-- 6. DESEMPEÑO POR CATEGORÍA
-- =====================================================

SELECT
    c.category_name,

    COUNT(DISTINCT o.order_id) AS orders,

    SUM(oi.quantity) AS units_sold,

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
            oi.quantity * oi.unit_cost
        ),
        2
    ) AS total_cost,

    ROUND(
        SUM(
            oi.quantity
            * (
                oi.unit_price
                * (1 - oi.discount_pct / 100)
                - oi.unit_cost
            )
        ),
        2
    ) AS gross_profit,

    ROUND(
        SUM(
            oi.quantity
            * (
                oi.unit_price
                * (1 - oi.discount_pct / 100)
                - oi.unit_cost
            )
        )
        /
        NULLIF(
            SUM(
                oi.quantity
                * oi.unit_price
                * (1 - oi.discount_pct / 100)
            ),
            0
        )
        * 100,
        2
    ) AS gross_margin_pct

FROM orders o

JOIN order_items oi
    ON o.order_id = oi.order_id

JOIN products p
    ON oi.product_id = p.product_id

JOIN categories c
    ON p.category_id = c.category_id

WHERE o.order_status <> 'Cancelled'

GROUP BY
    c.category_name

ORDER BY
    net_sales DESC;

-- =====================================================
-- 7. RANKING DE PRODUCTOS POR RENTABILIDAD
-- =====================================================

WITH product_performance AS (

    SELECT
        p.product_id,
        p.product_name,
        c.category_name,

        SUM(oi.quantity) AS units_sold,

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
                * (
                    oi.unit_price
                    * (1 - oi.discount_pct / 100)
                    - oi.unit_cost
                )
            ),
            2
        ) AS gross_profit,

        ROUND(
            SUM(
                oi.quantity
                * (
                    oi.unit_price
                    * (1 - oi.discount_pct / 100)
                    - oi.unit_cost
                )
            )
            /
            NULLIF(
                SUM(
                    oi.quantity
                    * oi.unit_price
                    * (1 - oi.discount_pct / 100)
                ),
                0
            )
            * 100,
            2
        ) AS gross_margin_pct

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    JOIN products p
        ON oi.product_id = p.product_id

    JOIN categories c
        ON p.category_id = c.category_id

    WHERE o.order_status <> 'Cancelled'

    GROUP BY
        p.product_id,
        p.product_name,
        c.category_name
)

SELECT
    RANK() OVER (
        ORDER BY gross_profit DESC
    ) AS profit_rank,

    product_name,
    category_name,
    units_sold,
    net_sales,
    gross_profit,
    gross_margin_pct

FROM product_performance

ORDER BY
    profit_rank

LIMIT 10;