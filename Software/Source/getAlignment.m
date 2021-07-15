function [embryoCentralizeCoordSample1,embryoCentralizeTransformedSample2,embryoCentralizeCoord1,embryoCentralizeCoord2,cardinalityRatio,alignmentResidue,numCellEmbryo1,numCellEmbryo2] = getAlignment(tabSample1,tabSample2,currentTemplateTime,currentSampleTime)

embryo1= tabSample1(tabSample1.time==currentTemplateTime,:);
embryo2= tabSample2(tabSample2.time==currentSampleTime,:);

if size(embryo1,1)>0 && size(embryo2,1)>0

    [commonLineage,idxA,idxB] = intersect(embryo1.cell,embryo2.cell);
    U = union(embryo1.cell,embryo2.cell);

    commonLineage;
    idxA;
    idxB;

    numCommonLineage = size(commonLineage,1);

    centerEmbryo1 = mean([embryo1.z(idxA),embryo1.x(idxA),embryo1.y(idxA)],1);
    centerEmbryo2 = mean([embryo2.z(idxB),embryo2.x(idxB),embryo2.y(idxB)],1);

    embryoCentralize1.z = embryo1.z-centerEmbryo1(1);
    embryoCentralize1.x = embryo1.x-centerEmbryo1(2);
    embryoCentralize1.y = embryo1.y-centerEmbryo1(3);

    embryoCentralizeCoord1 = [embryoCentralize1.z embryoCentralize1.x embryoCentralize1.y];
    embryoCentralizeCommonCoord1 = [embryoCentralize1.z(idxA) embryoCentralize1.x(idxA) embryoCentralize1.y(idxA)];

    embryoCentralize2.z = embryo2.z-centerEmbryo2(1);
    embryoCentralize2.x = embryo2.x-centerEmbryo2(2);
    embryoCentralize2.y = embryo2.y-centerEmbryo2(3);

    embryoCentralizeCoord2 = [embryoCentralize2.z embryoCentralize2.x embryoCentralize2.y]; 
    embryoCentralizeCommonCoord2 = [embryoCentralize2.z(idxB) embryoCentralize2.x(idxB) embryoCentralize2.y(idxB)];

    [d,Z,transform] = procrustes(embryoCentralizeCommonCoord1,embryoCentralizeCommonCoord2,'scaling',true);

    alignmentResidue = d;
    cardinalityRatio = size(commonLineage,1)/size(U,1);
    numCellEmbryo1 = size(embryoCentralizeCoord1,1);   
    numCellEmbryo2 = size(embryoCentralizeCoord2,1);

    c = transform.c;
    T = transform.T;
    b = transform.b;

    embryoCentralizeTransformedSample2 = b*embryoCentralizeCoord2*T;              
    embryoCentralizeCoordSample1 = embryoCentralizeCoord1;

else
    embryoCentralizeCoordSample1=[];
    embryoCentralizeTransformedSample2=[];
    cardinalityRatio=-1;
    alignmentResidue=-1;
    numCellEmbryo1=-1;
    numCellEmbryo2=-1;
end
      

 




