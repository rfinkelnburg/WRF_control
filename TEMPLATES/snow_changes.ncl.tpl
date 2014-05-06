begin
	f = addfile("wrfout_d01_2007-09-01_00:00:00", "r")
  	a=addfile("wrfinput_d01","w")

  	a->SNOW=(/f->SNOW(0:0,:,:)/) 
  	a->SNOWH=(/f->SNOWH(0:0,:,:)/) 
  	a->SNOWSI=(/f->SNOWSI(0:0,:,:)/) 
  	a->SNOWC=(/f->SNOWC(0:0,:,:)/) 
  	a->SNOALB=(/f->SNOALB(0:0,:,:)/) 

	;landmask = f->LANDMASK
end 
