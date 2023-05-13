function irTimeDomain = GenerateImpulseResponseFromParameters(signal_length, delays, input_gain, output_gain, direct, rt60s, tone_filters, fs, order)

    fprintf(">>>[INFO] start Generating Impulse Response based parameters...\n");

    FDNOrder = order;

    t_target_t60 = rt60s;

    t_initial_spectrum_values = tone_filters;

    %direct = zeros(1,1);
    
    feedback_matrix = randomOrthogonal(FDNOrder);
    
    zAbsorption = zSOS(absorptionGEQ(t_target_t60, delays, fs),'isDiagonal',true);
    powerCorrectionSOS = designGEQ(t_initial_spectrum_values);
    
    outputFilters = zSOS(permute(powerCorrectionSOS,[3 4 1 2]) .* output_gain);

    irTimeDomain = dss2impz(signal_length, delays, feedback_matrix, input_gain', outputFilters, direct, 'absorptionFilters', zAbsorption);
   