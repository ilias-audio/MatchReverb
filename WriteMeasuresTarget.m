%Result analysis

%MATCHREVERB - Match a target Impulse Response with an FDN
% Author: Ilias Ibnyahya
% Queen Mary University of London
% email: i.ibnyahya@qmul.ac.uk
% April 2022; Last revision: May 2022

%------------- BEGIN CODE --------------

fprintf(">>>[INFO] Setup Paths...\n");
targetIRPath = './IR_mono';
targetIR = dir(fullfile(targetIRPath, '**/*.wav'));
targetIR = targetIR(~[targetIR.isdir]);

fprintf(">>>[INFO] %d Impulse responses found...\n", length(targetIR));

FDNOrder = 16;


population_size = 10;
numOfGen = 3;

results_ir = zeros([4, length(targetIR)]);



for i= 1:length(targetIR)
%for i= 1:10

    
    fprintf(">>>[INFO] start IR %d/%d...\n", i , length(targetIR));
    
    clearvars -except numOfGen population_size FDNOrder targetIR OctaveCenterFreqs targetIRPath i results_ir
    
    resultPath = "./results";
    
%     full_filename  = fullfile(resultPath, [targetIR(i).name '_parameters.mat']);
%     
%     if isfile(full_filename)

    fprintf(">>>[INFO] start measuring %s...\n", targetIR(i).name);

    measures = MeasureImpulseResponseFeatures(fullfile(targetIR(i).folder, targetIR(i).name));

    save(['./results/' , targetIR(i).name, '_measures.mat'], 'measures'); 



    %% Generated IR
    
%         fprintf(">>>[INFO] start reading results %s...\n", [targetIR(i).name '_parameters.mat']);
% 
%         x = open(fullfile(full_filename));
%         x = x.x;
%         [g_input_gain,g_output_gain, g_delays] = splitXInParameters(x);
% 
%         g_target_t60 = t_target_t60; %% 0.01 : 6.0  // 10
%         g_target_t60(10) = g_target_t60(10) / 2;
%         g_feedback_matrix = randomOrthogonal(FDNOrder);
%         g_target_power = t_initial_spectrum_values;  % dB
% 
%         g_ir_time_domain = gen_IR_f(t_length_in_sample, FDNOrder, g_input_gain', g_output_gain, g_feedback_matrix, g_delays, g_target_t60, g_target_power, fs);
% 
%         [g_irValues,g_irT60, g_echo_density, g_signal_with_direct]  = ir_analysis(g_ir_time_domain, fs);
%         
%         g_signal_with_direct = g_signal_with_direct / max(abs(g_signal_with_direct));
% 
%         fprintf(">>>[INFO] start correlation results...\n");
%         
%         total_length = max(length(t_signal_with_direct), length(g_signal_with_direct));
%         t_signal_with_direct_pad = zeros([total_length,1]);
%         g_signal_with_direct_pad = zeros([total_length,1]);
%         
%         g_signal_with_direct_pad(1:length(g_signal_with_direct),1) = g_signal_with_direct;
%         t_signal_with_direct_pad(1:length(t_signal_with_direct),1) = t_signal_with_direct;
%         
%         g_signal_with_direct = g_signal_with_direct_pad;
%         t_signal_with_direct = t_signal_with_direct_pad;
%      
%         %results(1, i) = targetIR(i).name; % name
%         results_ir(2, i) = t_irValues.T60; % target rt60 global
%         results_ir(3, i) = g_irValues.T60; % generated rt60 global
%         results_ir(4, i) = abs(xcorr(t_signal_with_direct, g_signal_with_direct, 0, 'coeff')); % correlation
%         %results(5, i) = immse(t_irT60,g_irT60); % mean square error rt60
%         %%results(6, i) = immse(t_irT60,g_irT60);
        
        
        
    %else
      %  fprintf(">>>[WARNING] %s not found!...\n", full_filename);
    
    %end
    fprintf("\n");
end

B = sortrows(results_ir',2,'descend');



