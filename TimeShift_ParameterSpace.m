
function TimeShift_ParameterSpace

%--------------------------------------------------------------------
% Function to load the simulated data in the server for a range of 
% parameters and calculate:
%  - Matrix of INSIDEOUT time-shifts across the parameter space based 
% on when the autocorrelation function of each signal decays to 20% of
% its initial, maximum value.
%
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

save_file = 'Name_file';

Tau_ind = zeros(length(K),length(MD)); % matrix of time-shifts

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
        
        [Tau_ind(g,d)] = timeshift_insideout(Zsave);

    end    
end

save(save_file,'Tau_ind')
