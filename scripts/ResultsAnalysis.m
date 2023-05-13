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

OctaveCenterFreqs = [ 46, 63, 125, 250, 500, 1000, 2000, 4000, 8000 , 16000];
FDNOrder = 16;

population_size = 10;
numOfGen = 3;


for i= 1:length(targetIR)
    
    fprintf(">>>[INFO] start IR %d/%d...\n", i , length(targetIR));
    
    clearvars -except numOfGen population_size FDNOrder OctaveCenterFreqs targetIR targetIRPath i
    
    resultPath = "./results/parameters";
    
    full_filename  = fullfile(resultPath, ['gen_' targetIR(i).name(1:end-4) '_parameters.mat']);
    
    if isfile(full_filename)
        
        

        fprintf(">>>[INFO] start reading %s...\n", targetIR(i).name);


        [t_raw_signal, fs] = audioread(fullfile(targetIR(i).folder, targetIR(i).name));

        t_raw_signal = t_raw_signal / max(abs(t_raw_signal));

        [t_irValues,t_irT60,t_echo_density, t_signal_with_direct] = ir_analysis(t_raw_signal, fs);

        [t_schroder_energy_db, t_array_30dB , t_w ]= rt30_from_spectrum(t_signal_with_direct, fs);

        [t_upper, t_lower] = envelope(t_signal_with_direct, round(fs/300), 'peak');

        %% RT60
        values_time_freq_target = [t_array_30dB',t_w];

        rt30 = interp1( values_time_freq_target(:, 2), values_time_freq_target(:, 1), OctaveCenterFreqs');

        t_target_t60 = rt30'*2;

        t_initial_spectrum = t_schroder_energy_db(1,:);

        t_initial_spectrum_values = interp1(values_time_freq_target(:, 2) , t_initial_spectrum', OctaveCenterFreqs');

        t_length_in_sample = length(t_signal_with_direct);

        %% Genetic Algorithm


        boundary_target_t60  = [ones(1,10)*0.01; ones(1,10)*6];
        boundary_input_gain  = [ones(1,16)*-2; ones(1,16)*2];
        boundary_output_gain = [ones(1,16)*-2; ones(1,16)*2];
        boundary_delays      = [ones(1,16)*50; ones(1,16)*5000];
        boundary_power       = [ones(1,10)*-15; ones(1,10)*15];

        lb = [boundary_input_gain(1,:), boundary_output_gain(1,:), boundary_delays(1,:)];%, boundary_power(1,:)];
        ub = [boundary_input_gain(2,:), boundary_output_gain(2,:), boundary_delays(2,:)];%, boundary_power(2,:)];
        init_t_60 = t_target_t60;
        initial_vector = RT602slope(init_t_60,fs); 
        initial_matrix = repmat(initial_vector, 1, population_size);

        numberOfVariables = length(ub);
    % 
    %     options = optimoptions("ga",'PlotFcn',{@gaplotbestf},  ...
    %         'Display','iter', 'MaxStallGenerations',1,'MaxGenerations',numOfGen, ...
    %         "PopulationSize",population_size, 'UseParallel', true);
    % 
    % 
    %     FitnessFunction = @(x)reverb_fitness_full_order_16(x, ...
    %         t_irValues, t_target_t60', t_echo_density, ...
    %         t_initial_spectrum_values, t_signal_with_direct, t_array_30dB, ...
    %         t_schroder_energy_db, t_upper, t_lower, fs);
    % 
    %     [x,fval] = ga(FitnessFunction,numberOfVariables,[],[],[],[],lb,ub, [], options);

    %% Generated IR
    
        fprintf(">>>[INFO] start reading results %s...\n", [targetIR(i).name '_parameters.mat']);

        x = open(fullfile(full_filename));
        x = x.x;
        [g_input_gain,g_output_gain, g_delays] = splitXInParameters(x);

        g_target_t60 = t_target_t60; %% 0.01 : 6.0  // 10
        g_target_t60(10) = g_target_t60(10) / 2;
        g_feedback_matrix = randomOrthogonal(FDNOrder);

        %g_target_power = x(49:58);  % dB
        g_target_power = t_initial_spectrum_values;  % dB

        g_ir_time_domain = gen_IR_f(t_length_in_sample, FDNOrder, g_input_gain', g_output_gain, g_feedback_matrix, g_delays, g_target_t60, g_target_power, fs);

        [g_irValues,g_irT60, g_echo_density, g_signal_with_direct]  = ir_analysis(g_ir_time_domain, fs);

        [g_schroder_energy_db, g_array_30dB , g_w ]= rt30_from_spectrum(g_signal_with_direct, fs);

        g_initial_spectrum = g_schroder_energy_db(1,:);

        [g_upper, g_lower] = envelope(g_signal_with_direct, round(fs/300), 'peak');


        %% Figures
        figure(1)
        clf
        semilogx(t_w, t_array_30dB'*2, 'DisplayName','target t60')
        hold on
        semilogx(g_w, g_array_30dB'*2, 'DisplayName','generated t60')
        semilogx(OctaveCenterFreqs, g_target_t60, 'DisplayName','wanted rt60')
        legend


        figure(2)
        clf
        semilogx(t_w, g_initial_spectrum, 'DisplayName','generated power')
        hold on
        semilogx(g_w, t_initial_spectrum , 'DisplayName','target power')
        legend

        figure(3)
        clf
        plot(g_upper,'DisplayName','GenUpper')
        hold on 
        plot(t_upper,'DisplayName','TarUpper')

        figure(4)
        clf
        hold on
        plot(g_lower,'DisplayName','GenLower')
        plot(t_lower,'DisplayName','TarLower')
    else
        fprintf(">>>[WARNING] %s not found!...\n", full_filename);
    
    end
end



