#!/bin/bash

# set the number of nodes
#SBATCH --nodes=1

# set the number of CPU cores per node
#SBATCH --ntasks-per-node 2

# How much memory is needed (per node). Possible units: K, G, M, T
#SBATCH --mem=50G

# set a partition
#SBATCH --partition express

# set max wallclock time
#SBATCH --time=0-00:10:00

# set name of job
#SBATCH --job-name=test
# mail alert at start, end and abortion of execution
#SBATCH --mail-type=ALL

# set an output file
#SBATCH --output Output/Console/%x_%A

# send mail to this address
#SBATCH --mail-user=till.weigt@gmail.com

# run the application
../julia-1.1.0/bin/julia \
Hpc/temp.jl \
Parallel \
WellLog \
128 \
1 \
50 \
1 \
false \
true \
500 \
1000 \
0.001 \
1.1 \
10 \
true