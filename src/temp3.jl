Path = pwd()
push!(LOAD_PATH, joinpath(Path, "src"))
using FileIO, JLD2, Beate, DataFrames, Plots

AlgorithmType = "IbisDataTempering"

ModelChoice = "RealDataZero"

NumberOfParameterParticle = 500

NumberOfStateParticle = 128

NumberOfMcmcStep = 1

NumberOfDensityPoint = 1

ComputationLoopNumber = 1

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
	# "Setting",
	# "Computation",
	"temp"#,
	# "AlgorithmComputation"
)

plot(mean(Output[1, :, :], dims = 1)')
