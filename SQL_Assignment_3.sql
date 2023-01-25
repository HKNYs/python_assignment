
select *
from sale.order_item
where discount = 0.10 and product_id = 2
order by product_id


select product_id, discount, SUM(quantity) sum_of_quantity
from sale.order_item
group by product_id, discount
order by product_id;