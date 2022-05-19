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



for i= 1:length(targetMeasures)
    fprintf(">>>[INFO] start Measure %d/%d...\n", i , length(targetMeasures));
    fprintf(">>>[INFO] start reading %s...\n", targetMeasures(i).name);
    
    measuresArray(i,1) = open(fullfile(targetMeasures(i).folder, targetMeasures(i).name));
    measuresArray(i,2) = targetMeasures(i).name;
    fprintf("\n");

    


end