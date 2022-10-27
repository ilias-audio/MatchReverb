function PlotSignal(target_Structure,generated_Structure)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

figure(5)
clf


timescale = linspace(0, length(target_Structure.SIGNAL)/target_Structure.SAMPLE_RATE, length(target_Structure.SIGNAL));

RT30_sampleNumber = floor(2 * target_Structure.T60 * target_Structure.SAMPLE_RATE);
subplot(2, 1, 1)
semilogy(timescale(1:RT30_sampleNumber), abs(target_Structure.SIGNAL(1:RT30_sampleNumber)));
legend('Target IR');

title(['Raw Signal of ' target_Structure.NAME ': '  num2str(target_Structure.T60/2) 's'])
xlabel('Time (s)') 
ylabel('Amplitude') 

subplot(2, 1, 2)
semilogy(timescale(1:RT30_sampleNumber), abs(generated_Structure.SIGNAL(1:RT30_sampleNumber)));
legend('Best Generated IR');
xline(target_Structure.EDT)

title(['Raw Signal of ' generated_Structure.NAME ': ' num2str(generated_Structure.T60/2) 's'])
xlabel('Time (s)') 
ylabel('Amplitude') 
end

