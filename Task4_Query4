--TASK 4
--Create a single table containing:
--      The account_id_number and company_name for all accounts in Germany.
--      The count of cakes and pies delivered between 2/10/2018 and 5/15/2018.
--      The minimum and maxiumum office sizes of individuals having baked goods delivered.


--XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
--QUERY FOR TASK 4
SELECT *
FROM
--QUERY1 shows The account ID number and company name for all accounts in Germany.
        (SELECT dc.acc_id_number
            , dc.company_name as account_company_name

        FROM dimension_company as dc

        WHERE dc.region_id = 'Germany'
            ) as QUERY1


LEFT JOIN
--QUERY2 The total numbers of cakes delivered between 2/10/2018 and 5/15/2018 and min and max office size.
        (SELECT dc.acc_id_number
            , count(*) as Num_Cakes_Delivered
            , min(di.office_size) as cake_Office_Size_min
            , max(di.office_size) as cake_Office_Size_max

        FROM fact_individual_cake_delivered as ficd

        INNER JOIN dimension_individual as di
            on ficd.individual_id = di.id
            and ficd.status = 2
            and (ficd.delivery_time >= '2018-02-10 00:00:00'
                and ficd.delivery_time <= '2018-05-15 23:59:59')

        INNER JOIN dimension_company as dc
            on dc.id=di.acc_id
            and dc.region_id = 'Germany'

        GROUP BY dc.acc_id_number
        ) as QUERY2
            on QUERY1.acc_id_number=QUERY2.acc_id_number


LEFT JOIN
--QUERY3 The total numbers of pie deliveries taken between 2/10/2018 and 5/15/2018 and min and max office size.
		(SELECT dc.acc_id_number
            , count(*) as Num_Pies_Delivered
            , min(di.office_size) as Pie_Office_Size_min
            , max(di.office_size) as Pie_Office_Size_max

        FROM fact_individual_pie_delivered as fipd

        INNER JOIN dimension_individual as di
            on fipd.order_year_id = di.id
            and fipd.status = 2
			and (fipd.delivery_time >= '2018-02-10 00:00:00'
            	and fipd.delivery_time <= '2018-05-15 23:59:59')

        INNER JOIN dimension_company as dc
            on dc.id=di.acc_id
            and dc.region_id = 'Germany'

        GROUP BY dc.acc_id_number
			)
		as QUERY3
		on QUERY1.acc_id_number = QUERY3.acc_id_number
