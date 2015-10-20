close all;
clear;
clc;
addpath('mex');

files = dir('*.avi');
fileID = fopen('HOG_HOF.txt', 'a');
fprintf(fileID, '%s\n', '%HOF');
fclose(fileID);
% set optical flow parameters 
alpha = 0.012;
ratio = 1;
minWidth = 20;
nOuterFPIterations = 7;
nInnerFPIterations = 1;
nSORIterations = 30;

para = [alpha,ratio,minWidth,nOuterFPIterations,nInnerFPIterations,nSORIterations];
for fnum = 1:numel(files)
    [pathstr,name,ext] = fileparts(files(fnum).name);
    vidname = name;
    % Load video
    vreader = VideoReader(files(fnum).name);
    num_frames = vreader.NumberOfFrames;
    hist = zeros(5,5,8); 
    allframe_hists = zeros(num_frames, 200);
    by = 24;
    bx = 32;
    ori = zeros(120, 160, num_frames);
    magn = zeros(120, 160, num_frames);
    for f = 1:num_frames-1
        % Convert video into grayscale image frames
        im1 = imresize(vreader.read(f), 0.5);
        im1 = rgb2gray(im1);
        im2 = imresize(vreader.read(f+1), 0.5);
        im2 = rgb2gray(im2);
        % Calculate Dense Optical Flow
        tic;
        [vx,vy,warpI2] = Coarse2FineTwoFrames(im1,im2,para);
        toc
        % Calculate Magnitude and orientation
        magn(:,:,f) = sqrt(vx.^2 + vy.^2);
        ori(:, :, f) = mod(atan2d(vy,vx), 360);
        frame_hist = zeros(5,5,8);
        
        for ybin = (0:5)
            for xbin = (0:5)
                %Set the low and high centers for spatial binning
                ybefore = 24*ybin-(by/2);
                if ybefore <= 0
                    ybefore = 1; % compare with the smallest value in the smallest real bin for edge
                end
                yafter = 24*ybin+24 - (by/2);
                if yafter > 120
                    yafter = 120; % compare with the largest value in the largest real bin for edge
                end
                xbefore = 32*xbin - (bx/2);
                if xbefore <= 0
                    xbefore = 1;
                end
                xafter = 32*xbin+32 - (bx/2);
                if xafter > 160
                    xafter = 160;
                end
                rangey = ybefore:yafter;
                rangex = xbefore:xafter;
                seg = ori(rangey, rangex, f);
                % Determine Orientation Binning
                for q = (0:7)
                    a_before = q*45;
                    a_after = (q+1)*45;
                    [y_indicies, x_indicies] = find(seg >= a_before & seg <= a_after);
                    for j = (1:numel(x_indicies))
                        y = rangey(y_indicies(j));
                        x = rangex(x_indicies(j));
                        mag = magn(y,x,f);
                        if xbin == 0 
                            xid = 1;
                        elseif xbin == 5
                            xid = 5;
                        elseif x-xbefore < xafter -x
                            xid = xbin;
                        else
                            xid = xbin+1;
                        end
                        if ybin == 0 
                            yid = 1;
                        elseif ybin == 5
                            yid = 5;
                        elseif y-ybefore < yafter -y
                            yid = ybin;
                        else
                            yid = ybin+1;
                        end
                        ori(y,x,f) = -300;
                        hist(yid, xid, q+1) = mag;
                        frame_hist(yid, xid, q+1) = mag;
                    end
                end
            end
        end
        % Save the perframe HOF
        allframe_hists(f,:) = reshape(frame_hist, [1,200]);
    end
    % Save matricies to be accessed in part 2
    save(strcat(vidname,'_hof_hists.mat'), 'allframe_hists');
    % normalize
    for i = (1:8)
        L1_norm = norm(hist(:,:,i), 1);
        hist(:,:,i) = hist(:,:,i) ./ L1_norm;
    end
    save(strcat(vidname,'_hof_total.mat'), 'hist');
    % write to file
%     fileID = fopen('HOG_HOF.txt', 'a');
%     fprintf(fileID, '%s\n', strcat('HOF_',vidname, '=['));
%     fprintf(fileID, '%f %f %f %f %f\n', permute(hist, [2 1 3]));
%     fprintf(fileID, '%s\n', '];');
%     fclose(fileID);
end

