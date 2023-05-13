function cost = objective_loss(tar_signal, parameters, fs)


[g_input_gain, g_output_gain, g_delays, g_direct_gain, g_rt60s, g_tone_filter_gains] = splitAllParameters(parameters);
[g_ir_time_domain] = GenerateImpulseResponseFromParameters(length(tar_signal), g_delays, g_input_gain, g_output_gain,  g_direct_gain, g_rt60s, g_tone_filter_gains , fs , 16);
    
cost = sum(stftloss(tar_signal, g_ir_time_domain, fs), 2);

 fprintf('local cost: objective value = %f\n', cost);


end
