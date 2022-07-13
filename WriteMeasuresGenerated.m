% WriteMeasureGenerated

fprintf(">>>[INFO] Setup Paths...\n");
targetIRPath = './results/target';
targetMeasures = dir(fullfile(targetIRPath, '**/*measures.mat'));
targetMeasures = targetMeasures(~[targetMeasures.isdir]);

fprintf(">>>[INFO] %d Measures found...\n", length(targetMeasures));

OctaveCenterFreqs = [ 46, 63, 125, 250, 500, 1000, 2000, 4000, 8000 , 16000];
FDNOrder = 16;


for i= 2:20

    clearvars -except numOfGen population_size FDNOrder OctaveCenterFreqs targetMeasures targetIRPath i

    
    
    fprintf(">>>[INFO] start reading Measures %d/%d...\n", i , length(targetMeasures));
    fprintf(">>>[INFO] start reading %s...\n", targetMeasures(i).name);
   
    load(fullfile(targetMeasures(i).folder, targetMeasures(i).name));

    fprintf(">>>[INFO] start saving results %s...\n", targetMeasures(i).name);
%%
    
    load(fullfile('./results/parameters/' , ['gen_' , targetMeasures(i).name(1:end-13), '_parameters.mat']));

    [g_input_gain, g_output_gain, g_delays] = splitXInParameters(x);


    g_ir_time_domain = GenerateImpulseResponseFromFeatures(measures, g_delays, g_input_gain, g_output_gain);
    
    measures = MeasureImpulseResponseFeatures(g_ir_time_domain, measures.SAMPLE_RATE, ['gen_' targetMeasures(i).name(1:end-13)]);

    save(['./results/generated/' , ['gen_' targetMeasures(i).name(1:end-13)], '_measures.mat'], 'measures'); 

    
    g_fileName = ['gen_', targetMeasures(i).name(1:end-13), '.wav'];
    audiowrite(fullfile(targetIRPath, "../audio",g_fileName), g_ir_time_domain, measures.SAMPLE_RATE);

end