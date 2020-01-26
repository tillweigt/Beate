Path = pwd()
push!(LOAD_PATH, joinpath(Path, "src"))
using FileIO, JLD2, Beate, DataFrames, Plots, Statistics, Distributions

AlgorithmType = "IbisDataTempering"

ModelChoice = "WellLog"

NumberOfParameterParticle = 1000

NumberOfStateParticle = 128

NumberOfMcmcStep = 1

NumberOfDensityPoint = 1

ComputationLoopNumber = 1

NumberOfDataPoint = 99

File = joinpath(
	Path,
	"Output",
	"Computation",
	AlgorithmType,
	ModelChoice
)

File2 = joinpath(
	File,
	"PP_" * string(NumberOfParameterParticle) *
	"_SP_" * string(NumberOfStateParticle) *
	"_MS_" * string(NumberOfMcmcStep) *
	"_DP_" * string(NumberOfDensityPoint)
)

Setting1 = load(
	File2 *
	"_CLN_" * string(1) *
	".jld2",
	"Setting"
)

ComputationOverTempering1 = load(
	File2 *
	"_CLN_" * string(1) *
	".jld2",
	"ComputationOverTempering"
)

Setting2 = load(
	File2 *
	"_CLN_" * string(1) *
	".jld2",
	"Setting"
)

ComputationOverTempering2 = load(
	File2 *
	"_CLN_" * string(1) *
	".jld2",
	"ComputationOverTempering"
)

histogram(rand(Setting.Prior.Parameter[1], NumberOfParameterParticle))
vline!([0.1], linewidth = 5)
histogram(rand(Setting.Prior.Parameter[2], NumberOfParameterParticle))
vline!([0.0], linewidth = 5)
histogram(rand(Setting.Prior.Parameter[3], NumberOfParameterParticle))
vline!([1.0], linewidth = 5)

histogram(ComputationOverTempering1.Parameter[1, :, end])
vline!([0.1], linewidth = 5)
histogram(ComputationOverTempering.Parameter[2, :, end])
vline!([0.0], linewidth = 5)
histogram(ComputationOverTempering.Parameter[3, :, end])
vline!([1.0], linewidth = 5)

IndexParameter = 3

FilteredMean = mean(ComputationOverTempering.Parameter[IndexParameter, :, :], dims = 1)[1, :]
FilteredQuantileUpper = map(x -> quantile(x, 0.99), [ComputationOverTempering.Parameter[IndexParameter, :, i] for i in 1:NumberOfDataPoint])
FilteredQuantileLower = map(x -> quantile(x, 0.01), [ComputationOverTempering.Parameter[IndexParameter, :, i] for i in 1:NumberOfDataPoint])

plot(FilteredMean, legend = false)
plot!(FilteredQuantileUpper)
plot!(FilteredQuantileLower)

IndexCol1 = 1
IndexCol2 = 2

FilteredMean = mean(ComputationOverTempering.TransitionProbabilityMatrix[IndexCol1, IndexCol2, :, :], dims = 1)[1, :]
FilteredQuantileUpper = map(x -> quantile(x, 0.99), [ComputationOverTempering.TransitionProbabilityMatrix[IndexCol1, IndexCol2, :, i] for i in 1:NumberOfDataPoint])
FilteredQuantileLower = map(x -> quantile(x, 0.01), [ComputationOverTempering.TransitionProbabilityMatrix[IndexCol1, IndexCol2, :, i] for i in 1:NumberOfDataPoint])

histogram(ComputationOverTempering.TransitionProbabilityMatrix[IndexCol1, IndexCol2, :, end])

plot(FilteredMean, legend = false)
plot!(FilteredQuantileUpper)
plot!(FilteredQuantileLower)

FilteredMean = mean(ComputationOverTempering.State[1, :, :], dims = 1)[1, :]
FilteredQuantileUpper = map(x -> quantile(x, 0.99), [ComputationOverTempering.State[1, :, i] for i in 1:NumberOfDataPoint])
FilteredQuantileLower = map(x -> quantile(x, 0.01), [ComputationOverTempering.State[1, :, i] for i in 1:NumberOfDataPoint])

plot(Setting.Data.State[1, :])
plot!(FilteredMean, legend = false)
plot!(FilteredQuantileUpper)
plot!(FilteredQuantileLower)

FilteredMean = mean(ComputationOverTempering.Prediction[1, :, :], dims = 1)[1, :]
FilteredQuantileUpper = map(x -> quantile(x, 0.99), [ComputationOverTempering.Prediction[1, :, i] for i in 1:NumberOfDataPoint])
FilteredQuantileLower = map(x -> quantile(x, 0.01), [ComputationOverTempering.Prediction[1, :, i] for i in 1:NumberOfDataPoint])

plot(Setting.Data.Target[1, :])
plot!(FilteredMean, legend = false)
plot!(FilteredQuantileUpper)
plot!(FilteredQuantileLower)

# plot(AlgorithmComputation.AcceptanceRatio)

# plot(AlgorithmComputation.EffectiveSampleSizeParameterParticle)
