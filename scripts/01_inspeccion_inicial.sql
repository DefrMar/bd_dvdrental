-- 01_inspeccion_inicial.sql
-- Proyecto: Administración de la BD dvdrental
-- Objetivo: Inspección inicial de la base de datos

-- 1. Ver esquemas disponibles
SELECT schema_name
FROM information_schema.schemata
ORDER BY schema_name;

-- 2. Contar cuántas tablas tiene el esquema public
SELECT COUNT(*) AS total_tablas_public
FROM information_schema.tables
WHERE table_schema = 'public';

-- 3. Listar las tablas del esquema public
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- 4. Número de filas aproximado por tabla (estadísticas)
SELECT relname AS tabla,
       reltuples::bigint AS filas_aproximadas
FROM pg_class
WHERE relkind = 'r'
  AND relnamespace = 'public'::regnamespace
ORDER BY filas_aproximadas DESC;
