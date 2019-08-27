% This script loads the set of 576 precipitation (rainfall) and SST
% images and encodes them as an mp4 video file.
clc; clf; close;
clearvars -except worker

% Initialize the video:
   if worker == 1
      season = [ 'winter' ];
      outputVideo = VideoWriter( [ home_directory , '/Images_Rain_SST/' , ...
                           'MJO_Rain_SST_1080P_v2.mp4'  ] , 'MPEG-4' );
   else
      season = [ 'summer' ];
      outputVideo = VideoWriter( [ home_directory , '/Images_Rain_SST/' , ...
                           'MISO_Rain_SST_1080P_v2.mp4' ] , 'MPEG-4' );
   end
   outputVideo.FrameRate = 30;
   open( outputVideo );

% Fill the video with images:
   for frame = 1 : 576
      if frame < 10
         frame_string = [ '00' , num2str( frame ) ];
      elseif frame < 100
         frame_string = [ '0' , num2str( frame ) ];
      else frame_string = [ num2str( frame ) ];
      end
      
      img = imread([home_directory , '/Images_Rain_SST/' , ...
                    'mjo_' , season , '_' , frame_string , '_Pacific_1080P.png' ] );
      % img = imresize( img , [ 1080 1920 ] );
      writeVideo( outputVideo , img );
   end

close( outputVideo );
