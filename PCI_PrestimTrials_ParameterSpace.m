
function PCI_PrestimTrials_ParameterSpace

%--------------------------------------------------------------------
% Script to load the simulated data in the server for a range of 
% parameters and divide it into pre-stimulus/baseline trials of activity
% of 500ms in order to quickly calculate significance threshold and 
% respective PCI without needing to run new trials. 
%
% This scripts is prepared to be parallelized in the cluster by "lines"
% of the parameter space, that is, it runs for all Mean Delays of each 
% Coupling Strength and returns a vector of thresholds and PCIs per K.
%
% The original script to obtain metrics on simulated signals over a 
% defined parameter space was written by Joana Cabral 2017 
% joana.cabral@med.uminho.pt
% Modified and adapted by Mariana Henriques 2023 
% mariana.m.henriques@tecnico.ulisboa.pt
%-------------------------------------------------------------------

array_id = str2double(getenv('SLURM_ARRAY_TASK_ID')); % for the cluster

MD = 0:1:20; % Range of Mean Delay in ms

expK = -1:0.1:1.7;
K = 10.^(expK); % Range of Coupling Strengths

k = K(array_id);

K_label = num2str(log10(k));
ind_p = find(K_label == '.');

if numel(ind_p)
    K_label(ind_p) = 'p';
end

myDir1 = 'directory_baseline_simulations';
myDir2 = 'directory_perturbed_simulations';

save_file = ['Thresholds_K1E' K_label '_faketrials'];

Threshold = zeros(1,length(MD));
PCI = zeros(1,length(MD));

bootstraps = 500;
alpha = 0.01;

% Number of trials considered: 102 trials of 500ms based on 50s
% non-perturbed simulations + prestim intervals of stimulated simulation
% (in this approach, no repeated trials of perturbed simulations were considered)
% 
% 102 = 99 + 3 (99 trials of 500ms from 50s baseline signal
% (last time steps are discarted) + 1 simulation of 2s prestim (3
% trials of 500ms considered in each one)

for d=1:length(MD)
    md=MD(d);
    
    disp(['Now K=' num2str(k) ', mean Delay = ' num2str(md) 'ms'])

    load(fullfile(myDir1,['a_Remote_K1E' K_label '_MD_' num2str(md) 'a-5.mat']),'Zsave','dt_save') % load baseline

    data_pre = zeros(102,size(Zsave,1),0.5/dt_save); % array of prestim will contain 102 "trials" of 500 ms -> 0.5 s

    [nrepetitions, nodes, ~] = size(data_pre);

    ts = real(Zsave(:,1:size(Zsave,2)-250));

    indx_tr = 0;

    for tr = 1:99 % 99 trials from baseline simulations
        indx_tr = indx_tr + 1;
        ts_tr = ts(:,1+tr*250-250:tr*250);
        data_pre(indx_tr,:,:) = ts_tr;
    end

    % load perturbed simulation
    load(fullfile(myDir2,['Signal_K1E' K_label '_MD' num2str(md) 'amp_0p1']),'Zsave','dt_save','t_pert_start','tmax') 
    ts2 = real(Zsave);
    
    for tr2 = 1:3
        indx_tr =  indx_tr + 1;
        ts_tr2 = ts2(:,1+tr2*250-250:tr2*250);
        data_pre(indx_tr,:,:) = ts_tr2;
    end

    signal_centralized = data_pre - mean(data_pre,3); % prestim mean to 0

    % prestim std to 1
    signal_centre_norm = signal_centralized ./ std(signal_centralized,1,3);

    signal_prestim_shuffle = signal_centre_norm;

    max_absval_shuffled = zeros(1,bootstraps);

    for i_shuffle = 1:bootstraps
        for i_nodes = 1:nodes
            for i_repetition = 1:nrepetitions
                signal_curr = signal_prestim_shuffle(i_repetition, i_nodes, :);
                signal_curr = signal_curr(randperm(length(signal_curr))); % shuffle
                signal_prestim_shuffle(i_repetition, i_nodes, :) = signal_curr;
            end
        end

        % average over trials
        shuffle_avg = squeeze(mean(signal_prestim_shuffle,1));
        max_absval_shuffled(i_shuffle) = max(abs(shuffle_avg(:)));
    end

    % estimate significance threshold
    Threshold(d) = prctile(max_absval_shuffled,(1-alpha)*100);

    [pci] = pci_calc(Zsave,dt_save,t_pert_start,tmax,Threshold(d));
  
    PCI(d) = pci;

end

save(save_file,'Threshold','PCI')