%MATCHREVERB - Match a target Impulse Response with an FDN
% Author: Ilias Ibnyahya
% Queen Mary University of London
% email: i.ibnyahya@qmul.ac.uk
% April 2022; Last revision: June 2022

%------------- BEGIN CODE --------------

fprintf(">>>[INFO] Setup Paths...\n");
targetIRPath = './results/target';
targetMeasures = dir(fullfile(targetIRPath, '**/*measures.mat'));
targetMeasures = targetMeasures(~[targetMeasures.isdir]);
fprintf(">>>[INFO] %d Measures found...\n", length(targetMeasures));

FDNOrder = 16;
population_size = 30;
numOfGen = 5;

for i= 2:length(targetMeasures)

    clearvars -except numOfGen population_size FDNOrder  targetMeasures targetIRPath i

    
    
    fprintf(">>>[INFO] start reading Measures %d/%d...\n", i , length(targetMeasures));
    fprintf(">>>[INFO] start reading %s...\n", targetMeasures(i).name);
   
    load(fullfile(targetMeasures(i).folder, targetMeasures(i).name));
   
    %% Genetic Algorithm
    boundary_target_t60  = [ones(1,10)*0.01; ones(1,10)*6];
    boundary_input_gain  = [ones(1,16)*-1; ones(1,16)*1];
    boundary_output_gain = [ones(1,16)*-1; ones(1,16)*1];
    boundary_linear_gain = [0 ; 1];
    boundary_delays      = [ones(1,16)*round(0.00025*measures.SAMPLE_RATE); ones(1,16)*round(0.125*measures.SAMPLE_RATE)];
    boundary_power       = [ones(1,10)*-15; ones(1,10)*15];

    lb = [boundary_input_gain(1,:), boundary_output_gain(1,:), boundary_delays(1,:), boundary_linear_gain(1)];%, boundary_power(1,:)];
    ub = [boundary_input_gain(2,:), boundary_output_gain(2,:), boundary_delays(2,:), boundary_linear_gain(2)];%, boundary_power(2,:)];
    
%     init_t_60 = t_target_t60;
%     initial_vector = RT602slope(init_t_60,fs); 
%     initial_matrix = repmat(initial_vector, 1, population_size);

    numberOfVariables = length(ub);

    options = optimoptions("ga",'PlotFcn',{@gaplotbestf},  ...
        'Display','iter', 'MaxStallGenerations',1,'MaxGenerations',numOfGen, ...
        "PopulationSize",population_size, 'UseParallel', false);


    FitnessFunction = @(x)reverb_fitness_hybrid_order_16(measures, x);

    fprintf(">>>[INFO] start Genetic Algorithm %s...\n", targetMeasures(i).name);
    [x,fval] = ga(FitnessFunction,numberOfVariables,[],[],[],[],lb,ub, [], options);
    
    fprintf(">>>[INFO] start saving results %s...\n", targetMeasures(i).name);
%%
    [g_input_gain, g_output_gain, g_delays, g_direct_gain] = splitXInParameters(x);


    g_ir_time_domain = GenerateHybridResponseFromFeatures(measures, g_delays, g_input_gain, g_output_gain, g_direct_gain);
    
    %measures = MeasureImpulseResponseFeatures(g_ir_time_domain, measures.SAMPLE_RATE, ['gen_' targetMeasures(i).name(1:end-13)]);
    measures = MeasureImpulseResponseFeatures(g_ir_time_domain, measures.SAMPLE_RATE, ['hyb_' targetMeasures(i).name(1:end-13)]);
    
    measures.COST = fval;

    %save(['./results/generated/' , ['gen_' targetMeasures(i).name(1:end-13)], '_measures.mat'], 'measures');

    save(['./results/hybrid/' , ['hyb_' targetMeasures(i).name(1:end-13)], '_measures.mat'], 'measures'); 


    %save(['./results/parameters/' , ['gen_' targetMeasures(i).name(1:end-13)], '_parameters.mat'], 'x');
    save(['./results/parameters/' , ['hyb_' targetMeasures(i).name(1:end-13)], '_parameters.mat'], 'x');

    g_fileName = ['hyb_', targetMeasures(i).name(1:end-13), '.wav'];
    audiowrite(fullfile(targetIRPath, "../audio",g_fileName), g_ir_time_domain, measures.SAMPLE_RATE);
end



