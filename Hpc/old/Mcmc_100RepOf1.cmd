#!/bin/bash

# set the number of nodes
#SBATCH --nodes=1

# set the number of CPU cores per node
#SBATCH --ntasks-per-node 72

# How much memory is needed (per node). Possible units: K, G, M, T
#SBATCH --mem=50G

# set a partition
#SBATCH --partition d0ow

# set max wallclock time
#SBATCH --time=2-00:00:00

# set name of job
#SBATCH --job-name=Mcmc_100RepOf1
# mail alert at start, end and abortion of execution
#SBATCH --mail-type=ALL

# set an output file
#SBATCH --output Output/Console/%x_%A

# send mail to this address
#SBATCH --mail-user=till.weigt@gmail.com

# run the application
../julia-1.1.0/bin/julia \
src/main.jl \
NParallel \
WellLog \
128 `#NumberOfStateParticle` \
30000 `#NumberOfMcmcStep` \
1 `#NumberOfParameterParticle` \
1 `#PrintEach` \
false `#CovarianceScaling` \
true `#McmcFullCovariance` \
500 `#McmcUpdateIntevalLength` \
1000 `#McmcLstUpdateIndex` \
[0.001, 0.001, 0.001] `#McmcVarianceInitialisation` \
1.1 `#ResampleThresholdIbis` \
1 `#NumberOfDensityPoint` \
true `#SaveOutput` \
Mcmc `#AlgorithmType` \
1 `#ComputationLoopNumber`