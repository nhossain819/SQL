--TASK 5
--Create a single table containing:
--      The account ID number and company name for all accounts with individuals who had deliveries in a year later than their order year.
--      Account type for each such company
--      Number of individuals having deliveries in years later than their order year.
--      Number of deliveries associated with previous rules.


--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--QUERY FOR TASK 5
SELECT *
FROM
--QUERY1 The account ID number and company name for all accounts with individuals who had deliveries in a year later
--	than their order year.
        (SELECT dc.acc_id_number
        	, dc.company_name

        FROM fact_individual_cake_delivered as ficd
		INNER JOIN fact_individual_pie_delivered as fipd
			on ficd.order_year_id=fipd.order_year_id
            and (substring(ficd.order_year, 10, 4) < extract(year from ficd.delivery_time)
            	or substring(fipd.order_year, 10, 4) < extract(year from fipd.delivery_time))
		INNER JOIN dimension_individual as di
            on ficd.order_year_id=di.id
		INNER JOIN dimension_company as dc
            on dc.id = di.acc_id
			and dc.active='1'

		GROUP BY dc.acc_id_number
        	, dc.company_name
        ) as QUERY1

LEFT JOIN
--QUERY2 Account type for each such company.
		(SELECT dc.acc_id_number
        	, dc.account_type
			, dc.current_order_year

        FROM dimension_company as dc

		GROUP BY dc.acc_id_number
        	, dc.account_type
			, dc.current_order_year
		) as QUERY2
			on QUERY1.acc_id_number=QUERY2.acc_id_number



LEFT JOIN
--QUERY3 Number of individuals having deliveries in years later than their order year. (CAKE)
        (SELECT dc.acc_id_number
            , count(distinct(ficd.individual_id)) as num_individuals_with_cake_delivered

        FROM fact_individual_cake_delivered as ficd

        INNER JOIN dimension_individual as di
            on di.id=ficd.order_year_id

        INNER JOIN dimension_company as dc
            on dc.id=di.acc_id

        WHERE cast(substring(ficd.order_year, 10, 4) as int) < extract(year from ficd.delivery_time)

		GROUP BY dc.acc_id_number
        ) as QUERY3
            on QUERY1.acc_id_number=QUERY3.acc_id_number

LEFT JOIN
--QUERY4 Number of individuals having deliveries in years later than their order year. (PIE)
        (SELECT dc.acc_id_number
            ,  count(distinct(fipd.individual_id)) as num_individuals_with_pie_delivered

        FROM fact_individual_pie_delivered as fipd

        INNER JOIN dimension_individual as di
            on di.id=fipd.order_year_id

        INNER JOIN dimension_company as dc
            on dc.id=di.acc_id

        WHERE substring(fipd.order_year, 10, 4) < extract(year from fipd.delivery_time)

		GROUP BY dc.acc_id_number
        ) as QUERY4
		      on QUERY1.acc_id_number = QUERY4.acc_id_number

LEFT JOIN
--QUERY5 Number of deliveries associated with previous rules. (CAKE)
        (SELECT dc.acc_id_number
            ,  count(ficd.id) as Num_Cakes_Delivered

        FROM fact_individual_cake_delivered as ficd

        INNER JOIN dimension_individual as di
            on di.id=ficd.order_year_id

        INNER JOIN dimension_company as dc
            on dc.id=di.acc_id

        WHERE cast(substring(ficd.order_year, 10, 4) as int) < extract(year from ficd.delivery_time)

		GROUP BY dc.acc_id_number
        ) as QUERY5
            on QUERY1.acc_id_number = QUERY5.acc_id_number

LEFT JOIN
--QUERY6 Number of deliveries associated with previous rules. (PIE)
        (SELECT dc.acc_id_number
            ,  count(fipd.id) as Num_Pies_Delivered

        FROM fact_individual_pie_delivered as fipd

        INNER JOIN dimension_individual as di
            on di.id=fipd.order_year_id

        INNER JOIN dimension_company as dc
            on dc.id=di.acc_id

        WHERE substring(fipd.order_year, 10, 4) < extract(year from fipd.delivery_time)

		GROUP BY dc.acc_id_number
        ) as QUERY6
            on QUERY1.acc_id_number = QUERY6.acc_id_number

ORDER BY QUERY1.acc_id_number
		, QUERY2.current_order_year
