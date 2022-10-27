function [irTimeDomain] = gen_IR_f(length_in_sample, order_N, input_gain, output_gain, feedback_matrix, delays, target_rt60, target_power, fs)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    t_60_f = [target_rt60(1), target_rt60(2), target_rt60(3), target_rt60(4), target_rt60(5), target_rt60(6), target_rt60(7), target_rt60(8), target_rt60(9), target_rt60(10)];
    direct = zeros(1,1);
    % absorption filters
    zAbsorption = zSOS(absorptionGEQ(t_60_f, delays, fs),'isDiagonal',true);

    % power correction filter
    powerCorrectionSOS = designGEQ(target_power);
    outputFilters = zSOS(permute(powerCorrectionSOS,[3 4 1 2]) .* output_gain);

    irTimeDomain = dss2impz(length_in_sample, delays, feedback_matrix, input_gain, outputFilters, direct, 'absorptionFilters', zAbsorption);
    
end
