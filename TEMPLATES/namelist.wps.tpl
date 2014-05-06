&share
 wrf_core = 'ARW',
 max_dom = 1,
 start_date = '2007-09-01_00:00:00',
 end_date   = '2008-09-01_00:00:00',
 interval_seconds = 3600
 io_form_geogrid = 2,
/

&geogrid
 parent_id         =   0,
 parent_grid_ratio =   1,
 i_parent_start    =   1,
 j_parent_start    =   1,
 e_we              =   49,
 e_sn              =   77,
 geog_data_res     = '0.03s', !!!HAS TO BE SET TOGETHER WITH OPTIONS IN ../TABLES/GEOGRID.TBL!!!
 dx        = 350.,
 dy        = 350.,
 map_proj  = 'polar',
 ref_lat   =  77.08,
 ref_lon   =  15.6,
 truelat1  =  78.5,
 truelat2  =  78.5,
 stand_lon =  20.0,
 geog_data_path = 'MY_GEODATA', !!!HAS TO BE SET!!!
 opt_geogrid_tbl_path = '.',
/

&metgrid
 fg_name = 'WRF',
 io_form_metgrid = 2,
 opt_metgrid_tbl_path = '.',
/
