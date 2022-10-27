function listenIR(measures_struct)
%listenIR Summary of this function goes here
%   Detailed explanation goes here
    soundsc(measures_struct.SIGNAL, measures_struct.SAMPLE_RATE)
end

