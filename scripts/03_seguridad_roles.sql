-- ============================================================
-- SEGURIDAD, ROLES Y PERMISOS
-- Base de datos: dvdrental
-- PostgreSQL
-- ============================================================

-- Objetivo:
-- Implementar control de acceso mediante roles siguiendo
-- el principio de mínimo privilegio.


-- ============================================================
-- 1. CREACIÓN DE ROLES
-- ============================================================

-- Rol únicamente para consultas
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_roles
        WHERE rolname = 'rol_lectura'
    ) THEN
        CREATE ROLE rol_lectura NOLOGIN;
    END IF;
END
$$;


-- Rol para operaciones CRUD
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_roles
        WHERE rolname = 'rol_operador'
    ) THEN
        CREATE ROLE rol_operador NOLOGIN;
    END IF;
END
$$;


-- ============================================================
-- 2. ACCESO A LA BASE DE DATOS
-- ============================================================

GRANT CONNECT ON DATABASE dvdrental
TO rol_lectura, rol_operador;


-- ============================================================
-- 3. ACCESO AL ESQUEMA
-- ============================================================

GRANT USAGE ON SCHEMA public
TO rol_lectura, rol_operador;


-- ============================================================
-- 4. PERMISOS PARA ROL DE LECTURA
-- ============================================================

GRANT SELECT
ON ALL TABLES IN SCHEMA public
TO rol_lectura;


-- ============================================================
-- 5. PERMISOS PARA ROL OPERADOR
-- ============================================================

GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA public
TO rol_operador;


-- Permisos necesarios para secuencias utilizadas
-- por columnas SERIAL / IDENTITY

GRANT USAGE, SELECT
ON ALL SEQUENCES IN SCHEMA public
TO rol_operador;


-- ============================================================
-- 6. PERMISOS PARA TABLAS FUTURAS
-- ============================================================

ALTER DEFAULT PRIVILEGES
IN SCHEMA public
GRANT SELECT ON TABLES
TO rol_lectura;


ALTER DEFAULT PRIVILEGES
IN SCHEMA public
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES
TO rol_operador;


ALTER DEFAULT PRIVILEGES
IN SCHEMA public
GRANT USAGE, SELECT ON SEQUENCES
TO rol_operador;


-- ============================================================
-- 7. USUARIOS DE PRUEBA
-- ============================================================

-- No se almacenan contraseñas dentro del repositorio público.

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_roles
        WHERE rolname = 'usuario_consulta'
    ) THEN
        CREATE ROLE usuario_consulta LOGIN;
    END IF;
END
$$;


DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_roles
        WHERE rolname = 'usuario_operador'
    ) THEN
        CREATE ROLE usuario_operador LOGIN;
    END IF;
END
$$;


-- Asignación de roles

GRANT rol_lectura TO usuario_consulta;

GRANT rol_operador TO usuario_operador;


-- ============================================================
-- 8. EJEMPLO DE REVOKE
-- ============================================================

-- Se elimina cualquier capacidad de modificación
-- al usuario de consulta.

REVOKE INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA public
FROM usuario_consulta;


-- ============================================================
-- 9. VERIFICACIÓN
-- ============================================================

-- Consultar roles creados

SELECT
    rolname,
    rolcanlogin,
    rolsuper,
    rolcreatedb,
    rolcreaterole
FROM pg_roles
WHERE rolname IN (
    'rol_lectura',
    'rol_operador',
    'usuario_consulta',
    'usuario_operador'
);


-- Consultar privilegios otorgados

SELECT
    grantee,
    table_schema,
    table_name,
    privilege_type
FROM information_schema.role_table_grants
WHERE grantee IN (
    'rol_lectura',
    'rol_operador'
)
ORDER BY
    grantee,
    table_name,
    privilege_type;


-- ============================================================
-- NOTA DE SEGURIDAD
-- ============================================================

-- Las contraseñas no deben almacenarse en repositorios Git.
-- Deben configurarse localmente mediante:
--
-- ALTER ROLE usuario_consulta WITH PASSWORD 'contraseña_segura';
--
-- ALTER ROLE usuario_operador WITH PASSWORD 'contraseña_segura';
--
-- No subir contraseñas reales al repositorio.
