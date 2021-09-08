% Function to transform the image from cartesian to polar coordinates

function [transformed_img,transformed_ROI] = transformation(img,y,ROI)
    % Cut the image from the coordinates center
    size_orig_img=size(img);
    if y<0 % If the cut is above the zero of the image
        img=[zeros(abs(round(y)),size_orig_img(2)) ; img(:,:,1)];
        ROI=[zeros(abs(round(y)),size_orig_img(2)) ; ROI(:,:,1)];
        y=1;
    end
    if round(y)==0
        y=1;
    end
    img=img(round(y):size_orig_img(1),17:786); % cut the image
    ROI=ROI(round(y):size_orig_img(1),17:786);

    % Polar to Cartesian coordinate transformation
    size_img = size(img);
    r = size_img(1);
    c = floor(size_img(2) / 2);
    [X, Y] = meshgrid(-c:c-1,0:r-1);
    [theta, rho] = cart2pol(X, Y);
    rho=round(rho/1.5);
    theta=round((theta*180/pi)*3);
    transformed_img=zeros(max(max(rho))+1,max(max(theta))+1);
    transformed_ROI=zeros(max(max(rho))+1,max(max(theta))+1);
    for i=1:size(img,1)
        for j=1:size(img,2)
            transformed_img(rho(i,j)+1,theta(i,j)+1)=img(i,j);
            transformed_ROI(rho(i,j)+1,theta(i,j)+1)=ROI(i,j);
        end
    end
    B = bwboundaries(transformed_ROI);
    border=[min(B{1}); max(B{1})];

    % Interpolation of zero pixels
    patch_size=3;
    size_side=floor(patch_size/2);
    for i=border(1,1):border(2,1)
        for j=border(1,2):border(2,2)
            patch=transformed_ROI(max(1,i-size_side):min(i+size_side,size(transformed_ROI,1)),max(1,j-size_side):min(j+size_side,size(transformed_ROI,2)));
            if ~all(patch(:)==0)
                if transformed_ROI(i,j)==0
                    transformed_ROI(i,j)=mode(patch(:));
                    patch=transformed_img(max(1,i-size_side):min(i+size_side,size(transformed_ROI,1)),max(1,j-size_side):min(j+size_side,size(transformed_ROI,2)));
                    patch=patch(:);
                    patch=patch(patch>10);
                    transformed_img(i,j)=max(0,median(patch));
                end
            end
        end
    end

    % Median filter
    transformed_img=medfilt2(transformed_img,[3 3]);
    transformed_ROI=medfilt2(transformed_ROI,[3 3]);

    % Cut the images
    B = bwboundaries(transformed_ROI);
    border=[min(B{1}); max(B{1})];
    transformed_img=transformed_img(border(1,1):border(2,1),border(1,2):border(2,2));
    transformed_ROI=transformed_ROI(border(1,1):border(2,1),border(1,2):border(2,2));
    transformed_ROI(1:round(size(transformed_ROI,1)/2),1:end-size_side)=1;
    transformed_img=fliplr(transformed_img);
    transformed_img=uint8(transformed_img);
    transformed_img=imresize(transformed_img,1.5*size(transformed_img));
    transformed_ROI=imresize(transformed_ROI,1.5*size(transformed_ROI));
end