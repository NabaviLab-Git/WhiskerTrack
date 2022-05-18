function update_whiskers
global WT;
for ii = 1:WT.Whiskers_Num
    x1 = round(WT.Point1(ii,1));
    x2 = round(WT.Point2(ii,1));
    y1 = round(WT.Point1(ii,2));
    y2 = round(WT.Point2(ii,2));
    %
    ROI = WT.frame(min(y1,y2):max(y1,y2),min(end,max(1,min(x1,x2)-WT.Delta_X_ROI:max(x1,x2)+WT.Delta_X_ROI)),:);
    ROI = double(imadjust(255-ROI));
    x = x2-min(x1,x2)+1+(0:2*WT.Delta_X_ROI);
    Point1 = [x; ones(1,length(x))];
    x = x1-min(x1,x2)+1+(0:2*WT.Delta_X_ROI);
    Point2 = [x; size(ROI,1)*ones(1,length(x))];
    %%
    LineFitVal = -inf(size(Point1,2),size(Point2,2));
    for jj = 1:size(Point1,2)
        for kk = 1:size(Point2,2)
            temp_slope = (Point2(2,kk)-Point1(2,jj))/(Point2(1,kk)-Point1(1,jj));
            if (atand(temp_slope)>=0 && abs(180-atand(temp_slope)-WT.WhiskersAngle(ii,WT.current_frame-1))<=WT.Delta_Theta_ROI) ||...
               (atand(temp_slope)<0 && abs(-atand(temp_slope)-WT.WhiskersAngle(ii,WT.current_frame-1))<=WT.Delta_Theta_ROI)
            x_vec = (min(Point2(1,kk),Point1(1,jj)):max(Point2(1,kk),Point1(1,jj)));
            y_vec = 1:size(ROI);
            if length(x_vec)>=length(y_vec)
                Line_Pix = temp_slope * (x_vec - Point1(1,jj)) + Point1(2,jj);
                Idx = sub2ind(size(ROI),round(Line_Pix),x_vec);
            else
                Line_Pix = (y_vec - Point1(2,jj)) / temp_slope + Point1(1,jj);
                Idx = sub2ind(size(ROI),y_vec,round(Line_Pix));
            end
            LineFitVal(jj,kk) = mean(ROI(Idx));
            end
        end
    end
    [~,IdxMax] = max(LineFitVal(:));
    [idx_1, idx_2] = ind2sub(size(LineFitVal),IdxMax);
    %
    if WT.RealTimePlotFlag && WT.RealTimePlotROIFlag
    imshow(ROI,[],'parent',WT.AXROI(ii))
    hold(WT.AXROI(ii),'on')
    plot(WT.AXROI(ii),[Point1(1,idx_1) Point2(1,idx_2)],[Point1(2,idx_1) Point2(2,idx_2)],'-o','linew',2,'Color',WT.Line(ii).Color,'MarkerSize',4)
    hold(WT.AXROI(ii),'off')
    if ii==1, title(WT.AXROI(1),'ROI'); end
    colormap(WT.AXROI(ii),'bone')
    end
    %
    point = (Point1(:,idx_1)-[WT.Delta_X_ROI;0]).' + [min(x1,x2) min(y1,y2)];
    m = (Point2(2,idx_2)-Point1(2,idx_1))/(Point2(1,idx_2)-Point1(1,idx_1));
    if abs(m)<inf
        b = point(2) - m * point(1);
        p = -1/m;
        %
        y_init = -p * WT.Point1(ii,1) + WT.Point1(ii,2);
        x_proj = (y_init - b) / (m - p);
        y_proj = p * x_proj + y_init;
        point1 = [x_proj y_proj];
        %
        y_init = -p * WT.Point2(ii,1) + WT.Point2(ii,2);
        x_proj = (y_init - b) / (m - p);
        y_proj = p * x_proj + y_init;
        point2 = [x_proj y_proj];
    else
        x_proj = point(1);
        y_proj = WT.Point1(ii,2);
        point1 = [x_proj y_proj];
        %
        x_proj = point(1);
        y_proj = WT.Point2(ii,2);
        point2 = [x_proj y_proj];
    end    
    %
    R1 = norm(point1-point2);
    R2 = norm(WT.Point1(ii,:)-WT.Point2(ii,:));
    temp = (point1+point2)/2;
    point1 = point1 + max(0,1-R1/R2)*(point1-temp);
    point2 = point2 + max(0,1-R1/R2)*(point2-temp);
    %
    WT.Point1(ii,:) = [max(1,min(point1(1),size(WT.frame,2))) max(1,min(point1(2),size(WT.frame,1)))];
    WT.Point2(ii,:) = [max(1,min(point2(1),size(WT.frame,2))) max(1,min(point2(2),size(WT.frame,1)))];
    %
    WT.WhiskersAngle(ii,WT.current_frame) = atand((WT.Point1(ii,1)-WT.Point2(ii,1))/(WT.Point1(ii,2)-WT.Point2(ii,2)))+90;
    WT.WhiskersMiddle(ii,WT.current_frame) = (WT.Point1(ii,2)+WT.Point2(ii,2))/2;
end