function PlotAbsorptionResponse(target_Structure,generated_Structure)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

figure(1);

clf;

target_Structure.FREQ_T30 = target_Structure.FREQ_T30 + (187.5/2);
generated_Structure.FREQ_T30 = generated_Structure.FREQ_T30 + (187.5/2);

semilogx(target_Structure.FREQ_T30, target_Structure.SPECTRUM_T30);
hold on 
semilogx(generated_Structure.FREQ_T30, generated_Structure.SPECTRUM_T30);

OctaveCenterFreqs = [ 46, 63, 125, 250, 500, 1000, 2000, 4000, 8000 , 16000];

values_time_freq_target = [target_Structure.SPECTRUM_T30',target_Structure.FREQ_T30];

rt30 = interp1( values_time_freq_target(:, 2), values_time_freq_target(:, 1), OctaveCenterFreqs');

semilogx(OctaveCenterFreqs, rt30);


legend('Target RT30', 'Best Generated IR RT30', 'Requested RT30 Curve');

title(['RT30 of ' target_Structure.NAME ': '  num2str(target_Structure.T60/2) 's vs ' num2str(generated_Structure.T60/2) 's'])
ylabel('RT30 (s)') 
xlabel('Frequency (Hz)') 


end

