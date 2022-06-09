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

clear_signal_pad = signalPad(clear_signal',normalized_raw_audio);

MeasuresStruct = calc_ir_values(clear_signal_pad, size(clear_signal_pad,1), fs);

[schroder_energy_db, array_30dB , w ]= rt30_from_spectrum(clear_signal_pad, fs);

[t_upper, t_lower] = envelope(clear_signal_pad, round(fs/300), 'peak');



%MeasuresStruct.NAME = fullfile_name(find(fullfile_name == '/'| '\', 2,'last')+1:end);
MeasuresStruct.NAME = filename; 
MeasuresStruct.SPECTRUM_T30 = array_30dB;
MeasuresStruct.FREQ_T30 = w;
MeasuresStruct.SIGNAL = clear_signal_pad;
MeasuresStruct.SAMPLE_RATE = fs;
MeasuresStruct.INITIAL_SPECTRUM = schroder_energy_db(1,:);
MeasuresStruct.LOWER_ENVELOPE = t_lower;
MeasuresStruct.UPPER_ENVELOPE = t_upper;

end
