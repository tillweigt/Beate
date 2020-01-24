Path = pwd()
push!(LOAD_PATH, joinpath(Path, "src"))
using FileIO, JLD2, Beate, DataFrames, Plots

AlgorithmType = "IbisDataTempering"

ModelChoice = "WellLog"

NumberOfParameterParticle = 1000

NumberOfStateParticle = 128

NumberOfMcmcStep = 1

NumberOfDensityPoint = 1

ComputationLoopNumber = 1

File = joinpath(
	Path,
	"Output",
	"Computation",
	AlgorithmType,
	ModelChoice,
	"temp" *
	".jld2"
)

State,
Prediction,
TransitionProbabilityMatrix,
Parameter = load(
	File,
	"State",
	"Prediction",
	"TransitionProbability",
	"Parameter",
)

histogram(Parameter[3, :, end])

histogram(TransitionProbabilityMatrix[2, 2, :, end])
