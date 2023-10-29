
function Simulate_ParameterSpace

%--------------------------------------------------------------------
% Script to simulate 100 trials of each combination of global
% parameters in the defined parameter space, parallelized in the
% cluster. Simulations can be perturbed either with a single, or a
% square pulse
% Warning: this script creates many simulation files, as it results 
% in 100 simulations per point considered.
%
% Written by Mariana Henriques 2023 mariana.m.henriques@tecnico.ulisboa.pt
%--------------------------------------------------------------------

array_id = str2double(getenv('SLURM_ARRAY_TASK_ID')); % for the cluster

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

% Parameters for simulation
dt_save = 2e-3; % temporal resolution of simulations in seconds
input_amp = 0.1; % stimulation amplitude (numerical value added to solution of oscillator eq.)
k = Param{array_id}(1);
md = Param{array_id}(2);

% Labels
K_label = num2str(log10(k));
ind_p = find(K_label == '.');

if numel(ind_p)
    K_label(ind_p) = 'p';
end

% data and more parameters for simulation

f = 40; % natural frequency of oscillators (Hz)
SynDelay = 0;
sig = 0.001; % noise 

% SC - Structural Connectivity
load SC_90aal_32HCP.mat mat
red_mat = mat;
N = size(red_mat,1);
C = red_mat/mean(red_mat(ones(N)-eye(N)>0)); % Such that the mean of all non-diagonal elements is 1.

load SC_90aal_32HCP.mat mat_D
% Distance between areas
D = mat_D;
D = D/1000; % Distance matrix in meters

% Time vector and stimulation parameters
tmax = 3; % (in seconds)
t_prev = 0;
t_pert_start = 1.5; % start point of perturbation (in seconds)
%pulse_dur = 0.01; % if it will be perturbed with square pulse 

% original TMS targets (Casali et al. 2013) as nodes to be perturbed at once
targets = [1 2 3 4 7 8 45 46 47 48 49 50 59 60 67 68];

% Simulation over 100 trials
for tr = 1:100

    disp(['Now K=' num2str(k) ', mean Delay = ' num2str(md) 'ms'])

    % choose single pulse or square pulse
    [Zsave, dt_save] = Hopf_Delays_Run_HCP_Stim(f,k,md*10^-3,SynDelay,sig,input_amp,t_pert_start,targets,C,D,tmax,t_prev,dt_save);
    %[Zsave, dt_save] = Hopf_Delays_SquareStim(f,k,md*10^-3,SynDelay,sig,input_amp,t_pert_start,pulse_dur,targets,C,D,tmax,t_prev,dt_save);

    save([num2str(tr) '_Tri_K1E' K_label '_MD' num2str(md) 'amp_0p1'],'Zsave','tmax','t_pert_start','dt_save')

end