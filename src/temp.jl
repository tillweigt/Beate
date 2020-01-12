using FileIO, JLD2, Plots

AlgorithmType = "IbisDensityTempering"

ModelChoice = "WellLog"

NumberOfParameterParticle = 1000

NumberOfStateParticle = 128

NumberOfMcmcStep = 1

NumberOfDensityPoint = 100

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

# plot(Output[3].Parameter[3, 1, 15000:20000])

histogram(Output[3].Parameter[1, :, end])
