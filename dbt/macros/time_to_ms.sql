{% macro time_to_ms(time_expression) -%}
(
  case
    when {{ time_expression }} is null then null
    when {{ time_expression }} ~ '^[0-9]+:[0-9]{2}\.[0-9]{3}$' then
      (
        split_part({{ time_expression }}, ':', 1)::numeric * 60000
        + split_part(split_part({{ time_expression }}, ':', 2), '.', 1)::numeric * 1000
        + split_part({{ time_expression }}, '.', 2)::numeric
      )::bigint
    when {{ time_expression }} ~ '^[0-9]+\.[0-9]{3}$' then
      (
        split_part({{ time_expression }}, '.', 1)::numeric * 1000
        + split_part({{ time_expression }}, '.', 2)::numeric
      )::bigint
    else null
  end
)
{%- endmacro %}
