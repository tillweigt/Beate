using FileIO, JLD2, Plots

AlgorithmType = "Mcmc"

ModelChoice = "WellLog"

NumberOfParameterParticle = 1

NumberOfStateParticle = 128

NumberOfMcmcStep = 20000

NumberOfDensityPoint = 1

ComputationLoopNumber = 8

File = joinpath(
	pwd(),
	"Output",
	"Computation",
	AlgorithmType,
	ModelChoice
)

Output = load(
	joinpath(
		File,
		"PP_" * string(NumberOfParameterParticle) *
		"_SP_" * string(NumberOfStateParticle) *
		"_MS_" * string(NumberOfMcmcStep) *
		"_DP_" * string(NumberOfDensityPoint) *
		"_CLN_" * string(ComputationLoopNumber) *
		".jld2"
	),
	"Setting",
	"Computation",
	"ComputationOverTempering",
	"AlgorithmComputation"
)

plot(Output[3].Parameter[3, 1, 1:20000])

# histogram(Output[3].Parameter[1, :, end])

plot(Output[1].Data.Target[1, :])
