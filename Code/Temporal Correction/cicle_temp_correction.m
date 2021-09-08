% Function that correct the miss-classification frames during the video, 
% taking into account a previous and subsequent labels in a window of frames. 
% Required scripts:
    % temp_correction
function cicle_temp_correction(num_it,clasif,window,threshold,root_results)
    load([root_results '\metrics_' num2str(num_it) '_iterations.mat'])
    eval(['predictions=predictions_' clasif ';']);

    predictions_filt_tot=cell(num_it,1);
    metrics_filt_tot=zeros(num_it,15);
    % Cycle to process each iteration
    for it=1:num_it
        labels_it=labels_test_tot{it};
        predictions_it=predictions{it};
        names_it=names_test_tot{it,1};
        names_it=cat(1, names_it{:});

        % Apply the temporal correction to consecutive frames
        name_before=names_it{1,1};
        predictions_it_filt=[];
        pred=predictions_it(1,:);
        for k=2:length(names_it)
            name=names_it{k,1};
            numb=findstr(name,'_')+1;
            resta=str2num(name(numb:end-4))-str2num(name_before(numb:end-4));
            if resta<=2
                pred=[pred; predictions_it(k,:)];
            else
                predictions_filt_adaboost = temp_correction(pred(:,1),window,threshold);
                predictions_filt_rbf = temp_correction(pred(:,2),window,threshold);
                predictions_filt_linear = temp_correction(pred(:,3),window,threshold);

                predictions_it_filt=[predictions_it_filt; predictions_filt_adaboost predictions_filt_rbf predictions_filt_linear];
                pred=predictions_it(k,:);
            end
            name_before=name;
        end    
        predictions_filt_adaboost = temp_correction(pred(:,1),window,threshold);
        predictions_filt_rbf = temp_correction(pred(:,2),window,threshold);
        predictions_filt_linear = temp_correction(pred(:,3),window,threshold);
        predictions_it_filt=[predictions_it_filt; predictions_filt_adaboost predictions_filt_rbf predictions_filt_linear];

        predictions_filt_tot{it,1}=predictions_it_filt;

        positive=(labels_it==1);
        negative=(labels_it==0);
        P= sum(positive);
        N=sum(negative);
        [~,~,~,~,acc_filt,sens_filt,spec_filt,f1_filt,pres_filt] = confussion_matrix(predictions_it_filt,positive,negative,P,N);

        metrics_filt_tot(it,:)=[acc_filt sens_filt spec_filt f1_filt pres_filt];
    end
    if num_it~=1
        metrics_filt_tot=[metrics_filt_tot; mean(metrics_filt_tot); std(metrics_filt_tot)];
    end
    save([root_results '\metrics_temp_corr_W' num2str(window) '_T' num2str(threshold) '_' clasif '_clasif.mat'],'metrics_filt_tot','predictions_filt_tot')
end

