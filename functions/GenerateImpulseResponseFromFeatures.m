function [irTimeDomain] = GenerateImpulseResponseFromFeatures(MeasuresStruct, delays, input_gain, output_gain)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    FDNOrder = 16;

    OctaveCenterFreqs = [ 46, 63, 125, 250, 500, 1000, 2000, 4000, 8000 , 16000];

    fprintf(">>>[INFO] start Generating Impulse Response based on %s...\n", MeasuresStruct.NAME);

    [t_schroder_energy_db, t_array_30dB , t_w ]= rt30_from_spectrum(MeasuresStruct.SIGNAL, MeasuresStruct.SAMPLE_RATE);

   
    %% RT60
    values_time_freq_target = [MeasuresStruct.SPECTRUM_T30'*2,MeasuresStruct.FREQ_T30];

    rt30 = interp1( values_time_freq_target(:, 2), values_time_freq_target(:, 1), OctaveCenterFreqs');

    t_target_t60 = rt30'*2;

    t_initial_spectrum = t_schroder_energy_db(1,:);

    t_initial_spectrum_values = interp1(values_time_freq_target(:, 2) , t_initial_spectrum', OctaveCenterFreqs');

    direct = zeros(1,1);
    feedback_matrix = randomOrthogonal(FDNOrder);
    % absorption filters
    zAbsorption = zSOS(absorptionGEQ(t_target_t60, delays, MeasuresStruct.SAMPLE_RATE),'isDiagonal',true);

    % power correction filter
    powerCorrectionSOS = designGEQ(t_initial_spectrum_values);
    outputFilters = zSOS(permute(powerCorrectionSOS,[3 4 1 2]) .* output_gain);

    irTimeDomain = dss2impz(length(MeasuresStruct.SIGNAL), delays, feedback_matrix, input_gain', outputFilters, direct, 'absorptionFilters', zAbsorption);
   
end

