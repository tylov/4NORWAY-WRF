########
# This script chooses a single year and preprocesses all NorESM output for WRF intermediate file generation (extracts variables, windows the data etc.)
# Modified by Marie April 2020 to create files from NorESM cmip6 to Reeffutures project downscaling
# Modified by Tyge.
########

########
# python modules to import
import os
import sys
import platform
########

########
##era/year 
era = "20_thc"
#name = "k0100bs070k" # directory name / file name beginning 
##era = "82k"
##name = "k0100pi082k" # directory name / file name beginning 
year_str = sys.argv[1] # skip the leading zero (it will be added by the script), avoid quotes
                       # "0"+str(year) # year string, do not change this
#outdir = "/scratch/<user>/<project>/"+year_str+"_intoNCL"  # folder in work where files are written
outdir = sys.argv[2]
#########


#######
# windowing parameters (WRF Domain: 0-50S , 0-55E)
lim_n = "50.0"
lim_s = "-5.0"
lim_w = "255.0"
lim_e = "315.0"
#########
########
#to be modified only when file locations/names change 
print("creating the directory and moving the extracted files into it...")
os.makedirs(outdir, exist_ok=True)
#dir_extr = outdir+"/"+year_str+"_intoNCL"
#os.makedirs(dir_extr, exist_ok=True)

noresm_cases = "/projects/NS9560K/noresm/cases/"
noresm_exp = "NHISTfrc2_f09_tn14_20191025"

dir_6hr_day = noresm_cases+noresm_exp+"/atm/hist/"
dir_day = dir_6hr_day
dir_month = noresm_cases+noresm_exp+"/lnd/hist/"
file_ext_6hr = noresm_exp+".cam.h3."+year_str+"-??-??-21600.nc"
file_ext_day = noresm_exp+".cam.h1."+year_str+"-??-??-00000.nc"
file_ext_month = noresm_exp+".clm2.h0."+year_str+"-??-??-00000.nc"
name_6hr_orig = file_ext_6hr
name_day_orig = file_ext_day
name_month_orig = file_ext_month
name_6hr = outdir+"/file_6hr.nc" # preprocessed 6-hr file name (user-defined)  
name_month = outdir+"/file_month.nc" # preprocessed month file name (user-defined)  

name_ta = outdir+"/atmos_ta.nc" # 3-d temp file name (user-defined)
name_ua = outdir+"/atmos_ua.nc" # 3-d u wind file name (user-defined)
name_va = outdir+"/atmos_va.nc" # 3-d v wind file name (user-defined)
name_hus = outdir+"/atmos_hus.nc" # 3-d specific humidity file name (user-defined)
name_ps = outdir+"/atmos_ps.nc" # surface pressure file name (user-defined)
name_ts = outdir+"/atmos_ts.nc" # surface temp file name (user-defined)
name_hybrid = outdir+"/hybrid.nc" # static hybrid level coefs file name (user-defined)

name_lm = outdir+"/atmos_lmask.nc" # landmask file name (user-defined)
name_sm = outdir+"/atmos_mrlsl.nc" # soil moist file name (user-defined)
name_tsl = outdir+"/atmos_tsl.nc" # soil temp file name (user-defined)
name_snw = outdir+"/atmos_snw.nc" #
name_sst = outdir+"/atmos_sst.nc"
name_sic = outdir+"/atmos_sic.nc"
#######
########
########
########

########
surf_geo_again = False #True # create surface geopot field/file (zsfc) again? normally you do not have to. uncomment below lines if this is True
########


############################
######start the work########
############################

# window_command_6hr = "ncks -d lat,"+lim_s+","+lim_n+" -d lon,"+lim_w+","+lim_e+" "+dir_6hr_day+name_6hr_orig+" "+name_6hr
# window_command_month = "ncks -d lat,"+lim_s+","+lim_n+" -d lon,"+lim_w+","+lim_e+" "+dir_month+name_month_orig+" "+name_month
# #window_command_snw = "ncks -d time,"+str(month_start)+","+str(month_end)+" -d lat,"+lim_s+","+lim_n+" -d lon,"+lim_w+","+lim_e+" "+raw_file_snw+" "+name_snw # window snow file in "time" as well, as it has all the months in the era but we want only the months of the chosen year
# neglon_command_6hr = "ncap2 -O -s 'where(lon>180) lon=lon-360' "+name_6hr+" "+name_6hr
# neglon_command_month = "ncap2 -O -s 'where(lon>180) lon=lon-360' "+name_month+" "+name_month
# #neglon_command_snw = "ncap2 -O -s 'where(lon>180) lon=lon-360' "+name_snw+" "+name_snw
# 
# print("Working on "+era+", year: "+year_str) 
# print("windowing the 6-hourly file... [CAM]")
# os.system(window_command_6hr) # window the 6hr file
# print("windowing the monthly file... [CLM]")
# os.system(window_command_month) # window the daily file
# #print("windowing the monthly snow file...")
# #os.system(window_command_snw) # window the snow file
# print("converting wrapped lons to negative lons...  the 6-hourly file.")
# os.system(neglon_command_6hr) # make wrapped lons negative, 6hr file
# print("converting wrapped lons to negative lons...  the monthly file.")
# os.system(neglon_command_month) # make wrapped lons negative, daily file
# #print("converting wrapped lons to negative lons...  the snow file.")
# #os.system(neglon_command_snw) # make wrapped lons negative, snow file

############################
#### interpolate daily files/variables to 6-hourly
#inttime=year_str+"-01-01,00:00:00"
#int_command_day = "cdo -O inttime,"+inttime+",6hour "+name_day+" "+name_day+"_int"
#rename_command = "mv "+name_day+"_int"+" "+name_day
#print("interpolating daily variables to 6 hourly...")
#os.system(int_command_day) # interpolate daily to 6-hourly
#print("renaming daily file back to original...")
#os.system(rename_command) # rename interpolated file to original
############################
############################

############################
### if we are extracting the static surface geopot field ###
############################
if surf_geo_again: 
    print("will extract static surface geopot field!")
    raw_file_zsfc = dir_6hr_day+noresm_exp+".cam.h3.1991-01-01-21600.nc" # file from which zsfc will be extracted 
    name_zsfc = outdir+"/zsfc.nc"# static surface geopot file name (user-defined)

    extract_command_zsfc = "cdo select,name=PHIS "+raw_file_zsfc+" "+name_zsfc
    print("extracting static surface geopot field...")
    os.system(extract_command_zsfc) # 
    # window_command_zsfc = "ncks -O -d lat,"+lim_s+","+lim_n+" -d lon,"+lim_w+","+lim_e+" "+name_zsfc+" "+name_zsfc
    # print("windowing static surface geopot field...")
    # os.system(window_command_zsfc) # 
    # neglon_command_zsfc = "ncap2 -O -s 'where(lon>180) lon=lon-360' "+name_zsfc+" "+name_zsfc
    # print("converting wrapped lons to negative lons, static surface geopot field...")
    # os.system(neglon_command_zsfc) # 
    avg_command_zsfc = "ncwa -O -a time "+name_zsfc+" "+name_zsfc # We should average over "time" dimension as there is just 1 time for this static field, otherwise CDO looks for the other times and issues errors.
    print("averaging over time, static surface geopot field...")
    os.system(avg_command_zsfc) # 
    set_attr_command_zsfc = 'ncatted -O -a standard_name,PHIS,c,c,"surface_geopotential" '+name_zsfc+' '+name_zsfc # In order for CDO to recognize the "surface geopotential" field, the standard_name attribute of the variable (PHIS here) should be set as "surface_geopotential"
    print("setting the standard name attribute, static surface geopot field...")
    os.system(set_attr_command_zsfc) # 
    extr_hybrid_command = "cdo -select,name=hyai,hyam,hybi,hybm,ilev "+dir_6hr_day+noresm_exp+".cam.h3.1991-01-01-21600.nc "+name_hybrid # extract surface temp
    print("extracting static hybrid level coefs into separate file...")
    os.system(extr_hybrid_command) 
else:
    print("will NOT extract static surface geopotential and static hybrid levels!")

############################
############################
##########################

#### extract the variables into separate files
extr_ta_command = "cdo -select,name=T "+dir_6hr_day+name_6hr_orig+" "+name_ta # extract 3-d temp
extr_ua_command = "cdo -select,name=U "+dir_6hr_day+name_6hr_orig+" "+name_ua # extract 3-d u wind
extr_va_command = "cdo -select,name=V "+dir_6hr_day+name_6hr_orig+" "+name_va # extract 3-d v wind
extr_hus_command = "cdo -select,name=Q "+dir_6hr_day+name_6hr_orig+" "+name_hus # extract 3-d spec hum
extr_ps_command = "cdo -select,name=PS "+dir_6hr_day+name_6hr_orig+" "+name_ps # extract surface pressure
extr_ts_command = "cdo -select,name=TS "+dir_6hr_day+name_6hr_orig+" "+name_ts # extract surface temp

extr_sic_command = "cdo -select,name=ICEFRAC "+dir_day+name_day_orig+" "+name_sic
extr_sst_command = "cdo -select,name=SST "+dir_day+name_day_orig+" "+name_sst

extr_lm_command = "cdo -select,name=landmask,landfrac "+dir_month+name_month_orig+" "+name_lm # extract landmask
extr_sm_command = "cdo -select,name=SOILICE,SOILLIQ "+dir_month+name_month_orig+" "+name_sm # extract soil moisture
extr_tsl_command = "cdo -select,name=TSOI "+dir_month+name_month_orig+" "+name_tsl # extract soil temp
extr_snw_command = "cdo -select,name=SNOWLIQ,SNOWICE "+dir_month+name_month_orig+" "+name_snw # extract snow 

print("extracting 3-d temp into separate file...")
os.system(extr_ta_command) 
print("extracting 3-d u-wind into separate file...")
os.system(extr_ua_command) 
print("extracting 3-d v-wind into separate file...")
os.system(extr_va_command) 
print("extracting 3-d specific humidity into separate file...")
os.system(extr_hus_command) 
print("extracting surface pressure into separate file...")
os.system(extr_ps_command) 
print("extracting surface temp into separate file...")
os.system(extr_ts_command) 

print("extracting landmask into separate file...")
os.system(extr_lm_command) 
print("extracting soil moisture into separate file...")
os.system(extr_sm_command) 
print("extracting soil temp into separate file...")
os.system(extr_tsl_command) 
print("extracting snow into separate file...")
os.system(extr_snw_command)
print("extracting seaice into separate file...")
os.system(extr_sic_command)
print("extracting sst into separate file...")
os.system(extr_sst_command)

#################
#print("Deleting the windowed, multi-variable CAM/CLM files...")
#os.system("rm file*.nc")
#os.system("mv "+outdir+"/atmos*.nc "+dir_extr+"/")
print("Done!")
