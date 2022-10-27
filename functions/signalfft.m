figure(30)
clf
Fs = t_measures.SAMPLE_RATE;
ir = t_measures.SIGNAL;
gir = g_measures.SIGNAL;
[x, xdb] = schroeder(ir);
x = ir;
x = x/max(x);
xdft = fft(x);
xdft = xdft(1:length(x)/2+1);
DF = Fs/length(x); % frequency increment
freqvec = 0:DF:Fs/2;
tampitude = 20*log10(abs(xdft));
semilogx(freqvec,20*log10(abs(xdft)))



[x, xdb] = schroeder(gir);
x = gir;
x = x/max(x);
xdft = fft(x);
xdft = xdft(1:length(x)/2+1);
DF = Fs/length(x); % frequency increment
freqvec = 0:DF:Fs/2;
hold on
gampitude = 20*log10(abs(xdft));
%semilogx(freqvec,20*log10(abs(xdft)))

figure(31)
clf
semilogx(freqvec,tampitude - gampitude)
