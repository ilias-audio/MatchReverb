function MatchReverbDirectory(measures_dir, result_dir, OptimizationType)
    %MATCHREVERB - Match a target Impulse Response with an FDN
    % Author: Ilias Ibnyahya
    % Queen Mary University of London
    % email: i.ibnyahya@qmul.ac.uk
    % April 2022; Last revision: June 2022

    %------------- BEGIN CODE --------------

    fprintf(">>>[INFO] Setup Paths...\n");
    targetMeasures = dir(fullfile(measures_dir, '**/*measures.mat'));
    targetMeasures = targetMeasures(~[targetMeasures.isdir]);

    fprintf(">>>[INFO] %d Measures found...\n", length(targetMeasures));
    population_size = 50;
    numOfGen = 5;
    
    mkdir(fullfile(result_dir));
    mkdir(fullfile(result_dir, "audio"));
    mkdir(fullfile(result_dir, "measures"));

    for i= 1:length(targetMeasures)

        clearvars -except numOfGen population_size FDNOrder  targetMeasures targetIRPath i result_dir OptimizationType
        
        fprintf(">>>[INFO] Start reading %d/%d, %s...\n", i , length(targetMeasures), targetMeasures(i).name);

        load(fullfile(targetMeasures(i).folder, targetMeasures(i).name));

        %% Genetic Algorithm

        boundary_input_gain  = [ones(1,16)*-1; ones(1,16)*1];
        boundary_output_gain = [ones(1,16)*-1; ones(1,16)*1];
        boundary_direct_gain = [0;1];
        boundary_delays      = [ones(1,16)*round(0.00025*measures.SAMPLE_RATE); ones(1,16)*round(0.125*measures.SAMPLE_RATE)];

        if (OptimizationType == "FDN_Only")
            lb = [boundary_input_gain(1,:), boundary_output_gain(1,:), boundary_delays(1,:)];
            ub = [boundary_input_gain(2,:), boundary_output_gain(2,:), boundary_delays(2,:)];
        elseif (OptimizationType == "Hybrid")
            lb = [boundary_input_gain(1,:), boundary_output_gain(1,:), boundary_delays(1,:), boundary_direct_gain(1,:)];
            ub = [boundary_input_gain(2,:), boundary_output_gain(2,:), boundary_delays(2,:), boundary_direct_gain(2,:)];
        else
            error(">>>[ERROR] Unvalid Optimization Mode");
        end
        numberOfVariables = length(ub);

        options = optimoptions("ga",'PlotFcn',{@gaplotbestf},  ...
            'Display','iter', 'MaxStallGenerations',1,'MaxGenerations',numOfGen, ...
            "PopulationSize",population_size, 'UseParallel', false);


        if (OptimizationType == "FDN_Only")
            FitnessFunction = @(x)reverb_fitness_full_order_16(measures, x);
        elseif (OptimizationType == "Hybrid")
            FitnessFunction = @(x)reverb_fitness_hybrid_order_16(measures, x);
        end

        fprintf(">>>[INFO] start Genetic Algorithm %s...\n", targetMeasures(i).name);
        [x,fval] = ga(FitnessFunction,numberOfVariables,[],[],[],[],lb,ub, [], options);

        if (OptimizationType == "FDN_Only")
            [g_input_gain, g_output_gain, g_delays, g_direct_gain] = splitXInParameters([x,0]);
            g_ir_time_domain = GenerateImpulseResponseFromFeatures(measures, g_delays, g_input_gain, g_output_gain);
            name_header = 'gen_';
        elseif (OptimizationType == "Hybrid")
            [g_input_gain, g_output_gain, g_delays, g_direct_gain] = splitXInParameters(x);
            g_ir_time_domain = GenerateHybridResponseFromFeatures(measures, g_delays, g_input_gain, g_output_gain, g_direct_gain);
            name_header = 'hyb_';
        end

        measures = MeasureImpulseResponseFeatures(g_ir_time_domain, measures.SAMPLE_RATE, [name_header targetMeasures(i).name(1:end-13)]);

        measures.COST = fval;
        measures.INPUT_GAIN = g_input_gain;
        measures.OUTPUT_GAIN = g_output_gain;
        measures.DELAYS = g_delays;
        measures.DIRECT = g_direct_gain;        
       
        save(fullfile(result_dir, "measures", [name_header targetMeasures(i).name(1:end-13) '_measures.mat']), 'measures');

        g_fileName = [name_header, targetMeasures(i).name(1:end-13), '.wav'];
        audiowrite(fullfile(result_dir, "audio" , g_fileName), g_ir_time_domain, measures.SAMPLE_RATE);
    end
end


