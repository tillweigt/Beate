using Distributed

if !iszero(length(ARGS))

	ARGS[1] == "Parallel" ? addprocs() : nothing

end

if iszero(length(ARGS))

	@sync @everywhere Args = fill("", 20)

	Args[2] = "WellLog"
	Args[3] = "128" # NumberOfStateParticle = 128,
	Args[4] = "1" # NumberOfMcmcStep = 1,
	Args[5] = "50" # NumberOfParameterParticle = 50,
	Args[6] = "1" # PrintEach = 1,
	Args[7] = "false" # CovarianceScaling = false,
	Args[8] = "true" # McmcFullCovariance = true,
	Args[9] = "500" # McmcUpdateIntervalLength = 500,
	Args[10] = "1000" # McmcLastUpdateIndex = 1000,
	Args[11] = "0.001" # McmcVarianceInitialisation = 0.001,
	Args[12] = "1.1" # ResampleThresholdIbis = 1.1,
	Args[13] = "10" # NumberOfDensityPoint = 10,
	Args[14] = "true" # SaveOutput = true
else

	@sync @everywhere Args = ARGS

end

println(Args)

# @sync @everywhere Path = joinpath("C:\\", "GoogleDrive", "Forschung", "Software", "Beate")
@sync @everywhere Path = pwd()
@sync @everywhere push!(LOAD_PATH, joinpath(Path, "src"))
@sync @everywhere using Beate

@sync @everywhere using FileIO, DataFrames, StatsBase, Distributions

@sync @everywhere ModelChoice = Symbol(Args[2])

include(joinpath(Path, "Data", "get_Data.jl"))
include(joinpath(Path, "Models", string(ModelChoice) * ".jl"))
include(joinpath(Path, "Models", "get_Parameter_for_simulation.jl"))

Model = getfield(Main, ModelChoice)

Prior = getfield(Main, Symbol(string(ModelChoice) * "Prior"))

Data = get_Data(
	# [:BookToMarketRatio], # RegressorName
	ModelChoice, Path#,
	# 1, # NumberOfTarget
	# 100, # NumberOfDataPoint
	# Model, Prior,
	# [1.0, 0.0, 0.0], # Parameter for exogenuous Regressor Simulation
	# get_Parameter_for_simulation(ModelChoice)..., # Parameter and TransitionProbabilityMatrix
)

Output =
run_Algorithm(
	Model,
	Prior,
	Data,
	InputSettingStruct(
		NumberOfStateParticle = parse(Int64, Args[3]),
		NumberOfMcmcStep = parse(Int64, Args[4]),
		NumberOfParameterParticle = parse(Int64, Args[5]),
		PrintEach = parse(Int64, Args[6]),
		CovarianceScaling = parse(Bool, Args[7]),
		McmcFullCovariance = parse(Bool, Args[8]),
		McmcUpdateIntervalLength = parse(Int64, Args[9]),
		McmcLastUpdateIndex = parse(Int64, Args[10]),
		McmcVarianceInitialisation = parse(Float64, Args[11]),
		ResampleThresholdIbis = parse(Float64, Args[12]),
		NumberOfDensityPoint = parse(Int64, Args[13]),
		Path = Path,
		SaveOutput = parse(Bool, Args[14])
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
