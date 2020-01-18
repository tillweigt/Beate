push!(LOAD_PATH, joinpath(pwd(), "src"))
using FileIO, JLD2, Plots, Statistics, Beate, DataFrames

AlgorithmType = "IbisDataTempering"

ModelChoice = "RealData"

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

include(joinpath(pwd(), "Data", "get_Data.jl"))
Data = get_Data(
	[:DividendYield], # RegressorName
	Symbol(ModelChoice), pwd(),
	1, # NumberOfTarget
	# 100, # NumberOfDataPoint
	# Model, Prior,
	# [1.0, 0.0, 0.0],
	# # [0.1, 0.9, 0.05], # Parameter for exogenuous Regressor Simulation
	# get_Parameter_for_simulation(Symbol(ModelChoice))..., # Parameter and TransitionProbabilityMatrix
)
plot(Data.Target')

plot(Output[1].Data.Target')
plot!(Output[1].Data.Regressor' .+ 4.0)

plot(Output[3].Parameter[1, 1, 5000:end])

histogram(Output[3].Parameter[3, 1, 10000:end], nbins = 30)

plot(Output[4].ParameterFullCovariance[1, 1, 30000:end])


histogram(Output[3].Parameter[4, :, end])

mean(Output[3].TransitionProbabilityMatrix[:, :, :, end], dims = 3)

plot(dropdims(mean(Output[3].TransitionProbabilityMatrix[:, 2, :, 100:end], dims = 2), dims = 2)')

plot(Output[4].ParameterFullCovariance[3, 3, 20:end])

plot(Data.Target[1, :])
plot!(mean(Output[3].Prediction[1, :, :], dims = 1)')

plot(Data.State[1, :])
plot!(mean(Output[3].State[1, :, :], dims = 1)')


plot(
	mean(
		Output[3].Parameter[1, :, :], dims = 2
	)
)


plot(Output[4].EffectiveSampleSizeParameterParticle)

plot(Output[4].AcceptanceRatio)
