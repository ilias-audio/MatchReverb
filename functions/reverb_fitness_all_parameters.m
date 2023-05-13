function cost = reverb_fitness_full_order_16(TargetIRMeasures, x) 
   
    g_input_gain = x(1:16);  %% -1 : 1      // 16
    g_output_gain = x(17:32); %% -1 : 1     // 16
    g_delays = ceil(x(33:48)); %% 50 : 5000 // 16
    g_direct_gain = x(49);
    g_rt60s = x(50:59); %% 50 : 5000 // 10
    g_tone_filters = x(60:69); %% 50 : 5000 // 10

    g_signal_length = length(TargetIRMeasures.SIGNAL);

    g_fs = TargetIRMeasures.SAMPLE_RATE;

    g_order = 16;
   
    g_ir_time_domain = GenerateImpulseResponseFromParameters(g_signal_length, g_delays, g_input_gain, g_output_gain, g_direct_gain ,g_rt60s, g_tone_filters, g_fs, g_order);

    %GeneratedIRMeasures = MeasureImpulseResponseFeatures(g_ir_time_domain, TargetIRMeasures.SAMPLE_RATE, "generated_IR");
   
    %cost = CompareImpulseResponsesSpectrograms(TargetIRMeasures, g_ir_time_domain);

   %[g_freqs, g_RT60, g_initPower] = schroeder_linearReg_rt60(g_ir_time_domain, g_fs);

   %[t_freqs, t_RT60, t_initPower] = schroeder_linearReg_rt60(TargetIRMeasures.SIGNAL, g_fs);
    
    
   %cost = mean(abs(t_RT60 - g_RT60)) + 0.1 * mean(abs(t_initPower - g_initPower));
   
   cost = sum(mean(stftloss(TargetIRMeasures.SIGNAL, g_ir_time_domain, g_fs),2));

   fprintf("[LOG] Local Cost: %f \n", cost);

end


function [freqs, RT60, initPower] = schroeder_linearReg_rt60(signal, fs)
    octFilBank = octaveFilterBank('1 octave',fs);                        
    audio_out = octFilBank(signal);

    freqs = getCenterFrequencies(octFilBank);
    bands_ir = squeeze(audio_out(:,:,:));
    center_times = linspace(1,length(audio_out),length(audio_out)) / fs;
    center_times = center_times';
    [dummy_var , schroder_energy_db] = schroeder(abs(bands_ir));  
    half_length = round(length(center_times) / 1.5);
    x =  [center_times(1:half_length)];
    schroder_energy_db = schroder_energy_db';
    y = schroder_energy_db(:,1:half_length);
    % Step 2: Define the segmented linear function
    


    for n = 1:length(schroder_energy_db(:, 1))
        segmentedLinearFunc = @(b, x) (x <= b(1)).*(b(2)*x + b(3)) + (x > b(1)).*(b(4)*x + b(5));
        tol = 0.1;
        A = [0 0 1 0 0;  % b(2) >= 0: The slope on the left side of the knee point is non-negative
             0 0 0 0 1]; % b(5) >= tol: The difference between the two functions at the knee point is at least tol
        b = [y(n,1); tol];
        lb = [0 -inf -inf -inf -inf]; % lower bounds on parameters
        ub = [5 0 0 0 inf]; % upper bounds on parameters
        options = optimoptions('fmincon', 'Algorithm', 'interior-point', 'Display', 'none');
        initialGuess = [center_times(half_length)/3, 1, 0, 1, 0]; % initial guess for knee point and slopes/intercepts on either side
        %bestFitParams = lsqcurvefit(segmentedLinearFunc, initialGuess, x, y(n,:)');
        
        bestFitParams = fmincon(@(b) sum((y(n,:)' - segmentedLinearFunc(b, x)).^2), initialGuess, A, b, [], [], lb, ub, [], options);

        RT60(n) = -60 / bestFitParams(2);
        initPower(n) = bestFitParams(3);

        % Step 5: Plot the data and the best-fit line
%         figure(1);
%         clf
%         plot(x, y(n,:))
%         hold on
%         plot(x, segmentedLinearFunc(bestFitParams, x), 'r-', 'LineWidth', 2)
%         xlabel('x')
%         ylabel('y')
%         legend('Data', 'Best-fit line')
    end
      
end
