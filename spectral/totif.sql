USE airs;
SELECT 
    lat, lon, spect,
    CASE WHEN d == date_sub('${hiveconf:date}', 1) THEN 0
         WHEN d == '${hiveconf:date}' THEN 1
         WHEN d == date_add('${hiveconf:date}', 1) THEN 2 END AS ddate
FROM spectral
WHERE d BETWEEN date_sub('${hiveconf:date}', 1) AND date_add('${hiveconf:date}', 1) AND
    lat BETWEEN 20 AND 42 AND
    lon BETWEEN -105 AND -85
;