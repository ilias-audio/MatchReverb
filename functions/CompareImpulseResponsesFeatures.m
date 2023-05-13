function cost = CompareImpulseResponsesFeatures(TargetMeasures, GeneratedMeasures)
    %% very senstivive to IR noise...


    t_signal = TargetMeasures.SIGNAL;
    g_signal = GeneratedMeasures.SIGNAL;
    
    t_fs = TargetMeasures.SAMPLE_RATE;
    g_fs = GeneratedMeasures.SAMPLE_RATE;
    
    window_len = round(0.003 * t_fs); % win > olvp
    ovlp_len = round(0.002 * t_fs);
    
    noise_power = -75;
    additive_noise = (rand(size(g_signal)) - 0.5) * 10^(noise_power/20);

%%
    [t_coeffs] = melSpectrogram(t_signal, t_fs, "OverlapLength", ovlp_len,"Window", hamming(window_len, "periodic"),  "SpectrumType","power");
    [g_coeffs] = melSpectrogram((g_signal),g_fs, "OverlapLength", ovlp_len,"Window", hamming(window_len, "periodic"),  "SpectrumType","power");
    
    t_coeffs = 10 .* log10(t_coeffs);
    g_coeffs = 10 .* log10(g_coeffs);
    
    t_coeffs(isinf(t_coeffs)) = -200;
    g_coeffs(isinf(g_coeffs)) = -200;
    
    t_sample_to_match = round(0.5 * TargetMeasures.T60 * TargetMeasures.SAMPLE_RATE);

    
    min_length = min(t_sample_to_match, length(g_coeffs));
    
    spectr_diff = (t_coeffs(:, 1:min_length) - g_coeffs(:, 1:min_length));
    
    
    %sample_to_match = round((length(t_coeffs) * TargetMeasures.T60 * t_fs) /length(t_signal));
    %min_length_coeff = min(length(t_coeffs), length(g_coeffs));
    
    
    
    
   % if sample_to_match > min_length_coeff
   %     sample_to_match = min_length_coeff;
   % end
    
   % cost = mean(mean(abs(t_coeffs(1:sample_to_match,1:end) - g_coeffs(1:sample_to_match,1:end))));
 %%   
    t_sample_to_match = round(0.5 * TargetMeasures.T60 * TargetMeasures.SAMPLE_RATE);
    g_sample_to_match = length(GeneratedMeasures.SCHROEDER(:,1));
    
    min_length = min(t_sample_to_match, g_sample_to_match);
    
    t_schroeder = 10 .* log10(TargetMeasures.SCHROEDER(1:min_length,:));
    g_schroeder = 10 .* log10(GeneratedMeasures.SCHROEDER(1:min_length,:));
    
    t_schroeder(t_schroeder < max(max(t_schroeder))-60) = max(max(t_schroeder))-60;
    g_schroeder(g_schroeder < max(max(g_schroeder))-60) = max(max(g_schroeder))-60;
    
    %fprintf(">>>[INFO] T60 %d...\n", min_length);
    alpha = 1;
    beta = .5;
    cost = alpha * mean(mean(abs(t_schroeder - g_schroeder))) + beta * mean(mean(spectr_diff));
end
