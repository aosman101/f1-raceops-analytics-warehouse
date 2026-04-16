{#
  Override default dbt schema naming.

  Default dbt behavior concatenates target.schema with any custom +schema,
  producing names like `analytics_analytics` and `analytics_staging`.

  With this override, when a model sets `+schema: staging`, the schema
  is simply `staging` (not `analytics_staging`).
#}
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
