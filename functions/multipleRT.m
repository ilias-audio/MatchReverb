function [array_60dB, t_w] = multipleRT(signal, fs)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[t_s, t_w, t_t ] = spectrogram(signal, 256, 255, 512, fs, 'yaxis');
    
    [shroder_energy schroder_energy_db] = schroeder(abs(t_s'));    
    
    relative_band_energy = schroder_energy_db - schroder_energy_db(1,:);

    max_audible_freq = find(t_w(:,1) >= 18000, 1) - 1;

    rt_values = [-20];

    schroder_energy_db = schroder_energy_db(:, 1:max_audible_freq);
    

    for i = 1:length(rt_values)
        for n = 1:length(relative_band_energy(1, 1:max_audible_freq))
            x = find(relative_band_energy(:,n) < rt_values(i), 1);
            if isempty(x)
                array_60dB(n,i) = 0;
            else
                array_60dB(n,i) = find(relative_band_energy(:,n) < rt_values(i), 1);
            end
        end
        array_60dB(:,i) = ((-60/rt_values(i))*(array_60dB(:,i)))/fs; 
    end
    

  
    t_w =t_w(1:max_audible_freq);
end