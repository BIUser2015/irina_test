- view: merch_order_statuses

# # Specify the table name if it's different from the view name:
#   sql_table_name: my_schema_name.merch_order_statuses
#
# # Or, you could make this view a derived table, like this:
#   derived_table:
#     sql: |
#       SELECT
#         users.id as user_id
#         , COUNT(*) as lifetime_orders
#         , MAX(orders.date) as most_recent_purchase_date
#       FROM orders
#       GROUP BY user.id
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
    sortkeys: [dt]

  fields:
    - dimension: merch_name
      primary_key: true
    
    - dimension: dt
    
    - measure: accepted               
      type: int
      
    - measure: rejected               
      type: int
      
    - measure: cancelled               
      type: int    
      
    - measure: cancelled_over_accepted             
      type: number
      sql: 100.0 * ${cancelled}/NULLIF(${accepted},0)
      format: "%0.2f%"      

    - measure: rejected_over_accepted             
      type: number
      sql: 100.0 * ${rejected}/NULLIF(${accepted},0)
      format: "%0.2f%"   