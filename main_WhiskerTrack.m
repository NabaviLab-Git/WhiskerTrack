clc
clear
close all

%% ============= Define Global Variable for Whisket Tracking ==============
global WT;
addpath('./WhiskerTrack_Functions')

%% =========================== Set Parameters =============================
%--------------------------------------------------------------------------
% if you want to see the results of analysis in real time mode
WT.RealTimePlotFlag = 0; % "0" or "1"
WT.RealTimePlotROIFlag = 0; % display ROI for each whisker in real time mode
WT.WriteVideoFlag = 0;   % save the real time analysis as a .mp4 video
%--------------------------------------------------------------------------
% if you want to save the results as a .mat file
WT.SaveResultFlag = 0;
%--------------------------------------------------------------------------
% if you want to smooth the results (just for plot final figures)
WT.PlotFiltLength = 1;   % integer number ("1" for no smooting)
%--------------------------------------------------------------------------
% if you have an optical stimulation in your video
WT.LightStimFlag  = 0;   % "0" or "1"
WT.StimBLQuantile = 0.9; % proportion of the frames to calculate the bsaeline intensity value
WT.StimPeakWeight = 0.4; % weight of peak intensity to calculate the threshold for defining stimulated frames
%--------------------------------------------------------------------------
% Whisker Tracking Parameters
WT.Delta_X_ROI = 20;    % range of pixels to look for the start and end points of the whiskers in the next frame (0.5*size_ROI) (pixel)
WT.Delta_Theta_ROI = 6; % range of angle to look for the whiskers in the next frame (degree)
%--------------------------------------------------------------------------
% if you want to rotate the video
WT.RotationFrame = 0;   % "-90" , "0" , "90" (degree)

%% ============================= Load Video ===============================
[File, Path] = uigetfile('*.mp4;*.avi');
WT.File_Name = fullfile(Path, File);
WT.V = VideoReader(WT.File_Name);

%% ======================== Display First Frame ===========================
figure('Name','Whisker Tracking')
WT.current_frame = 1;
if WT.RotationFrame==90
    WT.frame = rgb2gray(permute(readFrame(WT.V),[2 1 3]));
elseif WT.RotationFrame==-90
    WT.frame = flipud(rgb2gray(permute(readFrame(WT.V),[2 1 3])));
else
    WT.frame = rgb2gray(readFrame(WT.V));
end
WT.Handle = imshow(WT.frame);

%% ================== Get the Number of Whiskers =======================
answer = inputdlg('Enter number of whiskers for tracking :','Whiskers Num', [1 40]);
WhiskersNum = str2double(answer{1});
if isnan(WhiskersNum) || WhiskersNum < 1
    errordlg('Number of whiskers should be a positive integer number!')
else
    WT.Whiskers_Num = round(WhiskersNum);
end
WT.Title = title(['Select wiskers by drawing lines ( ' num2str(0) ' / ' num2str(WT.Whiskers_Num) ' )']);
hold on;

%% ====================== Determine Whiskers by User ======================
WT.line_num = 1;
WT.Point1 = zeros(WT.Whiskers_Num,2);
WT.Point2 = zeros(WT.Whiskers_Num,2);
WT.Line = gobjects(WT.Whiskers_Num,1);
set(gcf,'WindowButtonDownFcn',@select_point);