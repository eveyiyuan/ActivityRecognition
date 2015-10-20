close all;
clear;
clc;
files = dir('*.avi');
fileID = fopen('HOG_HOF.txt', 'a');
fprintf(fileID, '%s\n', '%HOG');
fclose(fileID);
for fnum = 1:numel(files)
    [pathstr,name,ext] = fileparts(files(fnum).name);
    vidname = name;
    % Load video
    vreader = VideoReader(files(fnum).name);
    num_frames = vreader.NumberOfFrames;
    frames = zeros(120, 160, num_frames);

    xkernel = [-1, 0 ,1];
    ykernel = [-1; 0; 1];
    ygrad = zeros(120, 160, num_frames);
    xgrad = zeros(120, 160, num_frames);

    ori = zeros(120, 160, num_frames);
    magn = zeros(120, 160, num_frames);

    for f = 1:num_frames
        % Convert video into grayscale image frames
        im = imresize(vreader.read(f), 0.5);
        im = rgb2gray(im);
        frames(:, :, f) = im;  
        % apply x and y gradients
        ygrad(:, :, f) = imfilter(frames(:,:,f), ykernel);
        xgrad(:, :, f) = imfilter(frames(:,:,f), xkernel);
    end

    % Calculate magnitude and orientation
    for f = 1:num_frames
        magn(:,:,f) = sqrt(xgrad(:,:,f).^2 + ygrad(:,:,f).^2);
        ori(:, :, f) = abs(radtodeg(atan2(ygrad(:,:,f),xgrad(:,:,f))));
    end

    hist = zeros(7,7,11); 
    % 11 angle bins (2 trash bins for the edges) : 2- [0,20), 3 - [20, 40)
    % Trash bins: 1, 11; actual bins: 2-10
    % 7 spatial bins each (2 trash bins for the edges):
    % Trash bins: 1, 7; actual bins = 2-6
    bz = 20;
    by = 24;
    bx = 32;
    allframe_hists = zeros(num_frames, 225);
    for f = 1:num_frames
        frame_hist = zeros(7,7,11);
        tic
        for ybin = (0:5)
            for xbin = (0:5)
                % Set bounds for spatial binning
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
                for q = (0:9)
                    a_before = q*20 - 10;
                    a_after = q*20 + 10;
                    if a_before < 0
                        a_before = 0;
                    end
                    if a_after > 180
                        a_after = 180;
                    end
                    [y_indicies, x_indicies] = find(seg >= a_before & seg <= a_after);
                    % Determine orientation binning
                    for j = (1:numel(x_indicies))
                        y = rangey(y_indicies(j));
                        x = rangex(x_indicies(j));
                        if y <= 0
                            y = 1; % compare with the smallest value in the smallest real bin for edge
                        end
                        if y > 120
                            y= 120; % compare with the largest value in the largest real bin for edge
                        end
                        if x<= 0
                            x = 1;
                        end
                        if x > 160
                            x= 160;
                        end
                        % Do trilinear interpolation
                        angle = ori(y,x,f);
                        mag = magn(y,x,f);
                        hist(xbin+1, ybin+1, q+1) = hist(xbin+1, ybin+1, q+1) + mag*(1-(x-xbefore)/bx)*(1-(y-ybefore)/by)*(1-(angle-a_before)/bz);
                        hist(xbin+1, ybin+1, q+2) = hist(xbin+1, ybin+1, q+2) + mag*(1-(x-xbefore)/bx)*(1-(y-ybefore)/by)*((angle-a_before)/bz);
                        hist(xbin+1, ybin+2, q+1) = hist(xbin+1, ybin+2, q+1) + mag*(1-(x-xbefore)/bx)*((y-ybefore)/by)*(1-(angle-a_before)/bz);
                        hist(xbin+2, ybin+1, q+1) = hist(xbin+2, ybin+1, q+1) + mag*((x-xbefore)/bx)*(1-(y-ybefore)/by)*(1-(angle-a_before)/bz);
                        hist(xbin+1, ybin+2, q+2) = hist(xbin+1, ybin+2, q+2) + mag*(1-(x-xbefore)/bx)*((y-ybefore)/by)*((angle-a_before)/bz);
                        hist(xbin+2, ybin+1, q+2) = hist(xbin+2, ybin+1, q+2) + mag*((x-xbefore)/bx)*(1-(y-ybefore)/by)*((angle-a_before)/bz);
                        hist(xbin+2, ybin+2, q+1) = hist(xbin+2, ybin+2, q+1) + mag*((x-xbefore)/bx)*((y-ybefore)/by)*(1-(angle-a_before)/bz);
                        hist(xbin+2, ybin+2, q+2) = hist(xbin+2, ybin+2, q+2) + mag*((x-xbefore)/bx)*((y-ybefore)/by)*((angle-a_before)/bz);

                        frame_hist(xbin+1, ybin+1, q+1) = frame_hist(xbin+1, ybin+1, q+1) + mag*(1-(x-xbefore)/bx)*(1-(y-ybefore)/by)*(1-(angle-a_before)/bz);
                        frame_hist(xbin+1, ybin+1, q+2) = frame_hist(xbin+1, ybin+1, q+2) + mag*(1-(x-xbefore)/bx)*(1-(y-ybefore)/by)*((angle-a_before)/bz);
                        frame_hist(xbin+1, ybin+2, q+1) = frame_hist(xbin+1, ybin+2, q+1) + mag*(1-(x-xbefore)/bx)*((y-ybefore)/by)*(1-(angle-a_before)/bz);
                        frame_hist(xbin+2, ybin+1, q+1) = frame_hist(xbin+2, ybin+1, q+1) + mag*((x-xbefore)/bx)*(1-(y-ybefore)/by)*(1-(angle-a_before)/bz);
                        frame_hist(xbin+1, ybin+2, q+2) = frame_hist(xbin+1, ybin+2, q+2) + mag*(1-(x-xbefore)/bx)*((y-ybefore)/by)*((angle-a_before)/bz);
                        frame_hist(xbin+2, ybin+1, q+2) = frame_hist(xbin+2, ybin+1, q+2) + mag*((x-xbefore)/bx)*(1-(y-ybefore)/by)*((angle-a_before)/bz);
                        frame_hist(xbin+2, ybin+2, q+1) = frame_hist(xbin+2, ybin+2, q+1) + mag*((x-xbefore)/bx)*((y-ybefore)/by)*(1-(angle-a_before)/bz);
                        frame_hist(xbin+2, ybin+2, q+2) = frame_hist(xbin+2, ybin+2, q+2) + mag*((x-xbefore)/bx)*((y-ybefore)/by)*((angle-a_before)/bz);
                    end
                    clear y_indicies;
                    clear x_indicies;
                end
            end
        end
        toc
        % Save perframe HOGs
        frame_hist = frame_hist(2:6, 2:6, 2:10);
        allframe_hists(f,:) = reshape(frame_hist, [1,225]);
    end
    % Save matricies to be accessed in part 2
    save(strcat(vidname,'_hog_hists.mat'), 'allframe_hists');
    % throw out the trash bins
    hist = hist(2:6, 2:6, 2:10);
    % normalize
    for i = (1:9)
        L1_norm = norm(hist(:,:,i), 1);
        hist(:,:,i) = hist(:,:,i) ./ L1_norm;
    end
    save(strcat(vidname,'_hog_total.mat'), 'hist');
    % write to file
%     fileID = fopen('HOG_HOF.txt', 'a');
%     fprintf(fileID, '%s\n', strcat('HOG_',vidname, '=['));
%     fprintf(fileID, '%f %f %f %f %f\n', permute(hist, [2 1 3]));
%     fprintf(fileID, '%s\n', '];');
%     fclose(fileID);
end