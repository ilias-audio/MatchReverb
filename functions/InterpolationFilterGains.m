function [new_results] = InterpolationFilterGains(target_data,...
    target_freq, FiltersCenterFreqs)
%INTERPOLATIONFILTERGAINS gets a frequency spectrum and turns it into 
% a set of fixed filter gains to avoid missing energy in a band by 
% just taking a specific frequency measure
figure(89)
clf
FFTCenterFreqs = target_freq + (target_freq(2)/2);

%FiltersCenterFreqs = [ 46, 63, 125, 250, 500, 1000, 2000, 4000, 8000 , 16000];

semilogx(FFTCenterFreqs, target_data);


for i = 1:length(FiltersCenterFreqs)
    if(i == length(FiltersCenterFreqs))
        max_band_freq(i) = FFTCenterFreqs(length(FFTCenterFreqs));
    else
        max_band_freq(i) = mean([FiltersCenterFreqs(i), FiltersCenterFreqs(i+1)]);
    end
    
    if(i == 1)
        min_band_freq(i) = 0;
    else
       min_band_freq(i) = mean([FiltersCenterFreqs(i-1), FiltersCenterFreqs(i)]); 
    end
    
    [x,y] = find( max_band_freq(i) <= FFTCenterFreqs + (target_data(2)/2), 1);
    x(isempty(x)) = (length(FFTCenterFreqs));
    freq_max(i) = ((x));
    
    [x,y] = find( min_band_freq(i) >= FFTCenterFreqs - (target_data(2)/2),1,'last');
    x(isempty(x)) = 1;
  
    freq_min(i) = x;
 
    
    
    gain(i) = mean(target_data(freq_min(i):freq_max(i)));
    hold on
    scatter(FiltersCenterFreqs(i), target_data(freq_min(i):freq_max(i)));
end


hold on 
xline(max_band_freq)
xline(min_band_freq)

semilogx(FiltersCenterFreqs, gain);



new_results = gain;
end

