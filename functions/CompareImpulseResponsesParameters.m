function cost = CompareImpulseResponsesSpectrograms(TargetMeasures, g_signal)
    %% very senstivive to IR noise...


    t_signal = TargetMeasures.SIGNAL;
    
    t_fs = TargetMeasures.SAMPLE_RATE;
    
    noise_power = -75;
    additive_noise = (rand(size(g_signal)) - 0.5) * 10^(noise_power/20);

%%
    [t_coeffs] = melSpectrogram(t_signal, t_fs,  "SpectrumType","power", 'NumBands',10);
    [g_coeffs] = melSpectrogram((g_signal),g_fs,  "SpectrumType","power", 'NumBands',10);
    
    t_coeffs = 10 .* log10(t_coeffs);
    g_coeffs = 10 .* log10(g_coeffs);
    
    t_coeffs(isinf(t_coeffs)) = -150;
    g_coeffs(isinf(g_coeffs)) = -150;
    
    t_sample_to_match = round(TargetMeasures.T60 * TargetMeasures.SAMPLE_RATE);

    
    min_length = min(t_sample_to_match, length(g_coeffs));
    
    spectr_diff = (t_coeffs(:, 1:min_length) - g_coeffs(:, 1:min_length));
    
    cost = spectr_diff;
   
end
