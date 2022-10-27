function WriteMeasuresFromDirectory(targetIRPath)


    fprintf(">>>[INFO] Read target Impulse responses...\n");
    targetIR = dir(fullfile(targetIRPath, '**/*.wav'));
    targetIR = targetIR(~[targetIR.isdir]);

    fprintf(">>>[INFO] %d Impulse responses found...\n", length(targetIR));

    for i= 1:length(targetIR)

        fprintf(">>>[INFO] start IR %d/%d...\n", i , length(targetIR));
        clearvars -except  targetIR i targetIRPath
        fprintf(">>>[INFO] start measuring %s...\n", targetIR(i).name);

        [raw_audio, fs] = audioread(fullfile(targetIR(i).folder, targetIR(i).name));
        measures = MeasureImpulseResponseFeatures(raw_audio, fs, targetIR(i).name);
        save([targetIRPath, '/../target/' , targetIR(i).name(1:end-4), '_measures.mat'], 'measures'); 
        fprintf("\n");
    end
end

