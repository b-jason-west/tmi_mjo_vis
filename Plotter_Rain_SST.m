% This script contains the general workflow for generating the animations. 
   close; clc;
   clearvars -except worker;
   fig1 = figure(1);
   set(fig1,'visible','off');
   hyperwall_flag = 1;

% Specify MJO phase and day arrays for labels:
   for phase_num = 1 : 8   
     for day_num = 1 : 6      
       for frame_num = 1 : 12
         phase_string = [ 'Phase ' , num2str( phase_num ) , '/8' ];
         total_days = ( phase_num - 1 ) * 6 + day_num;
         if total_days < 10
            day_string = [ 'Day  ' , num2str( total_days ) , '/48' ];
         else
            day_string = [ 'Day ' , num2str( total_days ) , '/48' ];    
         end
         current_label = [ phase_string, ',  ' , day_string ];
         check_exist = exist('all_labels');
         if check_exist == 1
            all_labels = [ all_labels ; current_label ];
         else
            all_labels = current_label;
         end 
       end      
     end      
   end

% Pre-interpolated files:
   % for phase_step_num = [ phase_1 phase_1 : phase_2 ]
   for phase_step_num = [ 1 1 : 576 ]

      if     phase_step_num < 10
            phase_str = [ '00' , num2str( phase_step_num ) ];
      elseif  phase_step_num < 100
            phase_str = [ '0'  , num2str( phase_step_num ) ];
      else
            phase_str = [      num2str( phase_step_num ) ];   
      end

      load(                                                   ...
          [ home_directory , '/Data/full_interp/'                       , ...
            'TMI_SSTA_1998_2014_Global_dt_ds_filt_020_105_phase_num_'    , ...
            phase_str , '.mat' ]                         , ...
            'SSTA_interp_summer_partial' , 'SSTA_interp_winter_partial'   , ...
            'phase_steps'                                     ...
         );
      load(                                                   ...
          [ home_directory , '/Data/full_interp/'                       , ...
            'TMI_RainA_1998_2014_Global_dt_ds_filt_020_105_phase_num_'   , ...
            phase_str , '.mat' ]                         , ...
            'RainA_interp_summer_partial' , 'RainA_interp_winter_partial' , ...
            'phase_steps'                                      ...
         );

      if worker == 1
        SSTA_interp = SSTA_interp_winter_partial;
        RainA_interp = RainA_interp_winter_partial;
        season = 'winter';
     else
        SSTA_interp = SSTA_interp_summer_partial;
        RainA_interp = RainA_interp_summer_partial;
        season = 'summer';
     end

      clf( fig1 );
      set( fig1 , 'visible' , 'off' );
      RainA_frame = RainA_interp( : , : );    
      SSTA_frame  = SSTA_interp(  : , : );  


     % Shift all data from 180 deg. to 360 deg. (longitude) to -180 deg. to 0 deg.:
        RainA_shift = cat(  1  , RainA_frame( 721:1440 , :  )   , ...
                      RainA_frame(   1: 720 , :  )   );

        SSTA_shift   = cat(  1  , SSTA_frame(  721:1440 , :   )  , ...
                       SSTA_frame(   1: 720 , :   )  );


     % Add a column to the RainA data to account for the missing values between
     % 357.5 degrees longitude and 360 (0) degrees longitude:
        RainA_shift = cat( 1 , RainA_shift , RainA_shift( 1 , : ) );  
        SSTA_shift  = cat( 1 , SSTA_shift  , SSTA_shift(  1 , : ) );     


     % SSTA contours:
        % ColorBrewer; Diverging; 10-class; top-4 red and blue only.
         SST_cmap   =   [         ...
                215,48,39   ; ...
                244,109,67   ; ...
                253,174,97   ; ...
                254,224,144 ; ...
                        ...
                245,245,245 ; ...
                245,245,245 ; ...
                        ...
                224,243,248 ; ...
                171,217,233   ; ...
                116,173,209   ; ...
                69,117,180    ...
                ];
       % SST_cmap   =   [         ...
       %          165,0,38   ; ...
       %          215,48,39   ; ...
       %          244,109,67  ; ...
       %          253,174,97  ; ...
       %                  ...
       %          245,245,245 ; ...
       %          245,245,245 ; ...
       %                  ...
       %          171,217,233 ; ...
       %          116,173,209 ; ...
       %          69,117,180  ; ...
       %          49,54,149    ...
       %          ];

         SST_cmap   = flipud( SST_cmap ) / 255;  
        SST_inc   = 0.05;
        SST_levels   = 1 * [ -200 -0.20 -0.15 -0.10 -0.05 +0.05 +0.10 +0.15 +0.20 +200 ];
        % SST_levels   = [ -200 20 21 22 23 24 25 26 27 28 +200 ];
         [C1,H1]   = contourf(                      ...
                      [ -179.875 : 0.25 : +180.125 ] , ...
                           [ -040.125 : 0.25 : +039.875 ] , ...   
                           SSTA_shift( : , : )'        , ...
                           SST_levels                  ...
                        );           

     hold on;
     axis equal;
     caxis( [ SST_levels(2)-SST_inc  ,  SST_levels(end-1)+SST_inc ] );        
     grid on;
     set(H1,'LineStyle','none');
     colormap(SST_cmap);
     hold on;
                

   % Plot additional elements
     geoshow(   'landareas.shp' , 'FaceColor' , 0.2*[ 230/255  150/255  110/255 ] , ...
               'FaceAlpha' , 0.45 , 'LineStyle' , 'none' );
     hold on;

   % RainA contours:
     blank_color = [ 245 , 245 , 245 ];      
     % browns =   [                 ...
     %          084 , 048 , 005   ; ...
     %          140 , 081 , 010   ; ...
     %          191 , 129 , 045   ; ...
     %          223 , 194 , 125      ...
     %         ];   
     % greens =   [                 ...
     %          128 , 205 , 193   ; ...
     %          053 , 151 , 143   ; ...
     %          001 , 102 , 094   ; ...
     %          000 , 060 , 048      ...
     %         ];  
     browns =   [                 ...
              084 , 048 , 005   ; ...
              140 , 081 , 010   ; ...
              140 , 081 , 010   ; ...
              191 , 129 , 045      ...
             ];   
     greens =   [                 ...
              053 , 151 , 143   ; ...
              001 , 102 , 094   ; ...
              001 , 102 , 094   ; ...
              000 , 060 , 048      ...
             ];  
     Rain_cmap = [                ...
              browns          ; ...
               blank_color      ; ...
               blank_color      ; ...
               greens             ...
               ];
     % Rain_cmap = flipud( Rain_cmap ) / 255;  
     Rain_cmap = Rain_cmap / 255;             
     Rain_steps = 0.5 * [ -200 -0.4 -0.3 -0.2 -0.1  0.1 0.2 0.3 0.4 +200 ];

     for i = 2 : length(Rain_steps)-1
       [C,H] = contour(                    ... 
                  [ -179.875 : 0.25 : +180.125 ]  , ...
                      [ -040.125 : 0.25 : +039.875 ]  , ...   
                   RainA_shift'              , ...
                   [ Rain_steps(i) Rain_steps(i) ]   ...
                   ); 
       if   Rain_steps(i) < 0
         H.Color = Rain_cmap(i-1,:);
       else 
         H.Color = Rain_cmap(i+1,:);
       end

       if   hyperwall_flag == 0
         H.LineWidth = 0.5;
       else
         H.LineWidth = 0.5 * 2;
       end
     end
     hold on;

     % Longitude lines:
        lat_long_line_style = '--';
        lat_long_line_color = [ 0.3 * ones( 3 , 1 ) ; 0.5 ];
        if hyperwall_flag == 0
          lat_long_line_width = 0.5;
        else
          lat_long_line_width = 0.5 * 2;
        end

        for lat_i = [ -15 00 +15 ]
           line_lat = line( [-180 180] , [ lat_i  lat_i ] );
           line_lat.LineStyle = lat_long_line_style;
           line_lat.Color = lat_long_line_color;   
           line_lat.LineWidth = lat_long_line_width;
        end

        for long_i = -180 : 30 : +180
           line_long = line( [ long_i  long_i ] , [ -90 +90 ] );
           line_long.LineStyle = lat_long_line_style;
           line_long.Color = lat_long_line_color;   
           line_long.LineWidth = lat_long_line_width;
        end

      % Frame lines:
       edge_line_top          = line( [-180 +180] , [+90 +90] );
       edge_line_top.LineStyle   = '-';
       edge_line_top.LineWidth   = lat_long_line_width * 10;
       edge_line_top.Color      = 0.5 * ones(1,3);

       edge_line_bottom        = line( [-180 +180] , [-90 -90] );
       edge_line_bottom.LineStyle   = '-';
       edge_line_bottom.LineWidth   = lat_long_line_width * 10;
       edge_line_bottom.Color      = 0.5 * ones(1,3);

       % edge_line_left          = line( [-030 -030] , [-90 +90] );
       % edge_line_left.LineStyle   = '-';
       % edge_line_left.LineWidth   = lat_long_line_width * 2;
       % edge_line_left.Color      = 0.5 * ones(1,3);


     % Lat/long labels:
       if   hyperwall_flag == 0
         text_scale      = 1.00;
       else
         text_scale      = 2.00;
       end

       temp_long_labels = [ -180 : 30 : +180   ];
       temp_lat_labels  = [ -015   00   +015   ];

         % temp_long_full = [ -180 : 005 : +180 ];
         temp_long = [ -180 : 005 : +180 ];
         temp_lat_full = [ -90 : 05 : +90 ];
         temp_lat = [ -60 : 05 : +60 ];

       long_labels = [                 ...
                char(0176) , '   '    ; ...
                '150' , char(0176) , 'W' ; ...
                '120' , char(0176) , 'W' ; ...
                ' 90' , char(0176) , 'W' ; ...
                ' 60' , char(0176) , 'W' ; ...
                '    '           ; ...
                '  0' , char(0176) , 'E' ; ...
                ' 30' , char(0176) , 'E' ; ...
                ' 60' , char(0176) , 'E' ; ...
                ' 90' , char(0176) , 'E' ; ...
                '120' , char(0176) , 'E' ; ...
                '150' , char(0176) , 'E' ; ...
                '180  '            ...
                ];

       lat_labels  = [                  ...
                '15' , char(0176) , 'S'  ; ...
                'Eq. '             ; ...
                '15' , char(0176) , 'N'   ...
                ];


       for long_i = 1 : length(temp_long_labels)
         if   long_i == 1
            long_label = text(                     ...
                       temp_long_labels(long_i)-0  , ...
                       temp_lat(1)+3          , ...
                       long_labels( long_i , : )    ...
                     );
         else
            long_label = text(                     ...
                       temp_long_labels(long_i)-7.5 , ...
                       temp_lat(1)+3           , ...
                       long_labels( long_i , : )     ...
                     );
         end
         long_label.FontSize   = 12 * text_scale;
         long_label.FontWeight   = 'normal';
         long_label.Color      = 0.3 * ones(1,3);
       end

       for lat_i = 1 : 3
         lat_label = text(                   ...
                     -28              , ...
                     temp_lat_labels(lat_i)   , ...
                     lat_labels( lat_i , : )   ...
                  );
         lat_label.FontSize      = 12 * text_scale;
         lat_label.FontWeight   = 'normal';
         lat_label.Color      = 0.3 * ones(1,3);
       end

   % Legends and colorbars:
     % Draw two blank boxes where the legend will go:
       blank_color      = [ 245 245 245 ]/255;      
       bg_rect        = fill(                 ...
                       [-179.5 -120 -120 -179.5] , ...
                       [45 45 60 60]         , ...
                       blank_color          ...
                      );
       bg_rect.LineStyle   = '-';
       bg_rect.EdgeColor   = 0.5 * ones(1,3);
       bg_rect.LineWidth   = lat_long_line_width * 4;
       % bg_rect.LineWidth   = 2.5;
       bg_rect.FaceAlpha   = 1;

       bg_rect_2        = fill(             ...
                       [120 180 180 120] , ...
                       [45 45 60 60]     , ...
                       blank_color      ...
                      );
       bg_rect_2.LineStyle = '-';
       bg_rect_2.EdgeColor = 0.5 * ones(1,3);
       bg_rect_2.LineWidth   = lat_long_line_width * 4;
       bg_rect_2.FaceAlpha = 1;

       bg_rect_3        = fill(            ...
                       [060 120 120 060] , ...
                       [45 45 60 60]     , ...
                       blank_color       ...
                       );
       bg_rect_3.LineStyle = '-';
       bg_rect_3.EdgeColor = 0.5 * ones(1,3);
       bg_rect_3.LineWidth   = lat_long_line_width * 4;
       bg_rect_3.FaceAlpha = 1;

     % Create SSTA legend:
       color_bar_x = 5.5;
       levels      = Rain_steps;
       text_y      = 50.5;
       map1      = SST_cmap;

       for color_num = 1 : length( map1 )

         % Colors:
            x_start = 125-62 + color_bar_x * (color_num - 1 );
            color_rect = fill( [ x_start x_start ...
                       x_start+color_bar_x  x_start+color_bar_x ] , ...
                          [ 52.5 55 55 52.5 ] , ...
                          [ map1( color_num , : ) ] );
            color_rect.LineStyle = 'none';                 

         % Blue labels:
            if color_num == 2  |  color_num == 4 
              color_string = num2str( SST_levels( color_num ) );
              if color_num == 2  |  color_num == 3
                color_text = text( x_start-3.5 , text_y , color_string );
                else
                color_text = text( x_start-2.5 , text_y , color_string );
              end
              color_text.FontSize = 9 * text_scale;
              color_text.FontWeight = 'normal';
              color_text.Color = map1(1,:);
            end

         % Red labels:
            if color_num == 7  |  color_num == 9
              color_string = num2str( SST_levels( color_num ) );
              color_string = [ '+' , color_string ];
              if color_num == 8
                color_text = text( x_start+color_bar_x-3.5 , ...
                         text_y , color_string );
                else
                color_text = text( x_start+color_bar_x-2.5 , ...
                         text_y , color_string );
              end
              color_text.FontSize = 9 * text_scale;
              color_text.FontWeight = 'normal';
              color_text.Color = map1(end-1,:);              
            end

       end

     % SSTA title:
       color_title = text( 135.5-58, 57 , [ 'SST anomaly (K)' ] );
       color_title.FontSize = 10 * text_scale;
       color_title.FontWeight = 'normal';
       color_title.Color = 0.3 * ones(1,3);

     % SSTA labels:
       wet_label = text( 130-62 , 47.5 , [ '(cooler)' ] );
       wet_label.FontSize = 10 * text_scale;
       wet_label.FontWeight = 'normal';
       wet_label.Color = map1(1,:);


       dry_label = text( 160-60 , 47.5, [ '(warmer)' ] );
       dry_label.FontSize = 10 * text_scale;
       dry_label.FontWeight = 'normal';
       dry_label.Color = map1(end-1,:);

     % MJO phase and day:
       MJO_string = all_labels( phase_step_num , : );
       if worker == 1
         MJO_title = text( 132   , 55.5 , [ 'Nov.' , char(8211) , 'Apr. composites' ] );
         MJO_label = text( 128.5 , 49.5 , [ 'MJO ' , MJO_string ] );
       else
         MJO_title = text( 132   , 55.5 , [ 'May'  , char(8211) , 'Oct. composites' ] );
         MJO_label = text( 128.5 , 49.5 , [ 'MISO ' , MJO_string ] );
       end

       MJO_title.FontSize = 10 * text_scale;
       MJO_title.FontWeight = 'bold';
       MJO_title.Color = 0.3 * ones(1,3);

       MJO_label.FontSize = 10 * text_scale;
       MJO_label.FontWeight = 'bold';
       MJO_label.Color = 0.3 * ones(1,3);

     % Create RainA legend:
       color_bar_x = 5.5;
       levels = Rain_steps;
       text_y = 50.5;
       map1 = Rain_cmap;
       for color_num = 1 : length( map1 )

         % Colors:
            x_start = -177 + color_bar_x * (color_num - 1 );
            color_rect = fill( [ x_start x_start ...
                     x_start+color_bar_x  x_start+color_bar_x ] , ...
                        [ 52.5 55 55 52.5 ] , ...
                        [ map1( color_num , : ) ] );
            color_rect.LineStyle = 'none';                 

         % Brown labels:
            if color_num == 2 | color_num == 4
              color_string = num2str( levels( color_num ) );
              if color_num == 2  |  color_num == 3
                color_text = text( x_start-3.5 , text_y , color_string );
                else
                color_text = text( x_start-2.5 , text_y , color_string );
              end
              color_text.FontSize = 9 * text_scale;
              color_text.FontWeight = 'normal';
              color_text.Color = browns(2,:)/255;
            end

         % Green labels:
            if color_num == 7 | color_num == 9
              color_string = num2str( levels( color_num ) );
              color_string = [ '+' , color_string ];
              if color_num == 8
                color_text = text( x_start+color_bar_x-3.5 , ...
                         text_y , color_string );
                else
                color_text = text( x_start+color_bar_x-2.5 , ...
                         text_y , color_string );
              end
              color_text.FontSize = 9 * text_scale;
              color_text.FontWeight = 'normal';
              color_text.Color = greens(3,:)/255;
            end

       end

     % RainA title:
       color_title        = text( -167 , 57.5 , [ 'Rain anomaly (mm/hr)' ] );
       color_title.FontSize   = 10 * text_scale;
       color_title.FontWeight   = 'normal';
       color_title.Color      = 0.3 * ones(1,3);

     % RainA rain labels:
       wet_label          = text( -173 , 47.5 , [ '(less rain)'        ] );
       wet_label.FontSize      = 10 * text_scale;
       wet_label.FontWeight   = 'normal';
       wet_label.Color      = browns(2,:) / 255;

       dry_label          = text( -142 , 47.5 , [ '(more rain)'        ] );
       dry_label.FontSize      = 10 * text_scale;
       dry_label.FontWeight   = 'normal';
       dry_label.Color      = greens(3,:) / 255;

   % Final formatting:   
     axis off; 
     box off;
     set( 0 , 'defaultaxesposition' , [0 0 1 1] )

     if hyperwall_flag == 0
       % 1080P animation values:
       ylim([ -060  +060 ]);
       xlim([ -180  +180 ]);
       lat_max = +60;
       lat_min = -60;
       % x_res   = 2048;
       x_res = 1920;
       y_res   = x_res * 0.5 * (lat_max-lat_min)/180;

     else
       % Hyperwall (6K; 5760 x 3240) values:
       lat_max = +60;
       lat_min = -60;
       ylim([ lat_min lat_max ]);

       if      hyperwall_flag == 1
            xlim([ -180  +180 ]);
            % domain_str = '1';
       % elseif   hyperwall_flag == 2
       %      xlim([ +000  +180 ]);
       %      domain_str = '2';   
       end

       % x_res = 5760;
       x_res = 3840;
       y_res = x_res * 0.5 *(lat_max-lat_min)/180;
     end

     set( fig1 , 'Position' , [0 0 x_res/2 y_res/2]);

     labels = [ 1 : length( phase_steps ) ];
     if      labels( phase_step_num ) < 10
           label_string = [ '00' , num2str( labels( phase_step_num ) ) ];
     elseif   labels( phase_step_num ) < 100
           label_string = [ '0'  , num2str( labels( phase_step_num ) ) ];   
     else
           label_string = num2str( labels( phase_step_num ) );
     end

   % Save image:
     if hyperwall_flag == 0
       saveSameSize( fig1, 'format', 'png', 'file' , ...
              [ home_directory , '/Images_Rain_SST/' , 'mjo_' , season , '_' , label_string ] ); 
     elseif worker == 1
       saveSameSize( fig1, 'format', 'png', 'file'            , ...
               [ home_directory , '/Images_Rain_SST/West_4_MJO_Rain_SST/'   , ...
                 'mjo_' , season , '_' , label_string          , ...
                 '_high_res' ] ); 
     elseif worker == 2
       saveSameSize( fig1, 'format', 'png', 'file'            , ...
               [ home_directory , '/Images_Rain_SST/West_2_MISO_Rain_SST/'  , ...
                 'mjo_' , season , '_' , label_string          , ...
                 '_high_res' ] ); 
     end

   % Reload map image and shift to Pacific-centered view:
     if hyperwall_flag == 0
        temp_image = imread( [ home_directory , '/Images_Rain_SST/' , ...
                              'mjo_' , season , '_' , label_string , ...
                              '.png' ] );
        [ temp_y , temp_x , ~ ] = size( temp_image );
        new_image = cat( 2 , temp_image(:,796:end,:) , temp_image(:,1:795,:) );
        imwrite( new_image , [ home_directory , '/Images_Rain_SST/' , ...
                              'mjo_' , season , '_' , label_string , ...
                              '_Pacific.png' ] );
     elseif worker == 1
        temp_image = imread( [ home_directory , '/Images_Rain_SST/West_4_MJO_Rain_SST/' , ...
                              'mjo_' , season , '_' , label_string        , ...
                             '_high_res.png' ] );
        [ temp_y , temp_x , ~ ] = size( temp_image );
        new_image = cat( 2 , temp_image( : , 794*2 :   end-0   , : ) , ...
                    temp_image( : ,    1 : 794*2-1   , : ) );
        imwrite( new_image , [ home_directory , '/Images_Rain_SST/West_4_MJO_Rain_SST/' , ...
                              'mjo_' , season , '_' , label_string , ...
                              '_Pacific.png' ] );       
     elseif worker == 2
        temp_image = imread( [ home_directory , '/Images_Rain_SST/West_2_MISO_Rain_SST/' , ...
                      'mjo_' , season , '_' , label_string        , ...
                     '_high_res.png' ] );
        [ temp_y , temp_x , ~ ] = size( temp_image );
        new_image = cat( 2 , temp_image( : , 794*2 :   end-0   , : ) , ...
                    temp_image( : ,    1 : 794*2-1   , : ) );
        imwrite( new_image , [ home_directory , '/Images_Rain_SST/West_2_MISO_Rain_SST/' , ...
                     'mjo_' , season , '_' , label_string , ...
                     '_Pacific.png' ] );   
     end


   % Add a black buffer to the top/bottom:
     if hyperwall_flag == 0
        temp_image = imread( [ home_directory , '/Images_Rain_SST/' , ...
                              'mjo_' , season , '_' , label_string , ...
                              '_Pacific.png' ] );
        y_res_new = floor( 1080 * (1920/1920) );
        y_diff = y_res_new - 640;
        y_diff = floor( y_diff / 2 );
        blank_image = zeros( y_res_new , 1920 , 3 , 'uint8' );
        blank_image( [ y_diff+1 : y_diff+640 ] , : , : ) = temp_image;
        imwrite( blank_image , [ home_directory , '/Images_Rain_SST/' , ...
                                'mjo_' , season , '_' , label_string , ...
                                '_Pacific_1080P.png' ] );
     elseif worker == 1
        temp_image = imread( [ home_directory , '/Images_Rain_SST/West_4_MJO_Rain_SST/' , ...
                              'mjo_' , season , '_' , label_string , ...
                              '_Pacific.png' ] );
        blank_image = zeros( 2160 , 3840 , 3 , 'uint8' );
        blank_image( 441 : 441+1280-1 , : , : ) = temp_image;
        imwrite( blank_image , [ home_directory , '/Images_Rain_SST/West_4_MJO_Rain_SST/' , ...
                                'West_4_MJO_Rain_SST_4K_' , phase_str , '.png' ] );
     elseif worker == 2
        temp_image = imread( [ home_directory , '/Images_Rain_SST/West_2_MISO_Rain_SST/' , ...
                              'mjo_' , season , '_' , label_string , ...
                              '_Pacific.png' ] );
        blank_image = zeros( 2160 , 3840 , 3 , 'uint8' );
        blank_image( 441 : 441+1280-1 , : , : ) = temp_image;
        imwrite( blank_image , [ home_directory , '/Images_Rain_SST/West_2_MISO_Rain_SST/' , ...
                                'West_2_MISO_Rain_SST_4K_' , phase_str , '.png' ] );
     end

   % Delete temp images:
     if worker == 1
       delete( [ home_directory , '/Images_Rain_SST/West_4_MJO_Rain_SST/'   , ...
                     'mjo_' , season , '_' , label_string , ...
                     '_Pacific.png' ] );
       delete( [ home_directory , '/Images_Rain_SST/West_4_MJO_Rain_SST/'   , ...
                      'mjo_' , season , '_' , label_string , ...
                     '_high_res.png' ] );
     elseif worker == 2
       delete( [ home_directory , '/Images_Rain_SST/West_2_MISO_Rain_SST/'   , ...
                     'mjo_' , season , '_' , label_string , ...
                     '_Pacific.png' ] );
       delete( [ home_directory , '/Images_Rain_SST/West_2_MISO_Rain_SST/'   , ...
                      'mjo_' , season , '_' , label_string , ...
                     '_high_res.png' ] );
     end
   end
