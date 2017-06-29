function [clique] = unifyForests(clique,retrieveInfo);
clique0 = clique; 
clear clique
noOfSDPcones = size(retrieveInfo,2); 
cliquePointer = 0;
for kk=1:noOfSDPcones
    clique{kk}.NoC = 0;
    clique{kk}.NoElem = [];
    clique{kk}.Elem = [];
    clique{kk}.maxC = 0;
    clique{kk}.minC = 1.0e10;
    clique{kk}.NoCliqueInForest = [];
    noOfForest = retrieveInfo{kk}.noOfSDPcones;
    SetPointer = 0;
    blockPointer = 0;
    for ff =1:noOfForest
        cliquePointer = cliquePointer + 1;
        clique{kk}.NoCliqueInForest = [clique{kk}.NoCliqueInForest, clique0{cliquePointer}.NoC];
        clique{kk}.NoC = clique{kk}.NoC + clique0{cliquePointer}.NoC;
        clique{kk}.NoElem = [clique{kk}.NoElem, clique0{cliquePointer}.NoElem];
        clique{kk}.maxC = max([clique{kk}.maxC,clique0{cliquePointer}.maxC]);
        clique{kk}.minC = min([clique{kk}.minC,clique0{cliquePointer}.minC]);
        for j=1:size(clique0{cliquePointer}.Set,2)
            if ~isempty(clique0{cliquePointer}.Set{j})
                clique{kk}.Elem = [clique{kk}.Elem, retrieveInfo{kk}.retrieveIndex(blockPointer+clique0{cliquePointer}.Set{j})]; 
                SetPointer = SetPointer + 1;
                clique{kk}.Set{SetPointer} = ...
                    retrieveInfo{kk}.retrieveIndex(blockPointer+clique0{cliquePointer}.Set{j});                
            end
        end
		%%%%%%%%%%
		% Bug fixed, March 31, 2010 ---> 
		% blockPointer = blockPointer+retrieveInfo{kk}.s(cliquePointer);
		blockPointer = blockPointer+retrieveInfo{kk}.s(ff);
		% <--- 
		%%%%%%%%%%
    end
end
