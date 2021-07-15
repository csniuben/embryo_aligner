classdef app_align_embryo < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        ceEmbryoAlignerv10UIFigure  matlab.ui.Figure
        TabGroup                    matlab.ui.container.TabGroup
        EmbryoalignmentTab          matlab.ui.container.Tab
        Panel                       matlab.ui.container.Panel
        TimeLabel                   matlab.ui.control.Label
        UITable                     matlab.ui.control.Table
        SettemplateembryoButton     matlab.ui.control.Button
        UITable2                    matlab.ui.control.Table
        SetsampleembryoButton       matlab.ui.control.Button
        ProcessDataButton           matlab.ui.control.Button
        Switch                      matlab.ui.control.Switch
        Panel_3                     matlab.ui.container.Panel
        UIAxes                      matlab.ui.control.UIAxes
        UIAxes_2                    matlab.ui.control.UIAxes
        UIAxes_3                    matlab.ui.control.UIAxes
        UIAxes_4                    matlab.ui.control.UIAxes
        UIAxes_5                    matlab.ui.control.UIAxes
        UIAxes_6                    matlab.ui.control.UIAxes
        UIAxes_7                    matlab.ui.control.UIAxes
        UIAxes_8                    matlab.ui.control.UIAxes
        UIAxes_9                    matlab.ui.control.UIAxes
        UIAxes2                     matlab.ui.control.UIAxes
        UITable3                    matlab.ui.control.Table
        TextArea                    matlab.ui.control.TextArea
        UITable2_2                  matlab.ui.control.Table
        GeneratereferenceembryoTab  matlab.ui.container.Tab
        TextArea_2                  matlab.ui.control.TextArea
        UIAxes3                     matlab.ui.control.UIAxes
        Panel_4                     matlab.ui.container.Panel
        CellnameEditFieldLabel      matlab.ui.control.Label
        CellnameEditField           matlab.ui.control.EditField
        SearchButton                matlab.ui.control.Button
        RunButton                   matlab.ui.control.Button
        UIAxes2_2                   matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        globalState % Description
        numTemplateFile;
        numSampleFile;
        r1 % Description
        dispmsg % Description
        msgcount
    end
    

    methods (Access = private)        
        function  updateTimerLabel(app,t1)
            t2 = clock;
            tDiff = etime(t2,t1);
            dur = string(duration(seconds(tDiff),'format','hh:mm:ss'))
            app.TimeLabel.Text = [dur];
            drawnow
        end
    end
    

    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            drawnow;            
            app.dispmsg = "";
            msgcount = 0;            
            app.ceEmbryoAlignerv10UIFigure.WindowState = 'maximized';            
            app.UITable3.ColumnName={'ID','z scale','x scale','y scale'};            
            app.globalState.templatePath = '';
            app.globalState.samplePath = '';            
        end

        % Button pushed function: ProcessDataButton
        function ProcessDataButtonPushed(app, event)
            
            app.numTemplateFile = -1;
            app.numSampleFile = -1;
            
            if isvalid(app)            
                pos = getpixelposition(app.UITable3);
                widthPanel = pos(3)
                app.UITable3.ColumnWidth = {widthPanel*0.25,widthPanel*0.25,widthPanel*0.25,widthPanel*0.25};                      
                
                templatePath = app.globalState.templatePath;
                samplePath = app.globalState.samplePath;
                
                if isempty(templatePath) || isempty(samplePath) 
                    uialert(app.ceEmbryoAlignerv10UIFigure,'File path incorrect','Invalid file path','Icon','error');                    
                else       
                
                    disp(templatePath);
                    disp(samplePath);
                    
                    tabTemplateFileNames = app.UITable.Data;                    
                    if size(tabTemplateFileNames,1)>=1
                        tabTemplateFileNames = tabTemplateFileNames(tabTemplateFileNames.Selected,:);
                        if size(tabTemplateFileNames,1)~=1 
                           uialert(app.ceEmbryoAlignerv10UIFigure,'Please select one template sample!','Template selection','Icon','error');
                        else
                           app.numTemplateFile = size(tabTemplateFileNames,1);            
                        end                     
                    else
                        uialert(app.ceEmbryoAlignerv10UIFigure,'Please provide at least one template sample!','Template selection','Icon','error');                        
                    end
                    
                    tabSampleFileNames = app.UITable2.Data;
                    if size(tabSampleFileNames,1)>=1
                        tabSampleFileNames = tabSampleFileNames(tabSampleFileNames.Selected,:);                           
                        if size(tabSampleFileNames,1)<1
                           uialert(app.ceEmbryoAlignerv10UIFigure,'Please select at least one embryo sample!','Sample selection','Icon','error');
                        else
                           app.numSampleFile = size(tabSampleFileNames,1);           
                        end  
                        
                    else
                        uialert(app.ceEmbryoAlignerv10UIFigure,'Please provide at least one embryo sample!','Sample selection','Icon','error');                       
                    end
                    
                    if app.numTemplateFile == 1 && app.numSampleFile >=1         
                            
                        outputPath = [samplePath '/' 'output']

                        app.msgcount = app.msgcount + 1;
                        if app.msgcount>100
                            app.dispmsg = "";
                        end
                        app.dispmsg = "# Set result output path:" + outputPath + newline + newline + app.dispmsg + newline + newline;
                        app.TextArea.Value = app.dispmsg;

                        if isfolder(outputPath)
                            fclose all
                            delete([outputPath '/*']);
                            rmdir(outputPath,'s');
                            mkdir(outputPath);

                            app.msgcount = app.msgcount + 1;
                            if app.msgcount>100
                                app.dispmsg = "";
                            end
                            app.dispmsg = "# Delete old and create result output path:" + outputPath + newline + newline + app.dispmsg + newline + newline;
                            app.TextArea.Value = app.dispmsg;         

                        else
                            mkdir(outputPath);         

                            app.msgcount = app.msgcount + 1;
                            if app.msgcount>100
                                app.dispmsg = "";
                            end
                            app.dispmsg = "# Create result output path:" + outputPath + newline + newline + app.dispmsg + newline + newline;
                            app.TextArea.Value = app.dispmsg;                                 

                        end

                        if strcmp(app.ProcessDataButton.Text, 'Start alignment')
                            app.ProcessDataButton.Text = 'Running';
                            set(app.ProcessDataButton,'Enable','off');

                            app.msgcount = app.msgcount + 1;
                            if app.msgcount>100
                                app.dispmsg = "";
                            end
                            app.dispmsg = "# Start embryo alignment" + newline + newline + app.dispmsg + newline + newline;
                            app.TextArea.Value = app.dispmsg;                      

                        end

                        if size(timerfind('Tag','countTime'),2)>0
                            delete(timerfind('Tag','countTime'));

                            app.msgcount = app.msgcount + 1;
                            if app.msgcount>100
                                app.dispmsg = "";
                            end
                            app.dispmsg = "# Delete previous timer:" + newline + newline + app.dispmsg + newline + newline;
                            app.TextArea.Value = app.dispmsg;         

                        end

                        t = timer('Tag','countTime');          

                        app.msgcount = app.msgcount + 1;
                        if app.msgcount>100
                            app.dispmsg = "";
                        end
                        app.dispmsg = "# Start clock:" + newline + newline + app.dispmsg + newline + newline;
                        app.TextArea.Value = app.dispmsg;                          

                        currentTime = clock;
                        t.TimerFcn = @(~,~)updateTimerLabel(app,currentTime);            
                        t.Period = 1;          
                        t.ExecutionMode = 'fixedRate'; 

                        offsetRange = 0.1
                        start(t)
                        string(app.UITable3.Data.x)
                        app.TextArea.Value = string(app.UITable3.Data.x);        

                        ax = app.UIAxes2;
                        cla(ax);
                        ph = patch(ax,[0 0 0 0], [0 0 1 1],[1 1 1]);                  
                        th = text(ax,0.5,0.5,'Progress 0%','VerticalAlignment','middle','HorizontalAlignment','right','color','k');                 
                        inputFilePath1 = samplePath;
                        inputFilePath2 = templatePath;                          
                        outputFilePath = outputPath;

                        templateFNList = tabTemplateFileNames.FileName;
                        sampleFNList = tabSampleFileNames.FileName;

                        aspectRatioParamTemplate = app.UITable3.Data(1,:);
                        aspectRatioParamSample  = app.UITable3.Data(2,:);                            

                        sampleFileName1 = templateFNList{1};         

                        tabSample1 = readtable([inputFilePath2 '/' sampleFileName1]);

                        app.msgcount = app.msgcount + 1;
                        if app.msgcount>100
                            app.dispmsg = "";
                        end
                        app.dispmsg = "# Read template embryo coordinate file:" + string([inputFilePath2 '/' sampleFileName1]) + newline + newline + app.dispmsg + newline + newline;
                        app.TextArea.Value = app.dispmsg;                            


                        tabSample1.z = tabSample1.z*aspectRatioParamTemplate.z;
                        tabSample1.x = tabSample1.x*aspectRatioParamTemplate.x;
                        tabSample1.y = tabSample1.y*aspectRatioParamTemplate.y;                            

                        app.msgcount = app.msgcount + 1;
                        if app.msgcount>100
                            app.dispmsg = "";
                        end
                        app.dispmsg = "# Scale normalization of template embryo with aspect ratio factor:" + newline + newline + app.dispmsg + newline + newline;
                        app.TextArea.Value = app.dispmsg;                       

                        sampleRange1 = [min(tabSample1.z) max(tabSample1.z)+offsetRange min(tabSample1.x) max(tabSample1.x)+offsetRange min(tabSample1.y) max(tabSample1.y)+offsetRange]

                        numSampleFile = size(sampleFNList,1);

                        thresCR=0.1; 
                        thresCommonCellNum = 3;                 
                        for k=1:numSampleFile                      
                                tabEmpty = array2table([]);

                                if isvalid(app)
                                    app.UITable2_2.Data = tabEmpty;

                                    cla(app.UIAxes_9);                    
                                end
                                k
                                close all

                                alignPerformanceByCellStage=[];

                                alignmentPerformance2Factor_mse_vs_cardinal = [];
                                alignmentPerformance2Factor_cellnum_vs_mse = [];
                                alignmentPerformance2Factor_cellnum_vs_cardinal = [];        

                                alignmentPerformance3Factor=[];

                                sampleFileName2 = sampleFNList{k}
                                tabSample2 = readtable([inputFilePath1 '/' sampleFileName2]);

                                app.msgcount = app.msgcount + 1;
                                if app.msgcount>100
                                    app.dispmsg = "";
                                end
                                app.dispmsg = "# Read embryo sample coordinate file:" + string([inputFilePath1 '/' sampleFileName2]) + newline + newline + app.dispmsg + newline + newline;
                                app.TextArea.Value = app.dispmsg;                            

                                app.msgcount = app.msgcount + 1;
                                if app.msgcount>100
                                    app.dispmsg = "";
                                end
                                app.dispmsg = "# Scale normalization of sample embryo with aspect ratio factor:" + newline + newline + app.dispmsg + newline + newline;
                                app.TextArea.Value = app.dispmsg;                                                  

                                tabSample2.z = tabSample2.z*aspectRatioParamSample.z;
                                tabSample2.x = tabSample2.x*aspectRatioParamSample.x;
                                tabSample2.y = tabSample2.y*aspectRatioParamSample.y;

                                sampleRange2 = [min(tabSample2.z) max(tabSample2.z)+offsetRange min(tabSample2.x) max(tabSample2.x)+offsetRange min(tabSample2.y) max(tabSample2.y)+offsetRange]

                                timeUniqueSetSample1 = unique(tabSample1.time);
                                timeUniqueSetSample2 = unique(tabSample2.time);                 

                                totalProgress = (timeUniqueSetSample1(end)-timeUniqueSetSample1(1)+1)*(timeUniqueSetSample2(end)-timeUniqueSetSample2(1)+1);

                                countProgress = 0;

                                for tSample1 = timeUniqueSetSample1(1):timeUniqueSetSample1(end)
                                    embryo1= tabSample1(tabSample1.time==tSample1,:);                                   

                                    temp = ['Processing sample: ' num2str(k) ' of ' num2str(numSampleFile) ' template embryo t = ' num2str(tSample1)]
                                    disp(temp) ;                        

                                    app.msgcount = app.msgcount + 1;
                                    if app.msgcount>100
                                        app.dispmsg = "";
                                    end
                                    app.dispmsg = "# " + temp + newline + newline + app.dispmsg + newline + newline;
                                    app.TextArea.Value = app.dispmsg;                               

                                    for tSample2 = timeUniqueSetSample2(1):timeUniqueSetSample2(end)                

                                        countProgress = countProgress + 1;                                      

                                        if isvalid(app)

                                        else
                                           break;
                                        end

                                        stop_state = app.Switch.Value;
                                        if strcmp(stop_state,'Off')                                          
                                            while 1
                                                stop_state = app.Switch.Value;
                                                if strcmp(stop_state,'On');                                                   
                                                    break;
                                                else                                                                                              
                                                end
                                            end
                                        else

                                            ph.XData = [0 countProgress/totalProgress countProgress/totalProgress 0]; 
                                            th.String = sprintf('%.0f%%',round(countProgress/totalProgress*100)) ;
                                            drawnow 
                                            embryo2= tabSample2(tabSample2.time==tSample2,:);

                                            [commonLineage,idxA,idxB] = intersect(embryo1.cell,embryo2.cell);
                                            U = union(embryo1.cell,embryo2.cell);

                                            numCommonLineage = size(commonLineage,1);

                                            cardinalityRatio = size(commonLineage,1)/size(U,1);

                                            if numCommonLineage>=thresCommonCellNum && cardinalityRatio>=thresCR                                                

                                                app.msgcount = app.msgcount + 1;
                                                if app.msgcount>100
                                                    app.dispmsg = "";
                                                end
                                                app.dispmsg = "# " + "Alignment template t = " + num2str(tSample1) + " sample t = " + num2str(tSample2) + " feasible match" + newline + newline + app.dispmsg + newline + newline;
                                                app.TextArea.Value = app.dispmsg;                                                                                                         
                                                centerEmbryo1 = mean([embryo1.z(idxA),embryo1.x(idxA),embryo1.y(idxA)]);

                                                if isvalid(app)
                                                    plot3(app.UIAxes, embryo1.z,embryo1.x,embryo1.y,'k.'); hold(app.UIAxes,'on')
                                                    plot3(app.UIAxes, centerEmbryo1(1),centerEmbryo1(2),centerEmbryo1(3),'b+'); hold(app.UIAxes,'off')

                                                    axis(app.UIAxes,sampleRange1);
                                                    axui = app.UIAxes;
                                                    axui.XLabel.String = 'VD'
                                                    axui.YLabel.String = 'AP';
                                                    axui.ZLabel.String = 'LR';
                                                    grid(app.UIAxes, 'on');
                                                    title(app.UIAxes,['Embryo-1 time:' num2str(tSample1)]);                                    
                                                    set(app.UIAxes,'DataAspectRatio',[1 1 1]);                                     
                                                end
                                       
                                                centerEmbryo2 = mean([embryo2.z(idxB),embryo2.x(idxB),embryo2.y(idxB)]);

                                                if isvalid(app)
                                                    plot3(app.UIAxes_2, embryo2.z,embryo2.x,embryo2.y,'ro'); hold(app.UIAxes_2,'on')
                                                    plot3(app.UIAxes_2, centerEmbryo2(1),centerEmbryo2(2),centerEmbryo2(3),'b+'); hold(app.UIAxes_2,'off')

                                                    axis(app.UIAxes_2, sampleRange2);
                                                    axui = app.UIAxes_2;
                                                    axui.XLabel.String = 'VD'
                                                    axui.YLabel.String = 'AP';
                                                    axui.ZLabel.String = 'LR';
                                                    grid(axui, 'on');
                                                    title(app.UIAxes_2, ['Embryo-2 time:' num2str(tSample2) ' (sample\_' num2str(k) ')'])                                  
                                                    set(app.UIAxes_2,'DataAspectRatio',[1 1 1])
                                                end
                                      
                                                embryoCentralize1.z = embryo1.z-centerEmbryo1(1);
                                                embryoCentralize1.x = embryo1.x-centerEmbryo1(2);
                                                embryoCentralize1.y = embryo1.y-centerEmbryo1(3);
                                                centerEmbryoCentralize1(1) = centerEmbryo1(1)-centerEmbryo1(1);
                                                centerEmbryoCentralize1(2) = centerEmbryo1(2)-centerEmbryo1(2);
                                                centerEmbryoCentralize1(3) = centerEmbryo1(3)-centerEmbryo1(3);                 

                                                embryoCentralize2.z = embryo2.z-centerEmbryo2(1);
                                                embryoCentralize2.x = embryo2.x-centerEmbryo2(2);
                                                embryoCentralize2.y = embryo2.y-centerEmbryo2(3);
                                                centerEmbryoCentralize2(1) = centerEmbryo2(1)-centerEmbryo2(1);
                                                centerEmbryoCentralize2(2) = centerEmbryo2(2)-centerEmbryo2(2);
                                                centerEmbryoCentralize2(3) = centerEmbryo2(3)-centerEmbryo2(3);       

                                                embryoCentralizeCommonCoord1 = [embryoCentralize1.z(idxA) embryoCentralize1.x(idxA) embryoCentralize1.y(idxA)];
                                                embryoCentralizeCommonCoord2 = [embryoCentralize2.z(idxB) embryoCentralize2.x(idxB) embryoCentralize2.y(idxB)];                

                                                sampleRangeCentralize1 = [min(embryoCentralize1.z) max(embryoCentralize1.z) min(embryoCentralize1.x) max(embryoCentralize1.x) min(embryoCentralize1.y) max(embryoCentralize1.y)];
                                                sampleRangeCentralize2 = [min(embryoCentralize2.z) max(embryoCentralize2.z) min(embryoCentralize2.x) max(embryoCentralize2.x) min(embryoCentralize2.y) max(embryoCentralize2.y)];
                                                sampleRangeCentralizeMat = [sampleRangeCentralize1;sampleRangeCentralize2];
                                                sampleRangeCentralize = [min(sampleRangeCentralizeMat(:,1)),max(sampleRangeCentralizeMat(:,2))+offsetRange,min(sampleRangeCentralizeMat(:,3)),max(sampleRangeCentralizeMat(:,4))+offsetRange,min(sampleRangeCentralizeMat(:,5)),max(sampleRangeCentralizeMat(:,6))+offsetRange];                                    

                                                if isvalid(app)
                                                    plot3(app.UIAxes_3, embryoCentralize1.z,embryoCentralize1.x,embryoCentralize1.y,'k.'); hold(app.UIAxes_3,'on')
                                                    plot3(app.UIAxes_3, centerEmbryoCentralize1(1),centerEmbryoCentralize1(2),centerEmbryoCentralize1(3),'b*'); hold(app.UIAxes_3,'on')              
                                                    plot3(app.UIAxes_3, embryoCentralize2.z,embryoCentralize2.x,embryoCentralize2.y,'ro'); hold(app.UIAxes_3,'on')              

                                                    plot3(app.UIAxes_3, embryoCentralizeCommonCoord1(:,1),embryoCentralizeCommonCoord1(:,2),embryoCentralizeCommonCoord1(:,3),'k+'); hold(app.UIAxes_3,'on')
                                                    plot3(app.UIAxes_3, embryoCentralizeCommonCoord2(:,1),embryoCentralizeCommonCoord2(:,2),embryoCentralizeCommonCoord2(:,3),'r+'); hold(app.UIAxes_3,'on')

                                                    for j=1:size(embryoCentralizeCommonCoord2(:,1))             
                                                        plot3(app.UIAxes_3, [embryoCentralizeCommonCoord2(j,1),embryoCentralizeCommonCoord1(j,1)],[embryoCentralizeCommonCoord2(j,2),embryoCentralizeCommonCoord1(j,2)],[embryoCentralizeCommonCoord2(j,3),embryoCentralizeCommonCoord1(j,3)],'g-','linewidth',3); hold(app.UIAxes_3,'on')
                                                    end            

                                                    plot3(app.UIAxes_3, centerEmbryoCentralize2(1),centerEmbryoCentralize2(2),centerEmbryoCentralize2(3),'b+'); hold(app.UIAxes_3,'off')                            

                                                    axis(app.UIAxes_3, sampleRangeCentralize);
                                                    axui = app.UIAxes_3;
                                                    axui.XLabel.String = 'VD'
                                                    axui.YLabel.String = 'AP';
                                                    axui.ZLabel.String = 'LR';
                                                    grid(app.UIAxes_3, 'on');                                    
                                                    set(app.UIAxes_3,'DataAspectRatio',[1 1 1])

                                                    title(app.UIAxes_3, 'Centralized')
                                                end
                                       
                                                embryoCentralizeCommonCoord1 = [embryoCentralize1.z(idxA) embryoCentralize1.x(idxA) embryoCentralize1.y(idxA)];
                                                embryoCentralizeCommonCoord2 = [embryoCentralize2.z(idxB) embryoCentralize2.x(idxB) embryoCentralize2.y(idxB)];

                                                embryoCentralizeCoord1 = [embryoCentralize1.z embryoCentralize1.x embryoCentralize1.y];
                                                embryoCentralizeCoord2 = [embryoCentralize2.z embryoCentralize2.x embryoCentralize2.y];    

                                                cardinalityRatio=-1;
                                                alignmentResidue=-1;                    

                                                [d,Z,transform] = procrustes(embryoCentralizeCommonCoord1,embryoCentralizeCommonCoord2,'scaling',true);

                                                alignmentResidue = d;
                                                cardinalityRatio = size(commonLineage,1)/size(U,1);
                                                numCellEmbryo1 = size(embryoCentralizeCoord1,1);       

                                                c = transform.c;
                                                T = transform.T;
                                                b = transform.b;

                                                embryoCentralizeTransformed2 = b*embryoCentralizeCoord2*T;                                    

                                                rangeVectTransformed = [min(embryoCentralizeTransformed2(:,1)) max(embryoCentralizeTransformed2(:,1)) min(embryoCentralizeTransformed2(:,2)) max(embryoCentralizeTransformed2(:,2)) min(embryoCentralizeTransformed2(:,3)) max(embryoCentralizeTransformed2(:,3))];
                                                rangeMatVectNoTransform = [min(embryoCentralizeCoord1(:,1)) max(embryoCentralizeCoord1(:,1)) min(embryoCentralizeCoord1(:,2)) max(embryoCentralizeCoord1(:,2)) min(embryoCentralizeCoord1(:,3)) max(embryoCentralizeCoord1(:,3))];
                                                rangeMat = [rangeVectTransformed; rangeMatVectNoTransform];
                                                rangeTransform = [min(rangeMat(:,1)) max(rangeMat(:,2))+offsetRange min(rangeMat(:,3)) max(rangeMat(:,4))+offsetRange min(rangeMat(:,5)) max(rangeMat(:,6))+offsetRange];

                                                if isvalid(app)
                                                    plot3(app.UIAxes_4, mean(embryoCentralizeCommonCoord1(:,1)),mean(embryoCentralizeCommonCoord1(:,2)),mean(embryoCentralizeCommonCoord1(:,3)),'b*'); hold(app.UIAxes_4,'on')
                                                    plot3(app.UIAxes_4, mean(Z(:,1)),mean(Z(:,2)),mean(Z(:,3)),'b+'); hold(app.UIAxes_4,'on')

                                                    plot3(app.UIAxes_4, embryoCentralizeCommonCoord1(:,1),embryoCentralizeCommonCoord1(:,2),embryoCentralizeCommonCoord1(:,3),'k+'); hold(app.UIAxes_4,'on')
                                                    plot3(app.UIAxes_4, Z(:,1),Z(:,2),Z(:,3),'r+'); hold(app.UIAxes_4,'on')

                                                    for j=1:size(Z,1)                
                                                        plot3(app.UIAxes_4, [Z(j,1),embryoCentralizeCommonCoord1(j,1)],[Z(j,2),embryoCentralizeCommonCoord1(j,2)],[Z(j,3),embryoCentralizeCommonCoord1(j,3)],'g-','linewidth',2); hold(app.UIAxes_4,'on')
                                                    end

                                                    plot3(app.UIAxes_4, embryoCentralizeTransformed2(:,1),embryoCentralizeTransformed2(:,2),embryoCentralizeTransformed2(:,3),'ro'); hold(app.UIAxes_4,'on')
                                                    plot3(app.UIAxes_4, embryoCentralizeCoord1(:,1),embryoCentralizeCoord1(:,2),embryoCentralizeCoord1(:,3),'k.'); hold(app.UIAxes_4,'off')                     

                                                    axis(app.UIAxes_4, sampleRangeCentralize);
                                                    axui = app.UIAxes_4;
                                                    axui.XLabel.String = 'VD';
                                                    axui.YLabel.String = 'AP';
                                                    axui.ZLabel.String = 'LR';
                                                    grid(app.UIAxes_4, 'on');                                    
                                                    set(app.UIAxes_4,'DataAspectRatio',[1 1 1]);                                    
                                                    title(axui, 'Aligned');                                           

                                                    axis(axui, rangeTransform);                                   
                                                end

                                                alignmentPerformance3Factor = [alignmentPerformance3Factor;[alignmentResidue,cardinalityRatio,numCellEmbryo1]];

                                                if isvalid(app)
                                                    plot3(app.UIAxes_5, alignmentPerformance3Factor(:,1),alignmentPerformance3Factor(:,2),alignmentPerformance3Factor(:,3),'k.'); hold(app.UIAxes_5,'on')
                                                    plot3(app.UIAxes_5, alignmentResidue,cardinalityRatio,numCellEmbryo1,'r.','markersize',24); hold(app.UIAxes_5,'off')
                                                    grid(app.UIAxes_5, 'on');   
                                                    axis(app.UIAxes_5, 'square');
                                                    axui = app.UIAxes_5;
                                                    ylim(axui, [0 1]);

                                                    axui.XLabel.String = 'MSE';
                                                    axui.YLabel.String = 'CR';
                                                    axui.ZLabel.String = 'Cell number';
                                                    title(axui, 'Alignment accuracy')
                                                end

                                                alignmentPerformance2Factor_mse_vs_cardinal = [alignmentPerformance2Factor_mse_vs_cardinal;[alignmentResidue,cardinalityRatio]];

                                                if isvalid(app)
                                                    plot(app.UIAxes_6, alignmentPerformance2Factor_mse_vs_cardinal(:,1),alignmentPerformance2Factor_mse_vs_cardinal(:,2),'k.');  hold(app.UIAxes_6,'on')
                                                    plot(app.UIAxes_6, alignmentResidue,cardinalityRatio,'r.','markersize',24); hold(app.UIAxes_6,'off')
                                                    grid(app.UIAxes_6, 'on');                                    
                                                    axis(app.UIAxes_6, 'square');
                                                    ylim(app.UIAxes_6,[0 1])
                                                    axui = app.UIAxes_6;
                                                    axui.XLabel.String = 'MSE';                                    
                                                    axui.YLabel.String = 'CR';
                                                    title(app.UIAxes_6, 'Alignment accuracy')                
                                                end
                                                
                                                alignmentPerformance2Factor_cellnum_vs_mse = [alignmentPerformance2Factor_cellnum_vs_mse;[alignmentResidue,numCellEmbryo1]];

                                                if isvalid(app)
                                                    plot(app.UIAxes_7, alignmentPerformance2Factor_cellnum_vs_mse(:,1),alignmentPerformance2Factor_cellnum_vs_mse(:,2),'k.'); hold(app.UIAxes_7,'on')
                                                    plot(app.UIAxes_7, alignmentResidue,numCellEmbryo1,'r.','markersize',24); hold(app.UIAxes_7,'off')
                                                    grid(app.UIAxes_7, 'on');                    

                                                    alignPerformanceByCellStage = [alignPerformanceByCellStage; [k,tSample1,tSample2,numCellEmbryo1,cardinalityRatio,alignmentResidue]];

                                                    axis(app.UIAxes_7, 'square');
                                                    axui = app.UIAxes_7;
                                                    axui.XLabel.String = 'MSE';
                                                    axui.YLabel.String = 'Cell number';

                                                    title(app.UIAxes_7, 'Alignment accuracy')
                                                end

                                                alignmentPerformance2Factor_cellnum_vs_cardinal = [alignmentPerformance2Factor_cellnum_vs_cardinal;[numCellEmbryo1,cardinalityRatio]];

                                                if isvalid(app)
                                                    plot(app.UIAxes_8, alignmentPerformance2Factor_cellnum_vs_cardinal(:,2),alignmentPerformance2Factor_cellnum_vs_cardinal(:,1),'k.'); hold(app.UIAxes_8,'on')
                                                    plot(app.UIAxes_8, cardinalityRatio,numCellEmbryo1,'r.','markersize',24); hold(app.UIAxes_8,'off');
                                                    xlim(app.UIAxes_8,[0 1]);
                                                    grid(app.UIAxes_8, 'on');                                     
                                                    axis(app.UIAxes_8, 'square');
                                                    axui = app.UIAxes_8;
                                                    axui.YLabel.String = 'Cell number';

                                                    axui.XLabel.String = 'CR';
                                                    title(app.UIAxes_8, 'Alignment accuracy') ;    
                                                end
                                     
                                                if isvalid(app)
                                                    axis(app.UIAxes_9, 'square');

                                                    axui = app.UIAxes_9;
                                                    axui.XLabel.String = 'MSE';
                                                    axui.YLabel.String = 'Cell number';          

                                                    grid(app.UIAxes_9, 'on');

                                                    title(app.UIAxes_9, 'Optimal alignment (Running)');                   
                                                end
                                                pause(0.1)

                                            else

                                            end
                                        end
                                    end
                                end    

                                statFileName = [outputFilePath '/' 'multi_align_all_' sampleFileName1 '_vs_' sampleFileName2 '_' num2str(thresCR) '.csv'];

                                app.msgcount = app.msgcount + 1;
                                if app.msgcount>100
                                    app.dispmsg = "";
                                end
                                app.dispmsg = "# " + "Write result on alignment performance to file for current sample" + newline + newline + app.dispmsg + newline + newline;
                                app.TextArea.Value = app.dispmsg;                         

                                if isvalid(app)                        
                                    csvwrite(statFileName,alignPerformanceByCellStage) ;


                                fileID = fopen(statFileName);
                                if fseek(fileID, 1, 'bof') == -1
                                        disp('file  is empty')
                                        optSolution =[];
                                        optFileName = [outputFilePath '/' 'multi_align_template_vs_sample_' num2str(k) '_' num2str(thresCR) '_opt' '.csv']
                                        csvwrite(optFileName,optSolution) 
                                else
                                        stat = csvread(statFileName);
                                        optSolution = [];
                                        cellNumUnique = unique(stat(:,4));
                                        for i=1:size(cellNumUnique,1)
                                            currentCellNum = cellNumUnique(i);
                                            currentStageStat = stat(stat(:,4)==currentCellNum,:);
                                            currentStageMinError = min(currentStageStat(:,6));
                                            sampleID = currentStageStat(currentStageStat(:,6)==currentStageMinError,1);
                                            toptSample1=currentStageStat(currentStageStat(:,6)==currentStageMinError,2);
                                            toptSample2=currentStageStat(currentStageStat(:,6)==currentStageMinError,3);
                                            optCellNumSample1=currentStageStat(currentStageStat(:,6)==currentStageMinError,4);
                                            optCardinal=currentStageStat(currentStageStat(:,6)==currentStageMinError,5);
                                            optResidue=currentStageStat(currentStageStat(:,6)==currentStageMinError,6);

                                            optSolution = [optSolution; [sampleID,toptSample1,toptSample2,optCellNumSample1,optCardinal,optResidue]];

                                        end

                                        currentSampleStat = stat(stat(:,1)==k,:);

                                        if isvalid(app)
                                            plot(app.UIAxes_9, currentSampleStat(:,6),currentSampleStat(:,4),'.','color',[200 200 200]/255); hold(app.UIAxes_9,'on')
                                            plot(app.UIAxes_9, optSolution(:,6),optSolution(:,4),'r.','markersize',24)
                                            axis(app.UIAxes_9, 'square');

                                            axui = app.UIAxes_9;
                                            axui.XLabel.String = 'MSE';
                                            axui.YLabel.String = 'Cell number';          

                                            grid(app.UIAxes_9, 'on');

                                            title(app.UIAxes_9, 'Optimal alignment');


                                            app.msgcount = app.msgcount + 1;
                                            if app.msgcount>100
                                                app.dispmsg = "";
                                            end
                                            app.dispmsg = "# " + "Write result of optimal alignment to file for current sample" + newline + newline + app.dispmsg + newline + newline;
                                            app.TextArea.Value = app.dispmsg;                                                                                                          


                                            optFileName = [outputFilePath '/' 'multi_align_template_vs_sample_' num2str(k) '_' num2str(thresCR) '_opt' '.csv']
                                            csvwrite(optFileName,optSolution); 

                                            tabOpt = table(optSolution(:,4),optSolution(:,6));

                                            tabOpt.Properties.VariableNames = {'Cell_number','MSE'};                          
                                            app.UITable2_2.Data = tabOpt;                        
                                            app.UITable2_2.ColumnName = tabOpt.Properties.VariableNames;
                                        end
                                        pause(10)
                                end
                             end
                        end

                         if isvalid(app)
                            delete(t)              
                         else
                         end


                        if isvalid(app)   
                            if strcmp(app.ProcessDataButton.Text, 'Running')
                                app.ProcessDataButton.Text = 'Start';
                                set(app.ProcessDataButton,'Enable','on');
                            end
                        else

                        end  
                        
                        if isvalid(app)                    
                            uialert(app.ceEmbryoAlignerv10UIFigure,'All sample run finished!','Job finished','Icon','success');                     
                        end                        
                    end
                end         
            end
        end

        function SettemplateembryoButtonPushed(app, event)
            path=uigetdir;                    
                        
            app.msgcount = app.msgcount + 1;
            if app.msgcount>100
                app.dispmsg = "";
            end
            
            app.dispmsg = "# Set template embryo with path:" + path + newline + newline + app.dispmsg + newline + newline;
            
            app.TextArea.Value = app.dispmsg;
            
            if path > 0    
                app.globalState.templatePath = path;
                app.ceEmbryoAlignerv10UIFigure.Visible = 'off';     
                app.ceEmbryoAlignerv10UIFigure.Visible = 'on';      
     
                a=dir([path '/*.csv']);            
                b={a(:).name}';                   
                b(ismember(b,{'.','..'})) = [];      
                       
                intNumFile = size(b);
                strID = {};
                boolSelect = [];
                
                for i = 1:size(b,1)
                    strID = [strID; [num2str(i)]];
                    boolSelect  = [boolSelect;false];
                end                               
                boolSelect(1) = true;
                boolSelect = logical(boolSelect);
                tab  = table(strID, b, boolSelect);
                            
                tab.Properties.VariableNames  = {'ID', 'FileName', 'Selected'}
                app.UITable.ColumnName = tab.Properties.VariableNames;
                pos = getpixelposition(app.UITable);
                width = pos(3);
                app.UITable.ColumnWidth = {width*0.1,width*0.7,width*0.2}
                app.UITable.Data=tab;    
                
                if size(app.UITable3.Data,1)>0
                    app.UITable3.Data.Properties.VariableNames ={'Grp','z','x','y'} ;
                    app.UITable3.Data(strcmp(app.UITable3.Data.Grp,"template embryo"),:)=[]  ;                  
                    
                    grpName = "template embryo";
                    scaleZ = 1;
                    scaleX = 0.09;
                    scaleY = 0.09;
                    
                    tabTemp = table(grpName,scaleZ,scaleX,scaleY);
                    tabTemp.Properties.VariableNames = {'Grp','z','x','y'} ;
                    app.UITable3.Data = [app.UITable3.Data;tabTemp];
                    
                else
                    grpName = "template embryo";
                    scaleZ = 1;
                    scaleX = 0.09;
                    scaleY = 0.09;
                    
                    app.UITable3.Data = table(grpName,scaleZ,scaleX,scaleY);
                    app.UITable3.Data.Properties.VariableNames ={'Grp','z','x','y'} ;
                end   
                           
            end  
            
        end

        function SetsampleembryoButtonPushed(app, event)
            path=uigetdir;                   
             
            app.msgcount = app.msgcount + 1;
            if app.msgcount>100
                app.dispmsg = "";
            end
            app.dispmsg = "# Set sample embryo with path:" + path + newline + newline + app.dispmsg + newline + newline;
            app.TextArea.Value = app.dispmsg;
            
            if path > 0 
                app.globalState.samplePath = path;  
                app.ceEmbryoAlignerv10UIFigure.Visible = 'off';     
                app.ceEmbryoAlignerv10UIFigure.Visible = 'on';      
             
                a=dir([path '/*.csv']);          
                b={a(:).name}';                  
                b(ismember(b,{'.','..'})) = [];  
                       
                intNumFile = size(b);
                strID = {};
                boolSelect = [];
                
                for i = 1:size(b,1)
                    strID = [strID; [num2str(i)]];
                    boolSelect  = [boolSelect;true];
                end                               
               
                boolSelect = logical(boolSelect);
                tab  = table(strID, b, boolSelect);
                            
                tab.Properties.VariableNames  = {'ID', 'FileName', 'Selected'}
                app.UITable2.ColumnName = tab.Properties.VariableNames;
               
                pos = getpixelposition(app.UITable2);
                width = pos(3);
                app.UITable2.ColumnWidth = {width*0.1,width*0.7,width*0.2}
                app.UITable2.Data=tab;      
                
                if size(app.UITable3.Data,1)>0
                    
                    app.UITable3.Data.Properties.VariableNames ={'Grp','z','x','y'} ;
                    app.UITable3.Data
                    app.UITable3.Data(strcmp(app.UITable3.Data.Grp,"sample embryo"),:)=[]  ;
                    
                    
                    grpName = "sample embryo";
                    scaleZ = 1;
                    scaleX = 0.09;
                    scaleY = 0.09;
                    
                    tabTemp = table(grpName,scaleZ,scaleX,scaleY);
                    tabTemp.Properties.VariableNames = {'Grp','z','x','y'} ;
                    app.UITable3.Data = [app.UITable3.Data;tabTemp];
                    
                else
                    grpName = "sample embryo";
                    scaleZ = 1;
                    scaleX = 0.09;
                    scaleY = 0.09;
                    
                    app.UITable3.Data = table(grpName,scaleZ,scaleX,scaleY);
                    app.UITable3.Data.Properties.VariableNames ={'Grp','z','x','y'} ;
                end   
                
            end
        end
        
        function ceEmbryoAlignerv10UIFigureCloseRequest(app, event)
           YN = uiconfirm(app.ceEmbryoAlignerv10UIFigure,'Do you want to close the app?', 'Close request');
           if strcmpi(YN,'OK')                
                app.delete;
           end            
        end
        
        function RunButtonPushed(app, event)
              
            app.TextArea_2.Value = '';
            
            inputPathOptAlign = [app.globalState.samplePath '/output/'];
            
            app.msgcount = app.msgcount + 1;
            if app.msgcount>100
                app.dispmsg = "";
            end
            app.dispmsg = "# Set optimal alignment input path:" + inputPathOptAlign + newline + newline + app.dispmsg + newline + newline;
            app.TextArea_2.Value = app.dispmsg;                          
            
            
            inputPathSample = app.globalState.samplePath; 
            temp = dir([inputPathSample '/*.csv']);
            inputPathSampleCoordinateFiles = [];
            
            app.msgcount = app.msgcount + 1;
            if app.msgcount>100
                app.dispmsg = "";
            end
            app.dispmsg = "# Set sample coordinate file input path:" + inputPathSample + newline + newline + app.dispmsg + newline + newline;
            app.TextArea_2.Value = app.dispmsg;   
            

            for numFiles = 1:size(temp,1)
                currentFN = temp(numFiles).name;
                inputPathSampleCoordinateFiles = [inputPathSampleCoordinateFiles;string([inputPathSample '/' currentFN])]
            end
            
            tabTemplateFileNames = app.UITable.Data;                    
            templatePath = app.globalState.templatePath;
            inputPathTemplateCoordinateFile = '';
            
            app.msgcount = app.msgcount + 1;
            if app.msgcount>100
                app.dispmsg = "";
            end
            app.dispmsg = "# Set template coordinate file input path:" + templatePath + newline + newline + app.dispmsg + newline + newline;
            app.TextArea_2.Value = app.dispmsg;  
            
            
            if size(tabTemplateFileNames,1)>=1
                tabTemplateFileNames = tabTemplateFileNames(tabTemplateFileNames.Selected,:);
                if size(tabTemplateFileNames,1)>1
                   uialert(app.ceEmbryoAlignerv10UIFigure,'Please select only one template sample!','Template selection','Icon','error');                             
                else
                            inputPathTemplateCoordinateFile = [char(templatePath) '/' char(tabTemplateFileNames.FileName)];
                   
                            app.msgcount = app.msgcount + 1;
                            if app.msgcount>100
                                app.dispmsg = "";
                            end
                            app.dispmsg = "# Read template coordinate file:" + inputPathTemplateCoordinateFile + newline + newline + app.dispmsg + newline + newline;
                            app.TextArea_2.Value = app.dispmsg;                              
                            
                            disp(inputPathSampleCoordinateFiles);
                            disp(inputPathTemplateCoordinateFile);            
                            
                            outputFilePathAvgEmbryo = [inputPathSample '/avg_embryo/'];
                            
                            app.msgcount = app.msgcount + 1;
                            if app.msgcount>100
                                app.dispmsg = "";
                            end
                            app.dispmsg = "# Set virtual embryo output path:" + outputFilePathAvgEmbryo + newline + newline + app.dispmsg + newline + newline;
                            app.TextArea_2.Value = app.dispmsg;  
                            
                            
                            if isfolder(outputFilePathAvgEmbryo)
                                delete([outputFilePathAvgEmbryo '*']);            
                            else
                                mkdir(outputFilePathAvgEmbryo);
                            end            
                           
                            
                            optAlignSettingAll = [];
                            templateSampleTimeUniqueAll = [];
                            referenceEmbryos_all = {};
                            referenceCells_all = {};
                            referenceCoords_all = {};    
                            
                            thresCR = 0.1;
                            aspectRatioTemplate = app.UITable3.Data(1,:);
                            aspectRatioSample = app.UITable3.Data(2,:);
                            
                            
                            app.msgcount = app.msgcount + 1;
                            if app.msgcount>100
                                app.dispmsg = "";
                            end
                            app.dispmsg = "# Begin generating virtual embryo" + outputFilePathAvgEmbryo + newline + newline + app.dispmsg + newline + newline;
                            app.TextArea_2.Value = app.dispmsg;               
                            
                            app.r1 = ReferenceEmbryo(inputPathOptAlign,thresCR,optAlignSettingAll,templateSampleTimeUniqueAll,inputPathTemplateCoordinateFile,inputPathSampleCoordinateFiles,aspectRatioTemplate, aspectRatioSample,referenceEmbryos_all,referenceCells_all,referenceCoords_all,outputFilePathAvgEmbryo); 
                            
                            app.r1 = statisticAlignmentPerformance(app.r1);                            
                            app.r1 = generateReferenceEmbryo(app.r1,app.UIAxes2_2);
                            app.r1 = genReferenceCsv(app.r1,outputFilePathAvgEmbryo,app.UIAxes2_2);                             
                        
                            avgEmb = app.r1.avgEmb;                           
                            uniqueTime = unique(avgEmb.time);
                            
                            cla(app.UIAxes3)
                            for s = 1:size(uniqueTime,1) 
                                
                                app.msgcount = app.msgcount + 1;
                                if app.msgcount>100
                                    app.dispmsg = "";
                                end
                                app.dispmsg = "# Generate virtual embryo at time point :" + num2str(uniqueTime(s)) + newline + newline + app.dispmsg + newline + newline;
                                app.TextArea_2.Value = app.dispmsg;                  
                                
                                currT = uniqueTime(s);
                                tabCurr = avgEmb(avgEmb.time == currT,:);
                                plot3(app.UIAxes3,tabCurr.z,tabCurr.x,tabCurr.y,'ro');
                                daspect(app.UIAxes3,[1 1 1])  ;             
                                grid(app.UIAxes3,'on');
                                xlabel(app.UIAxes3, 'X')
                                ylabel(app.UIAxes3, 'Y')
                                zlabel(app.UIAxes3, 'Z')
                                title(app.UIAxes3,['t=' num2str(uniqueTime(s)) ' numcell=' num2str(size(tabCurr,1))]);
                                hold(app.UIAxes3,'off');
                                pause(0.2);
                                
                            end 
                            
                            app.msgcount = app.msgcount + 1;
                            if app.msgcount>100
                                app.dispmsg = "";
                            end
                            app.dispmsg = "# Virtual embryo generated, done." + newline + newline + app.dispmsg + newline + newline;
                            app.TextArea_2.Value = app.dispmsg;    
                            
                    end                     
              else
                        uialert(app.ceEmbryoAlignerv10UIFigure,'Select at least one template sample!','Template selection','Icon','error');                        
              end
            
        end

        function SearchButtonPushed(app, event)
            
            cla(app.UIAxes3);
            cellNamePrefix = app.CellnameEditField.Value;
            avgEmb = app.r1.avgEmb;                           
            uniqueTime = unique(avgEmb.time);                            
            
            app.msgcount = app.msgcount + 1;
            if app.msgcount>100
                app.dispmsg = "";
            end
            app.dispmsg = "# Locate cell type with name prefix of: " + cellNamePrefix + "*" + newline + newline + app.dispmsg + newline + newline;
            app.TextArea_2.Value = app.dispmsg;    
            
            
            currT = uniqueTime(end);
            tabCurr = avgEmb(avgEmb.time == currT,:);
              
            numCell = size(tabCurr,1);
            r=ones(1,numCell)*0.5
            alpha = 0.3
            color = repmat([1 0 0],numCell,1);
            bubbleplot3(app.UIAxes3,tabCurr.z,tabCurr.x,tabCurr.y,r,color,alpha);
            
            camlight(app.UIAxes3,'right'); lighting(app.UIAxes3,'phong');  
            camlight(app.UIAxes3,'left'); view(app.UIAxes3,60,30);
            camlight(app.UIAxes3,'headlight') ; view(app.UIAxes3,60,30);
            camlight(app.UIAxes3,'left') ; view(app.UIAxes3,60,30);
            
            light(app.UIAxes3,'Position',[-30 -10 -10],'Style','local')
            light(app.UIAxes3,'Position',[-30 10 -10],'Style','local')
            light(app.UIAxes3,'Position',[-30 0 0],'Style','local')           
                      
            ax = app.UIAxes2_2;
            cla(ax);        
            ph = patch(ax,[0 0 0 0], [0 0 1 1],[1 1 1]); %greenyellow      
            th = text(ax,0.5,0.5,'Progress 0%','VerticalAlignment','middle','HorizontalAlignment','right','color','k');   
              
            r = 0.5
            alpha = 1;
                    
            for i = 1:size(tabCurr,1)
                currentCellName = tabCurr(i,:).cell;      
                
                ph.XData = [0 i/size(tabCurr,1) i/size(tabCurr,1) 0]; 
                th.String = sprintf('%.0f%%',round(i/size(tabCurr,1)*100)) ;
                drawnow            
                
                if contains(currentCellName,cellNamePrefix)
                    color = [0 1 0];                
                    
                    bubbleplot3(app.UIAxes3,tabCurr(i,:).z,tabCurr(i,:).x,tabCurr(i,:).y,r,color,alpha);                  
                                   
                end
            end       
            
            camlight(app.UIAxes3,'left'); 
            camlight(app.UIAxes3,'headlight') ;  
            camlight(app.UIAxes3,'left') ; 
            
            light(app.UIAxes3,'Position',[-30 -10 -10],'Style','local')
            light(app.UIAxes3,'Position',[-30 10 -10],'Style','local')
            light(app.UIAxes3,'Position',[-30 0 0],'Style','local')
            
            grid(app.UIAxes3,'on')   
            
            daspect(app.UIAxes3,[1 1 1]);               
            grid(app.UIAxes3,'on');
            xlabel(app.UIAxes3, 'X')
            ylabel(app.UIAxes3, 'Y')
            zlabel(app.UIAxes3, 'Z')
            title(app.UIAxes3,['t=' num2str(uniqueTime(end)) ' numcell=' num2str(size(tabCurr,1))]);
            hold(app.UIAxes3,'off')            
           
        end
    end
   
    methods (Access = private)       
        
         
        function hWelcome = showWelcome(app)
        
            hWelcome = figure('name','Welcome embryo aligner version 1.0.','MenuBar', 'none', 'ToolBar', 'none', 'Resize', 'off'); 
           
            img = imread('./resource/welcome_img.png');           
            img = imresize(img,1);
            set (gcf,'Position',[500,160,size(img,2),size(img,1)])
            movegui(gcf,'center')
            set(gcf,'Name','Welcome ! Embryo aligner version 1.0.','NumberTitle','off')
            imshow(img,'border','tight','initialmagnification','fit')           

        end
        

        % Create UIFigure and components
        function createComponents(app)                        
                      
            % Create ceEmbryoAlignerv10UIFigure
            app.ceEmbryoAlignerv10UIFigure = uifigure;
            app.ceEmbryoAlignerv10UIFigure.Position = [100 100 1105 823];
            app.ceEmbryoAlignerv10UIFigure.Name = 'Embryo Aligner v1.0';
            app.ceEmbryoAlignerv10UIFigure.CloseRequestFcn = createCallbackFcn(app, @ceEmbryoAlignerv10UIFigureCloseRequest, true);

            % Create TabGroup
            app.TabGroup = uitabgroup(app.ceEmbryoAlignerv10UIFigure);
            app.TabGroup.Position = [38 15 1051 778];

            % Create EmbryoalignmentTab
            app.EmbryoalignmentTab = uitab(app.TabGroup);
            app.EmbryoalignmentTab.Title = 'Embryo alignment';
            app.EmbryoalignmentTab.BackgroundColor = [1 1 1];
            app.EmbryoalignmentTab.ForegroundColor = [0.149 0.149 0.149];

            % Create Panel
            app.Panel = uipanel(app.EmbryoalignmentTab);
            app.Panel.BackgroundColor = [1 1 1];
            app.Panel.Position = [35 30 234 706];

            % Create TimeLabel
            app.TimeLabel = uilabel(app.Panel);
            app.TimeLabel.HorizontalAlignment = 'center';
            app.TimeLabel.FontName = 'Arial';
            app.TimeLabel.FontSize = 16;
            app.TimeLabel.FontColor = [0.149 0.149 0.149];
            app.TimeLabel.Position = [30 677 176 22];
            app.TimeLabel.Text = 'Time';

            % Create UITable
            app.UITable = uitable(app.Panel);
            app.UITable.ColumnName = {'ID'; 'File name'; 'Selected'};
            app.UITable.ColumnWidth = {'auto'};
            app.UITable.RowName = {};
            app.UITable.ColumnEditable = true;
            app.UITable.FontName = 'Arial';
            app.UITable.Position = [14 570 208 106];

            % Create SettemplateembryoButton
            app.SettemplateembryoButton = uibutton(app.Panel, 'push');
            app.SettemplateembryoButton.ButtonPushedFcn = createCallbackFcn(app, @SettemplateembryoButtonPushed, true);
            app.SettemplateembryoButton.Position = [14 521 208 28];
            app.SettemplateembryoButton.Text = 'Set template embryo';

            % Create UITable2
            app.UITable2 = uitable(app.Panel);
            app.UITable2.ColumnName = {'ID'; 'File name'; 'Selected'};
            app.UITable2.RowName = {};
            app.UITable2.ColumnEditable = true;
            app.UITable2.Position = [14 147 208 357];

            % Create SetsampleembryoButton
            app.SetsampleembryoButton = uibutton(app.Panel, 'push');
            app.SetsampleembryoButton.ButtonPushedFcn = createCallbackFcn(app, @SetsampleembryoButtonPushed, true);
            app.SetsampleembryoButton.IconAlignment = 'center';
            app.SetsampleembryoButton.Position = [14 97 208 28];
            app.SetsampleembryoButton.Text = 'Set sample embryo';

            % Create ProcessDataButton
            app.ProcessDataButton = uibutton(app.Panel, 'push');
            app.ProcessDataButton.ButtonPushedFcn = createCallbackFcn(app, @ProcessDataButtonPushed, true);
            app.ProcessDataButton.BackgroundColor = [0 1 1];
            app.ProcessDataButton.Position = [14 51 208 29];
            app.ProcessDataButton.Text = 'Start alignment';

            % Create Switch
            app.Switch = uiswitch(app.Panel, 'slider');
            app.Switch.Position = [95 14 45 20];
            app.Switch.Value = 'On';

            % Create Panel_3
            app.Panel_3 = uipanel(app.EmbryoalignmentTab);
            app.Panel_3.BackgroundColor = [1 1 1];
            app.Panel_3.Position = [282 177 739 559];

            % Create UIAxes
            app.UIAxes = uiaxes(app.Panel_3);
            title(app.UIAxes, 'Title')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            app.UIAxes.PlotBoxAspectRatio = [1 0.742990654205608 0.742990654205608];
            app.UIAxes.BackgroundColor = [1 1 1];
            app.UIAxes.Position = [11 389 229 156];

            % Create UIAxes_2
            app.UIAxes_2 = uiaxes(app.Panel_3);
            title(app.UIAxes_2, 'Title')
            xlabel(app.UIAxes_2, 'X')
            ylabel(app.UIAxes_2, 'Y')
            app.UIAxes_2.PlotBoxAspectRatio = [1 0.742990654205608 0.742990654205608];
            app.UIAxes_2.BackgroundColor = [1 1 1];
            app.UIAxes_2.Position = [255 389 229 156];

            % Create UIAxes_3
            app.UIAxes_3 = uiaxes(app.Panel_3);
            title(app.UIAxes_3, 'Title')
            xlabel(app.UIAxes_3, 'X')
            ylabel(app.UIAxes_3, 'Y')
            app.UIAxes_3.PlotBoxAspectRatio = [1 0.742990654205608 0.742990654205608];
            app.UIAxes_3.BackgroundColor = [1 1 1];
            app.UIAxes_3.Position = [498 389 229 156];

            % Create UIAxes_4
            app.UIAxes_4 = uiaxes(app.Panel_3);
            title(app.UIAxes_4, 'Title')
            xlabel(app.UIAxes_4, 'X')
            ylabel(app.UIAxes_4, 'Y')
            app.UIAxes_4.PlotBoxAspectRatio = [1 0.742990654205608 0.742990654205608];
            app.UIAxes_4.BackgroundColor = [1 1 1];
            app.UIAxes_4.Position = [11 201 229 156];

            % Create UIAxes_5
            app.UIAxes_5 = uiaxes(app.Panel_3);
            title(app.UIAxes_5, 'Title')
            xlabel(app.UIAxes_5, 'X')
            ylabel(app.UIAxes_5, 'Y')
            app.UIAxes_5.PlotBoxAspectRatio = [1 0.742990654205608 0.742990654205608];
            app.UIAxes_5.BackgroundColor = [1 1 1];
            app.UIAxes_5.Position = [255 201 229 156];

            % Create UIAxes_6
            app.UIAxes_6 = uiaxes(app.Panel_3);
            title(app.UIAxes_6, 'Title')
            xlabel(app.UIAxes_6, 'X')
            ylabel(app.UIAxes_6, 'Y')
            app.UIAxes_6.PlotBoxAspectRatio = [1 0.742990654205608 0.742990654205608];
            app.UIAxes_6.BackgroundColor = [1 1 1];
            app.UIAxes_6.Position = [498 201 229 156];

            % Create UIAxes_7
            app.UIAxes_7 = uiaxes(app.Panel_3);
            title(app.UIAxes_7, 'Title')
            xlabel(app.UIAxes_7, 'X')
            ylabel(app.UIAxes_7, 'Y')
            app.UIAxes_7.PlotBoxAspectRatio = [1 0.742990654205608 0.742990654205608];
            app.UIAxes_7.BackgroundColor = [1 1 1];
            app.UIAxes_7.Position = [11 17 229 156];

            % Create UIAxes_8
            app.UIAxes_8 = uiaxes(app.Panel_3);
            title(app.UIAxes_8, 'Title')
            xlabel(app.UIAxes_8, 'X')
            ylabel(app.UIAxes_8, 'Y')
            app.UIAxes_8.PlotBoxAspectRatio = [1 0.742990654205608 0.742990654205608];
            app.UIAxes_8.BackgroundColor = [1 1 1];
            app.UIAxes_8.Position = [255 17 229 156];

            % Create UIAxes_9
            app.UIAxes_9 = uiaxes(app.Panel_3);
            title(app.UIAxes_9, 'Title')
            xlabel(app.UIAxes_9, 'X')
            ylabel(app.UIAxes_9, 'Y')
            app.UIAxes_9.PlotBoxAspectRatio = [1 0.742990654205608 0.742990654205608];
            app.UIAxes_9.BackgroundColor = [1 1 1];
            app.UIAxes_9.Position = [498 17 229 156];

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.EmbryoalignmentTab);
            app.UIAxes2.XLim = [0 1];
            app.UIAxes2.XColor = [1 1 1];
            app.UIAxes2.XTick = [];
            app.UIAxes2.YColor = [1 1 1];
            app.UIAxes2.YTick = [];
            app.UIAxes2.ZColor = [1 1 1];
            app.UIAxes2.Position = [282 32 739 20];

            % Create UITable3
            app.UITable3 = uitable(app.EmbryoalignmentTab);
            app.UITable3.ColumnName = {'ID'; 'z scale'; 'x scale'; 'y scale'};
            app.UITable3.ColumnWidth = {'auto'};
            app.UITable3.RowName = {};
            app.UITable3.ColumnEditable = true;
            app.UITable3.Position = [282 63 280 101];

            % Create TextArea
            app.TextArea = uitextarea(app.EmbryoalignmentTab);
            app.TextArea.Position = [576 63 251 101];

            % Create UITable2_2
            app.UITable2_2 = uitable(app.EmbryoalignmentTab);
            app.UITable2_2.ColumnName = {'Cell number'; 'optimal MSE'};
            app.UITable2_2.RowName = {};
            app.UITable2_2.ColumnEditable = true;
            app.UITable2_2.Position = [842 63 179 101];

            % Create GeneratereferenceembryoTab
            app.GeneratereferenceembryoTab = uitab(app.TabGroup);
            app.GeneratereferenceembryoTab.Title = 'Generate reference embryo';

            % Create TextArea_2
            app.TextArea_2 = uitextarea(app.GeneratereferenceembryoTab);
            app.TextArea_2.Position = [812 86 210 646];

            % Create UIAxes3
            app.UIAxes3 = uiaxes(app.GeneratereferenceembryoTab);
            title(app.UIAxes3, 'Reference embryo')
            xlabel(app.UIAxes3, 'X')
            ylabel(app.UIAxes3, 'Y')
            app.UIAxes3.PlotBoxAspectRatio = [1 0.731673582295989 0.731673582295989];
            app.UIAxes3.Position = [25 65 770 584];

            % Create Panel_4
            app.Panel_4 = uipanel(app.GeneratereferenceembryoTab);
            app.Panel_4.Position = [25 665 762 67];

            % Create CellnameEditFieldLabel
            app.CellnameEditFieldLabel = uilabel(app.Panel_4);
            app.CellnameEditFieldLabel.HorizontalAlignment = 'right';
            app.CellnameEditFieldLabel.Position = [144 22 60 22];
            app.CellnameEditFieldLabel.Text = 'Cell name';

            % Create CellnameEditField
            app.CellnameEditField = uieditfield(app.Panel_4, 'text');
            app.CellnameEditField.Position = [219 22 187 22];
            app.CellnameEditField.Value = 'E';

            % Create SearchButton
            app.SearchButton = uibutton(app.Panel_4, 'push');
            app.SearchButton.ButtonPushedFcn = createCallbackFcn(app, @SearchButtonPushed, true);
            app.SearchButton.Position = [441 22 120 22];
            app.SearchButton.Text = 'Search';

            % Create RunButton
            app.RunButton = uibutton(app.GeneratereferenceembryoTab, 'push');
            app.RunButton.ButtonPushedFcn = createCallbackFcn(app, @RunButtonPushed, true);
            app.RunButton.BackgroundColor = [0 1 1];
            app.RunButton.Position = [812 30 210 36];
            app.RunButton.Text = 'Run';

            % Create UIAxes2_2
            app.UIAxes2_2 = uiaxes(app.GeneratereferenceembryoTab);
            app.UIAxes2_2.XLim = [0 1];
            app.UIAxes2_2.XColor = [1 1 1];
            app.UIAxes2_2.XTick = [];
            app.UIAxes2_2.YColor = [1 1 1];
            app.UIAxes2_2.YTick = [];
            app.UIAxes2_2.ZColor = [1 1 1];
            app.UIAxes2_2.Position = [25 30 762 20];            
      
        end
    end

    methods (Access = public)

        % Construct app
        function app = app_align_embryo

            % Create and configure components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.ceEmbryoAlignerv10UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.ceEmbryoAlignerv10UIFigure)
        end
    end
end