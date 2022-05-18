function draw_line(varargin)
global WT;
coords = get(gca,'currentpoint');
WT.Point2(WT.line_num,:) = coords(1,1:2);
WT.Line(WT.line_num).XData(2) = WT.Point2(WT.line_num,1);
WT.Line(WT.line_num).YData(2) = WT.Point2(WT.line_num,2);
end