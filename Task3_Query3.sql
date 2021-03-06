--TASK 3
--Create a single table containing:
--      The account ID number and company name for the top 5 largest accounts in each region by total of individuals per company.
--      The count of individuals listed by account.
--      The count of individuals who ordered atleast one cake or pie between 7/1/2016 and 2/10/2017 by account and baked good.
--      The count of individuals who ordered atleast one cake or pie between 7/12/2016 and 2/25/2018 by account and baked good.


--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--QUERY FOR TASK 3

SELECT *
FROM
--QUERY1 shows the account ID number and company name for the top 5 largest accounts in each region by total of individuals per company.

        (SELECT subquery.region_id
            , subquery.acc_id_number
            , subquery.company_name
        	, subquery.total_individuals_at_company

        FROM
        	(
        		SELECT dc.region_id
        		    , dc.acc_id_number
        		    , dc.company_name
        			, (dc.total_cake_orders + dc.total_pie_orders) as total_individuals_at_company
        		    , row_number() over(partition by dc.region_id order by (total_individuals_at_company) desc) as rn
        		FROM dimension_company as dc
        		WHERE dc.total_cake_orders > 0
        			and dc.total_pie_orders > 0
        		GROUP BY dc.region_id
        		    , dc.acc_id_number
        		    , dc.company_name
        			, dc.total_cake_orders
        			, dc.total_pie_orders
        	) as subquery
        		WHERE subquery.rn <= 5
        ORDER BY region_id
            ) as QUERY1


LEFT JOIN
--QUERY2 shows the count of individuals listed by account.

        (SELECT dc.acc_id_number
        	, count(*) number_of_active_individuals

        FROM dimension_company as dc

        INNER JOIN dimension_individual as di
            on dc.id=di.acc_id
			and di.active = '1'

        GROUP BY dc.acc_id_number

        ORDER BY dc.acc_id_number
        ) as QUERY2
            on QUERY1.acc_id_number=QUERY2.acc_id_number


LEFT JOIN
--QUERY3 shows the count of individuals who ordered atleast one cake between 7/1/2016 and 2/10/2017 by account.

		(SELECT dc.acc_id_number
				,count(distinct(di.individual_id)) as Number_of_Individuals_with_Cakes_Delivered

		from fact_individual_cake_delivered as ficd

		INNER JOIN dimension_individual as di
			on ficd.individual_id = di.individual_id
            and ficd.status = '2'
			and (ficd.order_time >= '2016-07-01 00:00:00'
				and ficd.delivery_time <= '2017-02-10 23:59:59')

		INNER JOIN dimension_company as dc
        				on di.acc_id=dc.id

		GROUP BY
				dc.id
				, dc.acc_id_number
			)
		as QUERY3
		on QUERY1.acc_id_number = QUERY3.acc_id_number

LEFT JOIN
--QUERY4 shows the count of individuals who ordered atleast one pie between 7/1/2016 and 2/10/2017 by account.
			(SELECT dc.acc_id_number
					, count(distinct(di.individual_id)) as Number_of_Individuals_with_Pies_Delivered

			from fact_individual_pie_delivered as fipd

			INNER JOIN dimension_individual as di
				on fipd.individual_id = di.individual_id
                and fipd.status = '2'
				and (fipd.order_time >= '2016-07-01 00:00:00'
					and fipd.delivery_time <= '2017-02-10 23:59:59')

			INNER JOIN dimension_company as dc
				on di.acc_id=dc.id

			GROUP BY
				dc.id
				, dc.acc_id_number
			)
		as QUERY4
		on QUERY1.acc_id_number = QUERY4.acc_id_number
LEFT JOIN
--QUERY5 shows the count of individuals who ordered atleast one cake between 7/12/2016 and 2/25/2018 by account.
		(SELECT dc.acc_id_number
				,count(distinct(di.individual_id)) as Number_of_Individuals_with_Cakes_Delivered2

		from fact_individual_cake_delivered as ficd

		INNER JOIN dimension_individual as di
			on ficd.individual_id = di.individual_id
            		and ficd.status = '2'
			and (ficd.delivery_time >= '2016-07-12 00:00:00'
				and ficd.delivery_time <= '2018-02-25 23:59:59')

		INNER JOIN dimension_company as dc
        				on di.acc_id=dc.id

		GROUP BY
				dc.id
				, dc.acc_id_number
			)
		as QUERY5
		on QUERY1.acc_id_number = QUERY5.acc_id_number

LEFT JOIN
--QUERY6 shows the count of individuals who ordered atleast one pie between 7/12/2016 and 2/25/2018 by account.
			(SELECT dc.acc_id_number
					, count(distinct(di.individual_id)) as Number_of_Individuals_with_Pies_Delivered2

			from fact_individual_pie_delivered as fipd

			INNER JOIN dimension_individual as di
				on fipd.individual_id = di.individual_id
                	and fipd.status = '2'
			and (fipd.delivery_time >= '2016-07-12 00:00:00'
				and fipd.delivery_time <= '2018-02-25 23:59:59')

			INNER JOIN dimension_company as dc
				on di.acc_id=dc.id

			GROUP BY
				dc.id
				, dc.acc_id_number
			)
		as QUERY6
		on QUERY1.acc_id_number = QUERY6.acc_id_number

ORDER BY QUERY1.region_id
		, QUERY1.total_individuals_at_company desc
