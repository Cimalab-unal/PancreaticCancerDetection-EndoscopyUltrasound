% Temporal correction, It is calculated the percentage of ones in a window, 
% if it is higher than a threshold the frame is labeled as a positive class, 
% and if it is lower, the frame is labeled as a negative class
    
function filt_labels = temp_correction(labels,window,threshold)
    step=floor(window/2);
    filt_labels=labels;
    % If the window is smaller of window size
    for i=1:min(step,(length(labels)-step))
        vector=labels(1:i+step);
        count_ones=sum(vector);
        percent=count_ones*100/length(vector);
        if percent>=threshold
            filt_labels(i)=1;
        else
            filt_labels(i)=0;
        end
    end

    % complete window
    for j=i+1:length(labels)-step
        vector=labels(j-step:j+step);
        count_ones=sum(vector);
        percent=count_ones*100/window;
        if percent>=threshold
            filt_labels(j)=1;
        else
            filt_labels(j)=0;
        end
    end

    % If the window is smaller of window size
    for i=j+1:length(labels)
        vector=labels(i-step:length(labels));
        count_ones=sum(vector);
        percent=count_ones*100/length(vector);
        if percent>=threshold
            filt_labels(i)=1;
        else
            filt_labels(i)=0;
        end
    end
end

