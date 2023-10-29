
function Synch_Meta_ParameterSpace

%--------------------------------------------------------------------
% Script to load the simulated data in the server for a range of 
% parameters and calculate the level of Synchrony and Metastability of
% simulated signals based on the Kuramoto Order Parameter, as in 
% Cabral et al. (2022)
%  
% The original script to obtain metrics on simulated signals over a 
% defined parameter space was written by Joana Cabral 2017 
% joana.cabral@med.uminho.pt
% Adapted by Mariana Henriques 2023 mariana.m.henriques@tecnico.ulisboa.pt
%-------------------------------------------------------------------

MD = 0:1:20; % Range of Mean Delay in ms

expK = -1:0.1:1.7;
K = 10.^(expK); % Range of Coupling Strengths

myDir = 'folder'; % directory to where baseline simulations are

save_file = 'Name_file';

Synchrony = zeros(length(K),length(MD));
Metastability = zeros(length(K),length(MD));

for g=1:length(K)
    for d=1:length(MD)
        k=K(g);
        md=MD(d);
        
        disp(['Now K=' num2str(k) ', mean Delay = ' num2str(md) 'ms'])
        
        K_label = num2str(log10(k));
        ind_p = find(K_label == '.');

        if numel(ind_p)
            K_label(ind_p) = 'p';
        end

        load(fullfile(myDir,['a_Remote_K1E' K_label '_MD_' num2str(md) 'a-5.mat']),'Zsave','dt_save') % load simulated time series
        
        [Synchrony(g,d), Metastability(g,d)] = KOP_function(Zsave,dt_save);

    end    
end

save(save_file,'Synchrony','Metastability')
