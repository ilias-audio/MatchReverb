function [signal] = signalPad(signal,output_length)
%SIGNALPAD pad the signal to the desired size 
%   The size has to be bigger than the signal size
signal_pad = zeros(size(output_length));
signal_pad(1:length(signal),1) = signal;
signal = signal_pad;
end