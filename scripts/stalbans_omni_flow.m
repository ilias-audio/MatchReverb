%% First Steps
% run the python script 
% add functions and libs to path

%% Setup Steps
target_IR_folder = fullfile(pwd, "IR_test");
target_mesures_dir = fullfile(pwd, "debug/target/measures");
%MeasureImpulseResponsesDirectory(target_IR_folder, target_mesures_dir);
%% Optimization Steps
%FDN_Only_results = fullfile(pwd, "debug/generated");
%MatchReverbDirectory(target_mesures_dir, FDN_Only_results, "FDN_Only");

%Hybrid_results = fullfile(pwd, "debug/hybrid");
%MatchReverbDirectory(target_mesures_dir, Hybrid_results, "Hybrid");

%Tap_results = fullfile(pwd, "debug/tap");
%MatchReverbDirectory(target_mesures_dir, Tap_results, "Tap");

all_results = fullfile(pwd, "debug/all");
MatchReverbDirectory(target_mesures_dir, all_results, "FDN_Only_69_parameters");
%% FDN_only Evaluation Steps
%Gen_measures_folder = fullfile(FDN_Only_results, "measures");
%CompareMeasuresDirectories(target_mesures_dir, Gen_measures_folder);
%% Hybrid Evaluation Steps
%Hyb_measures_folder = fullfile(Hybrid_results, "measures");
%CompareMeasuresDirectories(target_mesures_dir, Hyb_measures_folder);
%% Tap Evaluation Steps
%Tap_measures_folder = fullfile(Tap_results, "measures");
%CompareMeasuresDirectories(target_mesures_dir, Tap_measures_folder);