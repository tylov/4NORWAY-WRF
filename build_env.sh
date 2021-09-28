# WRF Build environments for Betzy
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export NETCDF=/cluster/software/netCDF-Fortran/4.4.3-intel-2016a
export WRFIO_NCD_LARGE_FILE_SUPPORT=1

module load netCDF-Fortran/4.5.3-iompi-2020b
module load netCDF/4.7.4-iompi-2020b
module load HDF5/1.10.7-iompi-2020b

# explicitly defines which model core to build
export WRF_EM_CORE=1

export NETCDF=/cluster/software/netCDF-Fortran/4.5.3-iompi-2020b
export HDF5=/cluster/software/HDF5/1.10.7-iompi-2020b


#export WRF_NMM_CORE=0
#       explicitly defines which model core NOT to build

#export WRF_DA_CORE=0
#       explicitly defines no data assimilation

#export NETCDF_classic=1
#export NETCDF=/cluster/software/netCDF/4.7.4-iompi-2020b
#       all of the WRF components want both the lib and the include directories

#export JASPERLIB=/usr/lib64
#export JASPERINC=

#export OMP_NUM_THREADS=1000
#       if you have OpenMP on your system, this is how to specify the number of threads
#
#export MP_STACK_SIZE 64000000
