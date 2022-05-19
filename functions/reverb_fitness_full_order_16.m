function cost = reverb_fitness_full_order_16(x, t_irValues, t_irT60, t_echo_density, t_initial_spectrum_values, t_signal_with_direct, t_array_30dB, t_schroder_energy_db, t_upper, t_lower, fs) 

    N = 16;
    
    t_length_in_sample = length(t_signal_with_direct);
    
    
    
    
    g_target_t60 = t_irT60; %% 0.01 : 6.0  // 10
    g_input_gain = x(1:16);  %% -1 : 1    // 16
    g_output_gain = x(17:32); %% -1 : 1    // 16
    g_delays = ceil(x(33:48)); %% 50 : 5000      // 16
    g_feedback_matrix = randomOrthogonal(N);
    %g_target_power = x(49:58);  % dB
    g_target_power = t_initial_spectrum_values;  % dB
    
    g_ir_time_domain = gen_IR_f(t_length_in_sample, N, g_input_gain', g_output_gain, g_feedback_matrix, g_delays, g_target_t60, g_target_power, fs);
   
    
    g_ir_time_domain = g_ir_time_domain / max(abs(g_ir_time_domain));

    g_signal_with_direct = zeros(size(t_signal_with_direct));
    
    [g_irValues,g_irT60, g_echo_density, g_signal_with_direct_raw]  = ir_analysis(g_ir_time_domain, fs);
    
    g_signal_with_direct(1:length(g_signal_with_direct_raw),1) = g_signal_with_direct_raw;
    
    %[g_spectrum,g_cf,g_Sig,fs] = DoOctaveBandSpect((g_signal_with_direct),96, fs);

    
    g_schroder_energy_db = ones(size(t_schroder_energy_db))*(-120);
    
    [g_schroder_energy_db_raw, g_array_30dB , t_w ] = rt30_from_spectrum(g_signal_with_direct, fs);
    
    g_schroder_energy_db(1:length(g_schroder_energy_db_raw(:,1)),:) = g_schroder_energy_db_raw;
    
    [g_upper, g_lower] = envelope(g_signal_with_direct, round(fs/300), 'peak');
    
    %error_spectrum    = immse(t_spectrum, g_spectrum);
    
    %error_band_t60    = immse(g_array_30dB, t_array_30dB);
    
    error_full_spectrum = immse(g_schroder_energy_db, t_schroder_energy_db);
    
    %% CHANGE SPECTRUM WITH THIS : 
    sample_to_match = floor(max(t_array_30dB)*fs);

    error_local_spectrum = immse(t_schroder_energy_db(1:sample_to_match,:), g_schroder_energy_db(1:sample_to_match,:));

    %% NOT FULL SPECTRUM BUT ONLY UP TO RT30!!!!
    
    error_upper_envelope = immse(t_upper, g_upper);

    error_lower_envelope = immse(t_lower, g_lower);
    
%     error_irT60      = abs(t_irValues.T60 - g_irValues.T60);
%     error_edt        = abs(t_irValues.EDT - g_irValues.EDT);
%     error_predelay   = abs(t_irValues.PREDELAY - g_irValues.PREDELAY);
%     error_c80        = abs(t_irValues.C80 - g_irValues.C80);
%     error_bass_ratio = abs(t_irValues.BR - g_irValues.BR);

    
    weight_irT60      = 0;
    weight_band_t60   = 0;
    weight_spectrum   = 0;
    weight_full_spectrum       = 1/400;
    weight_local_spectrum = 1/2;
%     weight_predelay   = 0;
%     weight_c80        = 0;
%     weight_bass_ratio = 0;
    
% 
%     cost = (weight_irT60 * error_irT60) + ...
%            (weight_band_t60 * error_band_t60) + ...
%            (weight_spectrum * error_spectrum) + ...
%            (weight_full_spectrum * error_full_spectrum) + ...
%            (weight_predelay * error_predelay) + ...
%            (weight_c80  * error_c80 ) + ...
%            (weight_bass_ratio * error_bass_ratio);
    
cost = (weight_local_spectrum * error_local_spectrum) + error_upper_envelope + error_lower_envelope;



end