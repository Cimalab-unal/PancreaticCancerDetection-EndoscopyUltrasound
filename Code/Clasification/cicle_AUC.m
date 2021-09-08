% Function to calculate the metrics with different treshold probability
% scores

% Required scripts:
    % confussion_matrix
function [acc,sens,spec,f1,pres,predictions]=cicle_AUC(score,positive,negative,P,N)
    probability=0.1:0.1:0.9;
    acc=zeros(length(probability),1);
    sens=zeros(length(probability),1);
    spec=zeros(length(probability),1);
    f1=zeros(length(probability),1);
    pres=zeros(length(probability),1);
    predictions=zeros(length(positive),length(probability));

    for k=1:length(probability)
        prob=probability(k);    
        prediction=zeros(size(positive));
        prediction(score>prob)=1;
        [~,~,~,~,acc_c,sens_c,spec_c,f1_c,pres_c] = confussion_matrix(prediction,positive,negative,P,N);

        acc(k,1)=acc_c;
        sens(k,1)=sens_c;
        spec(k,1)=spec_c;
        f1(k,1)=f1_c;
        pres(k,1)=pres_c;      
        predictions(:,k)=prediction;
    end
end