% function to perform a fold validation, in each iteration is performed the 
% training and testing satages, it is used the default score in the predictions
% and a threshold values to obtain the AUC curves.
% The training models are:
    % Adaboost
    % SVM with RBF kernel
    % SVM with linear kernel
    
% Required scripts:
    % prediction_function
    % cicle_AUC
    % confussion_matrix

function clasification_cicle(type_points,num_it_adaboost,main_results,name_test,flg_sc,flg_optim,root_features)
    load([main_results 'train_iterations.mat'],'train') 
    num_it=length(train); % Number of Cross-Validation iterations
    
    load(root_features)
    eval(['features=features_cases_' type_points ';'])

    root_out=[main_results 'CLASSIFICATION\' name_test];
    if ~isfolder(root_out)
        mkdir(root_out)
    end

    % Variable initialization
    labels_train_tot=cell(num_it,1);
    labels_test_tot=cell(num_it,1);
    names_cases_train_tot=cell(num_it,1);
    names_cases_test_tot=cell(num_it,1);
    names_train_tot=cell(num_it,1);
    names_test_tot=cell(num_it,1);
    frames=zeros(10,6);

    acc_orig=zeros(num_it,3); sens_orig=zeros(num_it,3); spec_orig=zeros(num_it,3);
    f1_orig=zeros(num_it,3); pres_orig=zeros(num_it,3); 
    predictions_orig=cell(num_it,1);
    auc_orig=zeros(num_it,3);

    acc_optim=zeros(num_it,3); sens_optim=zeros(num_it,3); spec_optim=zeros(num_it,3);
    f1_optim=zeros(num_it,3); pres_optim=zeros(num_it,3); 
    auc_optim=zeros(num_it,3);
    predictions_optim=cell(num_it,1);
    
    acc_best=zeros(num_it,3); sens_best=zeros(num_it,3); spec_best=zeros(num_it,3);
    f1_best=zeros(num_it,3); pres_best=zeros(num_it,3);
    predictions_best=cell(num_it,1);
    
    predictions=cell(num_it,1);

    if ~isempty(flg_optim)
        root_out=[root_out '\Optim'];
        mkdir(root_out);
        if isfile([root_out '\optimizacion.txt'])
            delete([root_out '\optimizacion.txt'])
        end
        diary([root_out '\optimizacion.txt'])
        diary on
    end
    
    % Cross-Validation 
    for it=1:num_it
        disp(['Iteration' num2str(it)]);

        % Train and test cases of the fold
        train_it=train{it,1};
        train_it=[train_it{:}];
        train_it=strrep(train_it,'C','_C');
        train_it=strrep(train_it,'H','_H');
        train_it=strrep(train_it,'P','_P');
        train_it=[train_it '_'];
        train_indx=[];
        test_indx=[];
        for i=1:length(names_folders)
           name=char(names_folders{i,1});
           if ~contains(train_it,['_' name(1:end-4) '_'] )
               test_indx=[test_indx; i];
           else
               train_indx=[train_indx; i];           
           end
        end

        % Train and test features
        features_test=cell2mat(features(test_indx,1));
        features_train=cell2mat(features(train_indx,1));
        labels_test=cell2mat(labels(test_indx,1));
        labels_train=cell2mat(labels(train_indx,1));    
        names_train=names(train_indx);
        names_test=names(test_indx);    
        names_case_train=names_folders(train_indx);
        names_case_test=names_folders(test_indx);

        % Selection of features from only specific scales
        if min(flg_sc) ~= 0 
            if size(features_test,2)>960
                cant=size(features_test,2)/960;
                feat_test=[];
                feat_train=[];
                for f=1:cant
                    feat_test=[feat_test features_test(:,960*(f-1)+(flg_sc(1)-1):960*(f-1)+(64*(flg_sc(2)-1)))];
                    feat_train=[feat_train features_train(:,960*(f-1)+(flg_sc(1)-1):960*(f-1)+(64*(flg_sc(2)-1)))];
                end
                features_test=feat_test;
                features_train=feat_train;
            else
                features_test=features_test(:,flg_sc(1)-1:64*(flg_sc(2)-1));
                features_train=features_train(:,flg_sc(1)-1:64*(flg_sc(2)-1));
            end
        end

        % Classification
        clf(figure(1))
        [ac,au,sen,spc,f,p,prediction,score,X,Y,clasifiers]   = prediction_function(features_train, labels_train,num_it_adaboost,features_test,labels_test,flg_optim);

        % Store the features
        frames(it,:)= [sum(labels_train==1) sum(labels_train==0) length(labels_train) sum(labels_test==1) sum(labels_test==0) length(labels_test)];
        predictions_ada=prediction{1,1};
        predictions_rbf=prediction{1,2};
        predictions_linear=prediction{1,3};
        
        labels_train_tot{it}=labels_train;
        labels_test_tot{it}=labels_test;
        names_cases_test_tot{it}=names_case_test;
        names_cases_train_tot{it}=names_case_train;
        names_test_tot{it}=names_test;
        names_train_tot{it}=names_train;

        predictions{it,1}=prediction;

        acc_orig(it,:)=ac(1,:);
        sens_orig(it,:)=sen(1,:);
        spec_orig(it,:)=spc(1,:);
        f1_orig(it,:)=f(1,:);
        pres_orig(it,:)=p(1,:);
        auc_orig(it,:)=au(1,:);
        predictions_orig{it,1}=[predictions_ada(:,1) predictions_rbf(:,1) predictions_linear(:,1)];

        if ~isempty(flg_optim)
            acc_optim(it,:)=ac(2,:);
            sens_optim(it,:)=sen(2,:);
            spec_optim(it,:)=spc(2,:);
            f1_optim(it,:)=f(2,:);
            pres_optim(it,:)=p(2,:);
            auc_optim(it,:)=au(2,:);
            predictions_optim{it,1}=[predictions_ada(:,2) predictions_rbf(:,2) predictions_linear(:,2)];
        end

        [~,m_ada]=max(ac(:,1));
        [~,m_rbf]=max(ac(:,2));
        [~,m_lin]=max(ac(:,3));
        acc_best(it,:)=[ac(m_ada,1) ac(m_rbf,2) ac(m_lin,3)];
        sens_best(it,:)=[sen(m_ada,1) sen(m_rbf,2) sen(m_lin,3)];
        spec_best(it,:)=[spc(m_ada,1) spc(m_rbf,2) spc(m_lin,3)];
        f1_best(it,:)=[f(m_ada,1) f(m_rbf,2) f(m_lin,3)];
        pres_best(it,:)=[p(m_ada,1) p(m_rbf,2) p(m_lin,3)];
        predictions_best{it,1}=[predictions_ada(:,m_ada) predictions_rbf(:,m_rbf) predictions_linear(:,m_lin)];

        save([root_out '/training_it' num2str(it) '.mat'],'ac','au','sen','spc','f','p','prediction','labels_test','names_test','score','X','Y')
        save([root_out '/clasif_it' num2str(it) '.mat'],'clasifiers')
        saveas(figure(1),[root_out '/AUC_it' num2str(it) '.png'])    
    end
    if ~isempty(flg_optim)
        save([root_out '\metrics_' num2str(it) '_iterations.mat'],'labels_test_tot','names_cases_test_tot','names_test_tot','frames','acc_orig','sens_orig','spec_orig','f1_orig','pres_orig','predictions','predictions_orig','predictions_optim','predictions_best','auc_orig','acc_best','sens_best','spec_best','f1_best','pres_best','acc_optim','sens_optim','spec_optim','f1_optim','pres_optim','auc_optim');
        diary off
    else
        save([root_out '\metrics_' num2str(it) '_iterations.mat'],'labels_test_tot','names_cases_test_tot','names_test_tot','frames','acc_orig','sens_orig','spec_orig','f1_orig','pres_orig','predictions','predictions_orig','predictions_best','auc_orig','acc_best','sens_best','spec_best','f1_best','pres_best');
    end
    
end



