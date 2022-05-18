function stop_draw_rect(varargin)
global WT;
set(gcf,'WindowButtonDownFcn','');
set(gcf,'windowbuttonmotionfcn','');
set(gcf,'windowbuttonupfcn','');
WT.Title = title('Analyzing ...');
if WT.LightStimFlag
    WT.Stim_Loc = round([min(WT.Rect.XData) max(WT.Rect.XData); min(WT.Rect.YData) max(WT.Rect.YData)]);
end
drawnow
analysis_loop();
end