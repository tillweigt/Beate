using FileIO, JLD2, Plots

AlgorithmType = "Mcmc"

ModelChoice = "WellLog"

NumberOfParameterParticle = 1

NumberOfStateParticle = 128

NumberOfMcmcStep = 20000

NumberOfDensityPoint = 1

ComputationLoopNumber = 1

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

plot(Output[4].AcceptanceRatio)

histogram(Output[3].Parameter[3, :, end], bins = 10)

histogram(Output[3].Parameter[1, 1, 10000:end], nbins = 50)
