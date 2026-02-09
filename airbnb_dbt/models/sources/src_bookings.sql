{{ config(materialization = 'incremental') }}

{% set incremental_key = 'CREATED_AT' %}


SELECT * FROM {{ source('staging', 'src_bookings') }}

{% if is_incremental() %}
    WHERE {{ incremental_key }} > (SELECT coalesce(MAX({{ incremental_key }}), '1900-01-01') FROM {{ this }})
{% endif %}
