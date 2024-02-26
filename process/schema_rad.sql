USE AIRS;
DROP TABLE IF EXISTS radiances;
CREATE TABLE IF NOT EXISTS radiances (
    stime STRING COMMENT 'shutter time',
    lat DOUBLE COMMENT 'latitude',
    lon DOUBLE COMMENT 'longitude',
    rad ARRAY<DOUBLE> COMMENT 'radiances'
)
COMMENT 'AIRS L1C Infrared radiances'
PARTITIONED BY (d STRING, granule INT)
STORED AS PARQUET 
;
