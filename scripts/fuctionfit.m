% Step 1: Collect data
x = linspace(1, 10, 10);
y = [2.1, 4.2, 6.4, 8.2, 9.9, 9.9, 9.9, 9.9, 9.9, 9.9];

% Step 2: Define the segmented linear function
segmentedLinearFunc = @(b, x) (x <= b(1)).*(b(2)*x + b(3)) + (x > b(1)).*(b(4)*x + b(5));

% Step 3: Choose a fitting method
fittingMethod = 'lsqcurvefit';

% Step 4: Compute the best-fit parameters
initialGuess = [5, 1, 0, 1, 0]; % initial guess for knee point and slopes/intercepts on either side
bestFitParams = lsqcurvefit(segmentedLinearFunc, initialGuess, x, y);

% Step 5: Plot the data and the best-fit line
figure;
plot(x, y, 'o', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b')
hold on
plot(x, segmentedLinearFunc(bestFitParams, x), 'r-', 'LineWidth', 2)
xlabel('x')
ylabel('y')
legend('Data', 'Best-fit line')
