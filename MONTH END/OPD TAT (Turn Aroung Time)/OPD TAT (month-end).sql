SELECT
	DATENAME(MONTH, created_date_time) AS month,
	queue_number,
	name,
	queue_tag,
	CONVERT(VARCHAR(10), created_date_time, 101) AS created_date,
	CONVERT(VARCHAR(15), CAST(created_date_time AS TIME), 100) AS created_time,
	CONVERT(VARCHAR(10), modified_date_time, 101) AS modified_date,
	CONVERT(VARCHAR(15), CAST(modified_date_time AS TIME), 100) AS modified_time,
	DATEDIFF(MINUTE, created_date_time, modified_date_time) AS turn_around_time_in_minutes,
	CAST(DATEDIFF(MINUTE, created_date_time, modified_date_time) / 60.00 AS NUMERIC(4, 2)) AS turn_around_time_in_hours
FROM queue.entry_history
WHERE name IS NOT NULL
AND (
MONTH(created_date_time) = @Month
AND YEAR(created_date_time) = @Year
)
AND queue_tag <> 'Admission'
AND queue_number NOT IN ('R100', 'R099', 'R096')
ORDER BY MONTH(created_date_time) ASC,
name,
created_date_time