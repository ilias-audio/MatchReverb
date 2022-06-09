%Result analysis

%MATCHREVERB - Match a target Impulse Response with an FDN
% Author: Ilias Ibnyahya
% Queen Mary University of London
% email: i.ibnyahya@qmul.ac.uk
% April 2022; Last revision: May 2022

%------------- BEGIN CODE --------------
fprintf(">>>[INFO] Setup Paths...\n");
targetIRPath = './results';
targetMeasures = dir(fullfile(targetIRPath, '**/*measures.mat'));
targetMeasures = targetMeasures(~[targetMeasures.isdir]);

fprintf(">>>[INFO] %d Measures found...\n", length(targetMeasures));



for i= 1:length(targetIR)
    
    fprintf(">>>[INFO] start IR %d/%d...\n", i , length(targetIR));
    
    clearvars -except numOfGen population_size FDNOrder targetIR OctaveCenterFreqs targetIRPath i results_ir
    
    resultPath = "./results";

    fprintf(">>>[INFO] start measuring %s...\n", targetIR(i).name);

    measures = MeasureImpulseResponseFeatures(fullfile(targetIR(i).folder, targetIR(i).name));

    save(['./results/' , targetIR(i).name, '_measures.mat'], 'measures'); 

    fprintf("\n");
end


for i= 1:length(targetMeasures)
    fprintf(">>>[INFO] start Measure %d/%d...\n", i , length(targetMeasures));
    fprintf(">>>[INFO] start reading %s...\n", targetMeasures(i).name);
    
    measuresArray(i) = open(fullfile(targetMeasures(i).folder, targetMeasures(i).name));
    fprintf("\n");

    irTimeDomain = GenerateImpulseResponseFromFeatures(measuresArray.MeasuresStruct, delays, input_gain, output_gain);


end
