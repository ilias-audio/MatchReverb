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


%%
fprintf(">>>[INFO] Global POWER(f) compare...\n");
for i= 2:length(generatedMeasures)
    t_ini_spectr(i,1:length(target_measures(i).INITIAL_SPECTRUM)) = target_measures(i).INITIAL_SPECTRUM;
    g_ini_spectr(i,1:length(generated_measures(i).INITIAL_SPECTRUM)) = generated_measures(i).INITIAL_SPECTRUM;
    e_ini_spectr(i,:) = ((t_ini_spectr(i,:) - g_ini_spectr(i,:)));
end

fprintf(">>>[RESULT] POWER(f) MSE = %f...\n", sqrt(mse(e_ini_spectr)));

figure(13)
x = [ e_ini_spectr];
boxplot(x);