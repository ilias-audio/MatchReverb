function [irValues, schroder_energy_db , t_w]= rt30_from_spectrum(signal, fs)
% Input arguments:
% ir = column vector containing impulse response
% numSamples = length of impulse response
% sampleRate = sample rate of impulse response
%
% Output arguments:
% irValues = struct containing IR parameter values
%   T60 = T60 decay time (s)
%   EDT = early decay time (s)
%   PREDELAY = predelay time (s)
%   C80 = clarity (dB)
%   BR = bass ratio (dB)
%
  % Require all input arguments
% BROADBAND AND NARROWBAND MEASURMENTS

% broadband
  % =========================================================================

  % Find first reflection of impulse response
  [~, irInitSample] = max(abs(signal));
  numSamples = length(signal);
  % Calculate Schroeder curve of impulse response
  [irEDC, irEDCdB] = schroeder(signal);

  % =========================================================================

  % Predelay
  irDelay = irInitSample / fs;

  % T60 & EDT
  % T60 = Calculate T30 (time from -5 to -35 dB) and multiply by 2
  % EDT = Calculate time from 0 to -10 dB
  ir5dBSample = find(irEDCdB < -5, 1);
  if isempty(ir5dBSample), ir5dBSample = -Inf; end

  ir10dBSample = find(irEDCdB < -10, 1);
  if isempty(ir10dBSample), ir10dBSample = Inf; end

  ir25dBSample = find(irEDCdB < -25, 1);
  if isempty(ir25dBSample), ir25dBSample = Inf; end

  irT60 = (ir25dBSample - ir5dBSample) * 3 / fs;
  irEDT = (ir10dBSample - irInitSample) / fs;

  % C50 (clarity)
  sample_50ms = round(0.05 * fs);
  % if sample_50ms >= irParams.NUM_SAMPLES, f = Inf; return; end
  earlyEnergy = irEDC(1) - irEDC(sample_50ms);
  lateEnergy  = irEDC(sample_50ms);
  % lateEnergy(lateEnergy <= 0) = Inf;
  irC50 = 10 .* log10(earlyEnergy ./ lateEnergy);

  % BR (bass ratio)
  % Find amount of energy in 125 - 500Hz and 500Hz - 2000Hz bands and
  % calculate the ratio between the two
  irfft = 10 .* log10(abs(fft(signal)));
  f125 = ceil(125 * numSamples / fs) + 1;
  f500 = ceil(500 * numSamples / fs);
  f2000 = floor(2000 * numSamples / fs) + 1;
  lowContent = mean(irfft(f125:f500));
  highContent = mean(irfft((f500 + 1):f2000));
  irBR = lowContent - highContent;

  [t_s, t_w, t_t ] = spectrogram(signal, 256, 255, 512, fs, 'yaxis');
  
    %% add the RT60 vs frequency
    octFilBank = octaveFilterBank('1 octave',fs, ...
                                  'FrequencyRange',[18 22000]);

    %clear_signal = squeeze(signal');                          
    audio_out = octFilBank(signal);

    bands_ir = squeeze(audio_out(:,:,:));

    [schroeder_energy schroder_energy_db] = schroeder(abs(bands_ir));    
    
    relative_band_energy = ( schroder_energy_db - schroder_energy_db(1,:));

    %max_audible_freq = find(t_w(:,1) >= 18000, 1) - 1;

    %rt_value = -15;

    %schroder_energy_db = schroder_energy_db(:, 1:max_audible_freq);
    
    for n = 1:length(relative_band_energy(1, :))
        ir5dBSample = find(relative_band_energy(:,n) < -5, 1);
        if isempty(ir5dBSample), ir5dBSample = Inf; end
        
        ir10dBSample = find(relative_band_energy(:,n) < -10, 1);
        if isempty(ir10dBSample), ir10dBSample = Inf; end
        
        ir25dBSample = find(relative_band_energy(:,n) < -25, 1);
        if isempty(ir25dBSample), ir25dBSample = Inf; end
        
        array_30dB(n) = (ir25dBSample - ir5dBSample) * 1.5 / fs;
        array_edt(n) = (ir10dBSample - irInitSample) / fs;


        % C50 (clarity)
      sample_50ms = round(0.05 * fs);
      % if sample_50ms >= irParams.NUM_SAMPLES, f = Inf; return; end
      earlyEnergy = schroeder_energy(1,n) - schroeder_energy(sample_50ms,n);
      lateEnergy  = schroeder_energy(sample_50ms,n);
      % lateEnergy(lateEnergy <= 0) = Inf;
        array_c50(n) = 10 .* log10(earlyEnergy ./ lateEnergy);
    end
        
        %array_30dB = ((-30/rt_value)*(array_30dB))/fs;
  
    t_w =getCenterFrequencies(octFilBank);


    [t_upper, t_lower] = envelope(signal, round(fs/300), 'peak');
    
    edt_sample = floor(irEDT * fs);


  irValues = struct( ...
    'PREDELAY', irDelay, ...
    'T60', irT60, ...
    'EDT', irEDT, ...
    'C50', irC50, ...
    'BR', irBR, ...
    'FREQ_T30', t_w, ...
    'SPECTRUM_T30', array_30dB, ...
    'SPECTRUM_EDT', array_edt, ...
    'SPECTRUM_C50', array_c50, ...
    'SIGNAL' , signal, ... 
    'SAMPLE_RATE', fs, ...
    'INITIAL_SPECTRUM', mean(schroder_energy_db(1:edt_sample,:)),...
    'LOWER_ENVELOPE', t_lower, ... 
    'UPPER_ENVELOPE', t_upper, ...
    'SCHROEDER', schroeder_energy ...
    );

end