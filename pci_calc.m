
function [pci] = pci_calc(Zsave,dt_save,t_pert_start,tmax,threshold)

%-----------------------------------------------------------------------%
% This function calculates the PCI values of simulated signals based on
% a previously determined significance threshold. In this work, it was
% used to obtain the PCI values using thresholds obtained from exclusively
% pre-stimulus trials.
% 
% INPUT
% - Zsave: simulated time series (nodes x time)
% - dt_save: temporal resolution of the time series (in seconds)
% - t_pert_start: time point (in seconds) at which perturbation starts
% - tmax: duration of the complete simulation (in seconds)
% - threshold: previously determined significance threshold
%
% OUTPUT
% - pci: PCI value obtained for that time series with that threshold
% 
% Written by Mariana Henriques 2023 mariana.m.henriques@tecnico.ulisboa.pt
% ----------------------------------------------------------------------%

t = dt_save:dt_save:tmax; % time vector 

ts = real(Zsave);

ts_pre = ts(:,t <= t_pert_start - 1e-3 & t > t_pert_start - 500e-3); % between -500ms and -1ms

signal_centralized = ts - mean(ts_pre,2); % center the signal -> putting mean to 0 based on prestimulus mean

std_prestim = std(signal_centralized(:,t <= t_pert_start - 1e-3 & t > t_pert_start - 500e-3),1,2); % std of prestim based on centered data

signal_centre_norm = signal_centralized./std_prestim; % taking entire data and setting std to 1

ts_post = signal_centre_norm(:,t > t_pert_start & t < t_pert_start + 300e-3); % first 300ms following perturbation

signal_binary = abs(ts_post) > threshold;

pci = LZ_Complexity_Norm(signal_binary);
