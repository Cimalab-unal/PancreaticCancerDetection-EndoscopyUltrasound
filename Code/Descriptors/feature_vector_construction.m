% Function to construct the feature vector, according to the desired
% metrics and the scale
% It is concatenated the statistic applied to each scale

function feat_statistics=feature_vector_construction(features,scales,flg_mode,flg_median,flg_mean,flg_max,flg_min,flg_entropy,num_est,max_scale)
feat_statistics=[];

% Cycle to find each statistic per scale
for l=2:max_scale
    k=find(scales==l);    
    if ~isempty(k)
        feat_scale=features(k,:);
        if length(k)==1
            feat_scale=[feat_scale; feat_scale];
        end
        if flg_mode == 1
            feat_statistics=[feat_statistics mode(feat_scale)];
        end
        if flg_median == 1
            feat_statistics=[feat_statistics median(feat_scale)];
        end
        if flg_mean == 1
            feat_statistics=[feat_statistics mean(feat_scale)];
        end
        if flg_max == 1
            feat_statistics=[feat_statistics max(feat_scale)];
        end
        if flg_min == 1
            feat_statistics=[feat_statistics min(feat_scale)];
        end
        if flg_entropy == 1
            entropy_feat=zeros(1,64);
            for feat=1:64
                entropy_feat(1,feat)=entropy(feat_scale(:,feat));
            end
            feat_statistics=[feat_statistics entropy_feat];
        end
    else
        feat_statistics=[feat_statistics zeros(1,64*num_est)];
    end
end
end