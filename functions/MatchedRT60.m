

fileName1 = 'pori.wav';
filePath1 = '/Users/ilias/OneDrive/Documents/AudioResearch/MATLAB/MLReverb/IR/';

% % Read Input Audio Files
[signal1, Fs1] = audioread([filePath1 fileName1]);

[irValues1,irT60_1,echo_density1, clear_signal] = ir_analysis(signal1, Fs1);


input_signal = zeros(size(signal1));

ER_CUT_SIZE = 0.1 * Fs1; % 4800 samples

input_signal(1:ER_CUT_SIZE) = clear_signal(1:ER_CUT_SIZE);


plot(input_signal)

fs = Fs1;
impulseResponseLength = 109898;

% define FDN
N = 16;
numInput = 1;
numOutput = 1;
inputGain = 2.*rand(N,numInput) -1;
outputGain = ones(numOutput,N);
direct = zeros(numOutput,numInput);
delays = randi([500,2000],[1,N]);
feedbackMatrix = randomOrthogonal(N);

% absorption filters
centerFrequencies = [ 63, 125, 250, 500, 1000, 2000, 4000, 8000]; % Hz
T60frequency = [1, centerFrequencies fs];
%targetT60 = [0.48354166666667;0.56287500000000;0.62008333333333;0.47479166666667;0.39291666666667;0.35691666666667;0.12875000000000;0.82975000000000;0.59066666666667;0.50079166666667];  % seconds
%targetT60 = [3, 3, 3 , 3, 3, 3, 3, 2, 1 , 0.1]
targetT60 =[2.48354166666667;2.46287500000000;2.62008333333333;2.47479166666667;2.39291666666667;2.35691666666667;2.12875000000000;1.62975000000000;0.89066666666667;0.10079166666667];

%targetT60 = irT60_1;
zAbsorption = zSOS(absorptionGEQ(targetT60, delays, fs),'isDiagonal',true);

% power correction filter
%targetPower = [0; 0; 0; 0; 0; 0; 0; 0; 0; 0];  % dB
targetPower = [0; 0; 0; 0; 0; 0; 0; 0; 0; -5];
powerCorrectionSOS = designGEQ(targetPower);
outputFilters = zSOS(permute(powerCorrectionSOS,[3 4 1 2]) .* outputGain);

% compute impulse response
irTimeDomain = dss2impz(impulseResponseLength, delays, feedbackMatrix, inputGain, outputFilters, direct, 'absorptionFilters', zAbsorption);

%ir_TimeDomain = [zeros(ER_CUT_SIZE,1)' irTimeDomain'];

final_ir = conv(irTimeDomain, input_signal');


figure(1)
spectrogram(irTimeDomain, kaiser(256,5), 220, 512, Fs1, 'yaxis')
view(-45, 65)
set(gca, 'YScale', 'log')
colormap turbo

figure(2)
spectrogram(clear_signal, kaiser(256,5), 220, 512, Fs1, 'yaxis')
view(-45, 65)
colormap turbo
set(gca, 'YScale', 'log')

soundsc(irTimeDomain, Fs1, 24);

%wait 1 second;
%soundsc(clear_signal, Fs1, 24);


%audiowrite('pori_gen.wav', irTimeDomain, Fs1);
