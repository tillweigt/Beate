#!/bin/bash

# set the number of nodes
#SBATCH --nodes=1

# set the number of CPU cores per node
#SBATCH --ntasks-per-node 72

# How much memory is needed (per node). Possible units: K, G, M, T
#SBATCH --mem=50G

# set a partition
#SBATCH --partition express

# set max wallclock time
#SBATCH --time=0-02:00:00

# set name of job
#SBATCH --job-name=IbisDensity_100RepOf1
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
1 `#NumberOfMcmcStep` \
500 `#NumberOfParameterParticle` \
1 `#PrintEach` \
false `#CovarianceScaling` \
true `#McmcFullCovariance` \
1 `#McmcUpdateIntevalLength` \
1 `#McmcLstUpdateIndex` \
1.0 `#McmcVarianceInitialisation` \
1.1 `#ResampleThresholdIbis` \
50 `#NumberOfDensityPoint` \
true `#SaveOutput` \
IbisDensityTempering `#AlgorithmType` \
1 `#ComputationLoopNumber`