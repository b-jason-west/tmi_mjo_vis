#!/bin/bash

for WORKER_NUM in {1..32}
   do
     echo "worker number: $WORKER_NUM"
     export WORKER_NUM

     if   [ $WORKER_NUM -lt 5 ]
     then
       qsub -V -l nodes=compute-0-0:ppn=1 -l mem=10gb TMI_preprocessor_job.bash
     elif [ $WORKER_NUM -lt 9 ]
     then
       qsub -V -l nodes=compute-0-1:ppn=1 -l mem=10gb TMI_preprocessor_job.bash
     elif [ $WORKER_NUM -lt 13 ]
     then
       qsub -V -l nodes=compute-0-2:ppn=1 -l mem=10gb TMI_preprocessor_job.bash
     elif [ $WORKER_NUM -lt 17 ]
     then
       qsub -V -l nodes=compute-0-3:ppn=1 -l mem=10gb TMI_preprocessor_job.bash
     elif [ $WORKER_NUM -lt 21 ]
     then
       qsub -V -l nodes=compute-0-4:ppn=1 -l mem=10gb TMI_preprocessor_job.bash
     elif [ $WORKER_NUM -lt 25 ]
     then
       qsub -V -l nodes=compute-0-5:ppn=1 -l mem=10gb TMI_preprocessor_job.bash
     elif [ $WORKER_NUM -lt 29 ]
     then
       qsub -V -l nodes=compute-0-6:ppn=1 -l mem=10gb TMI_preprocessor_job.bash
     else
       qsub -V -l nodes=compute-0-9:ppn=1 -l mem=10gb TMI_preprocessor_job.bash
     fi

done
