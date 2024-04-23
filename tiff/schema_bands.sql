USE airs;
CREATE TABLE bands (
    lat DOUBLE COMMENT 'Latitude of the location',
    lon DOUBLE COMMENT 'Longitude of the location',
    swir2 DOUBLE COMMENT 'Average spectral band value for Short-Wave Infrared 2 (index range: 400-599)',
    swir DOUBLE COMMENT 'Average spectral band value for Short-Wave Infrared (index range: 600-880)',
    nnir DOUBLE COMMENT 'Average spectral band value for Near Near-Infrared (index range: 881-900)',
    red DOUBLE COMMENT 'Average spectral band value for Red (index range: 1300-1499)',
    green DOUBLE COMMENT 'Average spectral band value for Green (index range: 1500-1761)',
    blue DOUBLE COMMENT 'Average spectral band value for Blue (index range: 1762-2200)'
)
PARTITIONED BY (d DATE);
