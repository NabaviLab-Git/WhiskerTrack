function stop_draw_line(varargin)
global WT;
set(gcf,'windowbuttonmotionfcn','');
set(gcf,'windowbuttonupfcn','');
%
if WT.Point2(WT.line_num,2)>WT.Point1(WT.line_num,2)
    temp = WT.Point2(WT.line_num,:);
    WT.Point2(WT.line_num,:) = WT.Point1(WT.line_num,:);
    WT.Point1(WT.line_num,:) = temp;
end
%
WT.Title = title(['Select wiskers by drawing lines ( ' num2str(WT.line_num) ' / ' num2str(WT.Whiskers_Num) ' )']);
if WT.line_num == WT.Whiskers_Num
    if WT.LightStimFlag
    WT.Title = title('Select a region to detect the light stimulation by drawing a rectangular');
    set(gcf,'WindowButtonDownFcn','draw_rect');
    else
    stop_draw_rect();
    end
else
    WT.line_num = WT.line_num + 1;
end
end