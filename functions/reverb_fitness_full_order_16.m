function cost = reverb_fitness_full_order_16(TargetIRMeasures, x) 
   
    g_input_gain = x(1:16);  %% -1 : 1    // 16
    g_output_gain = x(17:32); %% -1 : 1    // 16
    g_delays = ceil(x(33:48)); %% 50 : 5000      // 16


    g_ir_time_domain = GenerateImpulseResponseFromFeatures(TargetIRMeasures, g_delays, g_input_gain, g_output_gain);
    
    %GeneratedIRMeasures = MeasureImpulseResponseFeatures(g_ir_time_domain, TargetIRMeasures.SAMPLE_RATE, "generated_IR");
   
    cost = sum(sum(melSpectrogramError(TargetIRMeasures.SIGNAL, g_ir_time_domain, TargetIRMeasures.SAMPLE_RATE)));
    
    fprintf("[LOG] Local Cost: %f \n", cost);

end