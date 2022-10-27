yourValues = (sqrt(COST));
x = t_t60;
y = t_c80;
cmap = jet(16);
v = rescale(yourValues, 1, 16); % Nifty trick!
numValues = length(yourValues);
markerColors = zeros(numValues, 3);
% Now assign marker colors according to the value of the data.
for k = 1 : numValues
    row = round(v(k));
    markerColors(k, :) = cmap(row, :);
end
% Create the scatter plot.
scatter(x, y, [], markerColors, 'fill'); 
colorbar;
caxis([min(yourValues) max(yourValues)]);
ylabel("Clarity 80 ms");
xlabel("Reverberation Time 60 dB in seconds")
title("Target Clarity 80 & RT60 compared to the cost function of the best Generated IR")
grid on;

