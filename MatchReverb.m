%% GENERATE FDN REVERBERATION FROM TARGET IR

t_IRPath = './MLReverb/IR/';

t_IRNames = dir([t_IRPath 'ir_jack.wav']); 
centerFrequencies = [ 46, 63, 125, 250, 500, 1000, 2000, 4000, 8000 , 16000]; % Hz

N = 16;

%% IRAnalysis

for i= 1:length(t_IRNames)

    [t_raw_signal, fs] = audioread([t_IRPath t_IRNames(i).name]);

    t_raw_signal = t_raw_signal / max(abs(t_raw_signal));

    [t_irValues,t_irT60,t_echo_density, t_signal_with_direct] = ir_analysis(t_raw_signal, fs);

    [t_spectrum,t_cf,t_Sig,fs] = DoOctaveBandSpect((t_signal_with_direct),96, fs);

    [t_schroder_energy_db, t_array_30dB , t_w ]= rt30_from_spectrum(t_signal_with_direct, fs);

    [t_upper, t_lower] = envelope(t_signal_with_direct, round(fs/300), 'peak');

    %% RT60
    values_time_freq_target = [t_array_30dB',t_w];

    rt30 = interp1( values_time_freq_target(:, 2), values_time_freq_target(:, 1), centerFrequencies');

    t_target_t60 = rt30'*2;



    t_initial_spectrum = t_schroder_energy_db(1,:);

    t_offset = min(min(t_schroder_energy_db)) + 144;

    t_initial_spectrum_values = interp1(values_time_freq_target(:, 2) , t_initial_spectrum' - t_offset, centerFrequencies');

    t_initial_spectrum_values = t_initial_spectrum_values - max(t_initial_spectrum_values);


    t_length_in_sample = length(t_signal_with_direct);

    %% Genetic Algorithm
    population_size = 20;

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

    options = optimoptions("ga",'PlotFcn',{@gaplotbestf},  ...
        'Display','iter', 'MaxStallGenerations',1,'MaxGenerations',3, "PopulationSize",population_size, 'UseParallel', true);


    FitnessFunction = @(x)reverb_fitness_full_order_16(x, t_irValues, t_spectrum, t_target_t60', ...
                                                        t_echo_density,t_initial_spectrum_values, ...
                                                        t_signal_with_direct, t_array_30dB,t_schroder_energy_db,t_upper, t_lower, fs);


    [x,fval] = ga(FitnessFunction,numberOfVariables,[],[],[],[],lb,ub, [], options);

    %% Generated IR
    g_target_t60 = t_target_t60; %% 0.01 : 6.0  // 10
    g_target_t60(10) = g_target_t60(10) / 2;
    g_input_gain = x(1:16);  %% -1 : 1    // 16
    g_output_gain = x(17:32); %% -1 : 1    // 16
    g_delays = ceil(x(33:48)); %% 50 : 5000      // 16
    g_feedback_matrix = randomOrthogonal(N);

    %g_target_power = x(49:58);  % dB
    g_target_power = t_initial_spectrum_values;  % dB


    g_ir_time_domain = gen_IR_f(t_length_in_sample, N, g_input_gain', g_output_gain, g_feedback_matrix, g_delays, g_target_t60, g_target_power, fs);

    [g_irValues,g_irT60, g_echo_density, g_signal_with_direct]  = ir_analysis(g_ir_time_domain, fs);

    [g_schroder_energy_db, g_array_30dB , g_w ]= rt30_from_spectrum(g_signal_with_direct, fs);

    g_initial_spectrum = g_schroder_energy_db(1,:) - min(g_schroder_energy_db(1,:));


    [g_upper, g_lower] = envelope(g_signal_with_direct, round(fs/300), 'peak');


    %% Figures
    figure(1)
    clf
    semilogx(t_w, t_array_30dB'*2, 'DisplayName','target t60')
    hold on
    semilogx(g_w, g_array_30dB'*2, 'DisplayName','generated t60')
    semilogx(centerFrequencies, g_target_t60, 'DisplayName','wanted rt60')
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

    %% Write audio file
    g_fileName = ['gen_', t_IRNames(i).name];
    audiowrite([t_IRPath g_fileName], g_ir_time_domain, fs);

    %%save values 

    save(['./MLReverb/results/' , t_IRNames(i).name, '_parameters.mat'], 'x'); 

end



