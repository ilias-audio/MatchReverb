function parameters = lsm_gains(tar_signal, parameters, fs)


[g_input_gain, g_output_gain, g_delays, g_direct_gain, g_rt60s, g_tone_filter_gains] = splitAllParameters(parameters);

tar_signal = tar_signal(1:length(tar_signal)/3);


iter = 100;
learn_rate_gain = 0.0001;
learn_rate_time = 0.00001;

octFilBank = octaveFilterBank('1 octave',fs, ...
                              'FrequencyRange',[22 22000]);

    tar_audio_out = octFilBank(tar_signal);

    freqs = getCenterFrequencies(octFilBank);
    tar_bands_ir = squeeze(tar_audio_out(:,:,:));

    lowest_error = 1e5;


for i= 1:iter
    [g_ir_time_domain] = GenerateImpulseResponseFromParameters(length(tar_signal), g_delays, g_input_gain, g_output_gain,  g_direct_gain, g_rt60s, g_tone_filter_gains , fs , 16);
        
    gen_audio_out = octFilBank(g_ir_time_domain);

    gen_bands_ir = squeeze(gen_audio_out(:,:,:));
   
    powerRange = 60; %dB
    max_size = 128;
    
    [tar_spectogram,cf, t] = poctave(tar_bands_ir, fs, 'spectrogram');
    
    [gen_spectogram,cf, t] = poctave(gen_bands_ir, fs, 'spectrogram');
    
    tar_spectrum_dB = (10*log10(abs(tar_spectogram)));
    gen_spectrum_dB = (10*log10(abs(gen_spectogram)));
    
    MaxPowerTar = max(max(tar_spectrum_dB));
    MaxPowerGen = max(max(gen_spectrum_dB));
    
    minThreshold = min(MaxPowerTar, MaxPowerGen) - powerRange;
    tar_spectrum_dB = max(10*log10(abs(tar_spectogram)), minThreshold);
    gen_spectrum_dB = max(10*log10(abs(gen_spectogram)), minThreshold);

    
    error_per_band_gain = sum(tar_spectrum_dB(:,1:max_size/2, :),2) - sum(gen_spectrum_dB(:, 1:max_size/2,:),2); % size 10
    error_per_band_time = sum(tar_spectrum_dB(:,1:max_size, :),2) - sum(gen_spectrum_dB(:,1:max_size, :),2); % size 10

    error_per_band_gain = sum(error_per_band_gain,3);
    error_per_band_time = sum(error_per_band_time,3);

    %error_per_band= sum(tar_spectrum_dB) - sum(gen_spectrum_dB); % size 10
    fprintf('local cost: objective value = %f\n', sum(abs(error_per_band_time),'all'));
    if sum(abs(error_per_band_time),'all') <= lowest_error
        best_tone_filter_gains = g_tone_filter_gains;
        best_rt60s = g_rt60s;
        lowest_error = sum(abs(error_per_band_time));
        fprintf('g_tone_filter_gains %f\n', best_tone_filter_gains);
        fprintf('g_rt60s %f\n', best_rt60s);
    end

    g_tone_filter_gains = g_tone_filter_gains + (learn_rate_gain  * (error_per_band_gain(4:13)'));
    g_rt60s = g_rt60s + (learn_rate_time  * (error_per_band_time(4:13)'));
end




fprintf('g_tone_filter_gains %f\n', best_tone_filter_gains);
fprintf('g_rt60s %f\n', best_rt60s);

parameters = [g_input_gain, g_output_gain, g_delays, g_direct_gain, best_rt60s, best_tone_filter_gains] ;

end