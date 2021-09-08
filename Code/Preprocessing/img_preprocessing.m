% function to cut the image, transform it and modify the contrast

% Required scripts:
    % transformation
    % find_center_coordinates
    
function img_preprocessing(main_root,frame_ext,save_mask,noise,var_noise,frames)
    % Out directions
    root_orig=[main_root 'Original'];
    root_cut=[main_root 'Original_Cut'];
    root_trf=[main_root 'Transformed'];
    root_preproc=[main_root 'Preprocessed'];
    
    if ~isfile([main_root 'centers_orig.mat']) % Find the center of coordinates
        % Variable inizalization
        orig_ROIs={}; % to save the general masks and center of coordinates
        centers_ROIs=[];
        tot_imgs= sum(cell2mat(frames(:,2)));
        centers=zeros(1,tot_imgs);
        names=cell(1,tot_imgs);
        cases=cell(1,tot_imgs);
        im=1;
        y_ant=10;
        ROI_ant=0;
        
        % Cycle to find the center of coordinates and masks in all the videos
        folders=dir(root_orig);
        for j=3:length(folders)
            folder=folders(j).name;
            
            % create folders
            mkdir([root_cut '\' folder]);
            mkdir([root_trf '\' folder]);
            mkdir([root_preproc '\' folder]);
            if save_mask==1
                mkdir([root_cut '\Masks\' folder]);
                mkdir([root_trf '\Masks\' folder]);
            end
            if ~isempty(noise)
                mkdir([root_cut '\' noise ' Noise - ' num2str(var_noise) '\' folder]);
                mkdir([root_trf '\' noise ' Noise - ' num2str(var_noise) '\' folder]);
                mkdir([root_preproc '\' noise ' Noise - ' num2str(var_noise) '\' folder]);
            end
            
            % Cycle to process each frame
            imgs=dir([root_orig '\' folder '\' '*' frame_ext]);
            for a=1:length(imgs)
                name_file=imgs(a).name;
                
                % read image
                img = imread([root_orig '\' folder '\' name_file]);
                img = img(:,:,1);
                
                % find the center of coordinates
                try [y,ROI] = find_center_coordinates(img(:,:,1));
                catch
                    y=y_ant;
                    ROI=ROI_ant;
                end
                
                % save the general masks and centers
                k=find(abs(centers_ROIs-y)<3);
                if length(k)>1
                    resta=abs(centers_ROIs-y);
                    [~,k]=min(resta);
                end
                if isempty(k)
                    orig_ROIs{end+1,1}=ROI;
                    centers_ROIs=[centers_ROIs; y];
                else
                    ROI_ant=orig_ROIs{k,1};
                    orig_ROIs{k,1}=orig_ROIs{k,1}+ROI;
                    y=centers_ROIs(k);
                end
                y_ant=y;
                ROI_ant=ROI;
                
                centers(1,im)=y;
                names{1,im}=name_file;
                cases{1,im}=folder;
                im=im+1;
            end
        end
        for k=1:length(orig_ROIs)
            ROI=orig_ROIs{k,1};
            ROI(ROI<0.7*max(ROI(:)))=0;
            ROI(ROI>0)=1;
            orig_ROIs{k,1}=uint8(ROI);
        end
        save([main_root 'centers.mat'],'centers_ROIs','orig_ROIs','centers','names','cases');
    else
        load([main_root 'centers.mat'])
        tot_imgs=length(centers);
    end
    
    if and(~isempty(noise),~isfolder([root_cut '\' noise ' Noise - ' num2str(var_noise)]))
        folders=dir(root_orig);
        for j=3:length(folders)
            folder=folders(j).name;
            mkdir([root_cut '\' noise ' Noise - ' num2str(var_noise) '\' folder]);
            mkdir([root_trf '\' noise ' Noise - ' num2str(var_noise) '\' folder]);
            mkdir([root_preproc '\' noise ' Noise - ' num2str(var_noise) '\' folder]);
        end
    end
    
    % Make the preprocessing step of the original images and add noise
    for j=1:tot_imgs
        folder=cases{1,j};
        name_file=names{1,j};
        y=centers(1,j);
        
        % read image
        img = imread([root_orig '\' folder '\' name_file]);
        img = img(:,:,1);
        
        % mask
        k=find(y==centers_ROIs);
        ROI=orig_ROIs{k,1};
        
        % Eliminate the information out of the ROI
        img=img.*ROI;

        if ~isfile([root_preproc '\' folder '\' name_file])
            % Cut the image and the mask
            img_cut=img(57:513,45:size(img,2)-45);
            ROI_cut=ROI(57:513,45:size(img,2)-45);

            % Transform the image from cartesian coordinates to polar
            [img_trf,ROI_trf] = transformation(img(:,:,1),y,ROI(:,:,1));
            %imshow(img_trf)

            % Preprocessing to the image
            img_preproc=medfilt2(img_trf,[9 9]); % median filter
            img_preproc = adapthisteq(img_preproc,'Distribution','rayleigh','Alpha',0.5); % contrast enhacement

            % Save the images
            imwrite(img_cut,[root_cut '\' folder '\' name_file]);
            imwrite(img_trf,[root_trf '\' folder '\' name_file]);
            imwrite(img_preproc,[root_preproc '\' folder '\' name_file]);
            if save_mask==1
                imwrite(ROI_cut,[root_cut '\Masks\' folder '\' name_file]);
                imwrite(ROI_trf,[root_trf '\Masks\' folder '\' name_file]);
            end
        end
        
        % Add noise
        if ~isempty(noise)
            I=im2double(img);
            v = (var_noise*std(I(:)/100))^2; % variance of noise
            if isequal(noise,'SPECKLE') % Add speckle noise to image
                I_noisy = imnoise(I, 'speckle', v);
            else
                if isequal(noise,'GAUSSIAN')% Add gaussian noise to image
                    I_noisy = imnoise(I, 'gaussian', 0, v);
                end
            end
            I_noisy=uint8(255.*I_noisy);
            
            % Transform the image from cartesian coordinates to polar
            [noisy_trf,~] = transformation(I_noisy(:,:,1),y,ROI(:,:,1));
            
            % Cut the image and the mask
            I_noisy=I_noisy.*ROI;
            I_noisy=I_noisy(57:513,45:size(img,2)-45);
            
            
            % Preprocessing to the image
            noisy_preproc=medfilt2(noisy_trf,[9 9]); % median filter
            noisy_preproc = adapthisteq(noisy_preproc,'Distribution','rayleigh','Alpha',0.5); % contrast enhacement
            
            imwrite(I_noisy,[root_cut '\' noise ' Noise - ' num2str(var_noise) '\' folder '\' name_file])
            imwrite(noisy_trf,[root_trf '\' noise ' Noise - ' num2str(var_noise) '\' folder '\' name_file])
            imwrite(noisy_preproc,[root_preproc '\' noise ' Noise - ' num2str(var_noise) '\' folder '\' name_file])
        end
    end
end
