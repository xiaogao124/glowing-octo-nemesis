
function [SimParams,SimStructs] = updateTransmitPower(SimParams,SimStructs)

bfPower = 0;
sdpPower = 0;
for iBand = 1:SimParams.nBands
    for iBase = 1:SimParams.nBases
        totalPowerSDP = 0;
        for iGroup = 1:length(SimStructs.baseStruct{iBase,1}.mcGroup)
            totalPowerSDP = totalPowerSDP + real(trace(SimStructs.baseStruct{iBase,1}.P_SDP{iBand,1}(:,:,iGroup)));
        end
        bfPower = bfPower + real(trace(SimStructs.baseStruct{iBase,1}.PG{iBand,1} * SimStructs.baseStruct{iBase,1}.PG{iBand,1}'));
        fprintf('Transmit Power on SC [%d] from BS [%d] : BF Pwr - %f \t SDP Pwr (LB) - %f',iBand,iBase,...
            real(trace(SimStructs.baseStruct{iBase,1}.PG{iBand,1} * SimStructs.baseStruct{iBase,1}.PG{iBand,1}')),...
            totalPowerSDP);
        sdpPower = sdpPower + totalPowerSDP;
    end
    fprintf('\n');
end

SimParams.totalTXpower_G(SimParams.iPkt,SimParams.iAntennaArray,SimParams.iGroupArray) = bfPower + SimParams.totalTXpower_G(SimParams.iPkt,SimParams.iAntennaArray,SimParams.iGroupArray);
SimParams.totalTXpower_SDP(SimParams.iPkt,SimParams.iAntennaArray,SimParams.iGroupArray) = sdpPower + SimParams.totalTXpower_SDP(SimParams.iPkt,SimParams.iAntennaArray,SimParams.iGroupArray);