t_IRPath = './MLReverb/IR/';

t_IRNames = dir([t_IRPath 'ir_*.wav']); 

for i= 1:length(t_IRNames)
    [t_v, g_v, e_v] = fdnResultCompare([t_IRPath 'gen_' t_IRNames(i).name],[t_IRPath t_IRNames(i).name]);
    
     save(['./MLReverb/results/' , t_IRNames(i).name, '_measures.mat'], 't_v'); 
     save(['./MLReverb/results/' , ['gen_' t_IRNames(i).name], '_measures.mat'], 'g_v'); 
     save(['./MLReverb/results/' , ['err_' t_IRNames(i).name], '_measures.mat'], 'e_v');     
end
