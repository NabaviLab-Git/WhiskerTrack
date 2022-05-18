function select_point(varargin)
global WT;
coords = get(gca,'currentpoint');
WT.Point1(WT.line_num,:) = round(coords(1,1:2));
WT.Point2(WT.line_num,:) = round(coords(1,1:2));
WT.Line(WT.line_num)     = plot([WT.Point1(WT.line_num,1) WT.Point2(WT.line_num,1)],[WT.Point1(WT.line_num,2) WT.Point2(WT.line_num,2)],'-o','linew',1.5,'MarkerSize',3);
set(gcf,'windowbuttonmotionfcn',@draw_line);
set(gcf,'windowbuttonupfcn',@stop_draw_line);
end