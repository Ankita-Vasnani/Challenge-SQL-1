---DANNY'S DINNER
--- #CHALLENGE-1










CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
    SELECT * FROM menu
	SELECT * FROM sales
  
  --- ques1 What is the total amount each customer spent at the restaurant?
  SELECT * ,
 SUM(price) OVER(ORDER BY product_name) AS "product_name"
  FROM menu
  ---ques2 How many days has each customer visited the restaurant?
 SELECT customer_id, COUNT(order_date) AS no_days
 FROM sales
 GROUP BY customer_id
 ORDER BY customer_id ASC;
  ---ques3What was the first item from the menu purchased by each customer?
  SELECT s.customer_id, m.product_name
  FROM sales AS s
  INNER JOIN menu AS m
  ON s.product_id = m.product_id
  ORDER BY s.customer_id, s.order_date
  
  ---ques4 What is the most purchased item on the menu and how many times was it purchased by all customers?
  SELECT m.product_name,COUNT(s.customer_id) AS purchase_count
  FROM sales AS s
  JOIN menu AS m
  ON s.product_id = m.product_id
  GROUP BY m.product_name
  ORDER BY purchase_count DESC
  
   ---ques5 Which item was the most popular for each customer?
 
  WITH
   customerpurchasecounts AS(
   
   SELECT
	   s.customer_id, m.product_name,
	   COUNT(s.product_id) AS purchase_count,
	   RANK() OVER(PARTITION BY s.customer_id ORDER BY COUNT(s.product_id) DESC)
   
   FROM sales AS s
	   JOIN menu AS m
	   ON s.product_id = m.product_id
 GROUP BY s.customer_id, m.product_name	   
 )
 SELECT
 customer_id, product_name, purchase_count
 FROM customerpurchasecounts
  
  ---ques6 Which item was purchased first by the customer after they became a member?

    SELECT m.product_name, s.customer_id, MIN(s.order_date) AS first_purchase_date
  FROM sales AS s
  JOIN menu AS m
  ON s.product_id = m.product_id
  JOIN members AS mem
   ON s.customer_id = mem.customer_id
   WHERE s.order_date >= mem.join_date
  GROUP BY m.product_name, s.customer_id;
  
  ---ques-7 Which item was purchased just before the customer became a member?
  SELECT m.product_name, s.customer_id, MIN(s.order_date) 
  FROM sales AS s
  JOIN menu AS m
  ON s.product_id = m.product_id
  JOIN members AS mem
  ON s.customer_id = mem.customer_id
  WHERE s.order_date < mem.join_date
 GROUP BY  s.customer_id, m.product_name;
 
 
 ---ques8 What is the total items and amount spent for each member before they became a member?
WITH total AS (
  SELECT  
    s.customer_id,
    COUNT(s.product_id) AS "total_items",
    SUM(m.price) AS "total_amt"
  FROM sales AS s
  JOIN menu AS m ON s.product_id = m.product_id
  JOIN members AS mem ON s.customer_id = mem.customer_id
  WHERE s.order_date < mem.join_date
  GROUP BY s.customer_id
)
SELECT customer_id, total_amt, total_items 
FROM total;

---ques9 If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH purchasepoints AS(
 SELECT s.customer_id,
	SUM(m.price*CASE WHEN m.product_name = 'sushi' THEN 2 ELSE 1 END*10) AS total_points
	FROM sales AS s
	JOIN menu AS m
	ON s.product_id = m.product_id
	GROUP BY s.customer_id
)
SELECT p.customer_id, p.total_points
FROM purchasepoints AS p
JOIN members AS mem
ON p.customer_id = mem.customer_id;
 
 ---ques10 In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
 WITH totalpoints AS(
 SELECT s.customer_id,
	 SUM( CASE 
		 WHEN s.order_date >= mem.join_date AND s.order_date < mem.join_date + INTERVAL '7 DAYS' 
		 THEN
		m.price * 2 * 10
		 ELSE 
		m.price * CASE
		 WHEN m.product_name = 'sushi' THEN 2 ELSE 1 END *10
		 END) AS total_points
 	FROM sales AS s
	 JOIN menu AS m
	 ON s.product_id = m.product_id
	 JOIN members AS mem
	 ON s.customer_id = mem.customer_id
	 GROUP BY s.customer_id
	)
 SELECT t.customer_id,t.total_points
 FROM  totalpoints AS t;
 
 
 
 
 
 
 
 

  