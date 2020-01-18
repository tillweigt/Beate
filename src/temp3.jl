Path = pwd()
push!(LOAD_PATH, joinpath(Path, "src"))
using FileIO, JLD2, Beate, DataFrames, Plots

AlgorithmType = "IbisDataTempering"

ModelChoice = "RealData"

File = joinpath(
	pwd(),
	"Output",
	"Computation",
	AlgorithmType,
	ModelChoice
)

File2 = joinpath(
	File,
	"temp" *
	".jld2"
)

Output = load(
	File2,
	"State",
	"Prediction",
	"TransitionProbability",
	"Parameter"
)

plot(mean(Output[1][3, :, :], dims = 1)')

plot!(mean(Output[2][1, :, :], dims = 1)')

plot(mean(Output[4][3, :, :], dims = 1)')

plot(mean(Output[3][2, 2, :, :], dims = 1)')
