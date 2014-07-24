function [SimParams,SimStructs] = systemLinking(SimParams,SimStructs)

uscoreIndex = find(SimParams.pathLossModel == '_');
if isempty(uscoreIndex)
    uscoreIndex = length(SimParams.pathLossModel) + 1;
end

if ~strcmp(SimParams.pathLossModel(1:uscoreIndex(1,1) - 1),'3GPP')
    
    for iBase = 1:SimParams.nBases
        SimStructs.baseStruct{iBase,1}.linkedUsers = [];
    end
    
    xBases = 1:SimParams.nBases;
    [~,maxI] = max(SimParams.PL_Profile,[],1);
    
    for iUser = 1:SimParams.nUsers
        cNode = maxI(1,iUser);
        SimStructs.userStruct{iUser,1}.baseNode = cNode;
        SimStructs.userStruct{iUser,1}.neighNode = find(xBases ~= cNode);
        SimStructs.baseStruct{cNode,1}.linkedUsers = [SimStructs.baseStruct{cNode,1}.linkedUsers ; iUser];
    end
    
else
    
    for iBase = 1:SimParams.nBases
        SimStructs.baseStruct{iBase,1}.linkedUsers = [];
    end
    
    for iUser = 1:SimParams.nUsers
        
        xCites = SimStructs.userStruct{iUser,1}.phyParams.listedCites;
             
        SimStructs.userStruct{iUser,1}.baseNode = xCites(1,1);
        SimStructs.userStruct{iUser,1}.neighNode = xCites(2:end,1)';
        SimStructs.baseStruct{xCites(1,1)}.linkedUsers = [SimStructs.baseStruct{xCites(1,1)}.linkedUsers ; iUser];
                
    end
    
end

if exist('SimParams.ffrProfile_dB','var')
    ffrProfile = 10.^(0.1 * SimParams.ffrProfile_dB);
    SimParams.sPower = SimParams.nBands * SimParams.sPower * ffrProfile;
else
    SimParams.sPower = ones(1,SimParams.nBands) * SimParams.sPower;
end

for iBase = 1:SimParams.nBases
    SimStructs.baseStruct{iBase,1}.sPower = circshift(SimParams.sPower',(iBase - 1))';
end

if SimParams.multiCasting
    for iBase = 1:SimParams.nBases
        sIndex = 1;
        linkedUsers = SimStructs.baseStruct{iBase,1}.linkedUsers;
        cUsers = linkedUsers(randperm(length(linkedUsers)));
        SimStructs.baseStruct{iBase,1}.mcGroup = cell(length(SimParams.mcGroups{iBase,1}),1);
        for iGroup = 1:length(SimParams.mcGroups{iBase,1})
            eIndex = sum(SimParams.mcGroups{iBase,1}(1,1:iGroup));
            if iGroup ~= 1
                sIndex = sum(SimParams.mcGroups{iBase,1}(1,1:iGroup - 1)) + 1;
            end
            SimStructs.baseStruct{iBase,1}.mcGroup{iGroup,1} = cUsers(sIndex:eIndex);
        end
    end
end

end



