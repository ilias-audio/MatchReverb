function [tap_delay_signal_output] = GenerateTapDelayfromEarlyReflections(target_measures, NumberofPeaks)
    early_reflections = extract_early_reflections(target_measures);
    [i_in_vector , gains_vector] = find_early_reflection_peaks(early_reflections, NumberofPeaks);
    input = zeros(size(early_reflections));
    input(1) = 1;
    tap_delay_signal_output = delayseq(input,i_in_vector) * gains_vector;
end

%local functions

function [delay_vector, gain_vector] = find_early_reflection_peaks( ...
                                        signal_vector, NPeaks)                             
	[peaks, index] = findpeaks(abs(signal_vector), 'SortStr', ...
                                'descend', 'NPeaks', NPeaks, ...
                                'MinPeakProminence',0.1, 'MinPeakDistance',10);
    delay_vector = index;
    gain_vector = signal_vector(index);
end

function samples_vector = extract_early_reflections(measures_struct)
    ER_index = round(measures_struct.EDT * measures_struct.SAMPLE_RATE);
    samples_vector = measures_struct.SIGNAL(1:ER_index);
end