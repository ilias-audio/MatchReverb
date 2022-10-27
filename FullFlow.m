% run the python script 
% add functions and libs to path

%% setup Steps
current_dir = pwd;
target_IR_folder = fullfile(pwd, "IR_mono");
target_mesures_dir = fullfile(pwd, "results/target/measures");
MeasureImpulseResponsesDirectory(target_IR_folder, target_mesures_dir);
%% Optimization Steps
FDN_Only_results = fullfile(pwd, "results/FDN");
MatchReverbDirectory(target_mesures_dir, FDN_Only_results, "FDN_Only");

Hybrid_results = fullfile(pwd, "results/hybrid");
MatchReverbDirectory(target_mesures_dir, Hybrid_results, "Hybrid");
%% Evaluation Steps
