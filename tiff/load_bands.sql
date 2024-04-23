USE airs;

INSERT INTO TABLE bands PARTITION(d = '${hiveconf:date}')
SELECT
    a.lat,
    a.lon,
    AVG(CASE WHEN a.pos >= 400 AND a.pos < 600 THEN a.rad_element ELSE NULL END) AS swir2,
    AVG(CASE WHEN a.pos >= 600 AND a.pos < 881 THEN a.rad_element ELSE NULL END) AS swir,
    AVG(CASE WHEN a.pos >= 881 AND a.pos < 901 THEN a.rad_element ELSE NULL END) AS nnir,
    AVG(CASE WHEN a.pos >= 1300 AND a.pos < 1500 THEN a.rad_element ELSE NULL END) AS red,
    AVG(CASE WHEN a.pos >= 1500 AND a.pos < 1762 THEN a.rad_element ELSE NULL END) AS green,
    AVG(CASE WHEN a.pos >= 1762 AND a.pos <= 2200 THEN a.rad_element ELSE NULL END) AS blue
FROM (
    SELECT lat, lon, pos, rad_element
    FROM radiances
    LATERAL VIEW posexplode(rad) exploded_table AS pos, rad_element
    WHERE d = '${hiveconf:date}' AND lat BETWEEN 20 AND 42 AND lon BETWEEN -105 AND -85
) a
GROUP BY a.lat, a.lon;