[input_gain, output_gain, delays] = splitXInParameters(x);


target_measures(1).INITIAL_SPECTRUM = target_measures(1).INITIAL_SPECTRUM + 12;
for i = 1:12
 irTimeDomain(:,i) = GenerateImpulseResponseFromFeatures(target_measures(1), delays, input_gain * 10^(i/10), output_gain * 10^(i/10));  



[MeasuresStruct(i)] = MeasureImpulseResponseFeatures(irTimeDomain(:,i) ,target_measures(1).SAMPLE_RATE, i)
   
   



end




figure(6)
clf

for i = 1:10


semilogx(MeasuresStruct(i).FREQ_T30, MeasuresStruct(i).INITIAL_SPECTRUM)

hold on
end
