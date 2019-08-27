% This script loads filtered SST and precipitation (rainfall) data
% and generates composites of the eight MJO phases based on the RMM
% index. The eight phases are then temporally interpolated to generate
% 576 frames of smoothly varying data.

% The user must first download the RMM index as a text file from the
% Australian Bureau of Meteorology, including the years 1998--2014.
% This file is called under "Load the RMM index" below.
close; clc;
clearvars -except worker;
addpath('Functions');
server_directory = [' '];
data_string = 'Rain';

% Load the filtered SSTA data:
   if   worker    < 10
       worker_str = [ '0' , num2str(worker) ];
   else worker_str = [      num2str(worker) ];
   end
   load( [ server_directory , 'TMI_processed_1/'                , ...
         'TMI_SSTA_2001_2012_Global_dt_ds_filt_020_105_domain_'     , ...
         worker_str , '.mat'  ]                             , ...
         'DATA_filt' , 'DATA_lat' , 'DATA_long' , 'DATA_dates' );

% Truncate the dataset to retain only the dates of interest:
   datenum1   = datenum(     1998 , 01 , 01 );
   datenum2   = datenum(     2014 , 12 , 31 );
   i1        = find( DATA_dates == datenum1 );
   i2        = find( DATA_dates == datenum2 );
   DATA_filt   = DATA_filt( : , : , i1:i2 );
   DATA_dates  = DATA_dates( i1:i2 );

   [ data_year , data_month , data_day ] = datevec( DATA_dates );
   data_month  = data_month';
   year_str1   = num2str( data_year(1)   );
   year_str2   = num2str( data_year(end) );

% Load the RMM index:
   index_raw = load( [ 'ABOM_RMM_1974_2017.txt' ] , '\t' );
   % Extract serial dates, amplitude, and phase:
     % Dates:
     dates   = datenum( index_raw(:,1) , index_raw(:,2) , index_raw(:,3) );
     i1     = find( dates == datenum1 );
     i2     = find( dates == datenum2 );
     dates   = dates( i1 : i2 );

     % Amplitude:
     amplitude = (index_raw(i1:i2,4).^2 + index_raw(i1:i2,5).^2).^0.5;

     % Phase:
     index_raw = index_raw( i1:i2 ,:,:,:,:,:);
     for i = 1 : length( dates )
     theta_abs = abs( atan( index_raw(i,5) / index_raw(i,4) ) );

     if     index_raw(i,5) < 0 && index_raw(i,4) < 0 && theta_abs  < pi/4
           phase(i) = 1;
     elseif  index_raw(i,5) < 0 && index_raw(i,4) < 0 && theta_abs >= pi/4
           phase(i) = 2;
     elseif  index_raw(i,5) < 0 && index_raw(i,4) > 0 && theta_abs  > pi/4
           phase(i) = 3;
     elseif  index_raw(i,5) < 0 && index_raw(i,4) > 0 && theta_abs <= pi/4
           phase(i) = 4;
        
     elseif  index_raw(i,5) > 0 && index_raw(i,4) > 0 && theta_abs  < pi/4
           phase(i) = 5;
     elseif  index_raw(i,5) > 0 && index_raw(i,4) > 0 && theta_abs >= pi/4
           phase(i) = 6;
     elseif  index_raw(i,5) > 0 && index_raw(i,4) < 0 && theta_abs  > pi/4
           phase(i) = 7;
     elseif  index_raw(i,5) > 0 && index_raw(i,4) < 0 && theta_abs <= pi/4
           phase(i) = 8;
     else   phase(i) = 0;
     end
       
     end
     phase = phase';

     % Clear original data:
     clear index_raw  theta_abs;

% Compute summer/winter MJO phase composites based on amplitude > 1.0
   for phase_num = 1 : 8   
      clear indices;
      indices_winter = find(  phase      == phase_num  &          ...
                        amplitude   > 1.0      &          ...
                      (  data_month  <= 4  |  data_month >= 11 ) ...
                      );
      indices_summer = find(  phase      == phase_num  &          ...
                        amplitude   > 1.0      &          ...
                      (  data_month  >= 5  &  data_month <= 10 ) ...
                      );
      DATA_composite_summer( : , : , phase_num ) = nanmean( DATA_filt( : , : , indices_summer ) , 3 );
      DATA_composite_winter( : , : , phase_num ) = nanmean( DATA_filt( : , : , indices_winter ) , 3 );   
   end

% Interpolate between, before, and after the 8 phase composite snapshots:
   phase_step_days   = 24*3;
   phase_days_full   = [ 1 : phase_step_days*(8) ];
   phase_days_cycle  = [ phase_days_full(1)-phase_days_full(end) : 1 : 0 ];
   phase_days_cycle2 = [ phase_days_cycle  phase_days_full  ...
                    phase_days_full(end)+1 : phase_days_full(end)*2 ];
   phase_days_mid   = floor( phase_step_days / 2 );
   phase_days      = [ ( phase_days_mid )                 : ...
                    phase_step_days                   : ...
                    ( phase_days_full(end)-phase_days_mid )   ...
                  ];
   phase_days_smooth = [ phase_days(1)-phase_step_days*8       : ...
                    phase_step_days                   : ...
                    phase_days(1)-phase_step_days          ...
                    phase_days                        ...
                  ];
   phase_days_smooth = [ phase_days_smooth                   ...
                    phase_days_smooth(end)+phase_step_days  : ...
                    phase_step_days                   : ...
                    phase_days_smooth(end)+phase_step_days*8  ...
                  ];

% Interpolation step:
   % Turn warning messages off (SST data processing generates many 
   % warnings because of the NaN values near coastlines.
   warning('off','all');
   for i = 1 : length( DATA_long )
      clc;
      disp( 'Applying cubic spline interpolation...' );
      disp( [ 'Longitude index ' , num2str(i) , '/' , num2str(length(DATA_long)) ] );   
      for j = 1 : length( DATA_lat )      
         temp_mean_summer = reshape( DATA_composite_summer( i , j , : ) , [ 08 , 01 ] );
         temp_mean_summer = [ temp_mean_summer ; ...
                         temp_mean_summer ; ...
                         temp_mean_summer ];
         temp_mean_winter = reshape( DATA_composite_winter( i , j , : ) , [ 08 , 01 ] );
         temp_mean_winter = [ temp_mean_winter ; ...
                         temp_mean_winter ; ...
                         temp_mean_winter ];
         try
            cubic_spline_summer              = spline( phase_days_smooth   , temp_mean_summer  );
            data_interp_summer( i , j , : )  = ppval(  cubic_spline_summer , phase_days_cycle2 );
            cubic_spline_winter              = spline( phase_days_smooth   , temp_mean_winter  );
            data_interp_winter( i , j , : )  = ppval(  cubic_spline_winter , phase_days_cycle2 );
         catch
            data_interp_summer( i , j , : )  = NaN( length( phase_days_cycle2 ) , 1 );
            data_interp_winter( i , j , : )  = NaN( length( phase_days_cycle2 ) , 1 );
         end      
      end   
   end

% Remove the extra days at the beginning and end of the array:
   index_end        = length( phase_days_cycle2 ) - 08 * phase_step_days;
   index_start      = length( phase_days_cycle2 ) - 16 * phase_step_days;
   data_interp_summer = data_interp_summer(:,:,index_start:index_end);
   data_interp_winter = data_interp_winter(:,:,index_start:index_end);

   for i = 1 : 8*phase_step_days
      phase_steps(i) = ceil( i / phase_step_days );
   end

   save([ server_directory , 'TMI_AGU_composites/full_interp/' , ...
         'TMI_' , data_string , '_'                      , ...
         year_str1 , '_' , year_str2                     , ...
         '_global_phase_composites_domain_'                , ...
         worker_str ]                                 , ...
         'data_interp_summer' , 'data_interp_winter'         , ...
         'phase_steps' , 'DATA_lat' , 'DATA_long' , '-v7.3'    );
