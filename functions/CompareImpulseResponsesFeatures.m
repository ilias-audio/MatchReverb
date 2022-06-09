function cost = CompareImpulseResponsesFeatures(TargetMeasures, GeneratedMeasures)

    [t_schroder_energy_db, t_array_30dB , t_w ] = rt30_from_spectrum(TargetMeasures.SIGNAL, TargetMeasures.SAMPLE_RATE);
    
    g_schroder_energy_db = ones(size(t_schroder_energy_db))*(-120);
    
    [g_schroder_energy_db_raw, g_array_30dB , t_w ] = rt30_from_spectrum(GeneratedMeasures.SIGNAL, GeneratedMeasures.SAMPLE_RATE);
    
    g_schroder_energy_db(1:length(g_schroder_energy_db_raw(:,1)),:) = g_schroder_energy_db_raw;


    sample_to_match = floor(max(TargetMeasures.SPECTRUM_T30*TargetMeasures.SAMPLE_RATE));


    weight_local_spectrum = 1;

    error_local_spectrum = immse(t_schroder_energy_db(1:sample_to_match,:), g_schroder_energy_db(1:sample_to_match,:));
    
    error_upper_envelope = immse(TargetMeasures.UPPER_ENVELOPE, GeneratedMeasures.UPPER_ENVELOPE);

    error_lower_envelope = immse(GeneratedMeasures.LOWER_ENVELOPE, GeneratedMeasures.LOWER_ENVELOPE);
    
    
    cost = (weight_local_spectrum * error_local_spectrum) + error_upper_envelope + error_lower_envelope;


end 