#!/bin/bash

# set the number of nodes
#SBATCH --nodes=1

# set the number of CPU cores per node
#SBATCH --ntasks-per-node 72

# How much memory is needed (per node). Possible units: K, G, M, T
#SBATCH --mem=150G

# set a partition
#SBATCH --partition normal

# set max wallclock time
#SBATCH --time=7-00:00:00

# set name of job
#SBATCH --job-name=IbisDataSim_100Of100
# mail alert at start, end and abortion of execution
#SBATCH --mail-type=ALL

# set an output file
#SBATCH --output Output/Console/%x_%A

# send mail to this address
#SBATCH --mail-user=till.weigt@gmail.com

# run the application
../julia-1.1.0/bin/julia \
src/main.jl \
Parallel \
WellLog \
128 `#NumberOfStateParticle` \
1 `#NumberOfMcmcStep` \
1000 `#NumberOfParameterParticle` \
1 `#PrintEach` \
false `#CovarianceScaling` \
true `#McmcFullCovariance` \
1 `#McmcUpdateIntevalLength` \
1 `#McmcLastUpdateIndex` \
"fill(0.01,10)" `#McmcVarianceInitialisation` \
1.1 `#ResampleThresholdIbis` \
1 `#NumberOfDensityPoint` \
true `#SaveOutput` \
IbisDataTempering `#AlgorithmType` \
50 `#ComputationLoopNumber` \
1 `#DataStart` \
500 `#DataEnd` \
501 `#NumberOfDataPoint` \
true `#Simulation`