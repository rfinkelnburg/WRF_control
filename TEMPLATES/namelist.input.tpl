&time_control
 run_days                            = 31, 
 run_hours                           = 0, 
 run_minutes                         = 0, 
 run_seconds                         = 0, 
 start_year                          = 2007,
 start_month                         = 09,
 start_day                           = 01,
 start_hour                          = 00,
 start_minute                        = 00,
 start_second                        = 00,
 end_year                            = 2008,
 end_month                           = 09,
 end_day                             = 01,
 end_hour                            = 00,
 end_minute                          = 00,
 end_second                          = 00,
 interval_seconds                    = 3600, 
 input_from_file                     = .true.,
 fine_input_stream                   = 0,
 history_interval                    = 60,
 frames_per_outfile                  = 24,
 restart                             = .false., 
 restart_interval                    = 1440, 
 io_form_history                     = 2, 
 io_form_restart                     = 2, 
 io_form_input                       = 2, 
 io_form_boundary                    = 2, 
 io_form_auxinput4                   = 2,
 auxinput4_interval		     = 60, 
 debug_level                         = 0, 
 auxinput1_inname                    = "met_em.d<domain>.<date>", 
 auxinput4_inname                    = "wrflowinp_d<domain>",
 adjust_output_times                 = .true.,
/

&domains
 time_step                           = 0, 
 time_step_fract_num                 = 60, 
 time_step_fract_den                 = 100, 
 max_dom                             = 1, 
 e_we                                = 49,
 e_sn                                = 77,
 e_vert                              = 28,
 use_levels_below_ground             = .false., ! Don't use levels below input surface level for vertical interpolation
 dx                                  = 350.,
 dy                                  = 350.,
 num_metgrid_levels                  = 27, 
 grid_id                             = 1,
 parent_id                           = 0,
 i_parent_start                      = 1,
 j_parent_start                      = 1,
 parent_grid_ratio                   = 1,
 parent_time_step_ratio              = 1,
 feedback                            = 0, ! feedback to parent domain 
 smooth_option                       = 0, ! smoothing of parent domain in nesting domain region
 s_we                                = 1,
 s_sn                                = 1,
 s_vert                              = 1,
 p_top_requested                     = 10000, ! pressure top used in the model
 force_sfc_in_vinterp                = 1, ! use surface data as lower boundary vor vertical interpolation
 interp_type                         = 2, ! vertical interpolation; 1: linear in pressure; 2: linear in log(pressure)
 extrap_type                         = 2, ! vertical extrap. of non-temp. variables. 1: use the two lowest levels; 2: use lowest level as constant below ground
 sfcp_to_sfcp                        = .true., ! compute model's surface pressure when incoming data only has surface pressure and terrain, but not SLP
 use_surface                         = .true., ! use surface data in vertical interpolation; true: use input surface data; false: don't use surface data
 use_adaptive_time_step              = .true., 
 step_to_output_time                 = .true.,
 target_cfl                          = 1.2,
 max_step_increase_pct               = 51,
 starting_time_step                  = 2,
 max_time_step                       = 6,
 min_time_step                       = 1,
 adaptation_domain                   = 1,
/

&physics
 mp_physics                          = 6, !=WSM6
 ra_lw_physics                       = 1, !=RRTM
 ra_sw_physics                       = 2, !=Goddard
 radt                                = 15, !=every 15 min
 sf_sfclay_physics                   = 2, !=Monin-Obukhov (Janjic Eta) scheme
 sf_surface_physics                  = 2, !=Noah land-surface model
 bl_pbl_physics                      = 2, !=Mellor-Yamada-Janjic (Eta) TKE scheme
 bldt                                = 0, !every iteration
 cu_physics                          = 0, !no cumulus
 cudt                                = 0, 
 fractional_seaice                   = 1, ! treat seaice as fractional field (1) or ice/no ice flag (0)
 seaice_threshold                    = 0.0, ! Don't use with fractional_seaice -> off = 0.0 
 seaice_albedo_opt	             = 1, ! option to set albedo over sea ice; constant seaice albedo (0), seaice albedo function (T,TSK,SNOW) (1), use input variable (2)
 sst_update                          = 1, ! 
 usemonalb			     = .true.,
 isfflx                              = 1, 
 ifsnow                              = 0,
 icloud                              = 1, 
 surface_input_source                = 1, 
 num_soil_layers                     = 4, 
 mp_zero_out                         = 0, 
 maxiens                             = 1, 
 maxens                              = 3, 
 maxens2                             = 3, 
 maxens3                             = 16, 
 ensdim                              = 144, 
/

&fdda
 grid_fdda                           = 1,
 gfdda_inname                        = "wrffdda_d<domain>",
 io_form_gfdda                       = 2,
 gfdda_interval_m                    = 60,
 gfdda_end_h                         = 11688,
 fgdt 				     = 0,
 fgdtzero                            = 0,
 if_no_pbl_nudging_q                 = 1, 
 if_no_pbl_nudging_uv                = 1,
 if_no_pbl_nudging_t                 = 1,
 if_no_pbl_nudging_ph                = 1,
 guv                                 = 0.0003,
 gt                                  = 0.0003,
 gph                                 = 0.0003,
 xwavenum                            = 6,
 ywavenum                            = 12,
 if_ramping                          = 0,
 dtramp_min 			     = 60.0
/

&dynamics
 rk_ord                              = 3, 
 w_damping                           = 1, 
 diff_opt                            = 1, 
 km_opt                              = 1, 
 base_temp                           = 268., 
 damp_opt                            = 3,
 zdamp                               = 17000.,
 dampcoef                            = 1.0,
 khdif                               = 0,
 kvdif                               = 0,
 smdiv                               = 0.1,
 emdiv                               = 0.01,
 epssm                               = 0.5,
 time_step_sound                     = 8,
 non_hydrostatic                     = .true.,
 h_mom_adv_order                     = 5,
 v_mom_adv_order                     = 3,
 h_sca_adv_order                     = 5,
 v_sca_adv_order                     = 3,
 moist_adv_opt                       = 1,
 scalar_adv_opt                      = 1,
 use_input_w                         = .true.,     ! whether to use vertical velocity from input file
/

&bdy_control
 spec_bdy_width                      = 9,
 spec_zone                           = 1,
 relax_zone                          = 8,
 spec_exp                            = 0.33, 
 specified                           = .true.,
 periodic_x                          = .false.,
 symmetric_xs                        = .false.,
 symmetric_xe                        = .false.,
 open_xs                             = .false.,
 open_xe                             = .false.,
 periodic_y                          = .false.,
 symmetric_ys                        = .false.,
 symmetric_ye                        = .false.,
 open_ys                             = .false.,
 open_ye                             = .false.,
 nested                              = .false.,
/


&grib2
/

&namelist_quilt
 nio_tasks_per_group                 = 0, 
 nio_groups                          = 1, 
/
