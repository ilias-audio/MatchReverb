%compare the schroeder rt60 based on EDR and melspectrogram

% MAKE A SCRIPT THAT SHOWS THE EDR MATCH
% BUT SHOW THE SPECTROGRAM DOESN'T
% FIGURE OUT WHY IT DOESN'T MATCH

close all
load('/Users/ilias/Documents/github/MatchReverb/debug/target/measures/stalbans_omni_measures.mat')
tar_measures = measures;
load('/Users/ilias/Documents/github/MatchReverb/debug/all/measures/all_stalbans_omni_measures.mat')
gen_measures = measures;

figure;
audio_fft = fft(tar_measures.SIGNAL(1:floor(3000)));

n = length(tar_measures.SIGNAL(1:floor(3000)));          % number of samples
f = (0:n-1)*(48000/n);     % frequency range
power = abs(audio_fft).^2/n;    % power of the DFT

semilogx(f(1:floor(n/2)),power(1:floor(n/2)))
xlabel('Frequency')
ylabel('Power Target')
ylim([0 0.1])
g_delays = gen_measures.DELAYS;
g_input_gain = gen_measures.INPUT_GAIN;
g_output_gain = gen_measures.OUTPUT_GAIN;
g_direct_gain = gen_measures.DIRECT;
g_rt60s =  gen_measures.ABSORPTION_FILTERS;
g_tone_filter_gains = gen_measures.TONE_GAINS;

g_tone_filter_gains(1) = gen_measures.TONE_GAINS(1) + 7;
g_tone_filter_gains(2) = gen_measures.TONE_GAINS(2) + 9;
g_tone_filter_gains(2) = gen_measures.TONE_GAINS(3) + 7;
g_tone_filter_gains(2) = gen_measures.TONE_GAINS(4) + 7;
g_tone_filter_gains(2) = gen_measures.TONE_GAINS(5) + 12;
g_tone_filter_gains(2) = gen_measures.TONE_GAINS(6) + 16;
g_tone_filter_gains(2) = gen_measures.TONE_GAINS(7) + 9;
g_tone_filter_gains(2) = gen_measures.TONE_GAINS(8) + 2;

g_rt60s(1) = gen_measures.ABSORPTION_FILTERS(1) + 0.2;
g_rt60s(2) = gen_measures.ABSORPTION_FILTERS(2) - 0.6;
g_rt60s(3) = gen_measures.ABSORPTION_FILTERS(3) - 0.5;
g_rt60s(4) = gen_measures.ABSORPTION_FILTERS(4) - 0.4;
g_rt60s(5) = gen_measures.ABSORPTION_FILTERS(5) - 0.3;
g_rt60s(6) = gen_measures.ABSORPTION_FILTERS(6) - 0.3;

%g_tone_filter_gains = [0 0 0 0 0 0 0 0 -10 -50];
%g_tone_filter_gains(7) = 0;

debug_ir = GenerateImpulseResponseFromParameters(length(gen_measures.SIGNAL), g_delays, g_input_gain, g_output_gain,  g_direct_gain, g_rt60s, g_tone_filter_gains , gen_measures.SAMPLE_RATE , 16);

figure;
noise = 10^(-80/20) * (rand(size(measures.SIGNAL)) - 0.5);
audio_fft = fft(gen_measures.SIGNAL(1:floor(3000) + noise));

n = length(gen_measures.SIGNAL(1:floor(3000)));          % number of samples
f = (0:n-1)*(48000/n);     % frequency range
power = abs(audio_fft).^2/n;    % power of the DFT

semilogx(f(1:floor(n/2)),power(1:floor(n/2)))
xlabel('Frequency')
ylabel('Power debug')
ylim([0 0.1])



[tar_freq , tar_rt60, tar_initPower, t_schroder_energy_db] = schroeder_linearReg_rt60(tar_measures.SIGNAL, 48000);
[gen_freq , gen_rt60, gen_initPower, g_schroder_energy_db] = schroeder_linearReg_rt60(debug_ir, 48000);
%[mel_freq , mel_rt60] = melspectrum_rt60(tar_measures.SIGNAL, 48000);

[freqs, RT60, t_spectrum] = melspectrum_rt60(tar_measures.SIGNAL, 48000)
[freqs, RT60, g_spectrum] = melspectrum_rt60(debug_ir, 48000)
figure;
surf(t_spectrum);
zlim([-80 -50])
figure;
surf(g_spectrum);
zlim([-80 -50])
figure;
semilogx(tar_freq , tar_rt60)
hold on 

semilogx(gen_freq , gen_rt60)
%semilogx(mel_freq , mel_rt60)
xline(tar_freq)
legend({'target','generated'})
%xline(mel_freq, Color='red')

figure;

semilogx(tar_freq , tar_initPower)
hold on 

semilogx(gen_freq , gen_initPower)
%semilogx(mel_freq , mel_rt60)
xline(tar_freq)
legend({'target','generated'})
%xline(mel_freq, Color='red')

function  [freqs, RT60] = schroeder_rt60(signal, fs)
    octFilBank = octaveFilterBank('1 octave',fs);                        
    audio_out = octFilBank(signal);

    freqs = getCenterFrequencies(octFilBank);
    bands_ir = squeeze(audio_out(:,:,:));

    [dummy_var , schroder_energy_db] = schroeder(abs(bands_ir));    
    
    relative_band_energy = ( schroder_energy_db - schroder_energy_db(1,:));
    
    for n = 1:length(relative_band_energy(1, :))
        ir5dBSample = find(relative_band_energy(:,n) < -5, 1);
        if isempty(ir5dBSample), ir5dBSample = Inf; end
        
        ir25dBSample = find(relative_band_energy(:,n) < -25, 1);
        if isempty(ir25dBSample), ir25dBSample = Inf; end
        
        RT60(n) = (ir25dBSample - ir5dBSample) * 3 / fs;
    end
end

% USEFUL
function [freqs, RT60, log_spectrum] = melspectrum_rt60(signal, fs)
    [spectrum, freqs, center_times] = melSpectrogram(signal, fs,...
               'Window',hann(2^12,'periodic'), ...
               'OverlapLength',2^10, ...
               'FFTLength',2^16, ...
               'NumBands',10, ...
               'FrequencyRange',[22.0,22e3]);     
    log_spectrum = 10 * log10(spectrum);
    relative_band_energy = ( log_spectrum - max(log_spectrum')');
    
    for n = 1:length(relative_band_energy(:, 1))
        plot(log_spectrum(n,:));
        ir5dBSample = find(relative_band_energy(n,:) < -5, 1);
        if isempty(ir5dBSample), ir5dBSample = Inf; end
        
        ir25dBSample = find(relative_band_energy(n,:) < -25, 1);
        if isempty(ir25dBSample), ir25dBSample = Inf; end
        
        RT60(n) = (center_times(round(ir25dBSample)) - center_times(round(ir5dBSample))) * 3;
    end
end


function [freqs, RT60] = linearReg_rt60(signal, fs)
    [spectrum, freqs, center_times] = melSpectrogram(signal, fs,"SpectrumType","power", 'NumBands',10);
    spectrum = 10 * log10(spectrum);
    half_length = round(length(center_times) / 4);
    x =  [ones(half_length,1) center_times(1:half_length)];
    for n = 1:length(spectrum(:, 1))
        y = spectrum(n,1:half_length)';
        b = x\y;
        RT60(n) = -60/b(2);
    end
end


function [freqs, RT60, initPower, schroder_energy_db] = schroeder_linearReg_rt60(signal, fs)
    octFilBank = octaveFilterBank('1 octave',fs);                        
    audio_out = octFilBank(signal);
    
    freqs = getCenterFrequencies(octFilBank);
    bands_ir = squeeze(audio_out(:,:,:));
    center_times = linspace(1,length(audio_out),length(audio_out)) / fs;
    center_times = center_times';
    [dummy_var , schroder_energy_db] = schroeder(abs(bands_ir));  
    half_length = round(length(center_times) / 1.5);
    x =  [center_times(1:half_length)];
    schroder_energy_db = schroder_energy_db';
    y = schroder_energy_db(:,1:half_length);
    % Step 2: Define the segmented linear function
    
    %figure;
    %surf(schroder_energy_db', 'edgecolor','none');
    %zlim([-80 0])
    
    
    
    figure;
    plot(x,y)
    ylim([-60 0])
    xlim([0 2])
    
    for n = 1:length(schroder_energy_db(:, 1))
    segmentedLinearFunc = @(b, x) (x <= b(1)).*(b(2)*x + b(3)) + (x > b(1)).*(b(4)*x + b(5));
    tol = 0.0;
    A = [0 0 0 0 0;  % b(3) >= y(n,1)
         0 0 0 0 0; % b(3) <= y(n,1)
         0 1 1 1 1]; % b(5) <= tol: The difference between the two functions at the knee point is at least tol
    d = [0; 0; tol];
    Aeq = [0 0 1 0 0;];
    Beq = [y(n,1)];
    lb = [0 -inf -inf -inf -inf]; % lower bounds on parameters
    ub = [5 0 0 0 0]; % upper bounds on parameters
    options = optimoptions('fmincon', 'Algorithm', 'interior-point', 'Display', 'none');
    initialGuess = [center_times(half_length)/3, -1, 0, -1, 0]; % initial guess for knee point and slopes/intercepts on either side
    %bestFitParams = lsqcurvefit(segmentedLinearFunc, initialGuess, x, y(n,:)');
    
    bestFitParams = fmincon(@(b) sum((y(n,:)' - segmentedLinearFunc(b, x)).^2), initialGuess, A, d, Aeq, Beq, lb, ub, [], options);
    
    RT60(n) = -60 / bestFitParams(2);
    initPower(n) = bestFitParams(3);
    
    
    %Step 5: Plot the data and the best-fit line
    figure(1);
    clf
    plot(x, y(n,:))
    hold on
    plot(x, segmentedLinearFunc(bestFitParams, x), 'r-', 'LineWidth', 2)
    xlabel('x')
    ylabel('y')
    legend('Data', 'Best-fit line')
    end
    
    end
    
    function [freqs, RT60] = mfcc_rt60(signal, fs)
        [spectrum, freqs, center_times] = mfcc_rt60(signal, fs);      
        log_spectrum = 10 * log10(spectrum);
        relative_band_energy = ( log_spectrum - max(log_spectrum')');
        
        for n = 1:length(relative_band_energy(:, 1))
            ir5dBSample = find(relative_band_energy(n,:) < -5, 1);
            if isempty(ir5dBSample), ir5dBSample = Inf; end
            
            ir25dBSample = find(relative_band_energy(n,:) < -25, 1);
            if isempty(ir25dBSample), ir25dBSample = Inf; end
            
            RT60(n) = (center_times(round(ir25dBSample)) - center_times(round(ir5dBSample))) * 3;
        end
end