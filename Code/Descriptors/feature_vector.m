% Function to construct the feature vector, according to the desirable
% statistics. flg_mode,flg_median,flg_mean,flg_max,flg_min,flg_entropy 
% determine if it will be apply each statistic

% Required scripts:
    % feature_vector_construction

function feature_vector(main_root,MetricThreshold,max_scale,categ,flg_mode,flg_median,flg_mean,flg_max,flg_min,flg_entropy,name_test)
% number of statistics
num_st=sum([flg_mode flg_median flg_mean flg_max flg_min flg_entropy]);

% SURF POINT directory
root_points=[main_root 'SURF POINTS\Threshold_' num2str(MetricThreshold) '_' categ '_Image']; 
folders=dir([root_points '\*.mat']);
num_cases=length(folders);

% Variable initialization
vector_dimention=64*num_st*(max_scale-1);
features_cases_orig=cell(num_cases,1);
features_cases_filt=cell(num_cases,1);
labels=cell(num_cases,1);
names=cell(num_cases,1);
names_folders=cell(num_cases,1);
num_img=zeros(num_cases,1);
num_points_orig=cell(num_cases,1);
num_points_filt=cell(num_cases,1);

% Cycle to process each case
for a=1:length(folders)
    
    % Load the surf points and features
    name=folders(a).name;
    names_folders{a,1}=name;
    load([root_points '\' name],'points_orig_case','points_filt_case','feat_points_orig_case','feat_points_filt_case','label_case','names_case');
    
    num_imgs=length(feat_points_orig_case);
    num_img(a)=num_imgs;
    num_points_orig_case=zeros(num_imgs,1);
    num_points_filt_case=zeros(num_imgs,1);    
    feat_orig_case=zeros(num_imgs,vector_dimention);
    feat_filt_case=zeros(num_imgs,vector_dimention);
    % Cycle to process each frame
    for i=1:num_imgs
        feat_orig_img=feat_points_orig_case{i};
        feat_filt_img=feat_points_filt_case{i};        
        points_orig=points_orig_case{i};
        points_filt=points_filt_case{i};
        
        num_points_orig_case(i)=points_orig.Count;
        num_points_filt_case(i)=points_filt.Count;
        
        scales_orig=points_orig.Scale;
        scales_filt=points_filt.Scale;
        
        % feature vector construction
        feat_orig_img_scales=feature_vector_construction(feat_orig_img,ceil(scales_orig),flg_mode,flg_median,flg_mean,flg_max,flg_min,flg_entropy,num_st,max_scale);
        feat_filt_img_scales=feature_vector_construction(feat_filt_img,ceil(scales_filt),flg_mode,flg_median,flg_mean,flg_max,flg_min,flg_entropy,num_st,max_scale);
        
        feat_orig_case(i,:)=feat_orig_img_scales;
        feat_filt_case(i,:)=feat_filt_img_scales;
    end
    features_cases_orig{a}=feat_orig_case;
    features_cases_filt{a}=feat_filt_case;
    labels{a}=label_case;
    names{a}=names_case;
    num_points_orig{a}=num_points_orig_case;
    num_points_filt{a}=num_points_filt_case;
end
mkdir([main_root 'FEATURE VECTORS\Threshold_' num2str(MetricThreshold) '_' categ '_Image\' name_test '\'])
save([main_root 'FEATURE VECTORS\Threshold_' num2str(MetricThreshold) '_' categ '_Image\' name_test '\orig_points.mat'], 'features_cases_orig','labels','names','num_img','num_points_orig','names_folders');
save([main_root 'FEATURE VECTORS\Threshold_' num2str(MetricThreshold) '_' categ '_Image\' name_test '\filt_points.mat'], 'features_cases_filt','labels','names','num_img','num_points_filt','names_folders');
end
