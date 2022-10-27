% diffuser

in = 1;

N=64;
fs = 48000;

max_delay = round(0.05 * fs) ;
delays = zeros(max_delay , N);

indexs = randi(max_delay, 1,N);
for i = 1:length(indexs)
    delays(indexs(i),i) = in / N;
end


diff_matrix = randomOrthogonal(N);

output =  delays * diff_matrix;

output_sum = sum(output');

output_sum = output_sum/max(abs(output_sum));

figure(60)

plot(output_sum);

soundsc(output_sum, fs);