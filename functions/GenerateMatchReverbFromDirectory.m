%MATCHREVERB - Match a target Impulse Response with an FDN
% Author: Ilias Ibnyahya
% Queen Mary University of London
% email: i.ibnyahya@qmul.ac.uk
% April 2022; Last revision: September 2022

%------------- BEGIN CODE --------------

function GenerateMatchReverbFromDirectory(targetMeasuresPath, useHybrid)

fprintf(">>>[INFO] Generate Match Reverb...\n");

targetMeasures = dir(fullfile(targetMeasuresPath, '**/*measures.mat'));
targetMeasures = targetMeasures(~[targetMeasures.isdir]);

fprintf(">>>[INFO] %d Measures found...\n", length(targetMeasures));

population_size = 25;
numOfGen = 3;

for i= 1:length(targetMeasures)

    clearvars -except numOfGen population_size FDNOrder  targetMeasures targetMeasuresPath i useHybrid

    fprintf(">>>[INFO] start reading Measures %d/%d...\n", i , length(targetMeasures));
    fprintf(">>>[INFO] start reading %s...\n", targetMeasures(i).name);
   
    load(fullfile(targetMeasures(i).folder, targetMeasures(i).name));

    if (useHybrid == false)
        fprintf(">>>[INFO] Raw Genetic Algorithm...\n");

        %% Genetic Algorithm

        boundary_input_gain  = [ones(1,16)*-1; ones(1,16)*1];
        boundary_output_gain = [ones(1,16)*-1; ones(1,16)*1];
        boundary_delays      = [ones(1,16)*round(0.00025*measures.SAMPLE_RATE); ones(1,16)*round(0.125*measures.SAMPLE_RATE)];

        lb = [boundary_input_gain(1,:), boundary_output_gain(1,:), boundary_delays(1,:)];
        ub = [boundary_input_gain(2,:), boundary_output_gain(2,:), boundary_delays(2,:)];

        numberOfVariables = length(ub);

        options = optimoptions("ga",'PlotFcn',{@gaplotbestf},  ...
            'Display','iter', 'MaxStallGenerations',1,'MaxGenerations',numOfGen, ...
            "PopulationSize",population_size, 'UseParallel', false);

        FitnessFunction = @(x)reverb_fitness_full_order_16(measures, x);

        fprintf(">>>[INFO] start Genetic Algorithm %s...\n", targetMeasures(i).name);
        [x,fval] = ga(FitnessFunction,numberOfVariables,[],[],[],[],lb,ub, [], options);

        fprintf(">>>[INFO] start saving results %s...\n", targetMeasures(i).name);

        [g_input_gain, g_output_gain, g_delays, g_direct] = splitXInParameters([x,0]);

        g_ir_time_domain = GenerateImpulseResponseFromFeatures(measures, g_delays, g_input_gain, g_output_gain);

        measures = MeasureImpulseResponseFeatures(g_ir_time_domain, measures.SAMPLE_RATE, ['gen_' targetMeasures(i).name(1:end-13)]);

        measures.COST = fval;

        save([targetMeasuresPath, '/../generated/' , ['gen_' targetMeasures(i).name(1:end-13)], '_measures.mat'], 'measures');

        save([targetMeasuresPath, '/../parameters/' , ['gen_' targetMeasures(i).name(1:end-13)], '_parameters.mat'], 'x');

        g_fileName = ['gen_', targetMeasures(i).name(1:end-13), '.wav'];

        audiowrite(fullfile(targetMeasuresPath, "../audio",g_fileName), g_ir_time_domain, measures.SAMPLE_RATE);
    else
        fprintf(">>>[INFO] Genetic Algorithm with Hybrid...\n");
        %% Genetic Algorithm
        boundary_input_gain  = [ones(1,16)*-1; ones(1,16)*1];
        boundary_output_gain = [ones(1,16)*-1; ones(1,16)*1];
        boundary_linear_gain = [0 ; 1];
        boundary_delays      = [ones(1,16)*round(0.00025*measures.SAMPLE_RATE); ones(1,16)*round(0.125*measures.SAMPLE_RATE)];

        lb = [boundary_input_gain(1,:), boundary_output_gain(1,:), boundary_delays(1,:), boundary_linear_gain(1)];%, boundary_power(1,:)];
        ub = [boundary_input_gain(2,:), boundary_output_gain(2,:), boundary_delays(2,:), boundary_linear_gain(2)];%, boundary_power(2,:)];

        numberOfVariables = length(ub);

        options = optimoptions("ga",'PlotFcn',{@gaplotbestf},  ...
            'Display','iter', 'MaxStallGenerations',1,'MaxGenerations',numOfGen, ...
            "PopulationSize",population_size, 'UseParallel', false);

        FitnessFunction = @(x)reverb_fitness_hybrid_order_16(measures, x);

        fprintf(">>>[INFO] start Genetic Algorithm %s...\n", targetMeasures(i).name);
        [x,fval] = ga(FitnessFunction,numberOfVariables,[],[],[],[],lb,ub, [], options);

        fprintf(">>>[INFO] start saving results %s...\n", targetMeasures(i).name);

        [g_input_gain, g_output_gain, g_delays, g_direct_gain] = splitXInParameters(x);

        g_ir_time_domain = GenerateHybridResponseFromFeatures(measures, g_delays, g_input_gain, g_output_gain, g_direct_gain);

        measures = MeasureImpulseResponseFeatures(g_ir_time_domain, measures.SAMPLE_RATE, ['hyb_' targetMeasures(i).name(1:end-13)]);

        measures.COST = fval;

        save([targetMeasuresPath, '/../hybrid/' , ['hyb_' targetMeasures(i).name(1:end-13)], '_measures.mat'], 'measures'); 

        save([targetMeasuresPath, '/../parameters/' , ['hyb_' targetMeasures(i).name(1:end-13)], '_parameters.mat'], 'x');

        g_fileName = ['hyb_', targetMeasures(i).name(1:end-13), '.wav'];

        audiowrite(fullfile(targetMeasuresPath, "../audio",g_fileName), g_ir_time_domain, measures.SAMPLE_RATE);
    end

end