---
- name: run sql command on instance
  script: run_sql_command_on_instance.ps1 -instanceName {{ mssql.instance_name }} -sqlQuery "{{ mssql.sql_query }}"

