push!(LOAD_PATH, joinpath(pwd(), "src"))
using FileIO, JLD2, Plots, Statistics, Beate, DataFrames

AlgorithmType = "IbisDataTempering"

ModelChoice = "WellLog"

NumberOfParameterParticle = 1000

NumberOfStateParticle = 128

NumberOfMcmcStep = 1

NumberOfDensityPoint = 1

ComputationLoopNumber = 1

NumberOfDataPoint = 99

File = joinpath(
	pwd(),
	"Output",
	"Computation",
	AlgorithmType,
	ModelChoice
)

Setting,
ComputationOverTempering,
AlgorithmComputation = load(
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
	# "Computation",
	"ComputationOverTempering",
	"AlgorithmComputation"
)

StateMean = mean(ComputationOverTempering.State, dims = 2)[1, 1, :]

StateUpper = map(
	x -> quantile(x, 0.99),
	[ComputationOverTempering.State[1, :, i] for i in 1:99]
)

StateLower = map(
	x -> quantile(x, 0.01),
	[ComputationOverTempering.State[1, :, i] for i in 1:99]
)

MixtureStateMean = mean(ComputationOverTempering.State, dims = 2)[3, 1, :]

MixtureStateUpper = map(
	x -> quantile(x, 0.99),
	[ComputationOverTempering.State[3, :, i] for i in 1:99]
)

MixtureStateLower = map(
	x -> quantile(x, 0.01),
	[ComputationOverTempering.State[3, :, i] for i in 1:99]
)

TransitionProbability11End = ComputationOverTempering.TransitionProbabilityMatrix[1, 1, :, end]

TransitionProbability12End = ComputationOverTempering.TransitionProbabilityMatrix[1, 2, :, end]

TransitionProbability11Mean = mean(ComputationOverTempering.TransitionProbabilityMatrix[1, 1, :, :], dims = 1)[1, :]

TransitionProbability12Mean = mean(ComputationOverTempering.TransitionProbabilityMatrix[1, 2, :, :], dims = 1)[1, :]

TransitionProbability11Upper = map(
	x -> quantile(x, 0.99),
	[ComputationOverTempering.TransitionProbabilityMatrix[1, 1, :, i] for i in 1:99]
)

TransitionProbability12Upper = map(
	x -> quantile(x, 0.99),
	[ComputationOverTempering.TransitionProbabilityMatrix[1, 2, :, i] for i in 1:99]
)

TransitionProbability11Lower = map(
	x -> quantile(x, 0.01),
	[ComputationOverTempering.TransitionProbabilityMatrix[1, 1, :, i] for i in 1:99]
)

TransitionProbability12Lower = map(
	x -> quantile(x, 0.01),
	[ComputationOverTempering.TransitionProbabilityMatrix[1, 2, :, i] for i in 1:99]
)

save(
	joinpath(
		"C:\\GoogleDrive",
		"Forschung",
		"Paper3",
		"Paper",
		"data",
		"WellLogIbisData1RealizationOverTime" *
		".csv"
	),
	DataFrame(
		StateMean = StateMean,
		StateUpper = StateUpper,
		StateLower = StateLower,
		MixtureMean = MixtureStateMean,
		MixtureLower = MixtureStateLower,
		MixtureUpper = MixtureStateUpper,
		TransitionProbability11Mean = TransitionProbability11Mean,
		TransitionProbability12Mean = TransitionProbability12Mean,
		TransitionProbability11Upper = TransitionProbability11Upper,
		TransitionProbability12Upper = TransitionProbability12Upper,
		TransitionProbability11Lower = TransitionProbability11Lower,
		TransitionProbability12Lower = TransitionProbability12Lower,
		SimulatedState = Setting.Data.State[1, :],
		SimulatdMixture = Setting.Data.State[3, :],
		Target = Setting.Data.Target[1, :]
	)
)

save(
	joinpath(
		"C:\\GoogleDrive",
		"Forschung",
		"Paper3",
		"Paper",
		"data",
		"WellLogIbisData1RealizationEnd" *
		".csv"
	),
	DataFrame(
		TransitionProbability11End = TransitionProbability11End,
		TransitionProbability12End = TransitionProbability12End
	)
)
