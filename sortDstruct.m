numParams = length(masterD);
paramVary = 'ffo';
paramLoop = 'be';
% sort D struct and resave
[~, sortInd] = sort( masterD(:).pConst );
masterD(:).pVary = masterD( sortInd ).pVary;
masterD(:).pConst = masterD( sortInd ).pConst;
masterD(:).D = masterD( sortInd ).D;
masterD(:).sig = masterD( sortInd ).sig;


