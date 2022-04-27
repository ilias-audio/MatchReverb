function [t_irValues, g_irValues, e_irValues] = fdnResultCompare(t_IR,g_IR)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%% target
    [t_raw_signal, t_fs] = audioread(t_IR);

    [t_irValues,t_irT60,t_echo_density, t_signal_with_direct_raw] = ir_analysis(t_raw_signal, t_fs);
    
    
    [g_raw_signal, g_fs] = audioread(g_IR);
    
    [g_irValues,g_irT60, g_echo_density, g_signal_with_direct_raw]  = ir_analysis(g_raw_signal, g_fs);
    
    
    ir_length = max([length(t_signal_with_direct_raw),length(g_signal_with_direct_raw)]);
    
    g_signal_with_direct = zeros([1,ir_length]);
    t_signal_with_direct = zeros([1,ir_length]);
    
    g_signal_with_direct(1:length(g_signal_with_direct_raw)) = g_signal_with_direct_raw;
    t_signal_with_direct(1:length(t_signal_with_direct_raw)) = t_signal_with_direct_raw;
    
    
    

    [t_spectrum,t_cf,t_Sig,t_fs] = DoOctaveBandSpect((t_signal_with_direct),96, t_fs);

    [t_schroder_energy_db, t_irValues.RT30F , t_w ]= rt30_from_spectrum(t_signal_with_direct, t_fs);

    [t_irValues.WAVUPPER, t_irValues.WAVLOWER] = envelope(t_signal_with_direct, round(t_fs/300), 'peak');

    %% RT60
    values_time_freq_target = [t_irValues.RT30F',t_w];

    %rt30 = interp1( values_time_freq_target(:, 2), values_time_freq_target(:, 1), centerFrequencies');

    %t_target_t60 = rt30'*2;



    t_initial_spectrum = t_schroder_energy_db(1,:);

    t_offset = min(min(t_schroder_energy_db)) + 144;

    %t_initial_spectrum_values = interp1(values_time_freq_target(:, 2) , t_initial_spectrum' - t_offset, centerFrequencies');

    %t_initial_spectrum_values = t_initial_spectrum_values - max(t_initial_spectrum_values);
    
    %% generated
    
    [g_schroder_energy_db, g_irValues.RT30F , g_w ]= rt30_from_spectrum(g_signal_with_direct, g_fs);

    g_initial_spectrum = g_schroder_energy_db(1,:) - min(g_schroder_energy_db(1,:));

    [g_irValues.WAVUPPER, g_irValues.WAVLOWER] = envelope(g_signal_with_direct, round(g_fs/300), 'peak');
    
    
    
    e_irValues.PREDELAY = immse(t_irValues.PREDELAY, g_irValues.PREDELAY);
    e_irValues.T60 = immse(t_irValues.T60, g_irValues.T60);
    e_irValues.EDT = immse(t_irValues.EDT, g_irValues.EDT);
    e_irValues.C80 = immse(t_irValues.C80, g_irValues.C80);
    e_irValues.BR = immse(t_irValues.BR, g_irValues.BR);
    e_irValues.BR = immse(t_irValues.BR, g_irValues.BR);
    e_irValues.WavUpper = immse(t_irValues.WAVUPPER, g_irValues.WAVUPPER);
    e_irValues.WavLower = immse(t_irValues.WAVUPPER, g_irValues.WAVLOWER);
    e_irValues.RT30F = immse(g_irValues.RT30F, t_irValues.RT30F);
    
end

