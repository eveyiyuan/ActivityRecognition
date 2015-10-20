close all;
clear;
clc;

% Mean HOG
files = dir('*_hog_total.mat');
features = zeros(84, 225);
Y = char(zeros(35,1));
for i = 1:5
    for j = 1:7
        Y((i-1)*7+j,1) = int2str(j);
    end
end
% sets 3 and 4 are irregular
Y= vertcat(Y, '1', '2', '3', '5', '6', '7', '1', '2', '3', '4', '4', '5', '6', '7');
for i = 5:9
    for j = 1:7
        Y = vertcat(Y, int2str(j));
    end
end
for fnum = 1:numel(files)
    [pathstr,name,ext] = fileparts(files(fnum).name);
    histname = name;
    histfile = strcat(histname,'.mat');
    load(histfile); %hist
    features(fnum,:) = reshape(hist, [1, 225]);
end


% Designate features for training
featuresTraining = features(1:42,:);
YTraining = Y(1:42,:);

% Designate 1/4 of features for testing
featuresTesting = features(43:84,:);
YTesting = Y(43:84,:);
tic
allTree = TreeBagger(200, featuresTraining, YTraining, 'OOBPred', 'On', 'OOBVarImp', 'On');
toc
oobErrorAll = oobError(allTree);
disp(oobErrorAll);

% Make a preduction with 1/4 of the data
prediction = cell2mat(predict(allTree, featuresTesting));

% Generate Confusion matrix
[conf, classorder] = confusionmat(YTesting, prediction);

% Write Matrix to file
% fileID = fopen('Confusion_matricies.txt', 'a');
% fprintf(fileID, '%s\n', 'Mean_HOG_Confusion=[');
% fprintf(fileID, '%f %f %f %f %f %f %f\n', permute(conf, [2 1]));
% fprintf(fileID, '%s\n', '];');
% fclose(fileID);

% Mean HOF
files = dir('*_hof_total.mat');
features = zeros(84, 200);
for fnum = 1:numel(files)
    [pathstr,name,ext] = fileparts(files(fnum).name);
    histname = name;
    histfile = strcat(histname,'.mat');
    load(histfile); %hist
    features(fnum,:) = reshape(hist, [1, 200]);
end


% Designate features for training
featuresTraining = features(1:42,:);
YTraining = Y(1:42,:);

% Designate 1/4 of features for testing
featuresTesting = features(43:84,:);
YTesting = Y(43:84,:);
tic
allTree = TreeBagger(200, featuresTraining, YTraining, 'OOBPred', 'On', 'OOBVarImp', 'On');
toc
oobErrorAll = oobError(allTree);
disp(oobErrorAll);
% Make a preduction with 1/4 of the data
prediction = cell2mat(predict(allTree, featuresTesting));

% Generate Confusion matrix
[conf, classorder] = confusionmat(YTesting, prediction);

% Write Matrix to file
% fileID = fopen('Confusion_matricies.txt', 'a');
% fprintf(fileID, '%s\n', 'Mean_HOF_Confusion=[');
% fprintf(fileID, '%f %f %f %f %f %f %f\n', permute(conf, [2 1]));
% fprintf(fileID, '%s\n', '];');
% fclose(fileID);

% BOW HOG

files = dir('*_hog_hists_bog.mat');
features = zeros(84, 25);
for fnum = 1:numel(files)
    [pathstr,name,ext] = fileparts(files(fnum).name);
    histname = name;
    histfile = strcat(histname,'.mat');
    load(histfile); %my_hist
    features(fnum,:) = my_hist;
end


% Designate features for training
featuresTraining = features(1:42,:);
YTraining = Y(1:42,:);

% Designate 1/4 of features for testing
featuresTesting = features(43:84,:);
YTesting = Y(43:84,:);
tic
allTree = TreeBagger(200, featuresTraining, YTraining, 'OOBPred', 'On', 'OOBVarImp', 'On');
toc
oobErrorAll = oobError(allTree);
disp(oobErrorAll);
% Make a preduction with 1/4 of the data
prediction = cell2mat(predict(allTree, featuresTesting));

% Generate Confusion matrix
[conf, classorder] = confusionmat(YTesting, prediction);

% Write Matrix to file
% fileID = fopen('Confusion_matricies.txt', 'a');
% fprintf(fileID, '%s\n', 'BOW_HOG_Confusion=[');
% fprintf(fileID, '%f %f %f %f %f %f %f\n', permute(conf, [2 1]));
% fprintf(fileID, '%s\n', '];');
% fclose(fileID);

% BOW HOF

files = dir('*_hof_hists_bog.mat');
features = zeros(84, 25);
for fnum = 1:numel(files)
    [pathstr,name,ext] = fileparts(files(fnum).name);
    histname = name;
    histfile = strcat(histname,'.mat');
    load(histfile); %my_hist
    features(fnum,:) = my_hist;
end


% Designate features for training
featuresTraining = features(1:42,:);
YTraining = Y(1:42,:);

% Designate 1/4 of features for testing
featuresTesting = features(43:84,:);
YTesting = Y(43:84,:);
tic
allTree = TreeBagger(200, featuresTraining, YTraining, 'OOBPred', 'On', 'OOBVarImp', 'On');
toc
oobErrorAll = oobError(allTree);
disp(oobErrorAll);
% Make a preduction with 1/4 of the data
prediction = cell2mat(predict(allTree, featuresTesting));

% Generate Confusion matrix
[conf, classorder] = confusionmat(YTesting, prediction);

% Write Matrix to file
% fileID = fopen('Confusion_matricies.txt', 'a');
% fprintf(fileID, '%s\n', 'BOW_HOF_Confusion=[');
% fprintf(fileID, '%f %f %f %f %f %f %f\n', permute(conf, [2 1]));
% fprintf(fileID, '%s\n', '];');
% fclose(fileID);