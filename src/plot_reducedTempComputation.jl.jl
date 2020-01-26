Path = pwd()
push!(LOAD_PATH, joinpath(Path, "src"))
using FileIO, JLD2, Beate, DataFrames, Plots, Statistics

include(joinpath(Path, "Data", "get_Data.jl"))

AlgorithmType = "IbisDataTempering"

ModelChoice = "WellLog"

NumberOfDataPoint = 0

Simulation = false

DataStart = 1

DataEnd = 1000

Model = missing

Prior = missing

File = joinpath(
	Path,
	"Output",
	"Computation",
	AlgorithmType,
	ModelChoice,
	"temp.jld2"
)

State,
Prediction,
TransitionProbablityMatrix,
Parameter =
ComputationOverTempering = load(
	File,
	"State",
	"Prediction",
	"TransitionProbability",
	"Parameter"
)

Data = get_Data(
	[:DividendYield], # RegressorName
	Symbol(ModelChoice), Path,
	1, # NumberOfTarget
	NumberOfDataPoint, # NumberOfDataPoint
	Model, Prior,
	[0.1, 0.9, 0.05], # Parameter for exogenuous Regressor Simulation
	Simulation,
	DataStart,
	DataEnd
)

histogram(Parameter[1, :, end])

plot(sqrt.(exp.(Data.Target[1, :])))
plot!(sqrt.(exp.(mean(Prediction[1, :, :], dims = 1)[1, :])))

plot(Data.Target[1, 30:end])
vline!(0:5:size(Data.Target, 2))
hline!(0.4:0.01:0.6)

plot!(mean(State[1, :, 1:end], dims = 1)[1, :])

plot(mean(State[3, :, :], dims = 1)[1, :])

plot(mean(TransitionProbablityMatrix[1, 1, :, :], dims = 1)[1, :])

plot!(mean(Output[3].State[1, :, :], dims = 1)[1, :])

plot(mean(Output[3].State[3, :, :], dims = 1)[1, :])
