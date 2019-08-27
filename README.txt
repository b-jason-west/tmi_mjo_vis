This describes the workflow for the TMI_MJO_visualization project. 
This was a project written by B. Jason West (b.jason.west@colorado.edu)
while he was a graduate student in Atmospheric and Oceanic Sciences
at the University of Colorado Boulder. The goal was to design and 
implement a high-resolution, high-frame-rate, clarity-optimized
data visualization of the Madden-Julian Oscillation (MJO) and Monsoon
Intraseasonal Oscillation (MISO), which are the dominant modes of
intraseasonal (20-90-day) variability in Earth's climate system. The
MJO and MISO strongly affect precipitation in the tropics that leads
to floods and droughts, which affect the livelihoods of millions of
people. Final results can be seen here: http://bjasonwest.com

This project utilizes rainfall and sea surface temperature data from
Remote Sensing Systems, Inc. (www.remss.com), which were originally
based on data from NASA's Goddard Space Flight Center, from the 
Tropical Rainfall Measuring Mission (TRMM) Microwave Imager (TMI)
instrument. The data from REMSS are Level-3 gridded data, which this
project then processes to isolate the MJO and MISO signals based on
nearly the entire 17-year operational lifetime of TRMM.

The code is organized into 5 sections. Sections 1-3 were run on 
a 16-node compute server running RedHat 4 with the TORQUE/PBS
resource manager. The *master.bash scripts are designed to be called
from the command line. The *master script submits jobs to TORQUE/PBS, 
which then call the *job.bash scripts, which in turn run the *.m Matlab
scripts. Sections 4-5 were run on a personal computer running Mac OSX,
and only include the *job.bash and *.m scripts. The *job.bash scripts
can be run from the Mac OSX terminal. Here is an overview of the 
functionality of each section:

Section 1: 
   TMI_nc_to_mat_master.bash
   TMI_nc_to_mat_job.bash
   TMI_nc_to_mat.m

   These files access the REMSS ftp server, download the Level 3 precip.
   and SST data, and save them to .mat format. The server directory must
   be specified for each file above.

Section 2: 
   TMI_preprocessor_master.bash
   TMI_preprocessor_job.bash
   TMI_preprocessor.m
 
   These files load the .mat files from Section 1 and apply a series of
   processing steps to isolate the intraseasonal signal. 

Section 3:
   TMI_composite_master.bash
   TMI_composite_job.bash
   TMI_composite.m

   These files load the processed .mat files from Section 3 along  
   with the RMM MJO Index from the Australia Bureau of Meteorology
   to generate a series of MJO/MISO composites for each of the 8 phases.
   The 8 phases are then interpolated to 576 frames.

Section 4:
   Plotter_Rain_SST_job.bash
   Plotter_Rain_SST.m

   These files are run on a local machine once the output of Section 3
   is downloaded. This is where the plotting and image rendering is
   accomplished.

Section 5:
   MJO_animator_video_job.bash
   MJO_animator_video.m
 
   These scripts load the PNG images generated in Section 4 and encode
   them to mp4 format for smooth playback.
