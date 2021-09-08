% Function to extract and save the frames of a video, eliminating the
% doppler and elastography images

function names=video2frames(root_input,root_output,frame_ext,video_ext)
    root_output=[root_output '\Original'];

    % Cycle to process each video
    folder=dir([root_input '\*' video_ext]);
    names=cell(length(folder),3);
    for j=1:length(folder)
        file_name=folder(j).name;
    
        % open the video
        video= VideoReader([root_input '\' file_name]); 
        
        file_name=file_name(1:end-4);
        digits=numel(num2str(video.NumFrames)); % numer of digits, ex: 0001
        digits=['%0' num2str(digits) 'd'];

        % Cycle to extract each frame
        names_case={};
        for i = 1 : video.NumFrames
            frame_name=[root_output '\' file_name '\'  file_name '_' num2str(i,digits) frame_ext];
            frame = read(video, i); % read the frame
            % check if image isn't doppler or elastography
            if max(max(frame(:,:,1)-frame(:,:,3)))<250 % If doesn't have blue 
                if ~isfolder([root_output '\' file_name])
                    mkdir([root_output '\' file_name]);% create the directory
                end
                
                imwrite(frame,frame_name); % save the frame
                names_case{end+1,1}=frame_name;
            end
        end
        
        names{j,1}=file_name;
        names{j,2}=length(names_case);
        names{j,3}=names_case;
    end
end

