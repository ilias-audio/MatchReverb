figure(30)
Fs = 96000;
ir = target_measures(10).SIGNAL;
gir = generated_measures(10).SIGNAL;
[x, xdb] = schroeder(ir);
x = x/max(x);
xdft = fft(x);
xdft = xdft(1:length(x)/2+1);
DF = Fs/length(x); % frequency increment
freqvec = 0:DF:Fs/2;
tampitude = 20*log10(abs(xdft));
semilogx(freqvec,20*log10(abs(xdft)))

gir = generated_measures(10).SIGNAL;

[x, xdb] = schroeder(gir);
x = x/max(x);
xdft = fft(x);
xdft = xdft(1:length(x)/2+1);
DF = Fs/length(x); % frequency increment
freqvec = 0:DF:Fs/2;
hold on
gampitude = 20*log10(abs(xdft));
semilogx(freqvec,20*log10(abs(xdft)))

figure(31)
semilogx(freqvec,tampitude - gampitude)