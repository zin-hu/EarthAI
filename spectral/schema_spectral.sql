USE airs;
DROP TABLE IF EXISTS spectral;
CREATE TABLE spectral (
    lat FLOAT COMMENT 'Latitude of the location',
    lon FLOAT COMMENT 'Longitude of the location',
    spect INT COMMENT 'Spectral clear indicator'
)
PARTITIONED BY (d DATE, granule INT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;