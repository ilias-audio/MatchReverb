% load st alban a

load('/Users/ilias/Documents/github/MatchReverb/results/target/stalbans_omni_measures.mat')

t_measures = measures;

load('/Users/ilias/Documents/github/MatchReverb/results/generated/gen_stalbans_omni_measures.mat')

g_measures = measures;



fs = t_measures.SAMPLE_RATE;

octFilBank = octaveFilterBank('1 octave',fs, 'FrequencyRange',[18 22000]);

t_audio_out = octFilBank(t_measures.SIGNAL);

t_lin_power = bandpower(t_audio_out, fs, [0 fs/2]);

t_dB_power = 10* log10(t_lin_power);


g_audio_out = octFilBank(g_measures.SIGNAL);

g_lin_power = bandpower(g_audio_out, fs, [0 fs/2]);

g_dB_power = 10* log10(g_lin_power);


diff_power = t_dB_power - g_dB_power;

irTimeDomain = GenerateImpulseResponseFromFeatures(t_measures, g_measures.DELAYS, g_measures.INPUT_GAIN, g_measures.OUTPUT_GAIN, diff_power);

audiowrite(fullfile( "../st_alban_omni_demo_audio.wav"), irTimeDomain, 48000);

gen2_audio_out = octFilBank(irTimeDomain);

gen2_lin_power = bandpower(gen2_audio_out, fs, [0 fs/2]);


gen2_dB_power = 10 *log10(gen2_lin_power);
clf
plot(t_dB_power)
hold on 
plot(gen2_dB_power);
