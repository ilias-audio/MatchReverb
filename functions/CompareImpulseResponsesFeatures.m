function cost = CompareImpulseResponsesFeatures(TargetMeasures, GeneratedMeasures)

    [t_schroder_energy_db, t_array_30dB , t_w ] = rt30_from_spectrum(TargetMeasures.SIGNAL, TargetMeasures.SAMPLE_RATE);
  
    t_schroder_energy_db(isinf(t_schroder_energy_db)) = -150;
  
    g_schroder_energy_db = ones(size(t_schroder_energy_db))*(-120);
    
    [g_schroder_energy_db_raw, g_array_30dB , t_w ] = rt30_from_spectrum(GeneratedMeasures.SIGNAL, GeneratedMeasures.SAMPLE_RATE);
    
    g_schroder_energy_db(1:length(g_schroder_energy_db_raw(:,1)),:) = g_schroder_energy_db_raw;


    sample_to_match = floor(max(TargetMeasures.SPECTRUM_T30*TargetMeasures.SAMPLE_RATE));
    
    if sample_to_match > length(t_schroder_energy_db(:,1))
        sample_to_match = length(t_schroder_energy_db(:,1)) - 1;
    end


    weight_local_spectrum = 1;

    error_local_spectrum = immse(t_schroder_energy_db(1:sample_to_match,:) , g_schroder_energy_db(1:sample_to_match,:));
    
    error_upper_envelope = immse(TargetMeasures.UPPER_ENVELOPE(1:sample_to_match), GeneratedMeasures.UPPER_ENVELOPE(1:sample_to_match));

    error_lower_envelope = immse(GeneratedMeasures.LOWER_ENVELOPE(1:sample_to_match), GeneratedMeasures.LOWER_ENVELOPE(1:sample_to_match));
    
    error_rt30 = immse(GeneratedMeasures.SPECTRUM_T30,TargetMeasures.SPECTRUM_T30);
    
    
    cost = (weight_local_spectrum * error_local_spectrum) + error_rt30 + (0.5 * error_upper_envelope) + (0.5 * error_lower_envelope);
    
    cost(isnan(cost)) = 10^50;


end 