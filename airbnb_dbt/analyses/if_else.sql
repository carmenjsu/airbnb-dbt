{%  set flag = 2 %}

SELECT * FROM {{ ref('src_bookings')}}
{% if flag == 1 %}
    where nights_booked > {{ flag }}
{% else %}    
    where nights_booked = 1
{% endif %}