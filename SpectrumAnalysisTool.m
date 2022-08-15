fprintf(">>>[INFO] load data...\n");
GeneratedParametersPath = './results/parameters';
GeneratedParameters = dir(fullfile(GeneratedParametersPath, '**/*parameters.mat'));
GeneratedParameters = GeneratedParameters(~[GeneratedParameters.isdir]);

load(fullfile(GeneratedParametersPath,GeneratedParameters.name));

[input_gain, output_gain, delays] = splitXInParameters(x);

targetIRPath = './results/target';
targetMeasures = dir(fullfile(targetIRPath, '**/*measures.mat'));
targetMeasures = targetMeasures(~[targetMeasures.isdir]);

load(fullfile(targetIRPath, targetMeasures(10).name));
target_measures = measures;


octFilBank = octaveFilterBank('1 octave',target_measures.SAMPLE_RATE, ...
                                  'FrequencyRange',[18 22000]);
                              
                              
edt_sample = floor(target_measures.EDT * target_measures.SAMPLE_RATE);
                         
audio_out = octFilBank(target_measures.SIGNAL(1:edt_sample));

bands_ir = squeeze(audio_out(:,:,:));

[schroeder_energy schroder_energy_db] = schroeder(abs(bands_ir));    

relative_band_energy = ( schroder_energy_db - schroder_energy_db(1,:));

   





target_measures.INITIAL_SPECTRUM = mean(schroder_energy_db);
target_measures.SPECTRUM_T30 = target_measures.SPECTRUM_T30;

gen_ir = GenerateImpulseResponseFromFeatures(target_measures, delays, input_gain, output_gain);

plot(target_measures.INITIAL_SPECTRUM)

generated_measures = MeasureImpulseResponseFeatures(gen_ir, target_measures.SAMPLE_RATE, 'generated_ir');


                              
fs = target_measures.SAMPLE_RATE;                             
%clear_signal = squeeze(signal');                          
audio_out = octFilBank(gen_ir);

bands_ir = squeeze(audio_out(:,:,:));
audio_fft = fft(gen_ir(1:floor(edt_sample)));

n = length(gen_ir(1:floor(edt_sample)));          % number of samples
f = (0:n-1)*(fs/n);     % frequency range
power = abs(audio_fft).^2/n;    % power of the DFT

figure(1)
semilogx(f(1:floor(n/2)),power(1:floor(n/2)))
xlabel('Frequency')
ylabel('Power')

figure(2)
audio_fft = fft(target_measures.SIGNAL(1:floor(edt_sample)));

n = length(target_measures.SIGNAL(1:floor(edt_sample)));          % number of samples
f = (0:n-1)*(fs/n);     % frequency range
power = abs(audio_fft).^2/n;    % power of the DFT

semilogx(f(1:floor(n/2)),power(1:floor(n/2)))
xlabel('Frequency')
ylabel('Power')



%generated_measures = MeasureImpulseResponseFeatures(gen_ir, target_measures.SAMPLE_RATE, 'generated_ir');

figure(66)
clf
plot(mean(schroder_energy_db))
hold on 
plot((schroder_energy_db(1,:)))
plot((generated_measures.INITIAL_SPECTRUM))
