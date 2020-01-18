Path = pwd()
push!(LOAD_PATH, joinpath(Path, "src"))
using FileIO, JLD2, Plots, Statistics, Beate, DataFrames

AlgorithmType = "IbisDataTempering"

ModelChoice = "RealData"

NumberOfParameterParticle = 500

NumberOfStateParticle = 128

NumberOfMcmcStep = 1

NumberOfDensityPoint = 1

ComputationLoopNumber = 1

File = joinpath(
	Path,
	"Output",
	"Computation",
	AlgorithmType,
	ModelChoice
)

File2 = joinpath(
	File,
	"PP_" * string(NumberOfParameterParticle) *
	"_SP_" * string(NumberOfStateParticle) *
	"_MS_" * string(NumberOfMcmcStep) *
	"_DP_" * string(NumberOfDensityPoint) *
	"_CLN_" * string(ComputationLoopNumber) *
	".jld2"
)

Output = load(
	File2,
	"Setting",
	"Computation",
	"ComputationOverTempering",
	"AlgorithmComputation"
)

save(
	joinpath(
		File,
		"temp.jld2"
	),
	"temp",
	Output[3].State
)
