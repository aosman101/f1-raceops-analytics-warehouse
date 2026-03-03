{% macro time_to_ms(time_str) %}
    -- Converts 'M:SS.mmm' or 'SS.mmm' to milliseconds (INTEGER)
    -- Returns NULL if input is NULL/empty.
    case
      when {{ time_str }} is null or nullif({{ time_str }}, '') is null then null
      when position(':' in {{ time_str }}) > 0 then
        (
          split_part({{ time_str }}, ':', 1)::int * 60 * 1000
          + floor(split_part(split_part({{ time_str }}, ':', 2), '.', 1)::numeric * 1000)::int
          + right(split_part({{ time_str }}, '.', 2), 3)::int
        )
      else
        (
          floor(split_part({{ time_str }}, '.', 1)::numeric * 1000)::int
          + right(split_part({{ time_str }}, '.', 2), 3)::int
        )
    end
{% endmacro %}