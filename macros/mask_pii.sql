{#-
    mask_pii(column_name, pii_type)
    ------------------------------------------------------------------
    HIPAA Safe Harbor PII masking macro for the Silver layer.

    Strategies (the only three supported — no Strategy 3 fallback):

      ssn   -> 'XXX-XX-####'   retain last 4 digits only
               e.g. 900-45-5012 -> XXX-XX-5012
      email -> '*@***.***'     retain first character of the local part only
               e.g. linda.johnson@example.com -> l@***.***
      phone -> '***-***-####'  retain last 4 digits only
               e.g. 555-858-9935 -> ***-***-9935

    NULL inputs return NULL (no fabricated masked values).
    Unknown pii_type raises a compile-time error so PII can never pass
    through unmasked by accident.
-#}

{% macro mask_pii(column_name, pii_type) %}

    {%- set t = pii_type | lower -%}

    {%- if t == 'ssn' -%}
        case
            when {{ column_name }} is null then null
            else concat('XXX-XX-', right(regexp_replace({{ column_name }}, '[^0-9]', ''), 4))
        end

    {%- elif t == 'phone' -%}
        case
            when {{ column_name }} is null then null
            else concat('***-***-', right(regexp_replace({{ column_name }}, '[^0-9]', ''), 4))
        end

    {%- elif t == 'email' -%}
        case
            when {{ column_name }} is null then null
            else concat(left({{ column_name }}, 1), '@***.***')
        end

    {%- else -%}
        {{ exceptions.raise_compiler_error(
            "mask_pii: unsupported pii_type '" ~ pii_type ~
            "'. Supported types: ssn, email, phone. No Strategy 3 fallback permitted."
        ) }}
    {%- endif -%}

{% endmacro %}
