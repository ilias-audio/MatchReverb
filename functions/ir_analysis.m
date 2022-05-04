function [irValues,irT60,echo_density, signal_with_direct] = ir_analysis(audio_in, Fs)



    % remove the silence before the IR
    [clear_signal, signal_with_direct, rir_cut] = remove_direct_sound(audio_in, Fs, size(audio_in,1));

    %% DO A SET OF MEASURMENTS ON THE IR
    signal_with_direct_padded = zeros(size(audio_in'));
    signal_with_direct_padded(1, 1:length(clear_signal)) = clear_signal;
    irValues = calc_ir_values(signal_with_direct_padded', size(signal_with_direct_padded,2), Fs);

    %% add the RT60 vs frequency
    octFilBank = octaveFilterBank('1 octave',Fs, ...
                                  'FrequencyRange',[18 22000]);

    clear_signal = squeeze(clear_signal');                          
    audio_out = octFilBank(clear_signal);

    bands_ir = squeeze(audio_out(:,:,:));

%     sa = dsp.SpectrumAnalyzer('SampleRate',Fs,...
%         'PlotAsTwoSidedSpectrum',false,...
%         'FrequencyScale','log',...
%         'SpectralAverages',100);
%     
%     sa(bands_ir);


    irT60 = zeros(size(bands_ir, 2),1);
    


    for i = 1:size(bands_ir, 2)

        [irEDC, irEDCdB]  = schroeder(bands_ir(:,i));

        ir5dBSample = find(irEDCdB < (max(irEDCdB)-5), 1);
        if isempty(ir5dBSample), ir5dBSample = -Inf; end

        ir35dBSample = find(irEDCdB < (max(irEDCdB)-35), 1);
        if isempty(ir35dBSample), ir35dBSample = Inf; end

        irT60(i) = (ir35dBSample - ir5dBSample) * 2 / Fs;
    end

%    echo_density_reference = gaussian_measure(Fs);

%     figure();
%     plot(getCenterFrequencies(octFilBank), irT60)
%     figure();
%     %%echo density vs time measurment
%     plot((1:length(signal_with_direct))/Fs, signal_with_direct, 'k');

    LCF_SINGLE_WINDOW_LENGTH = 0.025;     %  25ms
    SCT_WINDOW_LENGTH = 0.2;        % 200ms
    EDP_WINDOW_LENGTH = 0.2;              % 200ms

    signal_duration = length(clear_signal)/Fs;
%     subplot(2, 1, 1)
%     hold on
%     plot((1:length(signal_with_direct))/Fs, signal_with_direct, 'k')
%     xlim([0, signal_duration])
%     grid on
%     set(gca, 'ytick', [])
%     title('Impulse responses', 'FontSize', 12)
%     legend({'Target'}, 'FontSize', 9)
%     box on
    
%% remove echo density for now with faster computation    
%     LCF_single_window_size = round(LCF_SINGLE_WINDOW_LENGTH*Fs);
%     SCT_window_size = round(SCT_WINDOW_LENGTH*Fs);
%     EDP_window_size = round(EDP_WINDOW_LENGTH*Fs);
% 
%     [norm_echogram, ~] = NormEchogram(signal_with_direct, LCF_single_window_size, Fs);
%     echo_density = EDP_SCT(norm_echogram, SCT_window_size, Fs);
% 
%     echo_density = echo_density/echo_density_reference;
echo_density = 0;
    
    %% PRINTING
%     subplot(2, 1, 2)
%     hold on
% 
%     plot((1:length(echo_density))/Fs, echo_density, 'k')
%     plot((1:length(echo_density))/Fs, ones(length(echo_density), 1), 'k')
%     xlim([0, signal_duration])
%     ylim([0.4, Inf])
%     grid on
%     title('Echo density', 'FontSize', 12)
%     legend({'Target'}, 'Location', 'southeast', 'FontSize', 9)
%     box on
%     shg

signal_with_direct = clear_signal;
end