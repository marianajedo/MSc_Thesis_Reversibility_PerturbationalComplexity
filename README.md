Master's Thesis: Reversibility and Perturbational Complexity of brain network dynamics: a whole-brain modelling approach

Mariana Madeira Henriques, October 2023

mariana.m.henriques@tecnico.ulisboa.pt

In this repository, all the code to reproduce the results of the Master's Thesis "Reversibility and Perturbational Complexity of brain network dynamics: a whole-brain modelling approach" by Mariana Madeira Henriques is available.

This work was performed at the Center for Brain and Cognition in Barcelona, Spain, during the period February-October 2023, under the supervision of Prof. Gustavo Deco and Prof. Joana Cabral. 
The thesis was co-supervised by Prof. Patrícia Figueiredo at LaSEEB (Evolutionary Systems and Biomedical Engineering Lab) of Institute for Systems and Robotics at Instituto Superior Técnico in Lisbon, Portugal.

Abstract:
Despite intense research, the neurophysiological mechanisms driving pathological changes in brain network dynamics remain insufficiently understood. The development of measures reflecting and differentiating brain states provides promising tools to improve this understanding. The Perturbational Complexity Index (\acrshort{pci}) and Reversibility in brain dynamics have attracted attention as possible methods to better characterise states of consciousness, health, and disease. Additionally, computational advances in whole-brain modelling have proved its potential to simulate large-scale brain activity, which has opened new doors for the development of in-silico strategies to assess the behaviour of brain networks. By combining these methods, this work explores the limits of the \acrshort{pci} and Reversibility measures by applying them to simulated signals of a whole-brain model. Concisely, the influence of the model’s global parameters in shaping network activity and response to perturbation is demonstrated. Further findings include the rise in both measures in the presence of non-zero short conduction delays, and the fact that despite increasing in states of wakefulness, their highest levels are not found in healthy resting state, which supports evidence of other altered brain states exhibiting increased complexity and non-equilibrium. Lastly, despite their similarities, the distinct patterns found across coupling strengths suggest that the two metrics may capture somewhat different features of brain dynamics. Overall, this work contributes to the understanding of what is altered between disordered and healthy brain states by informing on the relationship between Perturbational Complexity, Reversibility and the underlying structure and dynamics of the network, and how whole-brain modelling can greatly contribute.

1st: Simulations

To obtain the simulated data, the script for the whole-brain model is available in the files "Hopf_Delays_Run_HCP_Stim.m" for perturbation with a Single Pulse, and Hopf_Delays_SquareStim.m for a Square Pulse. The file "Simulate_ParameterSpace.m" displays the script to obtain 100 trials of perturbed simulation per each point in the Parameter Space considered.

The baseline, non-perturbed simulations used in this work were provided by Joana Cabral and Francesca Castaldo (Cabral et al. 2022) 
(francesca.castaldo.20@ucl.ac.uk, joana.cabral@med.uminho.pt)

2nd: INSIDEOUT framework (Deco et al. 2022)

The file "TimeShift_ParameterSpace.m" results in a matrix of time-shifts across the defined Parameter space based on each baseline signal's autocorrelation function and was used to assess what common time-shift would be most appropriate to use to calculate the INSIDEOUT metrics. This script uses the function present in "timeshift_insideout.m".

The file "INSIDEOUT_ParameterSpace.m" calculates the INSIDEOUT measures of Non-Reversibility and Hierarchy across the defined Parameter Space, using the function "insideout_function.m".

3rd: PCI

The file "PCI_ParameterSpace.m" calculates the PCI and PCIst across the defined Parameter Space based on the perturbed simulations loaded (Single/Square Pulse), using "preprocess_bootstrap.m" to preprocess the time series and obtain the significance threshold, and the "LZ_Complexity_Norm.m" to calculate normalised Lempel-Ziv complexity of the response matrices. "PCIst.m" is the PCIst function.

Regarding the approach attempted in the thesis to quickly calculate the significance thresholds by using baseline simulations to obtain "pre-stimulus trials", the script "PCI_PrestimTrials_ParameterSpace.m" is responsible for obtaining these trials, calculating the respective thresholds and PCI values across the defined Parameter Space. It used solely the function "pci_calc.m" which calculates the PCI of signals with a previously determined significance threshold.

4th: Synchrony and Metastability

The script in the file "Synch_Meta_ParameterSpace.m" calculates the degree of Synchrony and the level of Metastability in the system across the defined Parameter Space as according to Cabral et al. (2022). It makes use of the function "KOP_function.m".
