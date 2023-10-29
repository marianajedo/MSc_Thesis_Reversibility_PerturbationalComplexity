
function PCI_ParameterSpace

%------------------------------------------------------------------------
% Script to load simulated data for a range of model parameters and 
% calculate PCI and PCIst for each point in the parameter space,
% parallelized in the cluster.
%
% Written by Mariana Henriques 2023 mariana.m.henriques@tecnico.ulisboa.pt
%------------------------------------------------------------------------

array_id = str2double(getenv('SLURM_ARRAY_TASK_ID')); % for cluster

MD = 0:1:20; % Range of Mean Delay in ms

expK = -1:0.1:1.7;
K = 10.^(expK); % Range of Coupling Strengths

Param = cell(1,length(K)*length(MD)); % Points of the Parameter Space

indx = 0;
for g = 1: length(K)
    for d = 1:length(MD)
        indx = indx +1;
        Param{indx} = [K(g),MD(d)];
    end
end

% Model Parameters
k = Param{array_id}(1);
md = Param{array_id}(2);

% Labels
K_label = num2str(log10(k));
ind_p = find(K_label == '.');

if numel(ind_p)
    K_label(ind_p) = 'p';
end

myDir = "/home/mhenriques/new/trials"; % directory to get simulated trials

% ---------- BUILD 3D DATA -------------
data = zeros(100,90,1500); % 100 trials x 90 nodes x 1500 time points -> adjust according to simulations

for tri = 1:100
    % load simulations
    load(fullfile(myDir,[num2str(tri) '_SQTri_K1E' K_label '_MD' num2str(md) 'amp_0p1.mat']),'Zsave','dt_save','tmax','t_pert_start');
    data(tri,:,:) = Zsave;
end
%---------------------------------------


% --------------- PCI ------------------
bootstraps = 500;
alpha = 0.01;
[~, signal_binary] = preprocess_bootstrap(data,dt_save,tmax,t_pert_start,bootstraps,alpha);
pci = LZ_Complexity_Norm(signal_binary);
%---------------------------------------


% -------------- PCIst -----------------
parameters.max_var=99; % Percentage of variance accounted for by the selected principal components.
parameters.min_snr=1.1; % Selects principal components with a signal-to-noise ratio (SNR) > min_snr.
parameters.k=1.2; % Noise control parameter.
parameters.baseline=[-400 -50]; % Signal's baseline time interval [ini,end] in milliseconds.
parameters.response=[0 300]; % Signal's response time interval [ini,end] in milliseconds.
parameters.nsteps=100; % Number of steps used to search for the threshold that maximizes ∆NST.
parameters.l=1; % Number of embedding dimensions (1 = no embedding).
parameters.tau=2; % Number of timesamples of embedding delay

times = dt_save:dt_save:tmax; %time vector 
times = times * 10^3; % miliseconds for PCIst
t_pert_start = t_pert_start * 10^3;
times = times - t_pert_start; % make stim time 0
times = round(times);

signal_evk = squeeze(mean(data,1));
pcist = PCIst(signal_evk,times,parameters);
%---------------------------------------


save(['pci_K1E' K_label '_MD' num2str(md)],'pci')
save(['pcist_K1E' K_label '_MD' num2str(md)],'pcist')
