using Distributed

# addprocs()

# @sync @everywhere Path = joinpath("C:\\", "GoogleDrive", "Forschung", "Software", "Beate")
@sync @everywhere Path = pwd()
@sync @everywhere push!(LOAD_PATH, joinpath(Path, "src"))
@sync @everywhere using Beate

@sync @everywhere using FileIO, DataFrames, StatsBase, Distributions

@sync @everywhere ModelChoice = :WellLog

include(joinpath(Path, "Data", "get_Data.jl"))
include(joinpath(Path, "Models", string(ModelChoice) * ".jl"))
include(joinpath(Path, "Models", "get_Parameter_for_simulation.jl"))

# Model = getfield(Main, ModelChoice)

# Prior = getfield(Main, Symbol(string(ModelChoice) * "Prior"))

# Data = get_Data(
# 	# [:BookToMarketRatio], # RegressorName
# 	ModelChoice, Path,
# 	1, # NumberOfTarget
# 	100, # NumberOfDataPoint
# 	Model, Prior,
# 	[1.0, 0.0, 0.0], # Parameter for exogenuous Regressor Simulation
# 	get_Parameter_for_simulation(ModelChoice)..., # Parameter and TransitionProbabilityMatrix
# )

Output =
run_Algorithm(
	# Model,
	getfield(Main, ModelChoice)
	# Prior,
	getfield(Main, Symbol(string(ModelChoice) * "Prior"))
	# Data,
	get_Data(
		# [:BookToMarketRatio], # RegressorName
		ModelChoice, Path,
		1, # NumberOfTarget
		100, # NumberOfDataPoint
		Model, Prior,
		[1.0, 0.0, 0.0], # Parameter for exogenuous Regressor Simulation
		get_Parameter_for_simulation(ModelChoice)..., # Parameter and TransitionProbabilityMatrix
	),
	InputSettingStruct(
		NumberOfStateParticle = 128,
		NumberOfMcmcStep = 1,
		NumberOfParameterParticle = 1000,
		PrintEach = 1,
		CovarianceScaling = false,
		McmcFullCovariance = true,
		McmcUpdateIntervalLength = 500,
		McmcLastUpdateIndex = 1000,
		McmcVarianceInitialisation = 0.001,
		ResampleThresholdIbis = 1.1,
		NumberOfDensityPoint = 10
	),
	:IbisDataTempering
)

# using Plots

# histogram(Output[3].Parameter[1, :, end])

# plot(Data.Target')

# plot!(Output[3].Prediction[1, 1, :])

# scatter(Output[3].TransitionProbabilityMatrix[1, 1, 1, :])

# scatter!(Output[3].TransitionProbabilityMatrix[1, 2, 1, :])

# histogram(Output[3].Parameter[1, 1, 8000:end])
