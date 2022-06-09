function [input_gain, output_gain, delays] = splitXinInParameters(x)
    input_gain = x(1:16);
    output_gain = x(17:32);
    delays = ceil(x(33:48));

end
