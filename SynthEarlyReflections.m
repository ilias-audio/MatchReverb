close all
clear
% load an impulse response
measure_file_name = "falkland_tennis_court_omni_measures";
load(fullfile("results", "target", "measures", measure_file_name));
target_measures = measures;
                   
%extract early reflections
early_reflections = extract_early_reflections(target_measures);


% plot Early reflections
plot(early_reflections)


%create a tap delay
%hold on 
%input = zeros([10000, 1]);
%input(1) = 1;
%output = tap_delay(input,[1;1000;5000;10000], [1; 0.2;0.1;0.1]);
%plot(output);


% get the max of the sequence
[delays , gains] = find_early_reflection_peaks(early_reflections, 100);
hold on
plot(delays, gains, '.');






% create a tap delay from values
%hold on 
input = rand(size(early_reflections));
input = input * (10^(-100/20));
input(1) = 1;
output = (tap_delay(input,delays,gains));
plot(output);

% compute error
error = 20 * log10(mean(abs(early_reflections - output)));







function [delay_vector, gain_vector] = find_early_reflection_peaks( ...
                                        signal_vector, NPeaks)                             
	[peaks, index] = findpeaks(abs(signal_vector), 'SortStr', ...
                                'descend', 'NPeaks', NPeaks, ...
                                'MinPeakProminence',0.1, 'MinPeakDistance',10);
    delay_vector = index;
    gain_vector = signal_vector(index);
end

function output_vector = tap_delay(input_vector, delay_vector, gain_vector)
    output_vector = delayseq(input_vector,delay_vector) * gain_vector;
end 

function samples_vector = extract_early_reflections(measures_struct)
    ER_index = round(measures_struct.EDT * measures_struct.SAMPLE_RATE);
    samples_vector = measures_struct.SIGNAL(1:ER_index);
end