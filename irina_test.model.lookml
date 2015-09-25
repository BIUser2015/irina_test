- connection: verticaprod

- include: "*.view.lookml"       # include all the views
- include: "*.dashboard.lookml"  # include all the dashboards

- view: merch_order_statuses
  derived_table:
    sql: |
            select merch_name,
              to_char(order_date,'yyyy-mm-dd hh24') dt,
              sum(case when checkout_status = 'GREEN' then 1 else 0 end) as accepted,
              sum(case when checkout_status = 'RED' then 1 else 0 end) as rejected,
              sum(case when checkout_status = 'CANCELLED' then 1 else 0 end) as cancelled
            from LOOKER.EXECUTIVE_DASHBOARD
            where order_date >= sysdate - 1
            group by merch_name,
                     to_char(order_date,'yyyy-mm-dd hh24')
            order by dt

  fields:

  - dimension: merch_name
    sql: ${TABLE}.merch_name

  - dimension: dt
    sql: ${TABLE}.dt

  - measure: accepted
    type: number
    sql: ${TABLE}.accepted

  - measure: rejected
    type: number
    sql: ${TABLE}."rejected"

  - measure: cancelled
    type: number
    sql: ${TABLE}.cancelled
    
  - measure: cancelled_over_accepted             
    type: number
    sql: 100.0 * ${cancelled}/NULLIF(${accepted},0)
    format: "%0.2f%"      

  - measure: rejected_over_accepted             
    type: number
    sql: 100.0 * ${rejected}/NULLIF(${accepted},0)
    format: "%0.2f%"  

  sets:
    detail:
      - merch_name
      - dt


