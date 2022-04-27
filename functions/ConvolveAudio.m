
fileName1 = 'vocals.wav';
filePath1 = '/Users/ilias/OneDrive/Documents/AudioResearch/MATLAB/';

fileName2 = 'pori.wav';
filePath2 = '/Users/ilias/OneDrive/Documents/AudioResearch/MATLAB/MLReverb/IR/';


fileName3 = 'pori_gen.wav';
filePath3 = '/Users/ilias/OneDrive/Documents/AudioResearch/MATLAB/MLReverb/IR/';

[signal1, Fs1] = audioread([filePath1 fileName1]);

[signal2, Fs2] = audioread([filePath2 fileName2]);

[signal3, Fs3] = audioread([filePath3 fileName3]);


output1 = conv(signal2, signal1(:, 1));

output2 = conv(signal3, signal1(:, 1));

audiowrite('vocals_pori_target.wav', output1*0.1, Fs1);

audiowrite('vocals_pori_gen.wav', output2*0.1, Fs1);