% Main script

% Objectives: 
    % Train and Test the models with our feature vectors

% Required scripts:
    % clasification_cicle
        % prediction_function
        % cicle_AUC
        % confussion_matrix        
clc
clear all
warning('off')

% Main directory
main_root='D:\Documents\Desktop\Scripts Github\';
flg_optim=0; % Flag to define if the models will be optimized


addpath('Clasification')
addpath('Temporal Correction')
root_features=[main_root '\Our results\RESULTS\FEATURE VECTORS\Threshold_500_Preprocessed_Image\filt_points.mat'];
if flg_optim==0% Default clasification
    clasification_cicle('filt',100,[main_root '\Our results\RESULTS\'],'median_scales_2_5',[2 5],'',root_features) % Without optimizing
    cicle_temp_correction(10,'orig',30,25,[main_root '\Our results\RESULTS\CLASSIFICATION\median_scales_2_5\'])
    cicle_temp_correction(10,'orig',60,25,[main_root '\Our results\RESULTS\CLASSIFICATION\median_scales_2_5\'])
else % Optimized clasification
    clasification_cicle('filt',100,[main_root '\Our results\RESULTS\'],'median_scales_2_5',[2 5],{10, 'expected-improvement-per-second-plus'},root_features)
    cicle_temp_correction(10,'optim',30,25,[main_root '\Our results\RESULTS\CLASSIFICATION\median_scales_2_5\Optim\'])
    cicle_temp_correction(10,'optim',60,25,[main_root '\Our results\RESULTS\CLASSIFICATION\median_scales_2_5\Optim\'])
end
    
    