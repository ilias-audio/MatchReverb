function [ratio_dB, ratio] = DirecttoReverbRatio(struct)
    [~, direct_index] = max(abs(struct.SIGNAL));
    
    direct_energy = struct.SIGNAL(direct_index);
    reverb_energy = struct.SIGNAL(direct_index:end);
    
    ratio = sum(direct_energy.^2) / sum(reverb_energy.^2);
    ratio_dB = 10*log10(ratio);

end

