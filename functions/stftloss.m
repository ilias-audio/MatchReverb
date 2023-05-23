function [S, F, T] = stftloss(tar_signal, gen_signal, fs)
    tar_signal = tar_signal(1:length(tar_signal)/3);

    octFilBank = octaveFilterBank('1 octave',fs, ...
                              'FrequencyRange',[22 22000]);

    tar_audio_out = octFilBank(tar_signal);

    freqs = getCenterFrequencies(octFilBank);
    tar_bands_ir = squeeze(tar_audio_out(:,:,:));

    lowest_error = 1e5;

    gen_audio_out = octFilBank(gen_signal);

    gen_bands_ir = squeeze(gen_audio_out(:,:,:));
   

    powerRange = 60; %dB
    max_size = 128;
    
    [tar_spectogram,cf, t] = poctave(tar_bands_ir, fs, 'spectrogram');
    
    [gen_spectogram,cf, t] = poctave(gen_bands_ir, fs, 'spectrogram');
    
    tar_spectrum_dB = (10*log10(abs(tar_spectogram)));
    gen_spectrum_dB = (10*log10(abs(gen_spectogram)));
    
    MaxPowerTar = max(max(tar_spectrum_dB));
    MaxPowerGen = max(max(gen_spectrum_dB));
    
    minThreshold = min(MaxPowerTar, MaxPowerGen) - powerRange;
    tar_spectrum_dB = max(10*log10(abs(tar_spectogram)), minThreshold);
    gen_spectrum_dB = max(10*log10(abs(gen_spectogram)), minThreshold);

    error_per_band_time = sum(tar_spectrum_dB(:,1:max_size, :),2) - sum(gen_spectrum_dB(:,1:max_size, :),2); % size 10

    error_per_band_time = sum(error_per_band_time,3);

    
    S = sum(abs(error_per_band_time),'all');
    F = cf;
    T = t;
    %P = tar_psd - gen_psd;

end