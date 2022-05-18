function analysis_loop
global WT;

%%
WT.WhiskersAngle = zeros(WT.Whiskers_Num,WT.V.NumFrames);
WT.WhiskersMiddle = zeros(WT.Whiskers_Num,WT.V.NumFrames);
for ii = 1:WT.Whiskers_Num
    WT.WhiskersAngle(ii,WT.current_frame) = atand((WT.Point1(ii,1)-WT.Point2(ii,1))/(WT.Point1(ii,2)-WT.Point2(ii,2)))+90;
    WT.WhiskersMiddle(ii,WT.current_frame) = (WT.Point1(ii,2)+WT.Point2(ii,2))/2;
end
if WT.SaveResultFlag
    saveas(gcf,[WT.File_Name(1:end-4) '_Whiskers_Final.png'])
end

%%
if WT.RealTimePlotFlag
    figure('Unit','Normalized','Position',[0.2 0.05 0.6 0.85])
    axes('Position',[0.03 0.02 0.5 0.9])
    hold on
    WT.Handle2 = imshow(WT.frame);
    WT.Title2  = title(['Time = ' num2str(round((WT.current_frame-1)/WT.V.NumFrames*WT.V.Duration)) ' / ' num2str(round(WT.V.Duration)) ' sec']);
    for ii = 1:WT.Whiskers_Num
        WT.Line(ii) = plot([WT.Point1(ii,1) WT.Point2(ii,1)],[WT.Point1(ii,2) WT.Point2(ii,2)],'-o','linew',1.5,'MarkerSize',3);
    end
    if WT.LightStimFlag
        plot(WT.Rect.XData,WT.Rect.YData,'y','linew',2)
    end
    WT.DisplayTime = 10;
    WT.AXSignal = gobjects(WT.Whiskers_Num,1);
    WT.AXROI    = gobjects(WT.Whiskers_Num,1);
    grid on, hold on
    WT.WhiskersAnglePlot = gobjects(WT.Whiskers_Num,1);
    for ii = 1:WT.Whiskers_Num
        if WT.RealTimePlotROIFlag
            WT.AXSignal(ii) = axes('Position',[0.53 0.11+(WT.Whiskers_Num-ii)*0.85/WT.Whiskers_Num 0.23 (0.85-0.05*(WT.Whiskers_Num-1))/WT.Whiskers_Num]);
        else
            WT.AXSignal(ii) = axes('Position',[0.53 0.11+(WT.Whiskers_Num-ii)*0.85/WT.Whiskers_Num 0.44 (0.85-0.05*(WT.Whiskers_Num-1))/WT.Whiskers_Num]);
        end
        WT.WhiskersAnglePlot(ii) = plot(WT.AXSignal(ii),(max(1,WT.current_frame-WT.DisplayTime*WT.V.FrameRate):WT.current_frame)/WT.V.NumFrames*WT.V.Duration,WT.WhiskersAngle(ii,max(1,WT.current_frame-WT.DisplayTime*WT.V.FrameRate):WT.current_frame),'linew',1.5,'Color',WT.Line(ii).Color);
        box off
        ylabel(WT.AXSignal(ii),['Whisker ' num2str(ii)])
        if WT.RealTimePlotROIFlag
            WT.AXROI(ii) = axes('Position',[0.77 0.11+(WT.Whiskers_Num-ii)*0.85/WT.Whiskers_Num 0.2 (0.85-0.05*(WT.Whiskers_Num-1))/WT.Whiskers_Num]);
            imshow(WT.frame)
            if ii==1, title(WT.AXROI(ii),'ROI'); end
        end
    end
    linkaxes(WT.AXSignal,'x')
    set(WT.AXSignal(1:end-1),'XTick','')
    title(WT.AXSignal(1),'Angle of Whiskers (deg)')
    xlabel(WT.AXSignal(end),'Time (sec)')
    %
    if WT.WriteVideoFlag
        WT.VideoWriter = VideoWriter([WT.File_Name(1:end-4) '_WhiskerTrack'],'MPEG-4');
        WT.VideoWriter.FrameRate = 25;
        open(WT.VideoWriter)
    end
else
    h = waitbar(WT.current_frame/WT.V.NumFrames,['Time = ' num2str((WT.current_frame-1)/WT.V.FrameRate) ' sec (of ' num2str(round(WT.V.Duration)) ')']);
end
%
if WT.LightStimFlag
    WT.Stim_Region_Val = zeros(1,WT.V.NumFrames);
    Stim_Frame = WT.frame(WT.Stim_Loc(2,1):WT.Stim_Loc(2,2),WT.Stim_Loc(1,1):WT.Stim_Loc(1,2),:);
    WT.Stim_Region_Val(WT.current_frame) = mean(Stim_Frame(:));
end

%%
while hasFrame(WT.V)
    WT.current_frame = WT.current_frame + 1;
    if WT.RotationFrame==90
        WT.frame = rgb2gray(permute(readFrame(WT.V),[2 1 3]));
    elseif WT.RotationFrame==-90
        WT.frame = flipud(rgb2gray(permute(readFrame(WT.V),[2 1 3])));
    else
        WT.frame = rgb2gray(readFrame(WT.V));
    end
    update_whiskers();
    %
    if WT.RealTimePlotFlag
        WT.Handle2.CData = WT.frame;
        WT.Title2.String = ['Time = ' num2str(round((WT.current_frame-1)/WT.V.NumFrames*WT.V.Duration,1)) ' / ' num2str(round(WT.V.Duration,1)) ' sec'];
        for ii = 1:WT.Whiskers_Num
            set(WT.WhiskersAnglePlot(ii),'XData',(max(1,WT.current_frame-WT.DisplayTime*WT.V.FrameRate):WT.current_frame)/WT.V.NumFrames*WT.V.Duration,...
                'YData',WT.WhiskersAngle(ii,max(1,WT.current_frame-WT.DisplayTime*WT.V.FrameRate):WT.current_frame));
            set(WT.Line(ii),'XData',[WT.Point1(ii,1) WT.Point2(ii,1)],'YData',[WT.Point1(ii,2) WT.Point2(ii,2)]);
        end
        set(WT.AXSignal,'XLim',[WT.WhiskersAnglePlot(1).XData(end)-WT.DisplayTime WT.WhiskersAnglePlot(1).XData(end)]);
        drawnow
    elseif mod((WT.current_frame-1),WT.V.FrameRate)==0
        waitbar(WT.current_frame/WT.V.NumFrames,h,['Time = ' num2str((WT.current_frame-1)/WT.V.FrameRate) ' sec (of ' num2str(round(WT.V.Duration)) ')'])
    end
    % detect stimulation
    if WT.LightStimFlag
        Stim_Frame = WT.frame(WT.Stim_Loc(2,1):WT.Stim_Loc(2,2),WT.Stim_Loc(1,1):WT.Stim_Loc(1,2),:);
        WT.Stim_Region_Val(WT.current_frame) = mean(Stim_Frame(:));
    end
    if WT.WriteVideoFlag
        Frame = getframe(gcf);
        WT.VideoWriter.writeVideo(Frame)
    end
end
if WT.RealTimePlotFlag==0
    delete(h);
    if WT.WriteVideoFlag
        close(WT.VideoWriter)
    end
end

%%
if WT.LightStimFlag
    Stim_BL = quantile(WT.Stim_Region_Val,WT.StimBLQuantile);
    Stim_Thr = (1-WT.StimPeakWeight)*Stim_BL + WT.StimPeakWeight*max(WT.Stim_Region_Val);
    Stim_Flag = WT.Stim_Region_Val > Stim_Thr;
    if WT.SaveResultFlag
        save([WT.File_Name(1:end-4) '_Final_Stim'],'Stim_Flag')
    end
end

%%
figure('units','normalized','outerposition',[0 0 1 1])
Ax = gobjects(WT.Whiskers_Num,1);
time = (1:WT.V.NumFrames)/WT.V.NumFrames*WT.V.Duration;
for ii = 1:WT.Whiskers_Num
    ColNum = ceil(WT.Whiskers_Num/5);
    RowNum = ceil(WT.Whiskers_Num/ColNum);
    Ax(ii) = subplot(RowNum,ColNum,ii);
    plot(time(2:end),WT.WhiskersAngle(ii,2:end),'Color',min(1,0.3+WT.Line(ii).Color));
    hold on
    plot(time(2:end),filtfilt(ones(1,WT.PlotFiltLength)/WT.PlotFiltLength,1,WT.WhiskersAngle(ii,2:end)),'linew',1.5,'Color',WT.Line(ii).Color);
    if WT.LightStimFlag
        plot(time,Stim_Flag+mean(WT.WhiskersAngle(ii,2:end)),'k','LineWidth',1.2)
    end
    ylabel(['\theta_{' num2str(ii) '}'])
    if ii==1
    title('Angle of Whiskers (deg)')
    end
    if ii>=WT.Whiskers_Num-ColNum+1
    xlabel('Time (sec)')
    end
end
linkaxes(Ax,'x')
%
figure('units','normalized','outerposition',[0 0 1 1])
Ax = gobjects(WT.Whiskers_Num,1);
time = (1:WT.V.NumFrames)/WT.V.NumFrames*WT.V.Duration;
for ii = 1:WT.Whiskers_Num
    ColNum = ceil(WT.Whiskers_Num/5);
    RowNum = ceil(WT.Whiskers_Num/ColNum);
    Ax(ii) = subplot(RowNum,ColNum,ii);
    plot(time(2:end),WT.WhiskersMiddle(ii,2:end),'Color',min(1,0.3+WT.Line(ii).Color));
    hold on
    plot(time(2:end),filtfilt(ones(1,WT.PlotFiltLength)/WT.PlotFiltLength,1,WT.WhiskersMiddle(ii,2:end)),'linew',1.5,'Color',WT.Line(ii).Color);
    if WT.LightStimFlag
        plot(time,Stim_Flag+mean(WT.WhiskersMiddle(ii,2:end)),'k','LineWidth',1.2)
    end
    ylabel(['X_{' num2str(ii) '}'])
    if ii==1
    title('Location of Whiskers (pix)')
    end
    if ii>=WT.Whiskers_Num-ColNum+1
    xlabel('Time (sec)')
    end
end
linkaxes(Ax,'x')

%%
if WT.SaveResultFlag
    answer = inputdlg('Enter whisker numbers you want to save:','Saving',[1 40],{['1:' num2str(WT.Whiskers_Num)]});
    if isempty(answer) || isempty(str2num(answer{1}))
        error('whiskers number should be a vector with positive integer numbers!')
    end
    WT.WhiskersSave = str2num(answer{1});
    WhiskersAngles = WT.WhiskersAngle(WT.WhiskersSave,:);
    WhiskersMiddle = WT.WhiskersMiddle(WT.WhiskersSave,:);
    save([WT.File_Name(1:end-4) '_Final'],'WhiskersMiddle','WhiskersAngles')
end
end