# mtlawson_public

Welcome to mtlawson_public! This repository contains public samples of code written by Michael T. Lawson (Biostatistics PhD candidate, UNC-Chapel Hill). This code was all written in the course of research projects at UNC; I've tried to comment things clearly and extract self-contained modules, but please note that some code may be hard to decipher without reading the underlying research. The remainder of this document is a brief overview of the projects and files contained in the repository.



MODULE 1: FLEX SIMULATION 2
This module contains the code needed to run Simulation 2 from "Precision Medicine Analysis of the Flexible Lifestyles Empowering Chnage (FLEX) Trial" by M. T. Lawson, A. R. Kahkoska, et al. (Submitted 2018) in a bash computing environment. Briefly, this paper was a precision medicine-based subgroup analysis of the FLEX trial, a clinical trial of a behavioral intervention in adolescent type 1 diabetes. The FLEX trial contained multiple outcomes of interest. The methodological advancement in this paper took the form of a composite outcome, which approximates constrained optimization over a set of multiple outcome variables by collapsing them into a single variable. Simulation 2 explores the properties of the precision medicine-based subgroup analysis in trial-like conditions (n=200, p=30, 2 outcome variables) where the true treatment effect for each univariate outcome can be known and specified.

To run Simulation 2, follow this procedure:
1) Update flex_sim2_input_matrix.sh, a bash script that generates a text file containing the specifications for each simulation to be run, to the local file structure, then run it.
2) Run flex_sim2.sh, a bash script that submits flex_sim2_rscript.R via Rscript for each set of parameter specifications in flex_sim2_input_matrix.sh's output file.
3) Once these jobs have completed, run flex_sim2_collect.sh, a bash script that submits flex_sim2_collect.R to collect the results of all simulations into a small set of .rda files, as well as generate a few human-readable tables based on them.

Other files needed for this simulation:
1) flex_sim2_rscript.R - concise file taking simulation specifications and directory locations, running simulation, and saving simulation output
2) flex_simulation_2.R - function to run the meat and potatoes of simulation 2; split off to flex_sim2_rscript to be concise
3) generate_sim_data_2.R - function to generate data for simulation 2
4) bivariate_to_composite.R - function to turn 2 bivariate outcomes into the single composite outcome
5) itr_rlt_01.R, itr_owl_fulldata.R - needed for underlying method
6) sim1s_true_diffs.R - needed to compute one summary of simulation performance
7) library_flex_sim_packages - function to library packages needed for underlying code



MODULE 2: 













All code is covered by the Community Research and Academic Programming License (included herein).
