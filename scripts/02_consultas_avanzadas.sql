-- ============================================================
-- CONSULTAS SQL AVANZADAS
-- Base de datos: dvdrental
-- PostgreSQL
-- ============================================================

-- Objetivo:
-- Practicar consultas SQL utilizando JOIN, GROUP BY,
-- subconsultas, CTE y funciones de ventana.


-- ============================================================
-- 1. JOIN + GROUP BY
-- Clientes con mayor gasto acumulado
-- ============================================================

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    ROUND(SUM(p.amount), 2) AS total_gastado
FROM customer c
JOIN payment p
    ON c.customer_id = p.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY total_gastado DESC
LIMIT 10;


-- ============================================================
-- 2. MÚLTIPLES JOIN
-- Películas más rentadas
-- ============================================================

SELECT
    f.film_id,
    f.title,
    COUNT(r.rental_id) AS total_rentas
FROM film f
JOIN inventory i
    ON f.film_id = i.film_id
JOIN rental r
    ON i.inventory_id = r.inventory_id
GROUP BY
    f.film_id,
    f.title
ORDER BY total_rentas DESC
LIMIT 10;


-- ============================================================
-- 3. SUBCONSULTA
-- Películas con tarifa superior al promedio
-- ============================================================

SELECT
    film_id,
    title,
    rental_rate
FROM film
WHERE rental_rate > (
    SELECT AVG(rental_rate)
    FROM film
)
ORDER BY rental_rate DESC;


-- ============================================================
-- 4. CTE
-- Ingresos generados por cada cliente
-- ============================================================

WITH ingresos_cliente AS (
    SELECT
        customer_id,
        SUM(amount) AS total
    FROM payment
    GROUP BY customer_id
)

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    ROUND(ic.total, 2) AS total_ingresos
FROM ingresos_cliente ic
JOIN customer c
    ON ic.customer_id = c.customer_id
ORDER BY total_ingresos DESC
LIMIT 10;


-- ============================================================
-- 5. FUNCIÓN DE VENTANA
-- Ranking de clientes por gasto
-- ============================================================

SELECT
    customer_id,
    total_gastado,
    RANK() OVER (
        ORDER BY total_gastado DESC
    ) AS ranking
FROM (
    SELECT
        customer_id,
        SUM(amount) AS total_gastado
    FROM payment
    GROUP BY customer_id
) AS gastos
ORDER BY ranking;


-- ============================================================
-- 6. ROW_NUMBER
-- Último pago registrado por cliente
-- ============================================================

WITH pagos_ordenados AS (
    SELECT
        customer_id,
        amount,
        payment_date,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY payment_date DESC
        ) AS numero
    FROM payment
)

SELECT
    customer_id,
    amount,
    payment_date
FROM pagos_ordenados
WHERE numero = 1
ORDER BY customer_id;


-- ============================================================
-- 7. CASE
-- Clasificación de clientes según gasto
-- ============================================================

SELECT
    customer_id,
    ROUND(SUM(amount), 2) AS total_gastado,

    CASE
        WHEN SUM(amount) >= 150 THEN 'Cliente Alto'
        WHEN SUM(amount) >= 100 THEN 'Cliente Medio'
        ELSE 'Cliente Bajo'
    END AS categoria_cliente

FROM payment
GROUP BY customer_id
ORDER BY total_gastado DESC;


-- ============================================================
-- 8. CTE + JOIN + FUNCIÓN DE VENTANA
-- Ranking de películas por categoría
-- ============================================================

WITH rentas_pelicula AS (

    SELECT
        c.name AS categoria,
        f.title,
        COUNT(r.rental_id) AS total_rentas

    FROM category c

    JOIN film_category fc
        ON c.category_id = fc.category_id

    JOIN film f
        ON fc.film_id = f.film_id

    JOIN inventory i
        ON f.film_id = i.film_id

    JOIN rental r
        ON i.inventory_id = r.inventory_id

    GROUP BY
        c.name,
        f.title
)

SELECT
    categoria,
    title,
    total_rentas,

    RANK() OVER (
        PARTITION BY categoria
        ORDER BY total_rentas DESC
    ) AS ranking_categoria

FROM rentas_pelicula
ORDER BY
    categoria,
    ranking_categoria;


-- ============================================================
-- CONCEPTOS APLICADOS
-- ============================================================

-- JOIN
-- GROUP BY
-- SUM
-- COUNT
-- AVG
-- Subconsultas
-- CTE (WITH)
-- CASE
-- RANK()
-- ROW_NUMBER()
-- PARTITION BY
-- ORDER BY
