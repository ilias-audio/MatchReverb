clear; clc; close all;

rng(5)

fs = 48000;
impulseResponseLength = fs;

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
targetT60 = [2.48354166666667;2.56287500000000;2.62008333333333;2.47479166666667;2.39291666666667;2.35691666666667;2.12875000000000;1.82975000000000;1.59066666666667;1.50079166666667];  % seconds

zAbsorption = zSOS(absorptionGEQ(targetT60, delays, fs),'isDiagonal',true);

% power correction filter
%targetPower = [0; 0; 0; 0; 0; 0; 0; 0; 0; 0];  % dB
targetPower = [5; 5; 5; 3; 2; 1; -1; -3; -5; -5];
powerCorrectionSOS = designGEQ(targetPower);
outputFilters = zSOS(permute(powerCorrectionSOS,[3 4 1 2]) .* outputGain);

% compute impulse response
irTimeDomain = dss2impz(impulseResponseLength, delays, feedbackMatrix, inputGain, outputFilters, direct, 'absorptionFilters', zAbsorption);
%% THIS IS GOING TO BE AMAZING!
% compute poles/zeros
%[res, pol, directTerm, isConjugatePolePair,metaData] = dss2pr(delays, feedbackMatrix, inputGain, outputFilters, direct, 'absorptionFilters', zAbsorption);
%irResPol = pr2impz(res, pol, directTerm, isConjugatePolePair, impulseResponseLength);

%difference = irTimeDomain - irResPol;
%fprintf('Maximum devation betwen time-domain and pole-residues is %f\n', permute(max(abs(difference),[],1),[2 3 1]));

% compute reverberation times 
[reverberationTimeEarly, reverberationTimeLate, F0, powerSpectrum, edr] = reverberationTime(irTimeDomain, fs);
targetPower = targetPower - mean(targetPower);
powerSpectrum = powerSpectrum - mean(powerSpectrum);


%% plot
figure(1); hold on; grid on;
t = 1:size(irTimeDomain,1);
%plot( t, difference(1:end) );
plot( t, irTimeDomain - 2 );
%plot( t, irResPol - 4 );
legend('Difference', 'TimeDomain', 'Res Pol')

 
figure(2); hold on; grid on;
plot(T60frequency,targetT60);
plot(F0,reverberationTimeLate);
plot(F0,reverberationTimeEarly);
%plot(rad2hertz(angle(pol),fs),slope2RT60(mag2db(abs(pol)), fs),'x');
set(gca,'XScale','log');
xlim([50 fs/2]);
xlabel('Frequency [Hz]')
ylabel('Reverberation Time [s]')
legend({'Target Curve','T60 Late','T60 Early','Poles'})

figure(3); hold on; grid on;
plot(T60frequency, targetPower);
plot(F0,powerSpectrum);
set(gca,'XScale','log');
xlim([50 fs/2]);
legend({'Target','Estimation'})
xlabel('Frequency [Hz]')
ylabel('Power Spectrum [dB]')


%% Test: Impulse Response Accuracy
%assert(isAlmostZero(difference,'tol',10^0)) % TODO bad due to extra filters

%% Test: Reverberation Time Accuracy, 5% threshold
testF0 = linspace(65,8000,20);
testTarget = interp1(T60frequency,targetT60, testF0);
testEsti = interp1(F0, reverberationTimeLate, testF0);

%% Test: Power Spectrum Accuracy
testF0 = linspace(65,8000,20);
testTarget = interp1(T60frequency,targetPower, testF0);
testEsti = interp1(F0, powerSpectrum, testF0);




%% add the early reflection


