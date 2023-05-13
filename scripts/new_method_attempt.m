% New optimisation technique

target_IR_folder = fullfile(pwd, "IR_test");
measures_dir = fullfile(pwd, "debug/target/measures");

result_dir = fullfile(pwd, "debug/all");

fprintf(">>>[INFO] Setup Paths...\n");
    targetMeasures = dir(fullfile(measures_dir, '**/*measures.mat'));
    targetMeasures = targetMeasures(~[targetMeasures.isdir]);

    fprintf(">>>[INFO] %d Measures found...\n", length(targetMeasures));
    population_size = 1;
    numOfGen = 3;
    
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



    %% Genetic Algorithm
    MIN_DELAY_IN_S = 0.00025;
    MAX_DELAY_IN_S = 0.125;

    boundary_input_gain  = [ones(1,16)*-1; ones(1,16)*1];
    boundary_output_gain = [ones(1,16)*-1; ones(1,16)*1];
    boundary_direct_gain = [0;1];
    boundary_delays      = [ones(1,16)*round(MIN_DELAY_IN_S * measures.SAMPLE_RATE); ones(1,16)*round(MAX_DELAY_IN_S * measures.SAMPLE_RATE)];
    boundary_rt60s       = [ones(1,10)*0.05; ones(1,10)*10]; %% 50 : 5000 // 10
    boundary_tone_filters = [ones(1,10)*-25; ones(1,10)*25]; %% 50 : 5000 // 10

    
    lb = [boundary_direct_gain(1,:), boundary_rt60s(1,:), boundary_tone_filters(1,:)];
    ub = [boundary_direct_gain(2,:), boundary_rt60s(2,:), boundary_tone_filters(2,:)];


    numberOfVariables = length(ub);

    %InitialPopulationMatrix = zeros((population_size, length(ub));
    InitialPopulationInputGain = (2 .* rand(population_size, length(boundary_input_gain(1,:)))) - 1;  % between -1 and 1
    InitialPopulationOutputGain = (2 .* rand(population_size, length(boundary_output_gain(1,:)))) - 1;% between -1 and 1
    InitialPopulationDelays = randi([boundary_delays(1,1) boundary_delays(2,1)], [population_size, length(boundary_delays(1,:))]);% between 12 samples and 125ms
    InitialPopulationDirectGain = (rand(population_size, length(boundary_direct_gain(1,:))));% between -1 and 1
    InitialPopulationrt60s = (0.5 + rand(population_size, length(boundary_rt60s(1,:)))) .* (measures.SPECTRUM_T30 * 2);
    InitialPopulationToneFilters = (0.5 + rand(population_size, length(boundary_tone_filters(1,:)))) .* measures.INITIAL_SPECTRUM;

    InitialPopulationMatrix = [InitialPopulationDirectGain InitialPopulationrt60s InitialPopulationToneFilters];




    parameters = lsm_gains(measures.SIGNAL,[gen_measures.INPUT_GAIN, gen_measures.OUTPUT_GAIN, gen_measures.DELAYS InitialPopulationDirectGain InitialPopulationrt60s InitialPopulationToneFilters], measures.SAMPLE_RATE);


    %algorithm = @fmincon; % Use the fmincon algorithm
    %options = optimoptions('gamultiobj', 'PlotFcn',@gaplotpareto, "InitialPopulationMatrix", InitialPopulationMatrix);
    %x0 = InitialPopulationMatrix;
    %objective = @(x) objective_loss(measures.SIGNAL,[gen_measures.INPUT_GAIN, gen_measures.OUTPUT_GAIN, gen_measures.DELAYS x], measures.SAMPLE_RATE);




    % Set the number of iterations
    %num_iterations = 1; % Replace with your desired number of iterations
    
    %x(gain(1)) + x(rt60(1)) <= loss(band(1));
    % I need 10 optimisation layers that will change the gain and rt60 
    % based on the difference in those bands, to minimize it.
    % How can I get 10 band optimisation?
    
    % Loop over the specified number of iterations
    %for i = 1:num_iterations
        % Optimize the parameters
     %   params = gamultiobj(objective, numberOfVariables, [] , [], [], [], lb, ub, [], options);
        
        % Evaluate the objective function for the updated candidate signal
      %  objective_value = objective(params);
        
        % Display the current objective value
       % fprintf('Iteration %d: objective value = %f\n', i, objective_value);
   % end

    name_header = 'all_';


    measures = MeasureImpulseResponseFeatures(g_ir_time_domain, measures.SAMPLE_RATE, [name_header targetMeasures(i).name(1:end-13)]);

    measures.COST = fval;
    measures.INPUT_GAIN = g_input_gain;
    measures.OUTPUT_GAIN = g_output_gain;
    measures.DELAYS = g_delays;
    measures.DIRECT = g_direct_gain;  
    measures.TONE_GAINS = g_tone_filter_gains;
    measures.ABSORPTION_FILTERS = g_rt60s;
   
    save(fullfile(result_dir, "measures", [name_header targetMeasures(i).name(1:end-13) '_measures.mat']), 'measures');

    g_fileName = [name_header, targetMeasures(i).name(1:end-13), '.wav'];
    audiowrite(fullfile(result_dir, "audio" , g_fileName), g_ir_time_domain, measures.SAMPLE_RATE);
end
