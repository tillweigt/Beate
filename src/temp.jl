using FileIO, JLD2, Plots

AlgorithmType = "IbisDataTempering"

ModelChoice = "WellLog"

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

plot(Output[3].Parameter[1, 1, 20000:end])

histogram(Output[3].Parameter[3, 1, 10000:end], nbins = 30)

plot(Output[4].ParameterFullCovariance[1, 1, 30000:end])


histogram(Output[3].Parameter[3, :, end])

plot(Output[4].ParameterFullCovariance[3, 3, 20:end])


plot(Output[4].EffectiveSampleSizeParameterParticle)

plot(Output[4].AcceptanceRatio)
