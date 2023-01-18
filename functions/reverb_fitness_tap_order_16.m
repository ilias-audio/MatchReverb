function cost = reverb_fitness_tap_order_16(TargetIRMeasures, x) 
   
    g_input_gain = x(1:16);  %% -1 : 1    // 16
    g_output_gain = x(17:32); %% -1 : 1    // 16
    g_delays = ceil(x(33:48)); %% 50 : 5000      // 16
    g_direct_gain = x(49);


    %g_ir_time_domain = GenerateImpulseResponseFromFeatures(TargetIRMeasures, g_delays, g_input_gain, g_output_gain);

    g_ir_time_domain = GenerateTapResponseFromFeatures(TargetIRMeasures, g_delays, g_input_gain, g_output_gain, g_direct_gain);
    
    %g_ir_time_domain = g_ir_time_domain / max(abs(g_ir_time_domain));
    
    
    GeneratedIRMeasures = MeasureImpulseResponseFeatures(g_ir_time_domain, TargetIRMeasures.SAMPLE_RATE, "hybrid_IR");
   
    cost = CompareImpulseResponsesFeatures(TargetIRMeasures, GeneratedIRMeasures);
    
    fprintf("[LOG] Local Cost: %f \n", cost);

    



end