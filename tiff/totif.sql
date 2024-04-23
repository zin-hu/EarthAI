USE airs;
SELECT 
    lat, lon, swir2, swir, nnir, red, green, blue,
    CASE WHEN d == date_sub('${hiveconf:date}', 1) THEN 0
         WHEN d == '${hiveconf:date}' THEN 1
         WHEN d == date_add('${hiveconf:date}', 1) THEN 2 END AS ddate
FROM bands 
WHERE d BETWEEN date_sub('${hiveconf:date}', 1) AND date_add('${hiveconf:date}', 1);
