% This script accesses the REMSS ftp file server and downloads
% SST and precipitation (rainfall) data. Bad indices are removed
% and the resulting arrays are decomposed into two longitude-demarcated
% subdomains. Results are saved in .mat format. 
clc; close;
clearvars -except worker;
addpath('Functions');
server_directory = [' ']; % Set directory in which to save files.

% Define the desired dates and long./lat. ranges:
   date_1     = datenum( 1998 , 01 , 01 );
   date_2     = datenum( 2014 , 12 , 31 );
   dates      = [ date_1 : date_2 ];
   num_days   = length( dates );

% Begin the loop:
   for i = 1 : num_days
      current_date = dates( i );
      [current_year,current_month,current_day] = datevec(current_date);
      
      if current_month < 10
         month_str = [ '0' , num2str( current_month ) ];
      else month_str = [ num2str( current_month ) ];
      end
      
      if current_day < 10
         day_str = [ '0' , num2str( current_day ) ];
      else day_str = [ num2str( current_day ) ];
      end

   % Call the "read_tmi_day_v7" function from the local directory to extract the desired information:
      clc;
      ftp_filedir  = [ '/tmi/bmaps_v07.1/y' , num2str( current_year ) , '/m' , month_str , '/' ];
      ftp_filename = [ 'F12_' , num2str( current_year ) , month_str , day_str , 'v7.1_d3d.gz'  ]; 
      disp(                                              ... 
          [ 'Current date: ' , num2str( current_year  ) , char(8211) , ...
            month_str , char(8211) , day_str ]                  ...
         );
      disp( 'Extracting desired information from file...' );
      try
         [ sst , rain ] = read_tmi_averaged_v7(        ...
                          [server_directory     ,...
                           ftp_filedir,ftp_filename ] );
         % Remove data with a flag > 250 (see documentation)
            bad_indices        = find( sst  > 250 );
            sst(  bad_indices )  = NaN;
            
            bad_indices        = find( rain > 250 );
            rain( bad_indices )  = NaN;

            sst              = sst';
            rain             = rain';

         if     worker == 1
               TMI_SST_1( :,:,i)  = sst(  200 : 520 ,   1 :  720 , : );
         elseif  worker ==2
               TMI_SST_2( :,:,i)  = sst(  200 : 520 ,  721 : 1440 , : );

         elseif  worker ==3
               TMI_Rain_1(:,:,i)  = rain( 200 : 520 ,   1 :  720 , : );
         elseif  worker ==4
               TMI_Rain_2(:,:,i)  = rain( 200 : 520 ,  721 : 1440 , : );
         end

      catch
         disp( [ 'Filling current iteration with NaNs...' ] );

         if     worker == 1
               TMI_SST_1(  : , : , i ) = NaN( 321 , 720 );
         elseif  worker == 2
               TMI_SST_2(  : , : , i ) = NaN( 321 , 720 );
         elseif  worker == 3
               TMI_Rain_1( : , : , i ) = NaN( 321 , 720 );
         elseif  worker == 4
               TMI_Rain_2( : , : , i ) = NaN( 321 , 720 );
         end
         continue;
      end
   end

% Split the data domain into four equal-longitude slices and save the results:
   if worker == 1
      save([ server_directory , '/TMI_raw/' , ...
            'TMI_SST_d3d_1998_2014_domain_1.mat' ] , ...
            'TMI_SST' , 'dates' , '-v7.3'   );
   elseif worker == 2
      save([ server_directory , '/TMI_raw/' , ...
            'TMI_SST_d3d_1998_2014_domain_2.mat' ] , ...
            'TMI_SST_2' , 'dates' , '-v7.3'   );
   elseif worker == 3
      save([ server_directory , '/TMI_raw/' , ...
            'TMI_Rain_d3d_1998_2014_domain_1.mat' ] , ...
            'TMI_Rain_1' , 'dates' , '-v7.3'   );
   elseif worker == 4
      save([ server_directory , '/TMI_raw/' , ...
            'TMI_Rain_d3d_1998_2014_domain_2.mat' ] , ...
            'TMI_Rain_2' , 'dates' , '-v7.3'   );
   end
