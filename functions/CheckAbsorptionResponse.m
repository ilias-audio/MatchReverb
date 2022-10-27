function CheckAbsorptionResponse(target_measures)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

figure(6);

clf;

OctaveCenterFreqs = [ 46, 63, 125, 250, 500, 1000, 2000, 4000, 8000 , 16000]; %% CAREFUL IT's 11360!!! it can explain the initial spectrum issue!


delays = [4947,1143,4205,1914,2697,4313,4596,1269,2457,1058,2647,217,1651,1465,2508,1682]; % taken from n10

values_time_freq_target = [target_measures.SPECTRUM_T30',target_measures.FREQ_T30];

rt30 = interp1( values_time_freq_target(:, 2), values_time_freq_target(:, 1), OctaveCenterFreqs');

t_target_t60 = rt30'*2;
t_target_t60(10) = t_target_t60(10)/2;


% absorption filters
zAbsorption = zSOS(absorptionGEQ(t_target_t60, delays, target_measures.SAMPLE_RATE),'isDiagonal',true);

Fs = target_measures.SAMPLE_RATE;
delay_n = 1;
[h, w] = freqz(squeeze(zAbsorption.sos(delay_n, 1, :, :)), 1024, Fs);



%freq = (w*target_measures.SAMPLE_RATE)/2;

semilogx(w, 20*log10(abs(h)));

hold on 


semilogx(target_measures.FREQ_T30, delays(delay_n)*RT602slope(target_measures.SPECTRUM_T30*2, target_measures.SAMPLE_RATE));


OctaveCenterFreqs = [ 46, 63, 125, 250, 500, 1000, 2000, 4000, 8000 , 16000];

values_time_freq_target = [target_measures.SPECTRUM_T30',target_measures.FREQ_T30];

rt30 = interp1( values_time_freq_target(:, 2), values_time_freq_target(:, 1), OctaveCenterFreqs');

semilogx(OctaveCenterFreqs, delays(delay_n)*RT602slope(rt30*2, target_measures.SAMPLE_RATE));

xlim([20, inf]);
legend('Absorption Filter Freq. Resp.', 'Target RT60 in Freq. Resp.', 'Requested Freq. Resp.');

title(['RT30 of ' target_measures.NAME ': '  num2str(target_measures.T60/2) 's vs ' num2str(target_measures.T60/2) 's'])
ylabel('RT30 (s)') 
xlabel('Frequency (Hz)') 


end

