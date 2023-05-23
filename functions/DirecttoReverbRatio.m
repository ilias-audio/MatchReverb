function [ratio_dB, ratio] = DirecttoReverbRatio(struct)
    threshold = 0.01;
    [~, direct_index] = max(abs(struct.SIGNAL) > threshold);
    
    direct_signal = struct.SIGNAL(1:direct_index);
    reverb_signal = struct.SIGNAL(direct_index+1:end-1200);

    direct_energy = sum(direct_signal.^2);
    reverb_energy = sum(reverb_signal.^2);
    
    ratio = direct_energy / reverb_energy;
    ratio_dB = 10*log10(ratio);

end

