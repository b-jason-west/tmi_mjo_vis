#!/bin/bash
for WORKER_NUM in 3
   do
      echo "worker number: $WORKER_NUM"
      export WORKER_NUM
      qsub -V -l nodes=1:ppn=4 -l mem=60gb TMI_nc_to_mat_job.bash
done
