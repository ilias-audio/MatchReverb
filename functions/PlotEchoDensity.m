function PlotEchoDensity(target_measures,generated_measures)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here


    echo_density_reference = gaussian_measure(target_measures.SAMPLE_RATE);

    LCF_SINGLE_WINDOW_LENGTH = 0.025;     %  25ms
    SCT_WINDOW_LENGTH = 0.2;        % 200ms
    EDP_WINDOW_LENGTH = 0.2;              % 200ms
    
%% remove echo density for now with faster computation    
    LCF_single_window_size = round(LCF_SINGLE_WINDOW_LENGTH*target_measures.SAMPLE_RATE);
    SCT_window_size = round(SCT_WINDOW_LENGTH*target_measures.SAMPLE_RATE);
    EDP_window_size = round(EDP_WINDOW_LENGTH*target_measures.SAMPLE_RATE);

    [t_norm_echogram, ~] = NormEchogram(target_measures.SIGNAL, LCF_single_window_size, target_measures.SAMPLE_RATE);
    t_echo_density = EDP_SCT(t_norm_echogram, SCT_window_size, target_measures.SAMPLE_RATE);
    
    
    

    t_echo_density = t_echo_density/echo_density_reference;
    
    
    
    
    [g_norm_echogram, ~] = NormEchogram(generated_measures.SIGNAL, LCF_single_window_size, generated_measures.SAMPLE_RATE);
    g_echo_density = EDP_SCT(g_norm_echogram, SCT_window_size, generated_measures.SAMPLE_RATE);
    
     g_echo_density = g_echo_density/echo_density_reference;
    
    
    %% PRINTING
    %subplot(2, 1, 2)
    hold on

    plot((1:length(t_echo_density))/target_measures.SAMPLE_RATE, t_echo_density, 'k')
    plot((1:length(g_echo_density))/generated_measures.SAMPLE_RATE, g_echo_density, 'k')
    plot((1:length(t_echo_density))/target_measures.SAMPLE_RATE, ones(length(t_echo_density), 1), 'k')
    %%
    signal_duration = floor(length(t_echo_density)/target_measures.SAMPLE_RATE);
    xlim([0, signal_duration])
    ylim([0.4, Inf])
    grid on
    title('Echo density', 'FontSize', 12)
    legend({'Target'}, 'Location', 'southeast', 'FontSize', 9)
    box on
    shg
end

