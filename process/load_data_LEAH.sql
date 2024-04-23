-- Description: Load data into Hive tables

USE AIRS;

ALTER TABLE spectrals DROP PARTITION (d='${hiveconf:date}', granule=${hiveconf:granule});
ALTER TABLE spectrals ADD PARTITION (d='${hiveconf:date}', granule=${hiveconf:granule});
LOAD DATA INPATH '${hiveconf:path}/airs_${hiveconf:date}_${hiveconf:granule}.csv'
    INTO TABLE spectrals
    PARTITION (d='${hiveconf:date}', granule=${hiveconf:granule});

ALTER TABLE spectrals DROP PARTITION (d='${hiveconf:date}');
ALTER TABLE spectrals ADD PARTITION (d='${hiveconf:date}');
LOAD DATA INPATH '${hiveconf:path}/airs_${hiveconf:date}_${hiveconf:granule}_attr.csv'
    INTO TABLE granules
    PARTITION (d='${hiveconf:date}');
