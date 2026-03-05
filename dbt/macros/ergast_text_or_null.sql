{% macro ergast_text_or_null(value_expr) %}
  (
    case
      when {{ value_expr }} is null then null
      when btrim({{ value_expr }}::text) = '' then null
      when upper(btrim({{ value_expr }}::text)) = 'NULL' then null
      when btrim({{ value_expr }}::text) = '\\N' then null
      else btrim({{ value_expr }}::text)
    end
  )
{% endmacro %}
