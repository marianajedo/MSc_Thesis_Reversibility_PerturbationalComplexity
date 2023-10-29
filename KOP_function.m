
function [Synchrony, Metastability] = KOP_function(Zsave,dt_save)

%--------------------------------------------------------------------
% Function to calculate the level of Synchrony and Metastability of
% simulated signals based on the Kuramoto Order Parameter, as in 
% Cabral et al. (2022)
%
% INPUT
% - Zsave: time series of simulated data (nodes x time)
% - dt_save: temporal resolution of the time series (in seconds)
% 
% OUTPUT
% - Synchrony: degree of synchrony of the system, given by the mean of
% the KOP
% - Metastability: level of metastability of the system, given by the
% standard deviation of the KOP
% 
% Adapted from Francesca Castaldo francesca.castaldo.20@ucl.ac.uk 
% and Joana Cabral joana.cabral@med.uminho.pt from the Hopf Delay
% Toolbox: https://github.com/fcast7/Hopf_Delay_Toolbox
% by Mariana Henriques 2023 mariana.m.henriques@tecnico.ulisboa.pt
%--------------------------------------------------------------------

% Simulation Parameters Scaling
fbins = 1000;
freqZ = (0:fbins-1)/(dt_save*fbins);
Zb = nan(size(Zsave,1),size(Zsave,2));

% Detect the peak Frequency in the Fourier Transform of all areas
Fourier_Complex = fft(Zsave,fbins,2); %% Fourier of Z (complex) in 2nd dimension

Fourier_Global = abs(mean(Fourier_Complex)).^2;
[~, Imax] = max(Fourier_Global);

% Evaluate Order Stability around the Global peak frequency
% Band-pass filter the signals Z around the peak frequency of the ensemble

for n=1:size(Zsave,1)
    Zb(n,:) = bandpasshopf(Zsave(n,:),[max(0.1,freqZ(Imax)-1) freqZ(Imax)+1],1/dt_save);
    Zb(n,:) = angle(hilbert(Zb(n,:)));           
end

KOP = abs(mean(exp(1i*(Zb)),1));

Synchrony = mean(KOP); % measure of global synchronization (mean of OP)
Metastability = std(KOP); %  how much OP fluctuates in time (std of OP)
