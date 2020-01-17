push!(LOAD_PATH, joinpath(pwd(), "src"))
using FileIO, JLD2, Plots, Statistics, Beate

AlgorithmType = "IbisDataTempering"

ModelChoice = "RealDataMixture"

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


plot(Output[1].Data.Target')

plot(Output[3].Parameter[1, 1, 5000:end])

histogram(Output[3].Parameter[3, 1, 10000:end], nbins = 30)

plot(Output[4].ParameterFullCovariance[1, 1, 30000:end])


histogram(Output[3].Parameter[5, :, end])

mean(Output[3].TransitionProbabilityMatrix[:, :, :, end], dims = 3)

plot(dropdims(mean(Output[3].TransitionProbabilityMatrix[:, 2, :, 100:end], dims = 2), dims = 2)')

plot(Output[4].ParameterFullCovariance[3, 3, 20:end])

plot(Data.Target[1, :])
plot!(mean(Output[3].Prediction[1, :, :], dims = 1)')

plot(Data.State[1, :])
plot(mean(Output[3].State[2, :, :], dims = 1)')


plot(
	mean(
		Output[3].Parameter[1, :, :], dims = 2
	)
)


plot(Output[4].EffectiveSampleSizeParameterParticle)

plot(Output[4].AcceptanceRatio)
