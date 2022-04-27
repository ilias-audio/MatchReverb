clear;
close all;




%% READ IMPULSE REPSONSE FROM FILE
t_fileName = 'SampleRIR.wav';
t_filePath = '/Users/ilias/OneDrive/Documents/AudioResearch/MATLAB/MLReverb/IR/';

[t_raw_signal, fs] = audioread([t_filePath t_fileName]);

[t_irValues,t_irT60,t_echo_density, t_clean_signal] = ...
    ir_analysis(t_raw_signal, fs);


% irValuesDiff.PREDELAY = irValues1.PREDELAY - irValues2.PREDELAY
% irValuesDiff.T60 = irValues1.T60 - irValues2.T60
% irValuesDiff.EDT = irValues1.EDT - irValues2.EDT
% irValuesDiff.C80 = irValues1.C80 - irValues2.C80
% irValuesDiff.BR = irValues1.BR - irValues2.BR
% irValuesDiff.irT60 = irT60_1 - irT60_2;
% %irValuesDiff.echo_density = echo_density1(1:100000)' - echo_density2(1:100000)';
% 

%% GENERATE A BATCH OF RANDOM IMPULSE RESPONSES
size_gen = 1;

t_sample_length = length(t_clean_signal(:,1));
RIR = zeros(t_sample_length, size_gen);

for i = 1:size_gen
    coeff(i) = generate_random_FDN_parameters(t_sample_length, 1, 1);
    RIR(:,i) = RandIR(coeff(i), t_sample_length, fs, 1, 1);
    
    [c_irValues(:,i),c_irT60(:,i),c_echo_density(:,i), c_clean_signal(:,i)] = ...
    ir_analysis(RIR(:,i), fs);

    

end





%% GENERATE a one generation of impulse response that's very large

%48000x100
