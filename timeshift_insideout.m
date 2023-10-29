
function [Tau_ind] = timeshift_insideout(Zsave)

%------------------------------------------------------------------------
% Function to estimate the value of the individual time-shift obtained to
% use in the insideout framework based on the number of time lags it takes
% for the autocorrelation function of the signal to decay to 20% of its 
% initial, maximum value.
%
% INPUT
% - Zsave: time series of simulated data (nodes x time)
% 
% OUTPUT
% - Tau_ind: value of the individual time-shift obtained for the insideout 
% framework based on the number of time steps it takes for the autocorrelation
% function of the signal to decay to 20% of its initial value.
%
% Mariana Henriques 2023 mariana.m.henriques@tecnico.ulisboa.pt
%------------------------------------------------------------------------

tss = real(Zsave); %timeseries

for a=1:size(Zsave,1)
    [acf(a,:),lags] = autocorr(tss(a,:),NumLags = 10000);
end

avg_aut = mean(acf);
Tau_ind = lags(find(avg_aut<0.2,1));

