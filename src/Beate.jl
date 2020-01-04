module Beate

using Distributions

using Parameters: @with_kw
using SharedArrays: SharedArray
using Distributed: @distributed
using StatsBase: weights, sample
using Statistics: mean, cov
using LinearAlgebra: Diagonal, I, diag
using FileIO: load, save
using Dates: format, now

import Distributions: rand

export

# Models
Invariant,
NoFilterStruct,
KalmanFilterStruct,
DiscreteParticleFilterStruct,
PriorStruct,

# get_Data.jl
make_NumberOfLatent,
make_PriorIndex,
DataStruct,

# main.jl
InputSettingStruct,
run_Algorithm

# Input
include("DistributionsExtentsions.jl")
include("InputStructs.jl")
include("initialize.jl")

# Algorithm
include("Filter.jl")
include("Mcmc.jl")
include("IbisDataTempering.jl")
include("IbisDensityTempering.jl")

# Filter
include("NoFilter!.jl")
include("KalmanFilter!.jl")
include("DiscreteParticleFilter!.jl")

# AlgorithmFunction
include("filter_State!.jl")
include("move_Computation!.jl")
include("ResampleSchemes.jl")
include("AlgorithmUtilities.jl")

# General
include("GeneralUtilities.jl")

end
