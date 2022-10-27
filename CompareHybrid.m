% Compare Results
%
% Author: Ilias Ibnyahya
% Queen Mary University of London
% email: i.ibnyahya@qmul.ac.uk
% June 2022; Last revision: June 2022

%------------- BEGIN CODE --------------

fprintf(">>>[INFO] Setup Paths...\n");
targetIRPath = './results/target';
targetMeasures = dir(fullfile(targetIRPath, '**/*measures.mat'));
targetMeasures = targetMeasures(~[targetMeasures.isdir]);

generatedIRPath = './results/hybrid';
generatedMeasures = dir(fullfile(generatedIRPath, '**/*measures.mat'));
generatedMeasures = generatedMeasures(~[generatedMeasures.isdir]);

fprintf(">>>[INFO] %d Target Measures found...\n", length(targetMeasures));
fprintf(">>>[INFO] %d Generated Measures found...\n", length(generatedMeasures));
fprintf(">>>[INFO] start Measure %d/%d...\n", i , length(generatedMeasures));
    
target_names = strings(1, length(targetMeasures));
generated_names = strings(1,length(generatedMeasures));


for i= 1:length(targetMeasures)
    target_names(i) = targetMeasures(i).name;
end


for i= 1:length(generatedMeasures)
    generated_names(i) = generatedMeasures(i).name;
    

end

for i= 1:length(generatedMeasures)
    fprintf(">>>[INFO] start reading %s...\n", generatedMeasures(i).name);
    if any(strcmp(target_names, eraseBetween(generated_names(i),1,4)))
        fprintf("It worked for %s\n", generated_names(i));
        match_index = find(strcmp(target_names, eraseBetween(generated_names(i),1,4)) == 1);
        load(fullfile(targetIRPath,target_names(match_index)));
        target_measures(i) = measures;
        load(fullfile(generatedIRPath,generated_names(i)));
        hybrid_measures(i) = measures;
        fprintf("comapre with %s\n", target_names(match_index));
    end
end

% for i= 1:length(generatedMeasures)
%     fprintf("%d\n",i);
%     generated_measures(i).COST = CompareImpulseResponsesFeatures(target_measures(i), generated_measures(i));
%     measures = generated_measures(i);
%     save(fullfile(generatedIRPath,generated_names(i)) , 'measures');
% end



%% pre delay compare
fprintf(">>>[INFO] Pre-Delay compare...\n");
for i= 1:length(generatedMeasures)
    t_predelay(i) = target_measures(i).PREDELAY;
    g_predelay(i) = hybrid_measures(i).PREDELAY;
    e_predelay(i) = abs((t_predelay(i) - g_predelay(i)));
end
fprintf(">>>[RESULT] Pre-Delay MSE = %f \n\n", (mean(e_predelay)));

fprintf(">>>[INFO] Global RT60 compare...\n");
for i= 1:length(generatedMeasures)
    t_t60(i) = target_measures(i).T60;
    g_t60(i) = hybrid_measures(i).T60;
    e_t60(i) = abs((t_t60(i) - g_t60(i)));
end
fprintf(">>>[RESULT] RT60 MSE = %f...\n\n", (mean(e_t60)));

fprintf(">>>[INFO] Global EDT compare...\n");
for i= 1:length(generatedMeasures)
    t_edt(i,1:length(target_measures(i).SPECTRUM_EDT)) = target_measures(i).SPECTRUM_EDT;
    g_edt(i,1:length(target_measures(i).SPECTRUM_EDT)) = hybrid_measures(i).SPECTRUM_EDT;
    e_edt(i,:) = (abs(t_edt(i,:) - g_edt(i,:)));
end
fprintf(">>>[RESULT] EDT MSE = %f...\n\n", mean(mean(e_edt')));

fprintf(">>>[INFO] Global C80 compare...\n");
for i= 1:length(generatedMeasures)
    t_c80(i,1:length(target_measures(i).SPECTRUM_C50)) = target_measures(i).SPECTRUM_C50;
    g_c80(i,1:length(target_measures(i).SPECTRUM_C50)) = hybrid_measures(i).SPECTRUM_C50;
    e_c80(i,:) = (abs((t_c80(i,:) - g_c80(i,:))));
end
fprintf(">>>[RESULT] C80 MSE = %f...\n\n", mean(mean(e_c80')));

fprintf(">>>[INFO] Global BR compare...\n");
for i= 1:length(generatedMeasures)
    t_br(i) = target_measures(i).BR;
    g_br(i) = hybrid_measures(i).BR;
    e_br(i) = abs((t_br(i) - g_br(i)));
end
fprintf(">>>[RESULT] BR MSE = %f...\n\n", (mean(e_br)));

fprintf(">>>[INFO] Global RT30(f) compare...\n");
for i= 1:length(generatedMeasures)
    t_rt30f(i,1:length(target_measures(i).SPECTRUM_T30)) = target_measures(i).SPECTRUM_T30;
    g_rt30f(i,1:length(hybrid_measures(i).SPECTRUM_T30)) = hybrid_measures(i).SPECTRUM_T30;
    e_rt30f(i) = mean(abs(2*t_rt30f(i,:) - 2*g_rt30f(i,:)));
end
fprintf(">>>[RESULT] RT30(f) MSE = %f...\n", (mean(e_rt30f)));

%%
fprintf(">>>[INFO] Global POWER(f) compare...\n");
for i= 1:length(generatedMeasures)
    t_ini_spectr(i,1:length(target_measures(i).INITIAL_SPECTRUM)) = target_measures(i).INITIAL_SPECTRUM;
    g_ini_spectr(i,1:length(hybrid_measures(i).INITIAL_SPECTRUM)) = hybrid_measures(i).INITIAL_SPECTRUM;
    e_ini_spectr(i) = mean(abs(t_ini_spectr(i,:) - g_ini_spectr(i,:)));
end

fprintf(">>>[RESULT] POWER(f) MSE = %f...\n", (mean(e_ini_spectr)));


figure(11)
x = [ e_t60;(mean(e_edt')); e_predelay ; e_rt30f];
boxplot(x','labels',{'RT 60dB','Early Decay Time','Pre-Delay','RT 60dB Vs (Freq)'});
title("FDN & FIR generated IR error");
ylabel("mean absolute error (MAE) in seconds (s)");

figure(12)
x = [ e_br; (mean(e_c80')); e_ini_spectr];
boxplot(x','labels',{'Bass Ratio','Clarity 80', 'Initial Power Spectrum'});
title("FDN & FIR generated IR error");
ylabel("mean absolute error (MAE) in decibels (dB)");