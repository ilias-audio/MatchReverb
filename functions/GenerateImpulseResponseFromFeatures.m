function [irTimeDomain] = GenerateImpulseResponseFromFeatures(MeasuresStruct, delays, input_gain, output_gain)

    FDNOrder = 16;

    fprintf(">>>[INFO] start Generating Impulse Response based on %s...\n", MeasuresStruct.NAME);

    rt30 = MeasuresStruct.SPECTRUM_T30;

    t_target_t60 = rt30'*2;

    t_initial_spectrum_values = bandpower(MeasuresStruct.SCHROEDER, MeasuresStruct.SAMPLE_RATE, [0 MeasuresStruct.SAMPLE_RATE/2]);

    direct = zeros(1,1);
    
    feedback_matrix = randomOrthogonal(FDNOrder);
    
    zAbsorption = zSOS(absorptionGEQ(t_target_t60, delays, MeasuresStruct.SAMPLE_RATE),'isDiagonal',true);
    powerCorrectionSOS = designGEQ(t_initial_spectrum_values);%, MeasuresStruct.SAMPLE_RATE);
    
    outputFilters = zSOS(permute(powerCorrectionSOS,[3 4 1 2]) .* output_gain);

    irTimeDomain = dss2impz(length(MeasuresStruct.SIGNAL), delays, feedback_matrix, input_gain', outputFilters, direct, 'absorptionFilters', zAbsorption);
    
end