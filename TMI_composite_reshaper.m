% This script reshapes the composite data generated with TMI_composite.m
% into 576 individual files in order to free memory during plotting.
close; clc;
addpath('Functions');
server_directory = [' '];

% Load the filtered SSTA data:
   % SSTA_interp_summer_full  = [];
   % SSTA_interp_winter_full  = [];
   RainA_interp_summer_full = [];
   RainA_interp_winter_full = [];

   for worker = 1 : 32
      if   worker    < 10
          worker_str = [ '0' , num2str(worker) ];
      else worker_str = [      num2str(worker) ];
      end

      % load( [ server_directory , 'TMI_AGU_composites/full_interp/' , ...
      %       'TMI_SST_1998_2014_global_phase_composites_domain_'    , ...
      %       worker_str , '.mat'  ]                                 , ...
      %       'data_interp_summer' , 'data_interp_winter'            , ...
      %       'phase_steps' );

      % SSTA_interp_summer_full = cat( 1 , SSTA_interp_summer_full , data_interp_summer );
      % SSTA_interp_winter_full = cat( 1 , SSTA_interp_winter_full , data_interp_winter );

      load( [ server_directory , 'TMI_AGU_composites/full_interp/' , ...
            'TMI_Rain_1998_2014_global_phase_composites_domain_'   , ...
            worker_str , '.mat'  ]                                 , ...
            'data_interp_summer' , 'data_interp_winter'            , ...
            'phase_steps' );

      RainA_interp_summer_full = cat( 1 , RainA_interp_summer_full , data_interp_summer );
      RainA_interp_winter_full = cat( 1 , RainA_interp_winter_full , data_interp_winter );
   end

% Save the results:
   for phase_step_num = 1 : length( phase_steps )

      if     phase_step_num < 10
            phase_str = [ '00' , num2str( phase_step_num ) ];
      elseif  phase_step_num < 100
            phase_str = [ '0'  , num2str( phase_step_num ) ];
      else
            phase_str = [      num2str( phase_step_num ) ];   
      end

      % SSTA_interp_summer_partial  = SSTA_interp_summer_full( : , : , phase_step_num );
      % SSTA_interp_winter_partial  = SSTA_interp_winter_full( : , : , phase_step_num );
      RainA_interp_summer_partial = RainA_interp_summer_full( : , : , phase_step_num );
      RainA_interp_winter_partial = RainA_interp_winter_full( : , : , phase_step_num );


      % save( [ server_directory , 'TMI_AGU_composites/full_interp/'      , ...
      %       'TMI_SSTA_1998_2014_Global_dt_ds_filt_020_105_phase_num_'   , ...
      %       phase_str , '.mat'  ]                                       , ...
      %       'SSTA_interp_summer_partial' , 'SSTA_interp_winter_partial' , ...
      %       'phase_steps' , '-v7.3' );

      save( [ server_directory , 'TMI_AGU_composites/full_interp/'        , ...
            'TMI_RainA_1998_2014_Global_dt_ds_filt_020_105_phase_num_'    , ...
            phase_str , '.mat'  ]                                         , ...
            'RainA_interp_summer_partial' , 'RainA_interp_winter_partial'  , ...
            'phase_steps' , '-v7.3' );
   end
