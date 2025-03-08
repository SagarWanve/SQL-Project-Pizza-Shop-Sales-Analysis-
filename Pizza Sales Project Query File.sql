Create Database Pizzahut;
use Pizzahut;


Create Table Orders(
Order_id int Not null,
Order_date Date not null,
Order_time Time not null,
Primary Key(order_id));

Create Table Order_Details(
Order_Details_id int Not null,
Order_id int Not Null,
Pizza_id Text Not Null,
Quantity int Not Null,
Primary key(order_details_id));

-- 1. Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS Total_Orders
FROM
    Orders;
    
    -- 2. Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(Quantity * pizzas.price), 2) AS Total_Sales
FROM
    Order_details
        JOIN
    pizzas ON order_details.Pizza_id = pizzas.pizza_id; 
    
    -- 3. Identify the highest-priced pizza.

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- 4. Identify the most common pizza size ordered. 

Select Pizzas.size, count(order_details.Order_Details_id) as order_count
from Pizzas join order_details
on Pizzas.pizza_id=order_details.Pizza_id
Group by Pizzas.size order by order_count Desc;


-- 5. List the top 5 most ordered pizza types along with their quantities.

SELECT 
    Pizza_types.name, SUM(order_details.Quantity) AS Quantity
FROM
    Pizza_types
        JOIN
    Pizzas ON Pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY Pizza_types.name
ORDER BY Quantity DESC
LIMIT 5;

-- 6. Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    Pizza_types.Category,
    SUM(order_Details.Quantity) AS Quantity
FROM
    pizza_types
        JOIN
    Pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_Details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY Pizza_types.Category
ORDER BY Quantity DESC;


-- 7. Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS Hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(order_time);


-- 8. Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    Category, COUNT(name) AS Pizza_count
FROM
    pizza_types
GROUP BY category;


-- 9. Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(sum_Quantity), 0) as pizzas_ordered_per_day
FROM
    (SELECT 
        Order_date, SUM(quantity) AS sum_Quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY Order_date) AS Order_Quantity;
    
    
    -- 10. Determine the top 3 most ordered pizza types based on revenue.
 
 SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.Pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;


-- 11. Calculate the percentage contribution of each pizza type to total revenue. 

SELECT 
    pizza_types.category,
    ROUND(SUM(order_details.Quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(order_details.Quantity * pizzas.price),
                                2) AS total_Sales
                FROM
                    order_details
                        JOIN
                    pizzas ON pizzas.pizza_id = order_details.pizza_id) * 100,
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_Type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;


-- 12. Analyze the cumulative revenue generated over time. 

Select order_date,
sum(revenue) over (order by order_date) as cum_revenue
from
(select orders.order_date,
sum(order_details.quantity * pizzas.price) as Revenue
from order_details join pizzas
on order_details.Pizza_id = pizzas.pizza_id
join orders
on orders.Order_id = order_details.Order_id
group by orders.order_date) as Sales;


-- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category. 

select name, revenue
from
(select category, name, revenue,
rank() over(partition by category order by revenue desc) as rn
from
(Select pizza_types.category, pizza_types.name,
sum(order_details.Quantity * pizzas.price) as Revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.Pizza_id = pizzas.pizza_id
Group by pizza_types.category, pizza_types.name) as a) as b
where rn <= 3;


