Path = pwd()
push!(LOAD_PATH, joinpath(Path, "src"))
using FileIO, JLD2, Beate, DataFrames, Plots, Statistics

AlgorithmType = "IbisDataTempering"

ModelChoice = "WellLog"

NumberOfParameterParticle = 1000

NumberOfStateParticle = 128

NumberOfMcmcStep = 1

NumberOfDensityPoint = 1

ComputationLoopNumber = 1

File1 = joinpath(
	Path,
	"Output",
	"Computation",
	AlgorithmType,
	ModelChoice,
	"temp" *
	".jld2"
)

File2 = joinpath(
	Path,
	"Data",
	"WellLog" *
	".jld2"
)

Data = load(
	File2,
	"WellLog"
)

State,
Prediction,
TransitionProbabilityMatrix,
Parameter = load(
	File1,
	"State",
	"Prediction",
	"TransitionProbability",
	"Parameter",
)

histogram(Parameter[3, :, end])

histogram(TransitionProbabilityMatrix[2, 2, :, end])

plot(Data.Target[1, :])
plot!(mean(Prediction[1, :, :], dims = 1)')

plot(Data.State[1, :])
plot!(mean(State[1, :, :], dims = 1)')
