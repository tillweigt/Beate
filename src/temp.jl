Path = pwd()
push!(LOAD_PATH, joinpath(Path, "src"))
using FileIO, JLD2, Beate, DataFrames, Plots, Statistics, Distributions

AlgorithmType = "IbisDataTempering"

ModelChoice = "WellLogManyOf1"

NumberOfDataPoint = 100

File = joinpath(
	Path,
	"Output",
	"Computation",
	AlgorithmType,
	ModelChoice,
	"JoinedAndReduced.jld2"
)

Parameter, State, TransitionProbabilityMatrix = load(
	File,
	"Parameter",
	"State",
	"TransitionProbabilityMatrix"
)

histogram(rand(Setting.Prior.Parameter[1], NumberOfParameterParticle))
vline!([0.1], linewidth = 5)
histogram(rand(Setting.Prior.Parameter[2], NumberOfParameterParticle))
vline!([0.0], linewidth = 5)
histogram(rand(Setting.Prior.Parameter[3], NumberOfParameterParticle))
vline!([1.0], linewidth = 5)

histogram(ComputationOverTempering.Parameter[1, :, end])
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
