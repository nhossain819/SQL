--TASK 2
--Create a single table containing:
--	The account ID number and Company Name of every active account in region 3 of Italy.
--	The count of active individuals listed in the database by office size and account.
--	The count of individuals who were delivered at least one cake or pie between 7/1/2016 and 2/10/2017 by account and office size.
--	The average number of deliveries in the same time period per individual with at least one order in that time period, by
--		pastry, company, and office size.


--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--QUERY FOR TASK 2

SELECT aid_s1 as acc_id_number
		, office_size as Office_Size
		, count as Num_of_Active_Individuals
		, num_individuals_with_cake_delivered as Num_Individuals_with_Cake_Delivered
		, num_individuals_with_pie_delivered as Num_Individuals_with_Pie_Delivered
		, avg as AvgNum_of_deliveries_per_ind

FROM
--SECTION ONE
--This first section addresses:
--	The account ID number and Company Name of every active account in region 3 of Italy.
--	The count of active individuals listed in the database by office size and account.

		(
            SELECT dc.acc_id_number as aid_s1
                , dc.company_name
                , di.office_size
                , count(
			    case
	                        when di.active='1'
	                            then di.id
	                                else null
	                                    end
                        )

            FROM dimension_company as dc

            INNER JOIN dimension_individual as di
                on di.acc_id=dc.id

            WHERE dc.region_id = 'italy3'
                and dc.active = '1'

            GROUP BY dc.acc_id_number
                , dc.company_name
                , di.office_size

            ORDER BY dc.acc_id_number
        )
        as QUERY1

LEFT JOIN
--SECTION TWO
--This section addresses:
--	The count of individuals who were delivered at least one cake or pie between 7/1/2016 and 2/10/2017 by account and office size.

		(
	            (
					SELECT dc.acc_id_number as aid_s2
					, dc.company_name

				FROM dimension_individual as di

				INNER JOIN dimension_company as dc
					on di.acc_id=dc.id

				WHERE dc.region_id = 'italy3'
					and dc.active = '1'

				GROUP BY dc.acc_id_number
					, dc.company_name

				ORDER BY dc.acc_id_number
			)
	    		as main_query

	    		LEFT JOIN

	    		(
				SELECT dc.acc_id_number
		    		, count(distinct(di.individual_id)) as num_individuals_with_cake_delivered

		    		FROM fact_individual_cake_delivered as ficd

		    		INNER JOIN dimension_individual as di
		    		on ficd.individual_id = di.individual_id

		    		INNER JOIN dimension_company as dc
		    		on di.acc_id=dc.id

		    		WHERE
		    		ficd.status = '2'
		    		and (ficd.order_time > '2016-07-01 00:00:00'
		    		and ficd.delivery_time < '2017-02-10 23:59:59')

		    		GROUP BY dc.acc_id_number
	    		)
	    		as subquery_C
	    		on main_query.aid_s2 = subquery_C.acc_id_number

			LEFT JOIN

	    		(
				SELECT dc.acc_id_number
		    		, count(distinct(di.individual_id)) as num_individuals_with_pie_delivered

		    		FROM fact_individual_pie_delivered as fipd

		    		INNER JOIN dimension_individual as di
		    		on fipd.individual_id = di.individual_id

		    		INNER JOIN dimension_company as dc
		    		on di.acc_id=dc.id

		    		WHERE
		    		fipd.status = '2'
		    		and (fipd.order_time > '2016-07-01 00:00:00'
		    		and fipd.delivery_time < '2017-02-10 23:59:59')


		    		GROUP BY dc.acc_id_number
	    		)
				as subquery_E
				on main_query.aid_s2 = subquery_E.acc_id_number
			)
    		as QUERY2
    		on QUERY1.aid_s1 = QUERY2.aid_s2

LEFT JOIN
--SECTION THREE
--This section address:
--	The average number of deliveries in the same time period per individual with at least one cake order in that time period, by
--		company and office size.

	       (
		    	SELECT acc_id_number as aid_s3
	                , avg(deliveries)


	            FROM
					(

	                SELECT dc.acc_id_number
	                    , ficd.individual_id
	                    , count(*) as deliveries

	                FROM fact_individual_cake_delivered as ficd

	                INNER JOIN dimension_individual as di
	                    on di.id = ficd.individual_id

	                INNER JOIN dimension_company as dc
	                    on dc.id = di.acc_id

	            	WHERE
	            	    ficd.status = '2'
		    		and (ficd.order_time > '2016-07-01 00:00:00'
		    		and ficd.delivery_time < '2017-02-10 23:59:59')

	            	GROUP BY dc.acc_id_number
	            	        , ficd.individual_id

	            	)
					as myquery

	            WHERE upper(acc_id_number) like 'ITALY3%'

	            GROUP BY acc_id_number
            )
            as QUERY3
            on QUERY1.aid_s1 = QUERY3.aid_s3




ORDER BY aid_s1
		, office_size
