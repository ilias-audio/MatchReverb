

for i = 1:20
    t_r(i) = DirecttoReverbRatio(target_measures(i));
    g_r(i) = DirecttoReverbRatio(generated_measures(i));
    h_r(i) = DirecttoReverbRatio(hybrid_measures(i));
    
    cmp_r = [t_r; g_r; h_r];
    
    
    
    err_rate = [local_error(t_r, t_r) ;  local_error(t_r, g_r) ; local_error(t_r, h_r)];
end


function error = local_error(t, g)
    error = (t-g)./t;
    error = round(error .*100);
end




