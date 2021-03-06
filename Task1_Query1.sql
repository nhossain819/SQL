--TASK 1
--Create a single table that contains:
--  	The account_id_number and name of every active account in region 3 of Italy.
--  	The numbers of cake and pie customers for each company account.
--  	The count of active individuals listed for each company account.
--  	The count of individuals who ordered at least one cake or pie between 7/12/2016 and 2/25/2018.


--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--QUERY FOR TASK 1
SELECT *

FROM
			(SELECT dc.account_id_number
				, dc.company_name
				, dc.total_cake_orders
				, dc.total_pie_orders
				, count(distinct(di.individual_id) as Num_Act_Individuals

			FROM dimension_company as dc

			LEFT JOIN dimension_individual as di
				on di.account_id=dc.id

			WHERE dc.region_id ='italy3'
				and dc.active = '1'

			GROUP BY dc.account_id_number
				, dc.company_name
				, dc.total_cake_orders
				, dc.total_pie_orders

			ORDER BY dc.account_id_number
			)
		as main_query

LEFT JOIN
			(SELECT dc.account_id_number
					,count(distinct(di.individual_id)) as Num_Cakes_Delivered

			FROM fact_individual_cake_delivered as ficd

			INNER JOIN dimension_individual as ds
				on ficd.individual_id = di.individual_id

			INNER JOIN dimension_company as da
				on di.account_id=dc.id

			WHERE
				ficd.status = '2'
				and (ficd.delivery_time > '2016-07-12 00:00:00'
					and ficd.delivery_time < '2018-02-25 23:59:59')

			GROUP BY dc.account_id_number
			)
		as subquery_C
		on main_query.account_id_number = subquery_C.account_id_number

LEFT JOIN
			(SELECT dc.account_id_number
					, count(distinct(di.individual_id)) as count_pies_delivered

			FROM fact_individual_pie_delivered as fipd

			INNER JOIN dimension_individual as ds
				on fipd.individual_id = di.individual_id

			INNER JOIN dimension_company as da
				on di.account_id=dc.id

			WHERE
				fipd.status = '2'
				and (fipd.delivery_time > '2016-07-12 00:00:00'
					and fipd.delivery_time < '2018-02-25 23:59:59')

			GROUP BY dc.account_id_number
			)
		as subquery_P
		on main_query.account_id_number = subquery_P.account_id_number
