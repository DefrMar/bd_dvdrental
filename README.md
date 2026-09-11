# PostgreSQL Database Administration — DVD Rental

Proyecto académico enfocado en la administración, consulta y análisis de una
base de datos relacional utilizando PostgreSQL y la base de ejemplo `dvdrental`.

El objetivo del proyecto es aplicar conceptos de diseño de bases de datos,
SQL, administración, seguridad, monitoreo, respaldo y optimización.

## Tecnologías

- PostgreSQL
- SQL
- DBeaver
- Git
- GitHub

## Funcionalidades implementadas

- Inspección de la estructura de la base de datos.
- Consulta de tablas y relaciones.
- Análisis de información mediante SQL.
- Uso del catálogo de PostgreSQL e `information_schema`.
- Administración y exploración de la base mediante DBeaver.
- Diagramas de la estructura de la base de datos.

## Estructura del proyecto

README.md
│
├── scripts/
│   ├── 01_inspeccion_inicial.sql
│   ├── 03_seguridad_roles.sql
│   ├── consultas_monitoreo.sql
│   ├── afinacion_parametros.sql
│   ├── respaldo_completo.sh
│   └── restaurar_respaldo.sh
│
├── diagramas/
│
└── backups/
    ├── dvdrental.tar
    └── dvdrental.zip
