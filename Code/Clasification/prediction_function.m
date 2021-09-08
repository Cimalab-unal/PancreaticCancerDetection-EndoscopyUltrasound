% Function to train and test the models. The models are optimized if the
% flg_optim is one.
% Also it is calculated the metrics with different treshold probabilities
% to achieve the best metrics, and achieve the AUC curves.

% outputs metrics configuration (acc, sens, spec, f1, pres):
%   [default scores, without optimizing
%    default scores, with optimizing
%    treshold score: 0.01, without optimizing
%    treshold score: 0.02, without optimizing
%    treshold score: 0.03, without optimizing
%    treshold score: 0.04, without optimizing
%    treshold score: 0.05, without optimizing
%    treshold score: 0.06, without optimizing
%    treshold score: 0.07, without optimizing
%    treshold score: 0.08, without optimizing
%    treshold score: 0.09, without optimizing
%    treshold score: 0.01, with optimizing
%    treshold score: 0.02, with optimizing
%    treshold score: 0.03, with optimizing
%    treshold score: 0.04, with optimizing
%    treshold score: 0.05, with optimizing
%    treshold score: 0.06, with optimizing
%    treshold score: 0.07, with optimizing
%    treshold score: 0.08, with optimizing
%    treshold score: 0.09, with optimizing]

% Required scripts:
    % cicle_AUC
    % confussion_matrix

function [acc,auc,sens,spec,f1,pres,predictions,scores,X,Y,clasifiers] = prediction_function(features_train, labels_train, iterations,features_test,labels_test,flg_optim)
    positive=(labels_test==1);
    negative=(labels_test==0);
    P= sum(positive);
    N=sum(negative);

    % Train the models
    disp('Adaboost')
    Adaboost_model = fitensemble(features_train, labels_train,'AdaBoostM1',iterations,'Tree','ScoreTransform','logit');
    disp('SVM RBF kernel')
    SVM_rbf_model=fitcsvm(features_train, labels_train,'KernelFunction', 'rbf','ScoreTransform','logit');
    disp('SVM linear kernel')
    SVM_linear_model = fitcsvm(features_train, labels_train,'KernelFunction', 'linear','ScoreTransform','logit');

    % Test the models
    [predictions_ada,scores_ada] = predict(Adaboost_model,features_test);
    [~,~,~,~,acc_ada,sens_ada,spec_ada,f1_ada,pres_ada] = confussion_matrix(predictions_ada,positive,negative,P,N);
    [predictions_svm_rbf,scores_svm_rbf] = predict(SVM_rbf_model,features_test);
    [~,~,~,~,acc_svm_rbf,sens_svm_rbf,spec_svm_rbf,f1_svm_rbf,pres_svm_rbf] = confussion_matrix(predictions_svm_rbf,positive,negative,P,N);
    [predictions_svm_linear,scores_svm_linear] = predict(SVM_linear_model,features_test);
    [~,~,~,~,acc_svm_linear,sens_svm_linear,spec_svm_linear,f1_svm_linear,pres_svm_linear] = confussion_matrix(predictions_svm_linear,positive,negative,P,N);

    % AUC
    [acc_auc_ada,sens_auc_ada,spec_auc_ada,f1_auc_ada,pres_auc_ada,predictions_auc_ada]=cicle_AUC(scores_ada(:,2),positive,negative,P,N);
    [X_ada,Y_ada,~,auc_ada] = perfcurve(positive,scores_ada(:,2),1);
    [acc_auc_rbf,sens_auc_rbf,spec_auc_rbf,f1_auc_rbf,pres_auc_rbf,predictions_auc_rbf]=cicle_AUC(scores_svm_rbf(:,2),positive,negative,P,N);
    [X_svm_rbf,Y_svm_rbf,~,auc_svm_rbf] = perfcurve(positive,scores_svm_rbf(:,2),1); % Curve
    [acc_auc_linear,sens_auc_linear,spec_auc_linear,f1_auc_linear,pres_auc_linear,predictions_auc_linear]=cicle_AUC(scores_svm_linear(:,2),positive,negative,P,N);
    [X_svm_linear,Y_svm_linear,~,auc_svm_linear] = perfcurve(positive,scores_svm_linear(:,2),1); % Curve
    plot(X_ada,Y_ada)
    hold on
    plot(X_svm_rbf,Y_svm_rbf)
    plot(X_svm_linear,Y_svm_linear)

    % Optimization
    if ~isempty(flg_optim)
        disp('Optimization');
        cp_pz = cvpartition(labels_train,'k',flg_optim{1}); 
        opts_pz = struct('Optimizer','bayesopt','CVPartition',cp_pz,'ShowPlots',false,'AcquisitionFunctionName',flg_optim{2});

        % Adaboost
        disp('Adaboost')
        l=1;
        minimization=zeros(4,3);
        for lr = [0.1 0.25 0.5 1]
            Adaboost_model1 = fitensemble(features_train, labels_train,'AdaBoostM1',iterations,'Tree','CVPartition',cp_pz,'LearnRate',lr);
            genError = kfoldLoss(Adaboost_model1,'Mode','Cumulative');
            [M,I] = min(genError);
            minimization(l,:)=[M I lr];
            l=l+1;
        end
        [~,I] = min(minimization(:,1));
        disp(['lr: ' num2str(minimization(I,3)) ', iteraciones: ' num2str(minimization(I,2))])
        lr=minimization(I,3);
        iterations=minimization(I,2);
        Adaboost_model_optim = fitensemble(features_train, labels_train,'AdaBoostM1',iterations,'Tree','ScoreTransform','logit','LearnRate',lr);
        [prediction_ada_optim,scores_ada_optim] = predict(Adaboost_model_optim,features_test);
        [~,~,~,~,acc_ada_optim,sens_ada_optim,spec_ada_optim,f1_ada_optim,pres_ada_optim] = confussion_matrix(prediction_ada_optim,positive,negative,P,N);
        % AUC
        [acc_ada_op_auc,sens_ada_op_auc,spec_ada_op_auc,f1_ada_op_auc,pres_ada_op_auc,predictions_ada_op_auc]=cicle_AUC(scores_ada_optim(:,2),positive,negative,P,N);
        [X_ada_optim,Y_ada_optim,~,auc_ada_optim] = perfcurve(positive,scores_ada_optim(:,2),1);
        plot(X_ada_optim,Y_ada_optim)

        % SVM RBF kernel
        disp('SVM RBF kernel')
        SVM_rbf_model_optim=fitcsvm(features_train, labels_train,'KernelFunction', 'rbf', 'OptimizeHyperparameters','auto','HyperparameterOptimizationOptions',opts_pz); % corre el svm(rbf) con optimizador
        [prediction_rbf_optim,scores_rbf_optim] = predict(SVM_rbf_model_optim,features_test);
        [~,~,~,~,acc_rbf_optim,sens_rbf_optim,spec_rbf_optim,f1_rbf_optim,pres_rbf_optim] = confussion_matrix(prediction_rbf_optim,positive,negative,P,N);
        % AUC
        [acc_rbf_op_auc,sens_rbf_op_auc,spec_rbf_op_auc,f1_rbf_op_auc,pres_rbf_op_auc,prediction_rbf_op_auc]=cicle_AUC(scores_rbf_optim(:,2),positive,negative,P,N);
        [X_rbf_optim,Y_rbf_optim,~,auc_rbf_optim] = perfcurve(positive,scores_rbf_optim(:,2),1);
        plot(X_rbf_optim,Y_rbf_optim)

        % SVM kernel lineal
        disp('SVM linear kernel')
        SVM_linear_model_optim = fitcsvm(features_train, labels_train,'KernelFunction', 'linear', 'OptimizeHyperparameters','auto','HyperparameterOptimizationOptions',opts_pz); % corre el svm(rbf) con optimizador
        [prediction_linear_optim,scores_linear_optim] = predict(SVM_linear_model_optim,features_test);
        [~,~,~,~,acc_linear_optim,sens_linear_optim,spec_linear_optim,f1_linear_optim,pres_linear_optim] = confussion_matrix(prediction_linear_optim,positive,negative,P,N);
        % AUC
        [acc_linear_op_auc,sens_linear_op_auc,spec_linear_op_auc,f1_linear_op_auc,pres_linear_op_auc,prediction_linear_op_auc]=cicle_AUC(scores_linear_optim(:,2),positive,negative,P,N);
        [X_linear_optim,Y_linear_optim,~,auc_linear_optim] = perfcurve(positive,scores_linear_optim(:,2),1);
        plot(X_linear_optim,Y_linear_optim)

        legend('Adaboost orig','RBF orig','Lineal orig','Adaboost optim','RBF optim','Lineal optim')
        clasifiers={Adaboost_model,Adaboost_model_optim,SVM_rbf_model,SVM_rbf_model_optim,SVM_linear_model,SVM_linear_model_optim};

        % Concatenation    
        acc= [acc_ada acc_svm_rbf acc_svm_linear; acc_ada_optim acc_rbf_optim acc_linear_optim; acc_auc_ada acc_auc_rbf acc_auc_linear; acc_ada_op_auc acc_rbf_op_auc acc_linear_op_auc];
        sens= [sens_ada sens_svm_rbf sens_svm_linear; sens_ada_optim sens_rbf_optim sens_linear_optim; sens_auc_ada sens_auc_rbf sens_auc_linear; sens_ada_op_auc sens_rbf_op_auc sens_linear_op_auc];
        spec= [spec_ada spec_svm_rbf spec_svm_linear; spec_ada_optim spec_rbf_optim spec_linear_optim; spec_auc_ada spec_auc_rbf spec_auc_linear;  spec_ada_op_auc spec_rbf_op_auc spec_linear_op_auc];
        f1= [f1_ada f1_svm_rbf f1_svm_linear; f1_ada_optim f1_rbf_optim f1_linear_optim; f1_auc_ada f1_auc_rbf f1_auc_linear; f1_ada_op_auc f1_rbf_op_auc f1_linear_op_auc];
        pres= [pres_ada pres_svm_rbf pres_svm_linear; pres_ada_optim pres_rbf_optim pres_linear_optim; pres_auc_ada pres_auc_rbf pres_auc_linear; pres_ada_op_auc pres_rbf_op_auc pres_linear_op_auc];
        auc= [auc_ada auc_svm_rbf auc_svm_linear; auc_ada_optim auc_rbf_optim auc_linear_optim];

        predictions_ada =[predictions_ada prediction_ada_optim predictions_auc_ada predictions_ada_op_auc];
        predictions_svm_rbf =[predictions_svm_rbf prediction_rbf_optim predictions_auc_rbf  prediction_rbf_op_auc];
        predictions_svm_linear =[predictions_svm_linear prediction_linear_optim  predictions_auc_linear  prediction_linear_op_auc];

        predictions={predictions_ada,predictions_svm_rbf, predictions_svm_linear};
        scores=[scores_ada scores_ada_optim scores_svm_rbf scores_rbf_optim scores_svm_linear scores_linear_optim];
        X={X_ada, X_ada_optim, X_svm_rbf, X_rbf_optim, X_svm_linear, X_linear_optim};
        Y={Y_ada, Y_ada_optim, Y_svm_rbf, Y_rbf_optim, Y_svm_linear, Y_linear_optim};    
    else
        legend('Adaboost','SVM RBF kernel','SVM Linear kernel')
        clasifiers={Adaboost_model,SVM_rbf_model,SVM_linear_model};

        % Concatenation
        acc=[acc_ada acc_svm_rbf acc_svm_linear; acc_auc_ada acc_auc_rbf acc_auc_linear];
        sens=[sens_ada sens_svm_rbf sens_svm_linear; sens_auc_ada sens_auc_rbf sens_auc_linear];
        spec=[spec_ada spec_svm_rbf spec_svm_linear; spec_auc_ada spec_auc_rbf spec_auc_linear];
        f1=[f1_ada f1_svm_rbf f1_svm_linear; f1_auc_ada f1_auc_rbf f1_auc_linear];
        pres=[pres_ada pres_svm_rbf pres_svm_linear; pres_auc_ada pres_auc_rbf pres_auc_linear];
        auc=[auc_ada auc_svm_rbf auc_svm_linear];        

        predictions={[predictions_ada predictions_auc_ada], [predictions_svm_rbf predictions_auc_rbf], [predictions_svm_linear predictions_auc_linear]};
        scores=[scores_ada scores_svm_rbf scores_svm_linear];
        X={X_ada, X_svm_rbf,X_svm_linear};
        Y={Y_ada, Y_svm_rbf, Y_svm_linear};    
    end
end


