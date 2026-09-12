-- ============================================================
-- MONITOREO DE POSTGRESQL
-- Base de datos: dvdrental
-- ============================================================

-- 1. CONEXIONES ACTIVAS
SELECT
    pid,
    usename,
    datname,
    client_addr,
    state,
    backend_start
FROM pg_stat_activity
WHERE datname = 'dvdrental'
ORDER BY backend_start;


-- 2. CONSULTAS QUE SE ESTÁN EJECUTANDO
SELECT
    pid,
    usename,
    state,
    query_start,
    NOW() - query_start AS duracion,
    query
FROM pg_stat_activity
WHERE state = 'active'
  AND datname = 'dvdrental'
  AND pid <> pg_backend_pid()
ORDER BY query_start;


-- 3. CONSULTAS DE LARGA DURACIÓN
SELECT
    pid,
    usename,
    NOW() - query_start AS duracion,
    query
FROM pg_stat_activity
WHERE state = 'active'
  AND query_start < NOW() - INTERVAL '1 second'
  AND pid <> pg_backend_pid()
ORDER BY duracion DESC;


-- 4. ESTADÍSTICAS GENERALES DE LA BASE
SELECT
    datname,
    numbackends AS conexiones,
    xact_commit AS commits,
    xact_rollback AS rollbacks,
    blks_read,
    blks_hit,
    tup_returned,
    tup_fetched,
    tup_inserted,
    tup_updated,
    tup_deleted
FROM pg_stat_database
WHERE datname = 'dvdrental';


-- 5. TABLAS CON MAYOR ACTIVIDAD
SELECT
    schemaname,
    relname AS tabla,
    seq_scan,
    idx_scan,
    n_tup_ins AS inserts,
    n_tup_upd AS updates,
    n_tup_del AS deletes
FROM pg_stat_user_tables
ORDER BY seq_scan DESC;


-- 6. USO DE ÍNDICES
SELECT
    schemaname,
    relname AS tabla,
    seq_scan,
    idx_scan,
    CASE
        WHEN (seq_scan + idx_scan) = 0 THEN 0
        ELSE ROUND(
            100.0 * idx_scan / (seq_scan + idx_scan),
            2
        )
    END AS porcentaje_uso_indices
FROM pg_stat_user_tables
ORDER BY porcentaje_uso_indices ASC;


-- 7. TAMAÑO DE TABLAS
SELECT
    relname AS tabla,
    pg_size_pretty(
        pg_total_relation_size(relid)
    ) AS tamano_total
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC;


-- 8. BLOQUEOS ACTIVOS
SELECT
    pid,
    locktype,
    relation::regclass AS relacion,
    mode,
    granted
FROM pg_locks
WHERE database = (
    SELECT oid
    FROM pg_database
    WHERE datname = 'dvdrental'
)
ORDER BY granted;


-- 9. CACHE HIT RATIO
SELECT
    datname,
    ROUND(
        100.0 * blks_hit /
        NULLIF(blks_hit + blks_read, 0),
        2
    ) AS cache_hit_ratio
FROM pg_stat_database
WHERE datname = 'dvdrental';
