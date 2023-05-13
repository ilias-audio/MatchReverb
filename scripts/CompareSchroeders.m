% Compare the spectrums of the different SCHROEDER Curves

for i = 4
    figure(1)
    clf
    surf(generated_measures(i).SCHROEDER);
    shading interp
    figure(2)
    surf(target_measures(i).SCHROEDER);
    shading interp
    figure(3)
    surf(target_measures(i).SCHROEDER - generated_measures(i).SCHROEDER);
    shading interp
    min(min(target_measures(i).SCHROEDER - generated_measures(i).SCHROEDER))
    
end
