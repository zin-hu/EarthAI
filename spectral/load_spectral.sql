USE AIRS;

ALTER TABLE spectral DROP PARTITION (d='${hiveconf:date}', granule=${hiveconf:granule});
ALTER TABLE spectral ADD PARTITION (d='${hiveconf:date}', granule=${hiveconf:granule});
LOAD DATA INPATH '${hiveconf:path}/airs_${hiveconf:date}_${hiveconf:granule}.txt'
    INTO TABLE spectral
    PARTITION (d='${hiveconf:date}', granule=${hiveconf:granule});
