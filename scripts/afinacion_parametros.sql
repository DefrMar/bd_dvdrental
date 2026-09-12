-- ============================================================
-- OPTIMIZACIÓN Y RENDIMIENTO
-- Base de datos: dvdrental
-- PostgreSQL
-- ============================================================

-- Objetivo:
-- Analizar planes de ejecución y mejorar consultas
-- mediante índices y estadísticas.


-- ============================================================
-- 1. PARÁMETROS IMPORTANTES DE POSTGRESQL
-- ============================================================

SHOW shared_buffers;
SHOW work_mem;
SHOW maintenance_work_mem;
SHOW effective_cache_size;


-- ============================================================
-- 2. CONSULTA A ANALIZAR
-- ============================================================

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    customer_id,
    payment_date,
    amount
FROM payment
WHERE customer_id = 100
ORDER BY payment_date DESC;


-- ============================================================
-- 3. CREACIÓN DE ÍNDICE COMPUESTO
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_payment_customer_date
ON payment (customer_id, payment_date DESC);


-- ============================================================
-- 4. ACTUALIZAR ESTADÍSTICAS
-- ============================================================

ANALYZE payment;


-- ============================================================
-- 5. ANALIZAR NUEVAMENTE
-- ============================================================

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    customer_id,
    payment_date,
    amount
FROM payment
WHERE customer_id = 100
ORDER BY payment_date DESC;


-- ============================================================
-- 6. CONSULTAR ÍNDICES DE LA TABLA PAYMENT
-- ============================================================

SELECT
    indexname,
    indexdef
FROM pg_indexes
WHERE tablename = 'payment'
ORDER BY indexname;


-- ============================================================
-- 7. DETECTAR TABLAS CON MUCHOS SEQUENTIAL SCANS
-- ============================================================

SELECT
    relname AS tabla,
    seq_scan,
    idx_scan,
    n_live_tup
FROM pg_stat_user_tables
ORDER BY seq_scan DESC;


-- ============================================================
-- 8. ESTADÍSTICAS DE ÍNDICES
-- ============================================================

SELECT
    relname AS tabla,
    indexrelname AS indice,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;


-- ============================================================
-- CONCEPTOS APLICADOS
-- ============================================================

-- EXPLAIN
-- EXPLAIN ANALYZE
-- BUFFERS
-- índices compuestos
-- ANALYZE
-- sequential scan
-- index scan
-- estadísticas de PostgreSQL
-- ============================================================
-- PRUEBA DE OPTIMIZACIÓN
-- ============================================================

-- Eliminar únicamente el índice creado para esta prueba
DROP INDEX IF EXISTS idx_payment_customer_date;

ANALYZE payment;

-- ============================================================
-- ANTES DEL ÍNDICE
-- ============================================================

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    customer_id,
    payment_date,
    amount
FROM payment
WHERE customer_id = 100
ORDER BY payment_date DESC
LIMIT 5;


-- ============================================================
-- CREACIÓN DEL ÍNDICE COMPUESTO
-- ============================================================

CREATE INDEX idx_payment_customer_date
ON payment (customer_id, payment_date DESC);

ANALYZE payment;


-- ============================================================
-- DESPUÉS DEL ÍNDICE
-- ============================================================

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    customer_id,
    payment_date,
    amount
FROM payment
WHERE customer_id = 100
ORDER BY payment_date DESC
LIMIT 5;
-- ============================================================
-- RESULTADO DEL ANÁLISIS
-- ============================================================

-- Sin el índice compuesto:
-- PostgreSQL utiliza idx_fk_customer_id y posteriormente
-- realiza un ordenamiento (Sort) por payment_date.

-- Con el índice:
-- idx_payment_customer_date (customer_id, payment_date DESC)
-- PostgreSQL puede realizar un Index Scan directo y evitar
-- el operador Sort.

-- En la base dvdrental, debido a su tamaño reducido, la
-- diferencia de tiempo de ejecución es mínima y puede variar
-- por efectos de caché. El objetivo de esta prueba es analizar
-- el cambio en el plan de ejecución, no afirmar una mejora
-- porcentual de rendimiento.
