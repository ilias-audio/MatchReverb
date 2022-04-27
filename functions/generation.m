clear; clc; close all;

fileName1 = 'pori.wav';
filePath1 = '/Users/ilias/OneDrive/Documents/AudioResearch/MATLAB/MLReverb/IR/';

[signal1, fs] = audioread([filePath1 fileName1]);

[target_irValues , target_irT60, target_echo_dednsity] = ir_analysis(signal1, fs);

[t_reverberationTimeEarly, t_reverberationTimeLate, t_F0, t_powerSpectrum, t_edr] = reverberationTime(signal1, fs);
impulseResponseLength = fs;

% define FDN
N = 16;
numInput = 1;
numOutput = 1;

% compute impulse response

GEN_NUM = 5;

irTimeDomain = zeros(impulseResponseLength, GEN_NUM);

for i = 1:size(irTimeDomain, 2)
    inputGain = 2.*rand(N,numInput) - 1;
    outputGain = 2.*rand(numOutput,N) -1;
    direct = zeros(numOutput,numInput);
    delays= randi([50,5000],[1,N]);
    feedbackMatrix = randomOrthogonal(N);

    % absorption filters
    centerFrequencies = [ 63, 125, 250, 500, 1000, 2000, 4000, 8000]; % Hz
    T60frequency = [1, centerFrequencies fs];
    %targetT60 = [2; 2; 2.2; 2.3; 2.1; 1.5; 1.1; 0.8; 0.7; 0.7];  % seconds
    targetT60 = target_irT60;
    zAbsorption = zSOS(absorptionGEQ(targetT60, delays, fs),'isDiagonal',true);

    % power correction filter
    targetPower = [0; 0; 0; 0; 0; 0; 0; 0; 0; 0];  % dB
    powerCorrectionSOS = designGEQ(targetPower);
    outputFilters = zSOS(permute(powerCorrectionSOS,[3 4 1 2]) .* outputGain);
  
    irTimeDomain(:,i) = dss2impz(impulseResponseLength, delays, feedbackMatrix, inputGain, outputFilters, direct, 'absorptionFilters', zAbsorption);

    i
    
    
    
end
%%

figure(1);
clf;
for i = 1:size(irTimeDomain, 2)
    [irValues(:,i),irT60(:,i),echo_density] = ir_analysis(irTimeDomain(:,i), fs);
    [reverberationTimeEarly, reverberationTimeLate, F0, powerSpectrum, edr] = reverberationTime(irTimeDomain(:,i), fs);
    t60s(i) = irValues(:,i);
    
    

figure(i); hold on; grid on;

plot(T60frequency,targetT60);
plot(F0,reverberationTimeLate);
plot(F0,reverberationTimeEarly);
plot(F0,t_reverberationTimeLate);
plot(F0,t_reverberationTimeEarly);
%plot(rad2hertz(angle(pol),fs),slope2RT60(mag2db(abs(pol)), fs),'x');
set(gca,'XScale','log');
xlim([50 fs/2]);
xlabel('Frequency [Hz]')
ylabel('Reverberation Time [s]')
legend({'Target Curve','T60 Late','T60 Early','target late', 'target early'})
    
end