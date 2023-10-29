
function INSIDEOUT_ParameterSpace

%--------------------------------------------------------------------
% Function to load the simulated data in the server for a range of 
% parameters and calculate measures of the INSIDEOUT framework:
%  - Level of Non-reversibility as in Deco et al. (2022)
%  - Level of Hierarchy as in Deco et al. (2022)
% 
% The original script to obtain metrics on simulated signals over a 
% defined parameter space was written by Joana Cabral 2017 
% joana.cabral@med.uminho.pt
% Modified and adapted by Mariana Henriques 2023 
% mariana.m.henriques@tecnico.ulisboa.pt
%--------------------------------------------------------------------

MD = 0:1:20; % Range of Mean Delay in ms

expK = -1:0.1:1.7;
K = 10.^(expK); % Range of Coupling Strengths

myDir = 'folder'; % directory to where baseline simulations for INSIDEOUT are

save_file = 'file_name';

Nonreversibility = zeros(length(K),length(MD));
Hierarchy = zeros(length(K),length(MD));

Tau = 3; % time-shift selected

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

        load(fullfile(myDir,['a_Remote_K1E' K_label '_MD_' num2str(md) 'a-5.mat']),'Zsave') % load simulated time series
        
        [Nonreversibility(g,d), Hierarchy(g,d)] = insideout_function(Zsave,Tau);

    end    
end

save(save_file,'Nonreversibility','Hierarchy')
