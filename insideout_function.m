
function [FowRev,Hierarchy] = insideout_function(Zsave,Tau)

%------------------------------------------------------------------------
% Function to estimate the level of non-reversibility and hierarchical
% organisation of simulated brain signals.
%
% INPUT
% - Zsave: time series of simulated data (nodes x time)
% - Tau: time-shift to calculate correlations
% 
% OUTPUT
% - FowRev: level of non-reversibility of the time series data
% - Hierarchy: measure of hierarchy (level of external driving of brain
% dynamics)
%
% Original script for the INSIDEOUT framework written by Deco et al. (2022)
% Adapted to a function for in-silico application by Mariana Henriques
% mariana.m.henriques@tecnico.ulisboa.pt and to include Tau as input
%------------------------------------------------------------------------

tss = real(Zsave); % time series
Tmm = size(tss,2); % get number of time points in the time series

FCtf = corr(tss(:,1:Tmm-Tau)',tss(:,1+Tau:Tmm)'); % time shifted correlation of forward time series
FCtr = corr(tss(:,Tmm:-1:Tau+1)',tss(:,Tmm-Tau:-1:1)'); % time shifted correlation of reversed time series

Itauf = -0.5*log(1-FCtf.*FCtf); % Mutual info - functional causal dependencies between variables
Itaur = -0.5*log(1-FCtr.*FCtr); % FSij forward e reverse (Deco et al. (2022))

Reference = ((Itauf(:)-Itaur(:)).^2)'; % Vector with levels of non-reversibility

index = find(Reference>quantile(Reference,0.0)); % by adjusting the value, sensitity is altered

FowRev = nanmean(Reference(index)); % I (level of non-reversibility)

Hierarchy = nanstd(Reference(index)); % Hierarchy measure
