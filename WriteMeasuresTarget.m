%WriteMeasuresTarget
%Reads the IRs and generates the measures required for generating IRs.

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

for i= 1:17
    
    fprintf(">>>[INFO] start IR %d/%d...\n", i , length(targetIR));
    
    clearvars -except  targetIR i
    

    fprintf(">>>[INFO] start measuring %s...\n", targetIR(i).name);

    [raw_audio, fs] = audioread(fullfile(targetIR(i).folder, targetIR(i).name));
    
    measures = MeasureImpulseResponseFeatures(raw_audio, fs, targetIR(i).name);

    save(['./results/target/' , targetIR(i).name(1:end-4), '_measures.mat'], 'measures'); 

    fprintf("\n");
end



