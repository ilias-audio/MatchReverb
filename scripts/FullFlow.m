%% First Steps
% run the python script 
% add functions scripts libs to path

%% Setup Steps
target_IR_folder = fullfile(pwd, "IR_mono");
target_mesures_dir = fullfile(pwd, "results/target/measures");
MeasureImpulseResponsesDirectory(target_IR_folder, target_mesures_dir);
%% Optimization Steps
FDN_Only_results = fullfile(pwd, "results/generated");
MatchReverbDirectory(target_mesures_dir, FDN_Only_results, "FDN_Only");

Hybrid_results = fullfile(pwd, "results/hybrid");
MatchReverbDirectory(target_mesures_dir, Hybrid_results, "Hybrid");
%% FDN_only Evaluation Steps
Gen_measures_folder = fullfile(FDN_Only_results, "measures");
CompareMeasuresDirectories(target_mesures_dir, Gen_measures_folder);
%% Hybrid Evaluation Steps
Hyb_measures_folder = fullfile(Hybrid_results, "measures");
CompareMeasuresDirectories(target_mesures_dir, Hyb_measures_folder);