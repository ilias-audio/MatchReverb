function [irTimeDomain] = GenerateHybridResponseFromFeatures(MeasuresStruct, delays, input_gain, output_gain, direct_linear_gain)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    FDNOrder = 16;

    fprintf(">>>[INFO] start Generating Impulse Response based on %s...\n", MeasuresStruct.NAME);

   
    %% RT60
    
    rt30 = MeasuresStruct.SPECTRUM_T30;
    t_target_t60 = rt30'*2;
    
    t_initial_spectrum_values = zeros(size(MeasuresStruct.INITIAL_SPECTRUM));

    [direct_target, ~] = splitEarlyLate(MeasuresStruct);
    direct = ones(1,1) * direct_linear_gain;
    feedback_matrix = randomOrthogonal(FDNOrder);
    % absorption filters
    zAbsorption = zSOS(absorptionGEQ(t_target_t60, delays, MeasuresStruct.SAMPLE_RATE),'isDiagonal',true);

    % power correction filter
    powerCorrectionSOS = designGEQ(t_initial_spectrum_values);%, MeasuresStruct.SAMPLE_RATE);
    outputFilters = zSOS(permute(powerCorrectionSOS,[3 4 1 2]) .* output_gain);

    %% Initialize
    A = convert2zFilter(feedback_matrix);
    B = convert2zFilter(input_gain');
    C = convert2zFilter(outputFilters);
    numInput = B.m;

    %% Create dirac pulse
    input = zeros(length(MeasuresStruct.SIGNAL), numInput);
    input(1:length(direct_target),:) = direct_target;

    %% Time-Domain Recursion
    irTimeDomain = processFDN(input, delays, A, B, C, direct','inputType','splitInput', 'absorptionFilters', zAbsorption);
    
end
