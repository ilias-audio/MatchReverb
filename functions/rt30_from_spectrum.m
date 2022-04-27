function [schroder_energy_db , array_30dB , t_w ]= rt30_from_spectrum(signal, fs)

    
    [t_s, t_w, t_t ] = spectrogram(signal, 256, 255, 512, fs, 'yaxis' );
    
    [shroder_energy schroder_energy_db] = schroeder(abs(t_s'));    
    
    relative_band_energy = schroder_energy_db - schroder_energy_db(1,:);
    
    for n = 1:length(relative_band_energy(1, :))
        x = find(relative_band_energy(:,n) < -30, 1);
        if isempty(x)
            array_30dB(n) = 0;
        else
            array_30dB(n) = find(relative_band_energy(:,n) < -30, 1);
        end
    end
    
    array_30dB = (array_30dB)/fs;
  

end