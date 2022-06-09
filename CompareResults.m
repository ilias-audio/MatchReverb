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

generatedIRPath = './results/generated';
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
        generated_measures(i) = measures;
        fprintf("comapre with %s\n", target_names(match_index));
    end
end

%% pre delay compare
fprintf(">>>[INFO] Pre-Delay compare...\n");
for i= 1:length(generatedMeasures)
    t_predelay(i) = target_measures(i).PREDELAY;
    g_predelay(i) = generated_measures(i).PREDELAY;
    e_predelay(i) = (t_predelay(i) - g_predelay(i));
end
fprintf(">>>[RESULT] Pre-Delay MSE = %f \n\n", mse(t_predelay, g_predelay));

fprintf(">>>[INFO] Global RT60 compare...\n");
for i= 1:length(generatedMeasures)
    t_t60(i) = target_measures(i).T60;
    g_t60(i) = generated_measures(i).T60;
    e_t60(i) = (t_t60(i) - g_t60(i));
end
fprintf(">>>[RESULT] RT60 MSE = %f...\n\n", mse(t_t60, g_t60));

fprintf(">>>[INFO] Global EDT compare...\n");
for i= 1:length(generatedMeasures)
    t_edt(i) = target_measures(i).EDT;
    g_edt(i) = generated_measures(i).EDT;
    e_edt(i) = (t_edt(i) - g_edt(i));
end
fprintf(">>>[RESULT] EDT MSE = %f...\n\n", mse(t_edt, g_edt));

fprintf(">>>[INFO] Global C80 compare...\n");
for i= 1:length(generatedMeasures)
    t_c80(i) = target_measures(i).C80;
    g_c80(i) = generated_measures(i).C80;
    e_c80(i) = (t_c80(i) - g_c80(i));
end
fprintf(">>>[RESULT] C80 MSE = %f...\n\n", mse(t_c80, g_c80));

fprintf(">>>[INFO] Global BR compare...\n");
for i= 1:length(generatedMeasures)
    t_br(i) = target_measures(i).BR;
    g_br(i) = generated_measures(i).BR;
    e_br(i) = (t_br(i) - g_br(i));
end
fprintf(">>>[RESULT] BR MSE = %f...\n\n", mse(t_br, g_br));

fprintf(">>>[INFO] Global RT30(f) compare...\n");
for i= 1:length(generatedMeasures)
    t_rt30f(i,1:length(target_measures(i).SPECTRUM_T30)) = target_measures(i).SPECTRUM_T30;
    g_rt30f(i,1:length(generated_measures(i).SPECTRUM_T30)) = generated_measures(i).SPECTRUM_T30;
    e_rt30f(i) = mse(t_rt30f(i,:), g_rt30f(i,:));
end
fprintf(">>>[RESULT] RT30(f) MSE = %f...\n", mse(e_rt30f));

%%
fprintf(">>>[INFO] Global POWER(f) compare...\n");
for i= 1:length(generatedMeasures)
    t_ini_spectr(i,1:length(target_measures(i).INITIAL_SPECTRUM)) = target_measures(i).INITIAL_SPECTRUM;
    g_ini_spectr(i,1:length(generated_measures(i).INITIAL_SPECTRUM)) = generated_measures(i).INITIAL_SPECTRUM;
    e_ini_spectr(i) = mse(t_ini_spectr(i,:), g_rt30f(i,:));
end
fprintf(">>>[RESULT] POWER(f) MSE = %f...\n", mse(e_ini_spectr));