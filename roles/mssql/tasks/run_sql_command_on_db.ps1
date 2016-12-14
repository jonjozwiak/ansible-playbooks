---
- name: run sql command on DB
  script: run_sql_command_on_db.ps1 -instanceName {{ mssql.instance_name }} -dbName {{ mssql.db_name }} -sqlQuery "{{ mssql.sql_query }}"


