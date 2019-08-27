#!/bin/bash

for WORKER_NUM in {1..2}
   do

   echo "worker number: $WORKER_NUM"
   export WORKER_NUM

   # Run Matlab under the 'no hangup' option (it will run in the background with no
   # active terminal window). Do not start the desktop or 'splash'
   # screen. Use the 'r' option, which will feed
   # all of the text in quotes to Matlab. Pass WORKER_NUM into Matlab as 'worker'.
   # Change directory to that containing the script. Run the script. Output to a text file.
   # Finally, use the '&' option at the end of 'nohup' to allow each instance of 
   # nohup within the for loop to be independent. I.e., each nohup will be 
   # placed in the background immediately and the for loop will continue, as 
   # opposed to waiting for the first nohup instance to complete.

   nohup /Applications/MATLAB_R2015b.app/bin/matlab -nodesktop -nosplash -r \
   "worker=$WORKER_NUM;\
   cd home_directory;\
   MJO_animator_video" > \
   "MJO_animator_video_$WORKER_NUM.txt" &

done
