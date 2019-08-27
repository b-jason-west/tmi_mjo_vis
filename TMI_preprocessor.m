% This script loads raw SST and precipitation (rainfall) data that were
% previously saved in .mat format in two longitude-demarcated subdomains
% by TMI_nc_to_mat.m. The climatological mean, linear trend, and 
% seasonal cycle are removed. Then, a Lanczos digital bandpass filter
% is applied with a 20-90-day passband to isolate the intraseasonal
% signal.
% This script is designed to be run with 32 workers at a time, each utilizing one
% core. It needs to be run separately for precip. (rainfall) and SST, accomplished
% by commenting/uncommenting the load commands below.
   close; clc;
   clearvars -except worker;
   % parpool(2);
   addpath('Functions');
   server_directory = [' ']; % Set working directory.
   disp( 'Loading file...' );

   if     worker <= 16
         %% Uncomment/comment below to switch from SST to Rainfall data:
         % load( [ server_directory , '/TMI_raw/TMI_SST_d3d_1998_2014_domain_1.mat'  ] , ...
         %       'TMI_SST_1' , 'dates' );
         % DATA_RAW            = TMI_SST_1;   clear TMI_SST_1;

         load( [ server_directory , '/TMI_raw/TMI_Rain_d3d_1998_2014_domain_1.mat'  ] , ...
               'TMI_Rain_1' , 'dates' );
         DATA_RAW            = TMI_Rain_1;   clear TMI_Rain_1;

         bad_indices         = find( DATA_RAW < -2.9 );
         DATA_RAW( bad_indices ) = NaN;
         DATA_long           = [   0.125 : 0.25 : 179.875 ];
         long_i1             = 1 + (worker-1) * 45
         long_i2             = long_i1 + 44
         DATA_long           = DATA_long(   long_i1 : long_i2    );
         DATA_RAW            = DATA_RAW( : , long_i1 : long_i2 , : );

   elseif  worker <= 32
         %% Uncomment/comment below to switch from SST to Rainfall data:
         % load( [ server_directory , '/TMI_raw/TMI_SST_d3d_1998_2014_domain_2.mat'  ] , ...
         %       'TMI_SST_2' , 'dates' );
         % DATA_RAW            = TMI_SST_2;   clear TMI_SST_2; 

         load( [ server_directory , '/TMI_raw/TMI_Rain_d3d_1998_2014_domain_2.mat'  ] , ...
               'TMI_Rain_2' , 'dates' );
         DATA_RAW            = TMI_Rain_2;   clear TMI_Rain_2; 

         bad_indices          = find( DATA_RAW < -2.9 );
         DATA_RAW( bad_indices ) = NaN;
         DATA_long            = [ 180.125 : 0.25 : 359.875 ]; 
         long_i1             = 1 + (worker-17) * 45
         long_i2             = long_i1 + 44
         DATA_long            = DATA_long(   long_i1 : long_i2    );
         DATA_RAW            = DATA_RAW( : , long_i1 : long_i2 , : );        

   end
         DATA_lat   = [ -40.125 : 0.25 :  39.875 ];
         DATA_dates = dates;  clear dates;

% Restrict dates, if necessary:
   date1      = datenum(     1998 , 01 , 01        );
   date2      = datenum(     2014 , 12 , 31        );
   date1i     = find(       DATA_dates == date1    );
   date2i     = find(       DATA_dates == date2    );
   DATA_RAW   = DATA_RAW(    : , : , date1i : date2i );
   DATA_RAW   = permute(     DATA_RAW , [2 1 3]     );
   DATA_dates  = DATA_dates(   date1i : date2i       );

   [ DATA_year , DATA_month , DATA_day ] = datevec( DATA_dates );

% Use 'detrend' to remove the trend and mean simultaneously:
   for i = 1 : length( DATA_long )
      clc;
      disp( 'Removing the period mean and trend...' );
      disp( [ 'Longitude index ' , num2str(i) , '/' , num2str( length( DATA_long ) ) ] );
      for j = 1 : length( DATA_lat )     
         temp_vector = reshape( DATA_RAW( i , j , : ) , [ length(DATA_dates) , 1 ] );
         temp_detrend = detrend_NaN( temp_vector );
         DATA_detrended( i , j , : ) = temp_detrend;   
      end
   end
   clearvars DATA_RAW;

% Remove the seasonal cycle:
   % Compute monthly means:
   for month_num = 1 : 12
      clc;
      disp( 'Computing monthly means...' );
      disp( [ 'Month ' , num2str( month_num ) , '/12' ] );
      month_indices = find( DATA_month == month_num );
      DATA_monthly_mean( : , : , month_num ) = nanmean( DATA_detrended( : , : , month_indices ) , 3 );
   end

   % Generate an array of approximately mid-month dates:
   for i = 1 : 12
      mid_month_day( i ) = round( eomday( 0 , i ) / 2 );
      if i == 1
      mid_month_day_cumulative( i ) = mid_month_day( i );
      else
      mid_month_day_cumulative( i ) = mid_month_day( i ) + datenum( 0 , i , 1 );
      end
   end
   clear mid_month_day;
   % adding an extra December to the beginning and
   % January to the end of the spline array in order to smooth the
   % year-to-year discontinuity:
   mid_month_day_smooth = [ -15 ...
                          mid_month_day_cumulative ...
                          365+mid_month_day_cumulative(1) ]

   % Interpolate to generate a 365-day mean array:
   for i = 1 : length( DATA_long )
      clc;
      disp( 'Applying cubic spline interpolation...' );
      disp( [ 'Longitude index ' , num2str(i) , '/' , num2str(length(DATA_long)) ] );

      for j = 1 : length( DATA_lat )
      temp_monthly_mean = reshape( DATA_monthly_mean( i , j , : ) , [ 12 , 01 ] );
         % adding an extra December to the beginning and
         % January to the end of the spline array in order to smooth the
         % year-to-year discontinuity:
         temp_monthly_mean = [ temp_monthly_mean( 12 )   ; ...
                          temp_monthly_mean       ; ...
                          temp_monthly_mean( 1 ) ];   
         try                              
            cubic_spline = spline( mid_month_day_smooth , temp_monthly_mean );
            spline_days = [ -15 : -1  1 : 365+15 ];
            DATA_daily( i , j , : ) = ppval( cubic_spline , spline_days );
         catch
            DATA_daily( i , j , : ) = NaN( 365+2*15 , 1 );
         end
      end
   end
   % Remove the extra 31 days from the end of the array:
   DATA_daily = DATA_daily( : , : , 16:365+15 );


   % Need to first generate a dates array with the number of days since the
   % beginning of the year:
   for i = 1 : length( DATA_dates )
      dates_366(i) = DATA_dates(i) - datenum( DATA_year(i) , 01 , 01 ) + 1;
   end

   % Subtract the daily means from the detrended data:
   for day_num = 1 : 366
       day_indices = find( dates_366 == day_num );
       if day_num < 366
          DATA_detrended_noseasonal( : , : , day_indices ) = bsxfun( @minus , ...
          DATA_detrended( : , : , day_indices ) , DATA_daily( : , : , day_num ) );
       else 
          DATA_detrended_noseasonal( : , : , day_indices ) = bsxfun( @minus , ...
          DATA_detrended( : , : , day_indices ) , DATA_daily( : , : , 365 ) );
       end
   end
   clearvars DATA_detrended DATA_daily;

   % Save the detrended, non-seasonal, but unfiltered anomaly, as well as the monthly and daily means:
   % (primarily for diagnostic purposes; not required)
      % save(                                           ...
      %      [ server_directory , '/TMI_processed_1/'          , ...
      %       'SSTA_TMI_1998_2014_Global_dt_domain_'           , ...
      %       num2str(worker) ]                           , ...
      %       'DATA_detrended' , 'DATA_lat' , 'DATA_long'       , ...
      %       'DATA_dates' , '-v7.3'                        ...
      %    );   

      % save(                                           ...
      %      [ server_directory , '/TMI_processed_1/'          , ...
      %       'SSTA_TMI_1998_2014_Global_dt_ds_domain_'         , ...
      %       num2str(worker) ]                           , ...
      %       'DATA_detrended_noseasonal' , 'DATA_monthly_mean'   , ...
      %       'DATA_daily' , 'DATA_lat' , 'DATA_long'          , ...
      %       'DATA_dates' , '-v7.3'                        ...
      %    );
      

% Apply the Lanczos bandpass filter:
   %% Uncomment the code below if loading detrended data after diagnostics:
   % if worker <= 4
   %    % load(                                           ...
   %    %      [ server_directory , '/TMI_processed_1/'          , ...
   %    %       'SSTA_TMI_1998_2014_Global_dt_domain_'           , ...
   %    %       num2str(worker) ]                           , ...
   %    %       'DATA_detrended' , 'DATA_lat' , 'DATA_long'       , ...
   %    %       'DATA_dates'                                ...
   %    %    );   
   %    load(                                           ...
   %         [ server_directory , '/TMI_processed_1/'          , ...
   %          'TMI_SSTA_1998_2014_Global_dt_ds_domain_'         , ...
   %          num2str(worker) ]                           , ...
   %          'DATA_detrended_noseasonal' , 'DATA_monthly_mean'   , ...
   %          'DATA_daily' , 'DATA_lat' , 'DATA_long'          , ...
   %          'DATA_dates'                                ...
   %       ); 
   % else
   %    load(                                           ...
   %         [ server_directory , '/TMI_processed_1/'          , ...
   %          'SSTA_TMI_1998_2014_Global_dt_domain_'           , ...
   %          num2str(worker) ]                           , ...
   %          'DATA_detrended' , 'DATA_lat' , 'DATA_long'       , ...
   %          'DATA_dates' , '-v7.3'                        ...
   %       );   
   %    load(                                           ...
   %         [ server_directory , '/TMI_processed_1/'          , ...
   %          'SSTA_TMI_1998_2014_Global_dt_ds_domain_'         , ...
   %          num2str(worker) ]                           , ...
   %          'DATA_detrended_noseasonal' , 'DATA_monthly_mean'   , ...
   %          'DATA_daily' , 'DATA_lat' , 'DATA_long'          , ...
   %          'DATA_dates' , '-v7.3'                        ...
   %       ); 
   % end

   for i = 1 : length( DATA_long )   
      clc;
      disp( 'Applying the Lanczos bandpass filter...' );
      disp( [ 'Longitude index ' , num2str(i) , '/' , num2str(length(DATA_long)) ] );   
      for j = 1 : length( DATA_lat )    
         DATA_timeseries       = reshape( DATA_detrended_noseasonal( i , j , : ) , ...
                                   [ 1 length( DATA_detrended_noseasonal( i , j , : ) ) ]   );   
         DATA_2090_timeseries   = lanczosfilter(   DATA_timeseries     , 1 , 1/105 , [ ] , 'high' );
         DATA_filt( i , j , : )  = lanczosfilter(   DATA_2090_timeseries , 1 , 1/020 , [ ] , 'low'  );      
      end
   end

   disp( 'Saving file...' );
   if   worker    < 10
        worker_str = [ '0' , num2str(worker) ];
   else worker_str = [      num2str(worker) ];
   end
   
   % save( [ server_directory , '/TMI_processed_1/'                      , ...
   %       'TMI_SSTA_1998_2014_Global_dt_ds_filt_020_105_domain_'           , ...
   %       worker_str ]                                          , ...
   %       'DATA_filt' , 'DATA_lat' , 'DATA_long' , 'DATA_dates' , '-v7.3' );

   save( [ server_directory , '/TMI_processed_1/'                      , ...
         'TMI_RainA_1998_2014_Global_dt_ds_filt_020_105_domain_'           , ...
         worker_str ]                                          , ...
         'DATA_filt' , 'DATA_lat' , 'DATA_long' , 'DATA_dates' , '-v7.3' );
