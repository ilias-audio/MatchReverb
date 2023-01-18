function [irTimeDomain] = GenerateTapResponseFromFeatures(MeasuresStruct, delays, input_gain, output_gain, direct_linear_gain)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    clf

    FDNOrder = 16;

    fprintf(">>>[INFO] start Generating Impulse Response based on %s...\n", MeasuresStruct.NAME);

    octFilBank = octaveFilterBank('1 octave',MeasuresStruct.SAMPLE_RATE, ...
                                  'FrequencyRange',[18 22000]); 
   
    %% RT60
    
    rt30 = MeasuresStruct.SPECTRUM_T30;
    t_target_t60 = rt30'*2;
    
    t_audio_out = octFilBank(MeasuresStruct.SIGNAL);
    
    m_initial_spectrum_values = 10 * log10 (bandpower(t_audio_out, MeasuresStruct.SAMPLE_RATE, [0 MeasuresStruct.SAMPLE_RATE/2]));
    
    t_initial_spectrum_values = zeros(size(MeasuresStruct.INITIAL_SPECTRUM));

    %% TODO this section has to implement the tap delay
    %[direct_target, ~] = splitEarlyLate(MeasuresStruct);
    [direct_target] = GenerateTapDelayfromEarlyReflections(MeasuresStruct, 100);
    %% 
    %direct = ones(1,1) * direct_linear_gain; to avoid comb effect
    direct = ones(1,1);
    feedback_matrix = randomOrthogonal(FDNOrder);
    % absorption filters
    zAbsorption = zSOS(absorptionGEQ(t_target_t60, delays, MeasuresStruct.SAMPLE_RATE),'isDiagonal',true);

    % power correction filter
    powerCorrectionSOS = designGEQ(t_initial_spectrum_values);%, MeasuresStruct.SAMPLE_RATE);
    outputFilters = zSOS(permute(powerCorrectionSOS,[3 4 1 2]) .* output_gain);

    %% Initialize
    A = convert2zFilter(feedback_matrix);
    B = convert2zFilter(input_gain');
    C = convert2zFilter(outputFilters);
    numInput = B.m;

    %% Create dirac pulse
    input = zeros(length(MeasuresStruct.SIGNAL), numInput);
    input(1:length(direct_target),:) = direct_target;

    %% Time-Domain Recursion
    irTimeDomain = processFDN(input, delays, A, B, C, direct','inputType','splitInput', 'absorptionFilters', zAbsorption);
    g_audio_out = octFilBank(irTimeDomain);
    g_post_spectrum_values = 10 * log10(bandpower(g_audio_out, MeasuresStruct.SAMPLE_RATE, [0 MeasuresStruct.SAMPLE_RATE/2]));
    
    g_post_spectrum_values(isinf(g_post_spectrum_values)) = -150;
    
    %% debug
    difference_in_energy =  m_initial_spectrum_values - g_post_spectrum_values;

    % power correction filter
    powerCorrectionSOS = designGEQ(difference_in_energy);%, MeasuresStruct.SAMPLE_RATE);
    outputFilters = zSOS(permute(powerCorrectionSOS,[3 4 1 2]) .* output_gain);
    C = convert2zFilter(outputFilters);
    irTimeDomain = processFDN(input, delays, A, B, C, direct','inputType','splitInput', 'absorptionFilters', zAbsorption);
 
    % Testing step
                  
    debug_audio_out = octFilBank(irTimeDomain);

    debug_bands_ir = squeeze(debug_audio_out(:,:,:));
    
    g_debug_spectrum_values = 10 * log10(bandpower(debug_bands_ir, MeasuresStruct.SAMPLE_RATE, [0 MeasuresStruct.SAMPLE_RATE/2]));
    g_debug_spectrum_values(isinf(g_debug_spectrum_values)) = -150;
   
    
    
    plot(m_initial_spectrum_values)
    hold on
    plot(t_initial_spectrum_values)
    plot(g_post_spectrum_values)
    plot(g_debug_spectrum_values)
    
end

