function [input_gain,output_gain, delays, direct, rt60s, tone_filters] = splitAllParameters(x)
%splitXInParameters Splits the returned X values of the GA 
% into an several arrays of data
input_gain = x(1:16);
output_gain = x(17:32);
delays = ceil(x(33:48));
direct = x(49);
rt60s = x(50:59); %% 50 : 5000 // 10
tone_filters = x(60:69); %% 50 : 5000 // 10
end