function cost = CompareImpulseResponsesFeatures(TargetMeasures, GeneratedMeasures)

    t_schroeder_lin = TargetMeasures.SCHROEDER;
    
    g_schroeder_lin = ones(size(t_schroeder_lin))*0.00001;
    
    g_schroeder_lin(1:length(GeneratedMeasures.SCHROEDER(:,1)),:) = GeneratedMeasures.SCHROEDER;

    error_shroeder = abs(t_schroeder_lin - g_schroeder_lin);
    
    


%     [t_struct , t_schroder_energy_db , t_w ] = rt30_from_spectrum(TargetMeasures.SIGNAL, TargetMeasures.SAMPLE_RATE);
%   
%     t_schroder_energy_db(isinf(t_schroder_energy_db)) = -150;
%   
%     g_schroder_energy_db = ones(size(t_schroder_energy_db))*(-120);
%     
%     [g_struct, g_schroder_energy_db_raw , t_w ] = rt30_from_spectrum(GeneratedMeasures.SIGNAL, GeneratedMeasures.SAMPLE_RATE);
%     
%     g_schroder_energy_db(1:length(g_schroder_energy_db_raw(:,1)),:) = g_schroder_energy_db_raw;
% 
% 
%      sample_to_match = floor(max(TargetMeasures.T60*TargetMeasures.SAMPLE_RATE));
%      
%      if sample_to_match > length(t_schroeder_lin(:,1))
%          sample_to_match = length(t_schroeder_lin(:,1)) - 1;
%      end
% 
% 
%     weight_local_spectrum = 1;
% 
%     

    error_local_spectrum = sum(sum(error_shroeder));
    
%     t_lin_sch = 10.^(TargetMeasures.SCHROEDER_DB/10);
%     g_lin_sch = 10.^(GeneratedMeasures.SCHROEDER_DB/10);
% 
%     diff_spec = t_lin_sch - g_lin_sch;
% 
% 
%     error_local_spectrum = mean(mean(abs(diff_spec)));


%     error_upper_envelope = immse(TargetMeasures.UPPER_ENVELOPE(1:sample_to_match), GeneratedMeasures.UPPER_ENVELOPE(1:sample_to_match));
% 
%     error_lower_envelope = immse(GeneratedMeasures.LOWER_ENVELOPE(1:sample_to_match), GeneratedMeasures.LOWER_ENVELOPE(1:sample_to_match));
%     
%     error_rt30 = immse(GeneratedMeasures.SPECTRUM_T30,TargetMeasures.SPECTRUM_T30);
    
    
    cost = ( error_local_spectrum);
    
    cost(isnan(cost)) = 10^50;


end 