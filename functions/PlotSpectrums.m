function PlotSpectrums(target_Structure,generated_Structure)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

figure(2);

clf;


[t_schroder_energy_db , t_array_30dB , t_w ]= rt30_from_spectrum(target_Structure.SIGNAL, target_Structure.SAMPLE_RATE);
[g_schroder_energy_db , g_array_30dB , g_w ]= rt30_from_spectrum(generated_Structure.SIGNAL, generated_Structure.SAMPLE_RATE);

diff_energy_db = t_schroder_energy_db.SCHROEDER - g_schroder_energy_db.SCHROEDER;



% 
% for n = 1:15
%    array_30dB(n) = find(relative_band_energy(:,n) < -60, 1);  
%    t_z(n) = schroder_energy_db(array_30dB(n), n);
%    rt_target(n) = array_30dB(n)/48000;
% end
% 
% for n = 15:257
%   array_30dB(n) = find(relative_band_energy(:,n) < -30, 1);
%   t_z(n) = schroder_energy_db(array_30dB(n)*2, n);
%   rt_target(n) = 2*array0dB(n)/48000;
% end
spectrogram(target_Structure.SIGNAL,128,120,128,target_Structure.SAMPLE_RATE,'yaxis')
ax = gca;
ax.YScale = 'log';
% h = surf( [ t_schroder_energy_db']);
% set(h,'LineStyle','none')
% set(gca,'YScale','log')
% hold on
% view(-45, 65);


figure(3)
clf

spectrogram(generated_Structure.SIGNAL,128,120,128,generated_Structure.SAMPLE_RATE,'yaxis')
ax = gca;
ax.YScale = 'log';
% 
% h = surf( [ g_schroder_energy_db']);
% set(h,'LineStyle','none')
% set(gca,'YScale','log')
% hold on
% view(-45, 65)
% 
% 
% figure(8)
% clf
% h = surf( [ diff_energy_db']);
% set(h,'LineStyle','none')
% set(gca,'YScale','log')
% hold on
% view(-45, 65)

% plot3(rt_target,t_w, t_z)
%plot3(array_60dB/48000,t_w, z_60)

% 
% semilogx(target_Structure.SIGNAL, target_Structure.SPECTRUM_T30);
% hold on 
% semilogx(generated_Structure.FREQ_T30, generated_Structure.SPECTRUM_T30);
% 
% OctaveCenterFreqs = [ 46, 63, 125, 250, 500, 1000, 2000, 4000, 8000 , 16000];
% 
% values_time_freq_target = [target_Structure.SPECTRUM_T30',target_Structure.FREQ_T30];
% 
% rt30 = interp1( values_time_freq_target(:, 2), values_time_freq_target(:, 1), OctaveCenterFreqs');
% 
% semilogx(OctaveCenterFreqs, rt30);
% 
% 
% legend('Target RT30', 'Best Generated IR RT30', 'Requested RT30 Curve');
% 
% title(['RT30 of ' target_Structure.NAME ': '  num2str(target_Structure.T60/2) 's vs ' num2str(generated_Structure.T60/2) 's'])
% xlabel('RT30 (s)') 
% ylabel('Frequency (Hz)') 
end

