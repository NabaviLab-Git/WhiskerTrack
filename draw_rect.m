function draw_rect(varargin)
global WT;
coords = get(gca,'currentpoint');
WT.Rect = plot([coords(1,1) coords(1,1) coords(1,1) coords(1,1) coords(1,1)],[coords(1,2) coords(1,2) coords(1,2) coords(1,2) coords(1,2)],'y','linew',2);
set(gcf,'windowbuttonmotionfcn','move_rect');
set(gcf,'windowbuttonupfcn','stop_draw_rect');
end