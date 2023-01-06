function [irTimeDomain] = GenerateImpulseResponseFromFeatures(MeasuresStruct, delays, input_gain, output_gain)
    clf

    FDNOrder = 16;

    fprintf(">>>[INFO] start Generating Impulse Response based on %s...\n", MeasuresStruct.NAME);

    rt30 = MeasuresStruct.SPECTRUM_T30;

    t_target_t60 = rt30'*2;
    
        % Additional step
    octFilBank = octaveFilterBank('1 octave',MeasuresStruct.SAMPLE_RATE, ...
                                  'FrequencyRange',[18 22000]);                        
    t_audio_out = octFilBank(MeasuresStruct.SIGNAL);
    
    t_bands_ir = squeeze(t_audio_out(:,:,:));


    t_initial_spectrum_values = 10 * log10 (bandpower(t_bands_ir, MeasuresStruct.SAMPLE_RATE, [0 MeasuresStruct.SAMPLE_RATE/2]));

    direct = zeros(1,1);
    
    feedback_matrix = randomOrthogonal(FDNOrder);
    
    zAbsorption = zSOS(absorptionGEQ(t_target_t60, delays, MeasuresStruct.SAMPLE_RATE),'isDiagonal',true);
    powerCorrectionSOS = designGEQ(t_initial_spectrum_values);
    
    outputFilters = zSOS(permute(powerCorrectionSOS,[3 4 1 2]) .* output_gain);

    irTimeDomain = dss2impz(length(MeasuresStruct.SIGNAL), delays, feedback_matrix, input_gain', outputFilters, direct, 'absorptionFilters', zAbsorption);
    
    % Additional step
    octFilBank = octaveFilterBank('1 octave',MeasuresStruct.SAMPLE_RATE, ...
                                  'FrequencyRange',[18 22000]);                        
    g_audio_out = octFilBank(irTimeDomain);

    g_bands_ir = squeeze(g_audio_out(:,:,:));

    [schroeder_energy schroder_energy_db] = schroeder(abs(g_bands_ir));
    
    g_post_spectrum_values = 10 * log10(bandpower(g_bands_ir, MeasuresStruct.SAMPLE_RATE, [0 MeasuresStruct.SAMPLE_RATE/2]));
    
    g_post_spectrum_values(isinf(g_post_spectrum_values)) = -150;
    
    difference_in_energy = t_initial_spectrum_values + ( t_initial_spectrum_values - g_post_spectrum_values);
    
    powerCorrectionSOS = designGEQ(difference_in_energy);
    
    outputFilters = zSOS(permute(powerCorrectionSOS,[3 4 1 2]) .* output_gain);

    irTimeDomain = dss2impz(length(MeasuresStruct.SIGNAL), delays, feedback_matrix, input_gain', outputFilters, direct, 'absorptionFilters', zAbsorption);
    
    % Testing step
                  
    debug_audio_out = octFilBank(irTimeDomain);

    debug_bands_ir = squeeze(debug_audio_out(:,:,:));

    [debug_schroeder_energy schroder_energy_db] = schroeder(abs(debug_bands_ir));
    
    g_debug_spectrum_values = 10 * log10(bandpower(debug_bands_ir, MeasuresStruct.SAMPLE_RATE, [0 MeasuresStruct.SAMPLE_RATE/2]));
    g_debug_spectrum_values(isinf(g_debug_spectrum_values)) = -150;
    plot(t_initial_spectrum_values)
    hold on
    plot(g_post_spectrum_values)
    plot(g_debug_spectrum_values)
    
    
end