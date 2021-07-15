classdef ReferenceEmbryo
   
   properties (Access = public)
    inputPathOptAlign
    thresCR
    optAlignSettingAll
    templateSampleTimeUniqueAll
    
    inputPathTemplateCoordinateFile
    inputPathSampleCoordinateFiles    
    
    aspectRatioTemplate
    aspectRatioSample
    
    referenceEmbryos_all    
    
    referenceCells_all
    referenceCoords_all   
    
    outputFilePathAvgEmbryo
    avgEmb
    
   end
   
   methods (Access = public)
       
       function result = getRefEmb(obj)
        result = obj.refEmb;       
       end
       
       function obj = ReferenceEmbryo(inputPathOptAlign,thresCR,...\
                                      optAlignSettingAll,templateSampleTimeUniqueAll, ...\
                                      inputPathTemplateCoordinateFile,inputPathSampleCoordinateFiles,...\
                                      aspectRatioTemplate, aspectRatioSample,...\
                                      referenceEmbryos_all, ...\    
                                      referenceCells_all,...\
                                      referenceCoords_all,...\
                                      outputFilePathAvgEmbryo)
           
           obj.inputPathOptAlign = inputPathOptAlign;
           obj.thresCR = thresCR;          
           
           obj.optAlignSettingAll = optAlignSettingAll;
           obj.templateSampleTimeUniqueAll = templateSampleTimeUniqueAll;
           
           obj.inputPathTemplateCoordinateFile = inputPathTemplateCoordinateFile;
           obj.inputPathSampleCoordinateFiles = inputPathSampleCoordinateFiles;
           obj.aspectRatioTemplate = aspectRatioTemplate;
           obj.aspectRatioSample = aspectRatioSample;           
          
           obj.referenceEmbryos_all = referenceEmbryos_all;
           obj.outputFilePathAvgEmbryo = outputFilePathAvgEmbryo;
           
       end
       
       function value = getinputPathOptAlign(obj)
         value =  obj.inputPathOptAlign      ; 
       end
       
       function obj = statisticAlignmentPerformance(obj)           
           
            obj.optAlignSettingAll = [];
            obj.templateSampleTimeUniqueAll = [];           

            prefix2 = 'multi_align_'
            
            alignPerformOptFileName = dir([obj.inputPathOptAlign prefix2 '*' '_' num2str(obj.thresCR) '_opt.csv']);

            numAlignment = size(alignPerformOptFileName,1)            

            for i=1:numAlignment    
                                
                currentFNOpt = [obj.inputPathOptAlign alignPerformOptFileName(i).name]                
                tabAlignmentOpt = readtable(currentFNOpt);
               
            end
            
            for i=1:numAlignment
   
                currentFNOpt = [obj.inputPathOptAlign alignPerformOptFileName(i).name]                 
                tabAlignmentOpt = readtable(currentFNOpt);
               
            end
          
            markerSet1 = {'*','.','o','v','s'}
            markerSet2 = {'.','.','.','.','.'}
            for i=1:numAlignment
              
               currentFNOpt = [obj.inputPathOptAlign alignPerformOptFileName(i).name];
               tabAlignmentOpt = readtable(currentFNOpt);
                          
            end

            for i=1:numAlignment
               currentFNOpt = [obj.inputPathOptAlign alignPerformOptFileName(i).name]  
               tabAlignmentOpt = readtable(currentFNOpt);               
            end
             
            alignmentCountAllSample = []
            for i=1:numAlignment
                currentFNOpt = [obj.inputPathOptAlign alignPerformOptFileName(i).name]  
                tabAlignmentOpt = readtable(currentFNOpt);
                if size(tabAlignmentOpt,1)                   
                    alignmentCountAllSample = [alignmentCountAllSample;[tabAlignmentOpt(:,2).Var2,tabAlignmentOpt(:,1).Var1,tabAlignmentOpt(:,3).Var3]];
                end
            end
           
            templateSampleTimeUnique_all = unique(alignmentCountAllSample(:,1));
            
            optAlignSetting_all={}
            for i=1:size(templateSampleTimeUnique_all,1)
                currentTemplateTime = templateSampleTimeUnique_all(i);
                currentTemplateOptSetting = alignmentCountAllSample(alignmentCountAllSample(:,1)==currentTemplateTime,:);
                optAlignSetting_all = [optAlignSetting_all;currentTemplateOptSetting];
            end

            optAlignSetting_all;
            
            obj.optAlignSettingAll = optAlignSetting_all;
            obj.templateSampleTimeUniqueAll = templateSampleTimeUnique_all;       
            
       end
       
       function obj = generateReferenceEmbryo(obj,axProgress)                             
              
                sampleFileName1 = obj.inputPathTemplateCoordinateFile;
                tabSample1 = readtable(sampleFileName1);                
               
                tabSample1.z = tabSample1.z*obj.aspectRatioTemplate.z;
                tabSample1.x = tabSample1.x*obj.aspectRatioTemplate.x;
                tabSample1.y = tabSample1.y*obj.aspectRatioTemplate.y;                

                numSampleFile = size(obj.inputPathSampleCoordinateFiles,1);

                numOptAlignSet = size(obj.optAlignSettingAll,1);

                totalProgress = numOptAlignSet;
                
                cla(axProgress);
            
                ph = patch(axProgress,[0 0 0 0], [0 0 1 1],[1 1 1]);
             
                th = text(axProgress,0.5,0.5,'Progress 0%','VerticalAlignment','middle','HorizontalAlignment','right','color','k');            
                
                count = 0;
                for i=1:numOptAlignSet

                    count = count+1;
                    
                    ph.XData = [0 count/totalProgress count/totalProgress 0]; 
                    th.String = sprintf('%.0f%%',round(count/totalProgress*100)) ;
                    drawnow               
                    
                    currentOptAlignSet = obj.optAlignSettingAll{i};

                    for j=1:size(currentOptAlignSet,1)        
                        currentTemplateTime = currentOptAlignSet(j,1);
                        currentSampleID = currentOptAlignSet(j,2);
                        currentSampleTime = currentOptAlignSet(j,3);

                        currentSampleFN = obj.inputPathSampleCoordinateFiles(currentSampleID,:);

                        sampleFileName2 = currentSampleFN;
                        tabSample2 = readtable(sampleFileName2);

                        tabSample2.z = tabSample2.z*obj.aspectRatioSample.z;
                        tabSample2.x = tabSample2.x*obj.aspectRatioSample.x;
                        tabSample2.y = tabSample2.y*obj.aspectRatioSample.y;  
                        
                        embryo1= tabSample1(tabSample1.time==currentTemplateTime,:);
                        embryo2= tabSample2(tabSample2.time==currentSampleTime,:);

                        [commonLineage,idxA,idxB] = intersect(embryo1.cell,embryo2.cell);        

                        [transformedCoordSample1,transformedCoordSample2,embryoCentralizeCoord1,embryoCentralizeCoord2,cardinalitySimilarity,mse,numCellSample1,numCellSample2] = getAlignment(tabSample1,tabSample2,currentTemplateTime,currentSampleTime);

                        optAlign.currentOptAlignSet=currentOptAlignSet;
                        optAlign.templateFileName=sampleFileName1;
                        optAlign.templateSampleTimeUnique = obj.templateSampleTimeUniqueAll;
                        optAlign.currentSampleID=currentSampleID;
                        optAlign.currentSampleFileName=sampleFileName2;        
                        optAlign.tabSample1=tabSample1;
                        optAlign.tabSample2=tabSample2;
                        optAlign.embryo1 = embryo1;
                        optAlign.embryo2 = embryo2;
                        optAlign.currentTemplateTime=currentTemplateTime;
                        optAlign.currentSampleTime=currentSampleTime;
                        optAlign.embryoCentralizeCoord1=embryoCentralizeCoord1;
                        optAlign.embryoCentralizeCoord2=embryoCentralizeCoord2;
                        optAlign.transformedCoordSample1=transformedCoordSample1
                        optAlign.transformedCoordSample2=transformedCoordSample2
                        optAlign.cardinalitySimilarity=cardinalitySimilarity;
                        optAlign.mse=mse;
                        optAlign.numCellSample1=numCellSample1;
                        optAlign.numCellSample2=numCellSample2;
                        optAlign.commonLineage=commonLineage;
                        optAlign.idxA = idxA;
                        optAlign.idxB = idxB;

                        obj.referenceEmbryos_all = [obj.referenceEmbryos_all,optAlign];
                        
                    end
                end
                
                for t=1:500
    
                    displayTemplateTime=t  ;       

                    alignmentSelected_all = [];

                    for k=1:size(obj.referenceEmbryos_all,2)
                        if obj.referenceEmbryos_all{k}.currentTemplateTime==displayTemplateTime    
                           alignmentSelected_all = [alignmentSelected_all obj.referenceEmbryos_all{k}];
                        end
                    end

                    if size(alignmentSelected_all,1)>0 || size(alignmentSelected_all,2)>0                    

                        obj = getAvgEmbryoAllNoDisplay(obj,alignmentSelected_all,displayTemplateTime);

                    end
                end         
                
       end
       
       function obj = getAvgEmbryoAllNoDisplay(obj,alignmentSelected_all,displayTemplateTime)
           
        templateEmbryoCellName = alignmentSelected_all(1).embryo1.cell;

        obj.referenceCells_all = {};
        obj.referenceCoords_all = {};

        for i=1:size(templateEmbryoCellName,1)
            currentTemplateCellName = templateEmbryoCellName{i};
            avgCoord = [];
            for j=1:size(alignmentSelected_all,1)    
                currentSampleAlignment = alignmentSelected_all(j);
                currentSampleCellName = currentSampleAlignment.embryo2.cell;
                for k = 1:size(currentSampleAlignment.embryo2.cell,1)            
                   if strcmp(currentTemplateCellName,currentSampleCellName{k})
                       avgCoord = [avgCoord;currentSampleAlignment.transformedCoordSample2(k,:)];
                   end
                end    
                if size(avgCoord,1)==0
                    avgCoord = currentSampleAlignment.transformedCoordSample1(i,:);
                end
            end
            avgCoord = mean(avgCoord,1);
            obj.referenceCoords_all=[obj.referenceCoords_all;avgCoord];
            obj.referenceCells_all=[obj.referenceCells_all;currentTemplateCellName];
        end
        
        referenceCells_all = obj.referenceCells_all;
        referenceCoords_all = obj.referenceCoords_all;
 
        save([obj.outputFilePathAvgEmbryo 'avgembryo_t_' num2str(displayTemplateTime)  '.mat'],'referenceCells_all','referenceCoords_all');       
       end
       
       function obj = genReferenceCsv(obj,outputFilePathAvgEmbryo,axProgress)

            fid = fopen([outputFilePathAvgEmbryo 'avgembryo.csv'],'w+');

            headLine = 'cell	time	z	x	y	size	gweight	cellNumberAge';
            fprintf(fid,'%s\n',headLine);

            tic
            count = 0;            
            numAvgEmbT = size(dir([outputFilePathAvgEmbryo 'avgembryo_t_*.mat']),1);            
            
            cla(axProgress);            
            ph = patch(axProgress,[0 0 0 0], [0 0 1 1],[1 1 1]);
            th = text(axProgress,0.5,0.5,'Progress 0%','VerticalAlignment','middle','HorizontalAlignment','right','color','k');            
                                
            for tC = 1:500            
                    fn = [outputFilePathAvgEmbryo 'avgembryo_t_' num2str(tC)  '.mat'];
                    if isfile(fn)
                        count = count+1 ;           
                        disp([num2str(count) ':' num2str(tC)]);                        
                          
                        ph.XData = [0 count/numAvgEmbT count/numAvgEmbT 0]; 
                        th.String = sprintf('%.0f%%',round(count/numAvgEmbT*100)) ;
                        drawnow 
                        
                        xx = load(fn);            
                        for i = 1:size(xx.referenceCoords_all,1)
                            
                            currentCoordZ = xx.referenceCoords_all{i}(1);
                            currentCoordX = xx.referenceCoords_all{i}(2);
                            currentCoordY = xx.referenceCoords_all{i}(3);

                            cellNum = size(xx.referenceCoords_all,1);
                            
                            currentCellName = xx.referenceCells_all{i};
                            line = [currentCellName '	' num2str(tC) '	' num2str(currentCoordZ) '	' num2str(currentCoordX) '	' num2str(currentCoordY) '	' num2str(-1) '	' num2str(-1) '	' num2str(cellNum)];                
                            
                           
                            if ~isnan(xx.referenceCoords_all{i})                            
                                fprintf(fid,'%s\n',line);
                            else
                                disp([num2str(i) ' NaN'])
                                xx.referenceCoords_all{i}     
                            end

                         end            
                    else
                       
                    end                    
                  
            end           

            fclose all

            obj.avgEmb = readtable([outputFilePathAvgEmbryo 'avgembryo.csv']);
           
       
       end
       
   end
end