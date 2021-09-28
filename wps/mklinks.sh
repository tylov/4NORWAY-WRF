#!/bin/bash
#ln -s /cluster/projects/nn9280k/mpo100/IM_files_NorESM2MM/1984 IM
ln -s ../IM_NorESM/$1 IM
#ln -s ERAI_FIXED -> NORESM_FIXED
if [ ! -f geo_em.d01.nc ]; then
  ln -s /cluster/projects/nn9280k/pmo033/TEST_DATA/WPS/geo_em.d01.nc geo_em.d01.nc
  ln -s /cluster/projects/nn9280k/pmo033/TEST_DATA/WPS/geo_em.d02.nc geo_em.d02.nc
fi
