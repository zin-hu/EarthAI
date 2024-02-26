-- Description: Load data into Hive tables

USE AIRS;

ALTER TABLE radiances DROP PARTITION (d='${hiveconf:date}', granule=${hiveconf:granule});
ALTER TABLE radiances ADD PARTITION (d='${hiveconf:date}', granule=${hiveconf:granule});
LOAD DATA INPATH '${hiveconf:path}/airs_${hiveconf:date}_${hiveconf:granule}.parquet'
    INTO TABLE radiances
    PARTITION (d='${hiveconf:date}', granule=${hiveconf:granule});

ALTER TABLE granules DROP PARTITION (d='${hiveconf:date}');
ALTER TABLE granules ADD PARTITION (d='${hiveconf:date}');
LOAD DATA INPATH '${hiveconf:path}/airs_${hiveconf:date}_${hiveconf:granule}_attr.parquet'
    INTO TABLE granules
    PARTITION (d='${hiveconf:date}');
