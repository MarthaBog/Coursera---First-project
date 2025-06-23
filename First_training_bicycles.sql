# First step
## Connecting two data sets

SELECT 
  a.started_at,
  a.ended_at,
  a.usertype,
  a.trip_length,
  a.weekday,
  b.trip_length AS trip_length_2020
FROM
  `train1-462510.Bycicles_project.bicycles19` AS a
LEFT JOIN
  `train1-462510.Bycicles_project.bicycles20` AS b
ON
  a.started_at = b.started_at
  AND a.ended_at = b.ended_at
  AND a.usertype = b.usertype
  AND a.trip_length = b.trip_length
  AND a.weekday = b.weekday


# Second step
## Count max,min and meand of length

WITH joined_data AS (
  SELECT 
    a.started_at,
    a.ended_at,
    a.usertype,
    a.trip_length,
    a.weekday,
    b.trip_length AS trip_length_2020
  FROM
    `train1-462510.Bycicles_project.bicycles19` AS a
  LEFT JOIN
    `train1-462510.Bycicles_project.bicycles20` AS b
  ON
    a.started_at = b.started_at
    AND a.ended_at = b.ended_at
    AND a.usertype = b.usertype
    AND a.trip_length = b.trip_length
    AND a.weekday = b.weekday
)

## Bigquery doesnt recognize trip_length as numbers, but as string, so i need to split a string into the format
## ['HH','MM','SS']. After that extract hours, minutes and seconds by OFFSET and final result devide on 3600 to get answer in hours.

SELECT
  MAX(hours * 3600 + minutes * 60 + seconds) / 3600 AS max_trip_length_hours,
  MIN(hours * 3600 + minutes * 60 + seconds) / 3600 AS min_trip_length_hours,
  AVG(hours * 3600 + minutes * 60 + seconds) / 3600 AS avg_trip_length_hours
FROM (
  SELECT
    SAFE_CAST(SPLIT(trip_length, ':')[OFFSET(0)] AS INT64) AS hours,
    SAFE_CAST(SPLIT(trip_length, ':')[OFFSET(1)] AS INT64) AS minutes,
    SAFE_CAST(SPLIT(trip_length, ':')[OFFSET(2)] AS INT64) AS seconds
  FROM joined_data
);

# Third step
## Customers type

WITH joined_data AS (
  SELECT 
    a.started_at,
    a.ended_at,
    a.usertype,
    a.trip_length,
    a.weekday,
    b.trip_length AS trip_length_2020
  FROM
    `train1-462510.Bycicles_project.bicycles19` AS a
  LEFT JOIN
    `train1-462510.Bycicles_project.bicycles20` AS b
  ON
    a.started_at = b.started_at
    AND a.ended_at = b.ended_at
    AND a.usertype = b.usertype
    AND a.trip_length = b.trip_length
    AND a.weekday = b.weekday
)

SELECT
  usertype,
  COUNT(*) AS usertype_count
FROM joined_data
GROUP BY usertype
ORDER BY usertype;

# Fourth step
## Customers type

WITH joined_data AS (
  SELECT 
    a.started_at,
    a.ended_at,
    a.usertype,
    a.trip_length,
    a.weekday,
    b.trip_length AS trip_length_2020
  FROM
    `train1-462510.Bycicles_project.bicycles19` AS a
  LEFT JOIN
    `train1-462510.Bycicles_project.bicycles20` AS b
  ON
    a.started_at = b.started_at
    AND a.ended_at = b.ended_at
    AND a.usertype = b.usertype
    AND a.trip_length = b.trip_length
    AND a.weekday = b.weekday
)

SELECT
  usertype,
  COUNT(*) AS usertype_count
FROM joined_data
GROUP BY usertype
ORDER BY usertype;

# Fifth step
# Investigate statistics and trends by year
## Firstly i will seperatly write code for each year. I want to know average trip length by usertype in both tables, average weekday by usertype in both tables, average start time by usertype in both tables

WITH joined_data AS (
  SELECT 
    started_at,
    ended_at,
    usertype,
    SAFE_CAST(SPLIT(trip_length, ':')[OFFSET(0)] AS INT64) * 3600 +
    SAFE_CAST(SPLIT(trip_length, ':')[OFFSET(1)] AS INT64) * 60 +
    SAFE_CAST(SPLIT(trip_length, ':')[OFFSET(2)] AS INT64) AS trip_seconds,
    EXTRACT(DAYOFWEEK FROM started_at) AS weekday_num,
    EXTRACT(HOUR FROM started_at) AS start_hour,
    2019 AS year
  FROM `train1-462510.Bycicles_project.bicycles19`

  UNION ALL

  SELECT 
    started_at,
    ended_at,
    usertype,
    SAFE_CAST(SPLIT(trip_length, ':')[OFFSET(0)] AS INT64) * 3600 +
    SAFE_CAST(SPLIT(trip_length, ':')[OFFSET(1)] AS INT64) * 60 +
    SAFE_CAST(SPLIT(trip_length, ':')[OFFSET(2)] AS INT64) AS trip_seconds,
    EXTRACT(DAYOFWEEK FROM started_at) AS weekday_num,
    EXTRACT(HOUR FROM started_at) AS start_hour,
    2020 AS year
  FROM `train1-462510.Bycicles_project.bicycles20`
)

SELECT
  usertype,
  AVG(trip_seconds) / 3600 AS avg_trip_length_hours,
  AVG(weekday_num) AS avg_weekday,
  AVG(start_hour) AS avg_start_hour
FROM joined_data
GROUP BY usertype;

# Fifth step
# Investigate statistics and trends both years

WITH joined_data AS (
  SELECT 
    started_at,
    ended_at,
    CASE 
      WHEN LOWER(usertype) IN ('customer', 'casual') THEN 'casual'
      WHEN LOWER(usertype) IN ('subscriber', 'member') THEN 'member'
      ELSE usertype
    END AS usertype,
    
    SAFE_CAST(SPLIT(trip_length, ':')[OFFSET(0)] AS INT64) * 3600 +
    SAFE_CAST(SPLIT(trip_length, ':')[OFFSET(1)] AS INT64) * 60 +
    SAFE_CAST(SPLIT(trip_length, ':')[OFFSET(2)] AS INT64) AS trip_seconds,

    EXTRACT(DAYOFWEEK FROM started_at) AS weekday_num,
    EXTRACT(HOUR FROM started_at) AS start_hour
  FROM `train1-462510.Bycicles_project.bicycles19`

  UNION ALL

  SELECT 
    started_at,
    ended_at,
    CASE 
      WHEN LOWER(usertype) IN ('customer', 'casual') THEN 'casual'
      WHEN LOWER(usertype) IN ('subscriber', 'member') THEN 'member'
      ELSE usertype
    END AS usertype,

    SAFE_CAST(SPLIT(trip_length, ':')[OFFSET(0)] AS INT64) * 3600 +
    SAFE_CAST(SPLIT(trip_length, ':')[OFFSET(1)] AS INT64) * 60 +
    SAFE_CAST(SPLIT(trip_length, ':')[OFFSET(2)] AS INT64) AS trip_seconds,

    EXTRACT(DAYOFWEEK FROM started_at) AS weekday_num,
    EXTRACT(HOUR FROM started_at) AS start_hour
  FROM `train1-462510.Bycicles_project.bicycles20`
)

SELECT
  usertype,
  AVG(trip_seconds) / 3600 AS avg_trip_length_hours,
  AVG(weekday_num) AS avg_weekday,
  AVG(start_hour) AS avg_start_hour
FROM joined_data
GROUP BY usertype;

# Answers in decimal, that means i need to calculate them into hours, for example - member start hour is 13.20802. It means 0.208 * 60 = 12.48 ≈ 12 minutes - Total 1,12pm