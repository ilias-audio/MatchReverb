function [MeasuresStruct] = MeasureImpulseResponseFeatures(raw_audio,fs, filename)

% Measure Impulse Response features

%MATCHREVERB - Match a target Impulse Response with an FDN
% Author: Ilias Ibnyahya
% Queen Mary University of London
% email: i.ibnyahya@qmul.ac.uk
% April 2022; Last revision: May 2022

%------------- BEGIN CODE --------------

fprintf(">>>[INFO] Start measure Impulse Response Features...\n");
    
normalized_raw_audio = raw_audio / max(abs(raw_audio));
[clear_signal, signal_with_direct, rir_cut] = remove_direct_sound( ...
    normalized_raw_audio, fs, size(normalized_raw_audio,1));

clear_signal_pad = signalPad(signal_with_direct',normalized_raw_audio);

[MeasuresStruct, schroder_energy_db, w]= rt30_from_spectrum(clear_signal_pad, fs);

MeasuresStruct.NAME = filename;

end
