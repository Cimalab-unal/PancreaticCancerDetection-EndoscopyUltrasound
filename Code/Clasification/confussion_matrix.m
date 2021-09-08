% Function to calculate the confussion matrix and the tipycal metrics
function [TP,TN,FP,FN,acc,sens,spec,f1,presition] = confussion_matrix(prediction,positive,negative,P,N)
    positive_prediction=(prediction==1);
    negative_prediction=(prediction==0);

    % Metrics
    TP=and(positive,positive_prediction);
    FP=and(negative,positive_prediction);
    TN=and(negative,negative_prediction);
    FN=and(positive,negative_prediction);
    TP=sum(TP);
    TN=sum(TN);
    FP=sum(FP);
    FN=sum(FN);
    acc=(TP+TN)/(P+N);
    sens=TP/P;
    spec=TN/N;
    f1=TP./(TP+((1/2)*(FP+FN)));
    presition=TP./(TP+FP);
end

