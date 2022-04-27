function [irTimeDomain] = RandIR(coeff, IRLength, fs, numInput, numOutput)



    direct = zeros(numOutput,numInput);
    % absorption filters
    zAbsorption = zSOS(absorptionGEQ(coeff.targetT60, coeff.delays, fs),'isDiagonal',true);

    % power correction filter
    targetPower = [0; 0; 0; 0; 0; 0; 0; 0; 0; 0];  % dB
    powerCorrectionSOS = designGEQ(targetPower);
    outputFilters = zSOS(permute(powerCorrectionSOS,[3 4 1 2]) .* coeff.outputGain);

    irTimeDomain = dss2impz(coeff.length, coeff.delays, coeff.feedbackMatrix, coeff.inputGain, outputFilters, direct, 'absorptionFilters', zAbsorption);
end