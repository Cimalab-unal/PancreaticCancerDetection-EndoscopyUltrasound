% Function to create a video of each case with the original image, the
% detected cone and the preprocessing stage to verify if some images have
% a bad transformation or bad cone mask

function verify_video(main_root)
    % Directories
    root_orig=[main_root 'Original'];
    root_cut=[main_root 'Original_Cut'];
    root_trf=[main_root 'Transformed'];
    root_preproc=[main_root 'Preprocessed'];
    mkdir([main_root '\Verify_Videos\'])
    
    % Cycle to process all the videos
    folders=dir(root_cut);
    for j=3:length(folders)
        folder=folders(j).name;  
        
        % Create and open the video object
        video_out = VideoWriter([main_root '\Verify_Videos\' folder],'MPEG-4'); 
        video_out.FrameRate=15;
        open(video_out);
        
        % Cycle to process each image
        imgs=dir([root_cut '\' folder '\' '*.tif']);
        for a=1:length(imgs) % a=1
            name_file=imgs(a).name;
            
            % read the images and masks
            img_orig = imread([root_orig '\' folder '\' name_file]);
            img_cut = imread([root_cut '\' folder '\' name_file]);
            img_trf = imread([root_trf '\' folder '\' name_file]);
            img_preproc = imread([root_preproc '\' folder '\' name_file]);            
            ROI_orig_mask = imread([root_cut '\Masks\' folder '\' name_file]);
            ROI_trf_mask = imread([root_trf '\Masks\' folder '\' name_file]);
            
            % Delineate the ROI in the images
            se = strel('disk',2);
            img = round(imdilate(edge(ROI_orig_mask),se));
            k=find(img);
            img_cut(k)=255;
            img = round(imdilate(edge(ROI_trf_mask),se));
            k=find(img);
            img_trf(k)=255;
            img_preproc(k)=255;
            
            % Save the frame
            subs=size(img_cut)-size(img_trf);
            if subs(1) > 0
                fig=[img_trf img_preproc; zeros(subs(1),2*size(img_preproc,2))];
                fig=[img_cut fig];
                subs=size(img_orig,1)-size(fig,1);
                fig=[zeros(57, size(fig,2)); fig; zeros(subs-57, size(fig,2))];
                fig=[img_orig(:,:,1) fig];
            else
                subs=size(img_orig,1)-size(img_cut,1);
                fig=[zeros(57, size(img_cut,2)); img_cut; zeros(subs-57, size(img_cut,2))];
                fig1=[img_orig(:,:,1) fig];
                
                subs=size(img_orig,1)-size(img_trf,1);
                fig=[zeros(57,2*size(img_trf,2)); img_trf img_preproc; zeros(subs-57,2*size(img_trf,2))];
                fig=[fig1 fig];
            end
            
            try  writeVideo(video_out,fig);
            catch
                fig=imresize(fig,[video_out.Height video_out.Width]);
                writeVideo(video_out,fig);
            end
        end
        close(video_out);
    end
end