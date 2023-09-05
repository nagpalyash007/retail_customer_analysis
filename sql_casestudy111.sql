
 use case_study
--- What is the total number of rows in each of the 3 tables in the database?
select * from( select 'Customer$' as table_name ,count(*)no_of_records from Customer$ union all
            select 'prod_cat_info$' as table_name ,count(*)no_of_records from prod_cat_info$ union all
            select 'Transactions$' as table_name ,count(*)no_of_records from Transactions$)tables


-------------------------------------------------------------------------------------------------------------------------------
---What is the total number of transactions that have a return?
select sum(case 
when total_amt<0 then 1
else 0
end )as sum_of_return
from Transactions$

-----------------------------------------------------------------------------------------------------------------------------------------------
---3. As you would have noticed, the dates provided across the datasets are not in a
----correct format. As first steps, pls convert the date variables into 
-----valid date formats before proceeding ahead.
select CONVERT(date,tran_date,108)date_of_transactions from Transactions$
select CONVERT(date,dob,108)date_of_birth from Customer$



---------------------------------------------------------------------------------------------------------------


 ----4. What is the time range of the transaction data available for analysis? 
 ---- Show the output in number of days, months and years simultaneously in different columns.
 select datediff(day,min(convert(date,tran_date)),max(convert(date,tran_date)))days ,
 datediff(MONTH,min(convert(date,tran_date)),max(convert(date,tran_date)))months,
 datediff(YEAR,min(convert(date,tran_date)),max(convert(date,tran_date)))years
 from Transactions$	



 ----------------------------------------------------------------------------------------------------------------------------


----5. Which product category does the sub-category “DIY” belong to?
select  prod_cat from prod_cat_info$
where prod_subcat = 'diy'

-----------------------------------------------------------------------------------------------------------------------------------------

---data analysis
-----------------------------------------------------------------------------------------------------------------------
--- Which channel is most frequently used for transactions?
select top 1 store_type,count(store_type)cnt
from Transactions$
group by store_type
order by count(store_type) desc;

-- as we can store_type e-shop is most frequent among all channels ,this can take into consideration and would be beneficial for company .



----find the age of all customers ??
select * from Customer$
alter table customer$
add age as datediff(year,dob,getdate())



-----------------------------------------------------------------------------------------------------------------------------------------
 
----2. What is the count of Male and Female customers in the database?
select sum(case when gender = 'm' then 1 else 0 end) as no_of_male,
sum(case when gender = 'f' then 1 else 0 end )as no_of_female 
from Customer$

----as we can we need distribution of gender ,how many males and females are our active customers 

-------------------------------------------------------------------------------------------------------------------------------------------
----3. From which city do we have the maximum number of customers and how many?
select * from (select city_code,count(city_code)cnt
,dense_rank() over(order by count(city_code) desc)rankk
from Customer$
group by city_code)x
where x.rankk=1;

--- here we city code 3 from there we are getting maximum number of our customers 

----------------------------------------------------------------------------------------------------------------------------------------------------

-----4. How many sub-categories are there under the Books category?
select prod_cat,count(prod_subcat)no_of_subcat from 
prod_cat_info$
where prod_cat='books'
group by prod_cat


---- here are 6 subcategories in category of books you can find how many subcategories in each category 

-------------------------------------------------------------------------------------------------------------------------------------------
-----5. What is the maximum quantity of products ever ordered?
select prod_cat,count_of_qty from(select p.prod_cat,count(t.Qty)count_of_qty,
DENSE_RANK() over (order by count(t.Qty) desc)rankk
from Transactions$ t 
join prod_cat_info$ p
on p.prod_cat_code=t.prod_cat_code
group by  p.prod_cat)x
where x.rankk=1
;


--- here we have category of books of which we sold maximum quantity 
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----- 6. What is the net total revenue generated in categories Electronics and Books?
select  p.prod_cat,round(sum(t.total_amt),1)total_net_revenue
from Transactions$ t 
join 
prod_cat_info$ p on
p.prod_cat_code=t.prod_cat_code
where p.prod_cat in ('electronics','books')
group by p.prod_cat;


--- we have generated total_revenue of total_net_revenue 76936164.2 and 53612318.2 in books and electronics respectively 

------------------------------------------------------------
----7. How many customers have >10 transactions with us, excluding returns?
select cust_id,count(transaction_id)count_of_transactions from Transactions$
where total_amt >0
group by cust_id
having count(transaction_id) >10
order by 2 desc;


-- we have 6 customers those have more than 10 transaction s without any return 
------------------------------------------------------

---8. What is the combined revenue earned from the “Electronics” & “Clothing”
-----categories, from “Flagship stores”?
select p.prod_cat, t.Store_type,round(sum(t.total_amt),0)total_net_revenue
from Transactions$ t 
join 
prod_cat_info$ p on
p.prod_cat_code=t.prod_cat_code
group by p.prod_cat,t.Store_type
having t.Store_type = 'flagship store'
and  p.prod_cat in ('electronics','clothing') ;


--- here we need to total_net_revenue with condition of having store_type of flagship and categories of electronics and clothing 




----------------------------------------------------------------------------------------------------------------


-----9. What is the total revenue generated from “Male” customers in “Electronics”
--------category? Output should display total revenue by prod sub-cat.
select  p.prod_subcat,sum(t.total_amt)net_revenue
from Customer$ c
join Transactions$ t on t.cust_id=c.customer_Id
join prod_cat_info$ p on p.prod_sub_cat_code=t.prod_subcat_code
where c.Gender = 'm'
and p.prod_cat= 'electronics'
group by  p.prod_subcat
order by 2;


--- here we only need to have revenue generated by male customers only in elctonics category 

------------------------------------------------------------------------------------------------------------
--10---What is percentage of sales and returns by product sub category; display only top
----5 sub categories in terms of sales?
select top 5 p.prod_subcat,(t.total_amt*100/(select sum(t.total_amt) from Transactions$ t)) percent_of_sale,
t.Qty*100/(select sum(t.qty) from Transactions$ t)percent_of_return
from Transactions$ t 
join prod_cat_info$ p 
on p.prod_cat_code=t.prod_cat_code
order by 2 desc

--------------------------------------------------------------------------------------------------------------------------------

-----11. For all customers aged between 25 to 35 years find what is the net total revenue 
select datediff(year,c.DOB,getdate())date_of_birth,sum(t.total_amt)net_total_revenue
from Customer$ c
left join
Transactions$ t on t.cust_id=c.customer_Id
where t.tran_date between dateadd(day,-30,EOMONTH((tran_date),0)) and EOMONTH((tran_date),0)
group by datediff(year,c.DOB,getdate())
having datediff(year,c.DOB,getdate())between 25 and 35 
order by 1


select age,sum(t.total_amt) from customer$ c
left join 
Transactions$ t 
on t.cust_id=c.customer_Id
where age between 25 and 35
group by age

 
select dob from Customer$ order by 1 
select EOMONTH((c.dob),0) from Customer$ c
----------------------------------------------------------------------------------------------------------------------
---12. Which product category has seen the max value of returns in the last 3 months of transactions?
select top 1 p.prod_cat,count(t.Qty)no_of_return
from Transactions$ t
join 
prod_cat_info$ p on t.prod_cat_code=p.prod_cat_code
where t.Qty<0 and t.tran_date between dateadd(day,1,EOMONTH((t.tran_date),-3)) and EOMONTH((t.tran_date),0)
group by p.prod_cat
order by 2 desc 

--- here we books in the category which have maximum return



select prod_cat_code,count(total_amt)  from Transactions$
where total_amt <0
group by prod_cat_code
order by 2 desc
select min(qty) from Transactions$
where Qty <0
group by prod_cat_code

select * from prod_cat_info$
select prod_cat_code, count(case when qty <0 then 1 else 0 end )as case_ from Transactions$
where case when qty <0 then 1 else 0 end=1
group by prod_cat_code

use case_study
-----13.Which store-type sells the maximum products; by value of sales amount and by quantity sold?
select  top 1 store_type,sum(total_amt)total_revenue,sum(Qty)quantity
from Transactions$
group by Store_type
order by 2 desc




-----14. What are the categories for which average revenue is above the overall average.
select p.prod_cat,avg(t.total_amt)average_,(select avg(total_amt) from transactions$)overall_average
from Transactions$ t 
join prod_cat_info$ p 
on p.prod_cat_code=t.prod_cat_code
group by p.prod_cat
having avg(t.total_amt)>(select avg(total_amt) from transactions$);


  ------15. Find the average and total revenue by each subcategory for the categories 
 ----------- which are among top 5 categories in terms of quantity sold.---
 select top 5 p.prod_subcat,avg(total_amt)average,sum(total_amt)total_revenue,count(qty)QTY
 from Transactions$ t
 join prod_cat_info$ p on p.prod_sub_cat_code=t.prod_subcat_code
 group by p.prod_subcat
 order by 4 desc











