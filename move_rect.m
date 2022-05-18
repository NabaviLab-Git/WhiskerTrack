function move_rect(varargin)
global WT;
coords = get(gca,'currentpoint');
xdata = [WT.Rect.XData(1) coords(1,1) coords(1,1) WT.Rect.XData(1) WT.Rect.XData(1)];
ydata = [WT.Rect.YData(1) WT.Rect.YData(1) coords(1,2) coords(1,2) WT.Rect.YData(1)];
xdata = max(1,min(xdata,size(WT.frame,2)));
ydata = max(1,min(ydata,size(WT.frame,1)));
set(WT.Rect,'XData',xdata,'YData',ydata);
end