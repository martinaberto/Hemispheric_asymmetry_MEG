# Hemispheric asymmetries in auditory cortex reflect discriminative responses to temporal details or summary statistics of stationary sounds.

This repository includes information on our MEG study published in Cortex.
The dataset includes data from 22 healthy individuals. The folder "Experimental protocol" includes all codes and materials used to run the experiment using MATLAB and Psychtoolbox.

The data has already been processed and is in source space (stcs). The repository also includes results of cluster-based permutation obtained with the [EELBRAIN](https://eelbrain.readthedocs.io/en/stable/) toolbox. 
To open the .dat files you need to install the local environment used in the paper and use the joblib.load() function. 
All dependencies are listed in the environment.yml file.

The analysis codes and functions are available in the Pipeline.ipynb notebook and utils folder.


Analyses and parameters are described in detail in the manuscript.
