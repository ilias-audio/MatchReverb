function [outputArg1,outputArg2] = PlotInitialSpectrum(target_Structure, generated_Structure)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

figure(4)
clf

target_Structure.FREQ_T30 = target_Structure.FREQ_T30 + (187.5/2);
generated_Structure.FREQ_T30 = generated_Structure.FREQ_T30 + (187.5/2);

semilogx(target_Structure.FREQ_T30, target_Structure.INITIAL_SPECTRUM);
hold on 
semilogx(generated_Structure.FREQ_T30, generated_Structure.INITIAL_SPECTRUM);

OctaveCenterFreqs = [ 46, 63, 125, 250, 500, 1000, 2000, 4000, 8000 , 16000];

values_time_freq_target = [target_Structure.INITIAL_SPECTRUM',target_Structure.FREQ_T30];

powerSpectrum = interp1( values_time_freq_target(:, 2), values_time_freq_target(:, 1), OctaveCenterFreqs');

semilogx(OctaveCenterFreqs, powerSpectrum);


legend('Target Spectrum', 'Best Generated Spectrum', 'Requested Spectrum');

title(['Initial Power Spectrum of ' target_Structure.NAME ': '  num2str(target_Structure.T60/2) 's vs ' num2str(generated_Structure.T60/2) 's'])
ylabel('Relative Energy (dB)') 
xlabel('Frequency (Hz)') 
end

