%Compare spectrums

close all
clear
load('/Users/ilias/Documents/github/MatchReverb/debug/target/measures/stalbans_omni_measures.mat')
tar_measures = measures;
load('/Users/ilias/Documents/github/MatchReverb/debug/all/measures/all_stalbans_omni_measures.mat')
gen_measures = measures;

[S, F, T] = stftloss(tar_measures.SIGNAL, gen_measures.SIGNAL, tar_measures.SAMPLE_RATE);