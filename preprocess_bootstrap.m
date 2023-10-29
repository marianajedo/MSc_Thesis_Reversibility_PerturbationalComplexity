
function [signalThresh, signal_binary] = preprocess_bootstrap(data,dt_save,tmax,t_pert_start,bootstraps,alpha)

%------------------------------------------------------------------------
% Function to preprocess simulated time series and obtain matrix of
% Significant Sources SS(x,t) as in Casali et al. (2013) for calculation of
% the Perturbational Complexity Index.
%
% INPUT
% - data: 3D matrix of time series (trials x nodes x time)
% - dt_save: temporal resolution of the time series (in seconds)
% - tmax: duration of the complete simulation (in seconds)
% - t_pert_start: time point (in seconds) at which perturbation starts
% - bootstraps: number of bootstraps to consider
% - alpha: significance level to calculate distribution of values to obtain
% threshold
% 
% OUTPUT
% - signalThresh: threshold obtained to binarise time series
% - singal_binary: binarised matrix of significant sources SS(x,t)
%
% Adapted from a Python Script from Tomas Berjaga Buisan
% https://github.com/tomasberjaga/Master-Thesis/tree/main
% Adapted to Matlab by Mariana Henriques 2023
% mariana.m.henriques@tecnico.ulisboa.pt
%------------------------------------------------------------------------

data = real(data);

[nrepetitions, nodes, ~] = size(data);

t = dt_save:dt_save:tmax; % time vector

data_pre = data(:,:,t <= t_pert_start - 1e-3 & t > t_pert_start - 500e-3); % baseline: between -500ms and -1ms 

signal_centralized = data - mean(data_pre,3); % prestim mean to 0

std_prestim = std(signal_centralized(:, :,t <= t_pert_start - 1e-3 & t > t_pert_start - 500e-3), 1, 3);

% prestim std to 1
signal_centre_norm = signal_centralized ./ std_prestim;

signal_prestim_shuffle = signal_centre_norm(:, :,t <= t_pert_start - 1e-3 & t > t_pert_start - 500e-3);

max_absval_shuffled = zeros(1, bootstraps);

for i_shuffle = 1:bootstraps
    for i_nodes = 1:nodes
        for i_repetition = 1:nrepetitions
            signal_curr = signal_prestim_shuffle(i_repetition, i_nodes, :);
            signal_curr = signal_curr(randperm(length(signal_curr))); % shuffle
            signal_prestim_shuffle(i_repetition, i_nodes, :) = signal_curr;
        end
    end
    % average over trials
    shuffle_avg = squeeze(mean(signal_prestim_shuffle, 1));
    max_absval_shuffled(i_shuffle) = max(abs(shuffle_avg(:)));    
end

% estimate significance threshold
signalThresh = prctile(max_absval_shuffled,(1-alpha)*100);

% binarise response matrix (300ms post-stimulus) 
averaged_trials_poststim = mean(signal_centre_norm(:,:,t > t_pert_start & t < t_pert_start + 300e-3),1);

signal_binary = squeeze(abs(averaged_trials_poststim) > signalThresh);
