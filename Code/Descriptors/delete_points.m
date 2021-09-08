% Function to delete some SURF points, taking into acount the location and scale.
% Are deleated:
% Points with higger percentage of the area out of the ROI
    % max_percentage: limit of area out of the ROI
% Overlapped points with similar scale, with these criteria:
    % step_location: maximum distance of the centers in pixels
    % step_scale: maximum scale difference


function points_out = delete_points(points,mask,NumScaleLevels,max_percent,step_location,step_scale)

% Delete points with higger percentage of the area out of the ROI
x_location=round(points.Location(:,1));
y_location=round(points.Location(:,2));
scale=ceil(points.Scale*(NumScaleLevels+1));

mask2=zeros(size(mask));
mask2=insertShape(mask2,'FilledCircle',[x_location y_location scale],'Color','w','Opacity',1);
mask2=and(~mask,mask2);
mask2=mask2(:,:,1);

if ~all(all(mask2==0))
    max_scale=max(scale)/2;
    locations=bwboundaries(mask2(:,:,1));
    l=1:points.Count;
    l1=l;
    k=[];
    for i=1:length(locations)
        minim= min(locations{i})-max_scale;
        maxim= max(locations{i})+max_scale;
        
        m=find(y_location>minim(1));
        locationy1=y_location(m);
        n=find(locationy1<maxim(1));
        m=m(n);
        locationx1=x_location(m);
        n=find(locationx1<maxim(2));
        n=m(n);
        locationx1=x_location(n);
        n=find(locationx1>minim(2));
        k=[k m(n)'];
        l1(m(n))=0;
    end
    l=l1(l1>0);
    
    x_location=x_location(k);
    y_location=y_location(k);
    scale=scale(k);
    for i=1:length(k)
        yc=y_location(i);
        xc=x_location(i);
        s=scale(i);
        miny=yc-s;
        maxy=yc+s;
        minx=xc-s;
        maxx=xc+s;
        if minx<1 || miny<1
            mask_point=mask(max(1,miny):min(maxy,size(mask,1)),max(1,minx):min(maxx,size(mask,2)));
        else
            if maxy>size(mask,1) || maxx>size(mask,2)
                mask_point=mask(miny:min(maxy,size(mask,1)),minx:min(maxx,size(mask,2)));
            else
                mask_point=mask(miny:maxy,minx:maxx);
            end
        end
        if  min(min(mask_point))==255
            l=[l k(i)];
        else
            size1=size(mask_point);
            size1=[1 1]*max(size1);
            mask_point_teor=zeros(size1);
            mask_point_teor= insertShape(mask_point_teor,'filledcircle',[size1/2 s],'Color','w','Opacity',1);
            mask_point_teor=mask_point_teor(:,:,1);
            if minx<1 || miny<1
                if minx<1
                    mask_point_teor=mask_point_teor(:,abs(minx)+2:end);
                else
                    mask_point_teor=mask_point_teor(abs(miny)+2:end,:);
                end
            else
                if maxy>size(mask,1) && maxx>size(mask,2)
                    mask_point_teor=mask_point_teor(1:size(mask_point,1),1:size(mask_point,2));
                else
                    if maxy>size(mask,1) || maxx>size(mask,2)
                        if maxy>size(mask,1)
                            dif=maxy-size(mask,1);
                            mask_point_teor=mask_point_teor(1:end-dif,:);
                        else
                            dif=maxx-size(mask,2);
                            mask_point_teor=mask_point_teor(:,1:end-dif);
                        end
                    end
                end
            end
            teorical_ones=length(find(mask_point_teor>0));
            if max(size(mask_point) ~= size(mask_point_teor))==1
                mask_point_teor=imresize(mask_point_teor,size(mask_point));
            end
            mask_point_teor=round(mask_point_teor);
            point_ones=length(find((and(mask_point,mask_point_teor))==1));
            porcent=point_ones*100/teorical_ones;
            if porcent>max_percent
                l=[l k(i)];
            end
        end
    end
    points2=points(l);
else
    points2=points;
end

% Delete overlapped points with similar scale
x_location=round(points2.Location(:,1));
y_location=round(points2.Location(:,2));
[x_location,k1]=sort(x_location);
x_location=[x_location; x_location(end)+step_location+1];
y_location=y_location(k1);
scale=points2.Scale(k1);
scale_round=round(scale);

eliminated=[];
for i=1:points2.Count
    minx=x_location(i);
    if minx~=0
        j=find(x_location>minx+step_location);
        if ~isempty(j)
            j=j(1)-1;
            locy_point=y_location(i);
            locy_points=y_location(i+1:j,:);
            if ~isempty(locy_points)
                iqual=[];
                scales=[];
                for m=1:length(locy_points)
                    difference_y=locy_points(m)-locy_point;
                    if abs(difference_y)<=step_location
                        difference_scale=abs(scale_round(m+i)-scale_round(i));
                        if abs(difference_scale)<=step_scale
                            iqual=[iqual; i; i+m];
                            scales=[scales; scale(i); scale(i+m)];
                            x_location(i+m)=0;
                        end
                    end
                end
                if ~isempty(iqual)
                    u=1:length(iqual);
                    [~,b]=max(scales);
                    u = u(u~=b);
                    eliminated=[eliminated; k1(iqual(u))];
                end
            end
        end
    end
end

k1=sort(k1);
eliminated=sort(eliminated);
k1(eliminated)=[];

points_out=points2(k1);
end
