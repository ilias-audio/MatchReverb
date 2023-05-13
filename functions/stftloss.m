function [S, F, T] = stftloss(tar_signal, gen_signal, fs)
    powerRange = 60; %dB
    max_size = 250;
    [tar_spectogram, tar_freqs, tar_times] = melSpectrogram(tar_signal, fs);

    [gen_spectogram, gen_freqs, gen_times] = melSpectrogram(gen_signal, fs);

    tar_spectrum_dB = max(10*log10(abs(tar_spectogram)));
    gen_spectrum_dB = max(10*log10(abs(gen_spectogram)));

    times = tar_times(1:max_size);
    
    MaxPowerTar = max(max(tar_spectrum_dB));
    MaxPowerGen = max(max(gen_spectrum_dB));

    minThreshold = min(MaxPowerTar, MaxPowerGen) - powerRange;
    tar_spectrum_dB = max(10*log10(abs(tar_spectogram(:, 1:max_size))), minThreshold);
    gen_spectrum_dB = max(10*log10(abs(gen_spectogram(:, 1:max_size))), minThreshold);
    %figure;
    %surf(times, tar_freqs, tar_spectrum_dB,  'LineStyle','none')

    %figure;
    %surf(times, tar_freqs, gen_spectrum_dB, 'LineStyle','none')

    %figure;
    %surf(times, tar_freqs, abs(tar_spectrum_dB - gen_spectrum_dB), 'LineStyle','none')


    S = abs(tar_spectrum_dB - gen_spectrum_dB);
    F = tar_freqs;
    T = tar_times;
    %P = tar_psd - gen_psd;

end