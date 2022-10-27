function PlotEDC_MFCC(t_struct,g_struct)

    g_signal_plus_noise = g_struct.SIGNAL + lowpass((randn(size(g_struct.SIGNAL)) - 0.5) * 0.0003 ...
        , 1e3, t_struct.SAMPLE_RATE,'Steepness',0.5);

    new_g_struct = MeasureImpulseResponseFeatures(g_signal_plus_noise,g_struct.SAMPLE_RATE, "DummyStruct")


    figure(1)
    clf
    [t_out t_outdB] = schroeder(t_struct.SCHROEDER);
    
    t_outdB = bsxfun(@minus, t_outdB, max(t_outdB(:, :)));
    
    t_outdB(t_outdB < -60) = -60;
    
    surf(t_outdB);
    shading interp;
    
    figure(2)
    clf
    [g_out g_outdB] = schroeder(new_g_struct.SCHROEDER);
    
    g_outdB = bsxfun(@minus, g_outdB, max(g_outdB(:, :)));
    
    g_outdB(g_outdB < -60) = -60;
    
    surf(g_outdB);
    shading interp;

    figure(3)
    clf
    
    e_outdB = abs(t_outdB - g_outdB);
    
    surf(e_outdB);
    shading interp;
    
    
    [t_coeffs] = mfcc(t_struct.SIGNAL,t_struct.SAMPLE_RATE,"LogEnergy","Ignore");
    [g_coeffs] = mfcc(new_g_struct.SIGNAL,new_g_struct.SAMPLE_RATE, "LogEnergy","Ignore");

    t_coeffs(isnan(t_coeffs)) = 0;
    t_coeffs(isinf(t_coeffs)) = 0;
    g_coeffs(isnan(g_coeffs)) = 0;
    g_coeffs(isinf(g_coeffs)) = 0;
    
    error_shroeder = sum(sum((t_coeffs(:,1:end) - g_coeffs(:,1:end).^2)));
    error_local_spectrum = sum(sum(abs(error_shroeder)));
    a = sqrt((t_coeffs(:,1:end) - g_coeffs(:,1:end)).^2);
    figure(1000)
    surf(a)
    shading interp
    figure(666)
    surf(t_coeffs(:,1:end))
    shading interp
    
    figure(777)
    surf(g_coeffs(:,1:end))
    shading interp
    cost = ( error_local_spectrum);
    
    cost(isnan(cost)) = 10^50;

    
    %% look at the global EDC
    figure(20)
    clf
    [g_out g_outdB] = schroeder(new_g_struct.SIGNAL);
    g_outdB = bsxfun(@minus, g_outdB, max(g_outdB(:, :)));
    [t_out t_outdB] = schroeder(t_struct.SIGNAL);
    t_outdB = bsxfun(@minus, t_outdB, max(t_outdB(:, :)));
    plot(t_outdB)
    hold on
    plot(g_outdB)
    
    
    %% log E curve
    figure(30)
    clf
    plot(t_coeffs(:,1))
    hold on
    plot(g_coeffs(:,1))
    
    figure(31)
    clf
    plot(t_coeffs(:,2))
    hold on
    plot(g_coeffs(:,2))
    
%     
%     for i = 1:12
%         figure(100+i)
%         clf
%         plot(t_coeffs(:,1+i))
%         hold on
%         plot(g_coeffs(:,1+i))
%     end
%     
   
    figure(30)
    clf
    Fs = t_struct.SAMPLE_RATE;
    ir = t_struct.SIGNAL(96000:end);

    x = ir/max(ir);
    xdft = fft(x);
    xdft = xdft(1:length(x)/2+1);
    DF = Fs/length(x); % frequency increment
    freqvec = 0:DF:Fs/2;
    tampitude = 20*log10(abs(xdft));
    semilogx(freqvec,20*log10(abs(xdft)))

end



