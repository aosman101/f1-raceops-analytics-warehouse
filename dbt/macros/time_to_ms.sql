{% macro time_to_ms(time_str) %}
    -- Converts 'M:SS.mmm' or 'SS.mmm' to milliseconds (INTEGER)
    -- Returns NULL if input is NULL/empty/'NULL'/\N.
    {% set cleaned_time = ergast_text_or_null(time_str) %}
    case
      when {{ cleaned_time }} is null then null
      when position(':' in {{ cleaned_time }}) > 0 then
        (
          split_part({{ cleaned_time }}, ':', 1)::int * 60 * 1000
          + floor(split_part(split_part({{ cleaned_time }}, ':', 2), '.', 1)::numeric * 1000)::int
          + right(split_part({{ cleaned_time }}, '.', 2), 3)::int
        )
      else
        (
          floor(split_part({{ cleaned_time }}, '.', 1)::numeric * 1000)::int
          + right(split_part({{ cleaned_time }}, '.', 2), 3)::int
        )
    end
{% endmacro %}
