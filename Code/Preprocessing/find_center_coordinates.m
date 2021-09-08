% Function to find the center of coordinates (center of the cone) and the
% mask of the image (US cone)

function [y,ROIf] = find_center_coordinates(img)
img_t=img;
img=[zeros(100,size(img,2)); img];

% General boundaries of the cone
x_min=20;
x_max=780;
y_bottom=612;

% Contrast enhacement to find the border of the cone better
img=imadjust(img);
img=medfilt2(img);

% Binarize the image
ROI=double(imbinarize(img,0.05));
ROI= imfill(ROI,'hole');

% Delete the superimposed information that affect the detection of the
% boundaries
ROI(175:300,45:65)=0;
ROI(540:700,10:90)=0;

% Selection of ROI
ROI=or(ROI,fliplr(ROI));
ROI= bwareafilt(logical(ROI),2);
ROI_left= boundarymask(ROI(1:(size(ROI,1)/2),1:size(ROI,2)/2,:));
ROI_right= boundarymask(ROI(1:(size(ROI,1)/2),size(ROI,2)/2:end,:));

% Find the lines
[H,T,R] = hough( ROI_left,'RhoResolution',1,'Theta',[5:1:89]);
lines_left = houghlines(ROI_left,T,R,houghpeaks(H,10),'MinLength',50);
[H,T,R] = hough(ROI_right,'RhoResolution',1,'Theta',[-90:1:-5]);
lines_right = houghlines(ROI_right,T,R,houghpeaks(H,10),'MinLength',50);

% Find the intersection between the candidate lines and the center of the image
flg=0; i=1; j=1; i_ini=1;
while flg==0
    % define the points of the lines
    xy_left = [lines_left(i).point1; lines_left(i).point2];
    xy_rigth = [lines_right(j).point1; lines_right(j).point2];
    
    % find the line equation
    [~,m_left,b_left] = regression(xy_left(:,1)' ,xy_left(:,2)');
    y1_left=round(m_left*1+b_left);
    y2_left=round(m_left*410+b_left);
    [~,m_right,b_right] = regression(xy_rigth(:,1)'+400 ,xy_rigth(:,2)');
    y1_right=round(m_right*390+b_right);
    y2_right=round(m_right*800+b_right);
    
    % Find the intersection
    left=insertShape(zeros(size(img)),'line',[1 y1_left 410 y2_left]);
    right=insertShape(zeros(size(img)),'line',[390 y1_right 800 y2_right]);
    [ky,kx]=find(and(left,right));
    if find(and(kx>396,kx<404)) % verify if the intersection is in the middle of the image
        k=find(kx==400);
        y=ky(k(1));
        y_min=round(m_left*x_min+b_left);
        flg=1;
    else
        y_left=round(m_left*400+b_left);
        y_right=round(m_right*400+b_right);
        
        if abs(y_left-y_right)<=5
            y=mean([y_left y_right]);
            y_min=round(m_left*x_min+b_left);
        end
    end
    
    j=j+1;
    if j>length(lines_right)
        i=i_ini+1;
        j=1;
        i_ini=i_ini+1;
    end
    
    % don't find the intersection
    if and(i_ini>length(lines_left),flg==0) 
        flg=1;
    end
    
end

% Construct the cone
ROI=uint8(ROI);
x1_bottom=find(ROI(y_bottom,:),1,'first');

try S1=sqrt(((find(ROI(:,x_min),1,'last')-y)^2)+((400-x_min)^2));
catch
    S1=600;
end
try S2=sqrt(((y_bottom-y)^2)+((400-x1_bottom)^2));
catch
    S2=600;
end
rad=min(S1,S2);
circle=insertShape(zeros(size(ROI)),'FilledCircle',[400 y rad]);
ROI=insertShape(zeros(size(ROI)),'FilledPolygon',[x_min y_min 400 y x_max y_min x_max y_bottom x_min y_bottom]);
k=find(ROI(165,:),1,'first');
rad=sqrt(((165-y)^2)+((400-k)^2));
circle2=insertShape(zeros(size(ROI)),'FilledCircle',[400 y rad]);
ROI=uint8(and(ROI(:,:,1),and(circle(:,:,1),~circle2(:,:,1))));

y=round(y-100);
ROI=ROI(101:end,:);

se =  strel('disk',5);
dilatedI = imdilate(ROI,se);

ROI_t=1-dilatedI(120:510,100:700);
img_t=img_t(120:510,100:700);
m=(ROI_t.*img_t);
if sum(m(:))<1500
    ROIf=ROI;
end
end