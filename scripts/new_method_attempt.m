% New optimisation technique

target_IR_folder = fullfile(pwd, "IR_test");
measures_dir = fullfile(pwd, "debug/target/measures");

result_dir = fullfile(pwd, "debug/all");

fprintf(">>>[INFO] Setup Paths...\n");
    targetMeasures = dir(fullfile(measures_dir, '**/*measures.mat'));
    targetMeasures = targetMeasures(~[targetMeasures.isdir]);

    fprintf(">>>[INFO] %d Measures found...\n", length(targetMeasures));
    population_size = 25;
    numOfGen = 1;
    
    mkdir(fullfile(result_dir));
    mkdir(fullfile(result_dir, "audio"));
    mkdir(fullfile(result_dir, "measures"));

    genMeasures = dir(fullfile(result_dir, "measures", '**/*measures.mat'));
    genMeasures = genMeasures(~[genMeasures.isdir]);

for i= 1:length(targetMeasures)

    clearvars -except numOfGen population_size FDNOrder  targetMeasures targetIRPath i result_dir OptimizationType genMeasures
    
    fprintf(">>>[INFO] Start reading %d/%d, %s...\n", i , length(targetMeasures), targetMeasures(i).name);

    load(fullfile(genMeasures(i).folder, genMeasures(i).name));

    gen_measures = measures;
    
    load(fullfile(targetMeasures(i).folder, targetMeasures(i).name));

    tar_measures = measures;


    %% Genetic Algorithm
    genMIN_DELAY_IN_S = 0.00025;
    MAX_DELAY_IN_S = 0.125;

    boundary_input_gain  = [ones(1,16)*-1; ones(1,16)*1];
    boundary_output_gain = [ones(1,16)*-1; ones(1,16)*1];
    boundary_direct_gain = [0;1];
    boundary_delays      = [ones(1,16)*round(MIN_DELAY_IN_S * measures.SAMPLE_RATE); ones(1,16)*round(MAX_DELAY_IN_S * measures.SAMPLE_RATE)];
    boundary_rt60s       = [ones(1,10)*0.05; ones(1,10)*10]; %% 50 : 5000 // 10
    boundary_tone_filters = [ones(1,10)*-25; ones(1,10)*25]; %% 50 : 5000 // 10

    
    lb = [boundary_input_gain(1,:), boundary_output_gain(1,:), boundary_delays(1,:) ,boundary_direct_gain(1,:)];
    ub = [boundary_input_gain(2,:), boundary_output_gain(2,:), boundary_delays(2,:), boundary_direct_gain(2,:)];

    numberOfVariables = length(ub);

    %InitialPopulationMatrix = zeros((population_size, length(ub));
    InitialPopulationInputGain = (2 .* rand(population_size, length(boundary_input_gain(1,:)))) - 1;  % between -1 and 1
    InitialPopulationOutputGain = (2 .* rand(population_size, length(boundary_output_gain(1,:)))) - 1;% between -1 and 1
    InitialPopulationDelays = randi([boundary_delays(1,1) boundary_delays(2,1)], [population_size, length(boundary_delays(1,:))]);% between 12 samples and 125ms
    InitialPopulationDirectGain = (rand(population_size, length(boundary_direct_gain(1,:))));% between -1 and 1
    InitialPopulationrt60s = (0.5 + rand(population_size, length(boundary_rt60s(1,:)))) .* (measures.SPECTRUM_T30 * 2);
    InitialPopulationToneFilters = (0.5 + rand(population_size, length(boundary_tone_filters(1,:)))) .* measures.INITIAL_SPECTRUM;

    InitialPopulationMatrix = [InitialPopulationInputGain InitialPopulationOutputGain InitialPopulationDelays InitialPopulationDirectGain];


    options = optimoptions("ga",'PlotFcn',{@gaplotbestf},  ...
    'Display','iter', 'MaxStallGenerations',1,'MaxGenerations',numOfGen, ...
    "PopulationSize",population_size, 'UseParallel', false, "InitialPopulationMatrix",InitialPopulationMatrix);

    measures.INITIAL_SPECTRUM = gen_measures.TONE_GAINS_NEW;
    measures.SPECTRUM_T30 = gen_measures.ABSORPTION_FILTERS_NEW / 2;

    FitnessFunction = @(x)reverb_fitness_full_order_16(measures, x(1:end-1));

    [x,fval] = ga(FitnessFunction,numberOfVariables,[],[],[],[],lb,ub, [], options);

    

    [g_input_gain, g_output_gain, g_delays, g_direct_gain] = splitXInParameters(x);

    g_direct_gain = 1;

    parameters = lsm_gains(measures.SIGNAL,[g_input_gain, g_output_gain, g_delays, g_direct_gain, gen_measures.ABSORPTION_FILTERS_NEW, gen_measures.TONE_GAINS_NEW], measures.SAMPLE_RATE);


   [g_input_gain, g_output_gain, g_delays, g_direct_gain, g_rt60s, g_tone_filter_gains] = splitAllParameters(parameters);
   [g_ir_time_domain] = GenerateImpulseResponseFromParameters(length(measures.SIGNAL), g_delays, g_input_gain, g_output_gain,  g_direct_gain, g_rt60s, g_tone_filter_gains , measures.SAMPLE_RATE , 16); 
   name_header = 'all_';


    measures = MeasureImpulseResponseFeatures(g_ir_time_domain, measures.SAMPLE_RATE, [name_header targetMeasures(i).name(1:end-13)]);

    %measures.COST = fval;
    measures.INPUT_GAIN = g_input_gain;
    measures.OUTPUT_GAIN = g_output_gain;
    measures.DELAYS = g_delays;
    measures.DIRECT = g_direct_gain;  
    measures.TONE_GAINS_NEW = g_tone_filter_gains;
    measures.ABSORPTION_FILTERS_NEW = g_rt60s;
   
    save(fullfile(result_dir, "measures", [name_header targetMeasures(i).name(1:end-13) '_measures.mat']), 'measures');

    g_fileName = [name_header, targetMeasures(i).name(1:end-13), '.wav'];
    audiowrite(fullfile(result_dir, "audio" , g_fileName), g_ir_time_domain, measures.SAMPLE_RATE);
end
