function cost = CompareImpulseResponsesSpectrograms(TargetMeasures, g_signal)

    t_signal = TargetMeasures.SIGNAL;
    
    t_fs = TargetMeasures.SAMPLE_RATE;
    
    %noise_power = -45;
    %additive_noise = (rand(size(g_signal)) - 0.5) * 10^(noise_power/20);

    [t_coeffs,t_freqs,t_time] = melSpectrogram(t_signal, t_fs,  "SpectrumType","power", 'NumBands',10);
    [g_coeffs] = melSpectrogram(g_signal,t_fs,  "SpectrumType","power", 'NumBands',10);
    
    t_coeffs = 10 .* log10(t_coeffs);
    g_coeffs = 10 .* log10(g_coeffs);
    
    t_coeffs(isinf(t_coeffs)) = -150;
    g_coeffs(isinf(g_coeffs)) = -150;
    
    

    
    %min_length = min(t_sample_to_match, length(g_coeffs));
        
    for i = 1:length(TargetMeasures.SPECTRUM_T30)
        min_length = round(0.25 * TargetMeasures.SPECTRUM_T30(i) * TargetMeasures.SAMPLE_RATE *(t_time(2)-t_time(1)));
        spectr_diff(i,1:min_length) = (t_coeffs(i, 1:min_length) - g_coeffs(i, 1:min_length));
        %clf
        %plot(spectr_diff(i,1:min_length))
        %hold on
        %plot(t_coeffs(i, 1:min_length))
        %plot(g_coeffs(i, 1:min_length))
    end
    
    
    cost = sum(mean(spectr_diff.^2,2));
   
end
