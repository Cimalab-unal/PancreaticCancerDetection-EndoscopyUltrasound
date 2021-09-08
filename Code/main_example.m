% Objectives: 
    % Process a complete video
    % Extract the frames
    % Transform the frames from cartesian coordinates to polar and apply the preprocessing step.
    % Apply the SURF detector and dectriptor
    % Construct the feature vector
    % Train and test the models
    % Correct the miss-classification frames

% Required scripts:
    % video2frames
    % img_preprocesing 
        % transformation
        % find_center_coordinates
    % verify_video
    % points_found
        % delete_points
    % feature_vector
        % feature_vector_construction
    % clasification_cicle
        % prediction_function
        % cicle_AUC
        % confussion_matrix
    % cicle_temp_correction
        % temp_correction
        
clc
clear all
warning('off')

% Main directory
%main_root='D:\Documents\Desktop\Scripts Github\';
main_root='D:\Documents\Desktop\Testing NN\';

% PARAMETERS THAT COULD BE CHANGED:

% Flags to perform each stage of the process, if is one apply the procedure
flg_frames=1; % Extract the frames of the videos. Wthout Doppler and Elastography 
flg_preprocessing=1; % Cut, Transform and contrast enhacement.
flg_verify = 1; % Make a video with the preprocessed images to verigy if some of them are wrong
SURF_features= 0; % Detect the SURF points and Extract the descriptor
construct_feature_vector= 0; % Construct the feature vector
clasiffy= 0; % Train and test the models
test_noisy= 0; % Test the models with noisy images
temp_corr= 1; % Temporal Correction to predicted labels

% Parameters to extract the frames and apply the preprocessing
frames_ext='.tif'; % extention of output frames
videos_ext='.mp4'; % extention of input videos
save_mask=1; % save US cone. It is necessary in the SURF detector to delete the border points
% If it is test images with noise
noise='SPECKLE'; % Could be: 'SPECKLE', 'GAUSSIAN' or ''
var_noise=10; % Percentage of variance (1 to 100) or ''

% Type of images to apply the Description and classification processes
categ='Preprocessed'; % Could be: 'Original_Cut', 'Transformed' or 'Preprocessed'

% Parameters to detect the SURF points and extract the descriptors
MetricThreshold= 500; % Strongest feature threshold
NumOctaves=3; % Higger values detect larger blobs.
NumScaleLevels=5; % Number of scale levels per octave
% Parameters to delete points
max_percent=80; % Max percent area over the black mask
step_location=5; % Max distance betwen centers
step_scale=1; % Max scale diference betwen points

% Parameters to construct the feature vector (Statistics flags)
flg_mode=1;
flg_median=1;
flg_mean=1;
flg_max=1;
flg_min=1;
flg_entropy=1;

% Parameters to perform the clasification process
flg_sc=[2 5]; % If it is classify specific scales. Could be: [min_scale max_scale] or ''
type_points='filt'; % If it was trainied the models with filtered points (deleting the overlaped and out of ROI SURF points). Could be: 'orig' or 'filt'
num_it_adaboost=100; % Number of iterations of the adaboost model
% If the models will be optimized
k_part= 10; % number of partitions for k-fold cross-validation on optimizing stage
method= 'expected-improvement-per-second-plus';  % Acquisition Function Name for the optimizing stage

% Parameters to perform the temporal correction
clasif='orig'; % Could be: 'orig', 'optim', 'best'
window=30;
threshold=25;

root_files=[main_root '\Example\'];
root_results=[main_root '\Example\RESULTS\'];

% extract the frames of the videos
if flg_frames==1
    disp('Extracting the frames')
    addpath('Preprocessing')
    cancer=video2frames([root_files 'Videos\CANCER'],[root_files 'Images\CANCER'],frames_ext,videos_ext);
    no_cancer=video2frames([root_files 'Videos\HEALTHY PANCREAS'],[root_files 'Images\HEALTHY PANCREAS'],frames_ext,videos_ext);
    mkdir([root_files 'RESULTS'])
    save([root_files 'RESULTS\frames.mat'],'cancer','no_cancer');
end

% Preprocessing of the images: Coordinates transformation and contrast enhacement
if flg_preprocessing==1
    disp('Preprocessing')
    addpath('Preprocessing')
    load([root_files 'RESULTS\frames.mat'],'cancer','no_cancer');
    img_preprocessing([root_files 'Images\CANCER\'],frames_ext,save_mask,noise,var_noise,cancer)
    img_preprocessing([root_files 'Images\HEALTHY PANCREAS\'],frames_ext,save_mask,noise,var_noise,no_cancer)
end

% Save a video to varify the transformation
if flg_verify == 1
    disp('Make verify videos')
    addpath('Preprocessing')
    verify_video([root_files 'Images\CANCER\'])
    verify_video([root_files 'Images\HEALTHY PANCREAS\'])
end

% Apply SURF detector and descriptor
if SURF_features==1
    disp('SURF Detector and Descriptor')
    addpath('Descriptors')
    points_found([root_files 'Images\CANCER\'],MetricThreshold,NumOctaves,NumScaleLevels,step_location,step_scale,1,max_percent,[root_results 'SURF POINTS'],categ,'C')
    points_found([root_files 'Images\HEALTHY PANCREAS\'],MetricThreshold,NumOctaves,NumScaleLevels,step_location,step_scale,0,max_percent,[root_results 'SURF POINTS'],categ,'H')
end

% Name of the test according to the statistics and scales
statistics={'mean','median','mode','entropy','max','min'};
name_test='';
for i=1:length(statistics)
    if  eval(['flg_' statistics{i}]) ==1
        if isempty(name_test)
            name_test=[name_test statistics{i}];
        else
            name_test=[name_test '-' statistics{i}];
        end
    end
end
if ~isempty(flg_sc)
    name_test=[name_test '_scales_' num2str(flg_sc(1)) '_' num2str(flg_sc(2))];
else
    name_test=[name_test '_all_scales'];
end
if or(~isempty(k_part),k_part>0)
    flg_optim={k_part, method}; 
else
    flg_optim='';
end


% Create the feature vector
if construct_feature_vector==1
    disp('Feature vector Construction')
    addpath('Descriptors')
    max_scale=NumOctaves*NumScaleLevels+1;
    feature_vector(root_results,MetricThreshold,max_scale,categ,flg_mode,flg_median,flg_mean,flg_max,flg_min,flg_entropy,name_test)
end

% Clasification
root_features=[root_results 'FEATURE VECTORS\Threshold_' num2str(MetricThreshold) '_' categ '_Image\' name_test '\' type_points '_points.mat'];
if clasiffy==1
    disp('Clasification')    
    addpath('Clasification')
    clasification_cicle(type_points,num_it_adaboost,root_results,['\Threshold_' num2str(MetricThreshold) '_' categ '_Image\' name_test],flg_sc,flg_optim,root_features)
end

% Test the models with noisy images
if test_noisy==1
    disp('Testing Noisy database')
    root_noise=[noise ' Noise - ' num2str(var_noise) '\'];
    if ~isfolder([root_files 'Images\CANCER\' categ '\' root_noise])
        addpath('Preprocessing')
        load([root_files 'RESULTS\frames.mat'],'cancer','no_cancer');
        img_preprocessing([root_files 'Images\CANCER\'],frames_ext,save_mask,noise,var_noise,cancer)
        img_preprocessing([root_files 'Images\HEALTHY PANCREAS\'],frames_ext,save_mask,noise,var_noise,no_cancer)
    end
    if ~isfolder([root_results root_noise 'SURF POINTS'])
        addpath('Descriptors')
        points_found([root_files 'Images\CANCER\' root_noise],MetricThreshold,NumOctaves,NumScaleLevels,step_location,step_scale,1,max_percent,[root_results root_noise 'SURF POINTS'],categ,'C_')
        points_found([root_files 'Images\HEALTHY PANCREAS\' root_noise],MetricThreshold,NumOctaves,NumScaleLevels,step_location,step_scale,0,max_percent,[root_results root_noise 'SURF POINTS'],categ,'H_')
    end
    if ~isfolder([root_results root_noise 'FEATURE VECTORS\Threshold_' num2str(MetricThreshold) '_' categ '_Image\' name_test '\'])
        max_scale=NumOctaves*NumScaleLevels+1;
        feature_vector([root_results root_noise],MetricThreshold,max_scale,categ,flg_mode,flg_median,flg_mean,flg_max,flg_min,flg_entropy,name_test)
    end
    addpath('Clasification')
    cicle_test([root_results root_noise 'FEATURE VECTORS\Threshold_' num2str(MetricThreshold) '_' categ '_Image\' name_test '\'],[root_results root_noise],root_results,flg_sc,flg_optim,type_points,['\Threshold_' num2str(MetricThreshold) '_' categ '_Image\' name_test '\']) 
end

% Temporal Correction
if temp_corr==1
    disp('Temporal Correction')
    root_clasification=[root_results 'CLASSIFICATION\Threshold_' num2str(MetricThreshold) '_' categ '_Image\' name_test];
    if ~isempty(flg_optim)
        root_clasification=[root_clasification '\Optim\'];
    end
    addpath('Temporal Correction')
    addpath('Clasification') 
    load([root_results 'train_iterations.mat'],'train') 
    num_it=length(train);     
    cicle_temp_correction(num_it,clasif,window,threshold,root_clasification)    
end
    
    