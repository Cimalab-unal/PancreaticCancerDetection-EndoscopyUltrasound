% Function to find the SURF points and each descriptors

% Required scripts:
    % delete_points
    
function points_found(root_folders,threshold,octaves,scalelevels,step_location,step_scale,label,max_percent,root_results,category,class)
    % Directories
    if findstr(root_results,'Noise')
        k=max([findstr(root_folders,'SPECKLE') findstr(root_folders,'GAUSSIAN')]);
        if isequal(category,'Preprocessed')
            root_folders_masks=[root_folders(1:k-1) 'Transformed\Masks\'];
        else
            root_folders_masks=[root_folders(1:k-1) category 'Masks\'];
        end
        root_folders=[root_folders(1:k-1) category '\' root_folders(k:end)];
    else
        if isequal(category,'Preprocessed')
            root_folders_masks=[root_folders 'Transformed\Masks\'];
        else
            root_folders_masks=[root_folders category 'Masks\'];
        end
        root_folders=[root_folders category];
    end
        
    if ~isfolder([root_results '\Threshold_' num2str(threshold) '_' category '_Image\'])
        mkdir([root_results '\Threshold_' num2str(threshold) '_' category '_Image\'])
    end
    
    % Cycle to process each case
    folders=dir(root_folders);
    for j=3:length(folders)
        folder=folders(j).name;
        
        imgs=dir([root_folders '\' folder '\' '*.tif']);
        total=length(imgs);
        
        % Variable initialization
        points_orig_case=cell(total,1);
        points_filt_case=cell(total,1);
        feat_points_orig_case=cell(total,1);
        feat_points_filt_case=cell(total,1);
        label_case=label*ones(total,1);
        names_case=cell(total,1);
        
        % Cycle to process each frame
        for a=1:total
            name_file=imgs(a).name; % name of frame
            names_case{a}=name_file;
            
            % Load the image and the mask
            img = imread([root_folders '\' folder '\' name_file]);
            img = img(:,:,1);
            mask=imread([root_folders_masks '\' folder '\' name_file]);
            
            % SURF Detector and Descriptor
            size_img=size(img);
            size_ROI=round(size_img*.95);
            ROI=[round((size_img(1)-size_ROI(1))/2) 5 size_ROI(2) size_ROI(1)];
            
            % Detector
            orig_points= detectSURFFeatures(img,'MetricThreshold',threshold,'NumOctaves',octaves,'NumScaleLevels',scalelevels,'ROI',ROI);
            
            % Descriptor
            if ~isempty(orig_points)
                [features_orig_points,~] = extractFeatures(img,orig_points,'Method','SURF');
                features_orig_points= double(features_orig_points);
                
                % Delete repeated and border SURF points
                filt_points = delete_points(orig_points,mask,scalelevels,max_percent,step_location,step_scale);
                if ~isempty(filt_points)
                    [features_filt_points,~] = extractFeatures(img,filt_points,'Method','SURF');
                    features_filt_points=double(features_filt_points);
                else
                    features_filt_points=zeros(1,64);
                end
            else
                filt_points=orig_points;
                features_filt_points=zeros(1,64);
            end
            
            points_orig_case{a}= orig_points;
            points_filt_case{a}= filt_points;
            feat_points_orig_case{a}= features_orig_points;
            feat_points_filt_case{a}= features_filt_points;
        end
        if ~isempty(names_case)
            save([root_results '\Threshold_' num2str(threshold) '_' category '_Image\' class folder '.mat'], 'points_orig_case','points_filt_case','feat_points_orig_case','feat_points_filt_case','label_case','names_case');
        end
    end
end

