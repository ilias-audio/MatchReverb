function MeasureImpulseResponsesDirectory(source_dir, results_dir)
    %MeasureImpulseResponsesDirectory
    %Reads the IRs from a given directory including subfolders
    %and generates the measures required for generating IRs.
    %only works with .wav files

    % Author: Ilias Ibnyahya
    % Queen Mary University of London
    % email: i.ibnyahya@qmul.ac.uk
    % April 2022; Last revision: May 2022

    %------------- BEGIN CODE --------------

    fprintf(">>>[INFO] Measure Impulse Responses From Directory...\n");
    targetIR = dir(fullfile(source_dir, '**/*.wav'));
    targetIR = targetIR(~[targetIR.isdir]);

    fprintf(">>>[INFO] %d Impulse responses found...\n", length(targetIR));

    mkdir(fullfile(results_dir));
    
    desired_sample_rate = 48000;
    
    max_audio_length = 10; %seconds
    
    max_sample_length = max_audio_length * desired_sample_rate;
    
    for i= 1:length(targetIR)
        
        clearvars -except  targetIR results_dir i desired_sample_rate max_sample_length 
        
        fprintf(">>>[INFO] Start IR %d/%d %s...\n", i , length(targetIR), targetIR(i).name);

        [raw_audio, fs] = audioread(fullfile(targetIR(i).folder, targetIR(i).name));
        
        [P,Q] = rat(desired_sample_rate/fs);

        src_audio = resample(raw_audio,P,Q);
        
        if length(src_audio) > max_sample_length
            src_audio = src_audio(1:max_sample_length);
        end
       
        measures = MeasureImpulseResponseFeatures(src_audio, desired_sample_rate, targetIR(i).name);

        save(fullfile(results_dir, [targetIR(i).name(1:end-4) '_measures.mat']), 'measures');

        fprintf("\n");
    end
end
