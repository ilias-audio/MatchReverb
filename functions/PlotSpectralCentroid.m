function PlotSpectralCentroid(target_measures,generated_measures)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
figure(16)
clf

t_centroid = spectralCentroid(target_measures.SIGNAL,target_measures.SAMPLE_RATE);
g_centroid = spectralCentroid(generated_measures.SIGNAL,generated_measures.SAMPLE_RATE);

plot(t_centroid/1000)

hold on

plot(g_centroid/1000)



end

