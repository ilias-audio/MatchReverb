function CheckSpectrumResponse(target_measures)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

figure(6);

clf;

OctaveCenterFreqs_for_power = [ 46, 63, 125, 250, 500, 1000, 2000, 4000, 8000 , 17500]; %% CAREFUL IT's 11360!!! it can explain the initial spectrum issue!


delays = [4947,1143,4205,1914,2697,4313,4596,1269,2457,1058,2647,217,1651,1465,2508,1682]; % taken from n10
output_gain = [0.0340346215245080	0.131302355197819	1.37723517078156	1.69351856841298	0.411372357528332	-0.950071061206669	1.85235415714765	1.95192801264653	-1.45378745057852	-0.663347789050015	0.470665558353819	-0.328291417270973	0.0865993698571348	0.595965970849425	-1.30644554752398	0.511893436760417];

values_time_freq_target = [target_measures.INITIAL_SPECTRUM',target_measures.FREQ_T30];


t_initial_spectrum_values = interp1(values_time_freq_target(:, 2) , values_time_freq_target(:,1), OctaveCenterFreqs_for_power');



% power correction filter
powerCorrectionSOS = designGEQ(t_initial_spectrum_values, target_measures.SAMPLE_RATE);
outputFilters = zSOS(permute(powerCorrectionSOS,[3 4 1 2]) .* output_gain);


Fs = MeasuresStruct.SAMPLE_RATE;
delay_n = 1;
[h, w] = freqz(squeeze(outputFilters.sos(delay_n, 1, :, :)), 1024, Fs);




semilogx(w, 20*log10(abs(h)));

hold on 


semilogx(target_measures.FREQ_T30, target_measures.INITIAL_SPECTRUM);


%OctaveCenterFreqs = [ 46, 63, 125, 250, 500, 1000, 2000, 4000, 8000 , 16000];

%values_time_freq_target = [target_measures.SPECTRUM_T30',target_measures.FREQ_T30];

%rt30 = interp1( values_time_freq_target(:, 2), values_time_freq_target(:, 1), OctaveCenterFreqs');

semilogx(OctaveCenterFreqs_for_power, t_initial_spectrum_values);

xlim([20, inf]);
legend('Absorption Filter Freq. Resp.', 'Target RT60 in Freq. Resp.', 'Requested Freq. Resp.');

title(['RT30 of ' target_measures.NAME ': '  num2str(target_measures.T60/2) 's vs ' num2str(target_measures.T60/2) 's'])
ylabel('RT30 (s)') 
xlabel('Frequency (Hz)') 

end