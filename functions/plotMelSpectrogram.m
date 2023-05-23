function plotMelSpectrogram(tar_signal,gen_signal, fs)

powerRange = 60;
max_size = 250;

[tar_spect, tar_freqs, tar_times] = melSpectrogram(tar_signal, fs);

[gen_spect, gen_freqs, gen_times] = melSpectrogram(gen_signal, fs);

tar_spect_dB = (10*log10(abs(tar_spect)));
gen_spect_dB = (10*log10(abs(gen_spect)));

MaxPowerTar = max(max(tar_spect_dB));
MaxPowerGen = max(max(gen_spect_dB));

minThreshold = min(MaxPowerTar, MaxPowerGen) - powerRange;

tar_spectrum_dB = max(tar_spect_dB(:, 1:max_size), minThreshold);
gen_spectrum_dB = max(gen_spect_dB(:, 1:max_size), minThreshold);

figure;
surf(tar_times(1:max_size,:), tar_freqs, tar_spectrum_dB,  'LineStyle','none');
title("Target");

figure;
surf(tar_times(1:max_size,:), tar_freqs, gen_spectrum_dB, 'LineStyle','none');
title("Generated");

figure;
surf(tar_times(1:max_size,:), tar_freqs, abs(tar_spectrum_dB - gen_spectrum_dB), 'LineStyle','none');
title("Error");

end