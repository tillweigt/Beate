using Distributed

iszero(length(ARGS)) ? ComputationOnCluster = false : ComputationOnCluster = true

if !ComputationOnCluster

	Args = fill("", 20)

	Args[1] = "NParallel"
	Args[2] = "WellLog"
	Args[3] = "128" # NumberOfStateParticle = 128,
	Args[4] = "1" # NumberOfMcmcStep = 1,
	Args[5] = "300" # NumberOfParameterParticle = 50,
	Args[6] = "1" # PrintEach = 1,
	Args[7] = "false" # CovarianceScaling = false,
	Args[8] = "true" # McmcFullCovariance = true,
	Args[9] = "500" # McmcUpdateIntervalLength = 500,
	Args[10] = "1000" # McmcLastUpdateIndex = 1000,
	Args[11] = "0.001" # McmcVarianceInitialisation = 0.001,
	Args[12] = "1.1" # ResampleThresholdIbis = 1.1,
	Args[13] = "1" # NumberOfDensityPoint = 10,
	Args[14] = "false" # SaveOutput = true
	Args[15] = "IbisDataTempering"
	Args[16] = "1"

else

	Args = ARGS

end

Args[1] == "Parallel" ? addprocs() : nothing

# @sync @everywhere Path = joinpath("C:\\", "GoogleDrive", "Forschung", "Software", "Beate")
@sync @everywhere Path = pwd()
@sync @everywhere push!(LOAD_PATH, joinpath(Path, "src"))
@sync @everywhere using Beate

@sync @everywhere using FileIO, DataFrames, StatsBase, Distributions

ModelChoice = Args[2]

include(joinpath(Path, "Data", "get_Data.jl"))
include(joinpath(Path, "Models", ModelChoice * ".jl"))
include(joinpath(Path, "Models", "get_Parameter_for_simulation.jl"))

Model = getfield(Main, Symbol(ModelChoice))

Prior = getfield(Main, Symbol(ModelChoice * "Prior"))

Data = get_Data(
	# [:BookToMarketRatio], # RegressorName
	Symbol(ModelChoice), Path,
	1, # NumberOfTarget
	100, # NumberOfDataPoint
	Model, Prior,
	[1.0, 0.0, 0.0], # Parameter for exogenuous Regressor Simulation
	get_Parameter_for_simulation(Symbol(ModelChoice))..., # Parameter and TransitionProbabilityMatrix
)

# using Plots
# plot(Data.Target')

for preRun in 1:5

	run_Algorithm(
		Model,
		Prior,
		Data,
		InputSettingStruct(
			NumberOfStateParticle = parse(Int64, Args[3]),
			NumberOfMcmcStep = 1,
			NumberOfParameterParticle = 1,
			PrintEach = 0,
			CovarianceScaling = false,
			McmcFullCovariance = false,
			McmcUpdateIntervalLength = parse(Int64, Args[9]),
			McmcLastUpdateIndex = parse(Int64, Args[10]),
			McmcVarianceInitialisation = parse(Float64, Args[11]),
			ResampleThresholdIbis = parse(Float64, Args[12]),
			NumberOfDensityPoint = 1,
			Path = Path,
			SaveOutput = false,
			ModelChoice = ModelChoice,
			AlgorithmType = "Filter"
		),
		:Filter # AlgorithmType
	)

end

computationLoopNumber = 1
for computationLoopNumber in 1:parse(Int64, Args[16])

	Output = run_Algorithm(
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
			SaveOutput = parse(Bool, Args[14]),
			ModelChoice = ModelChoice,
			AlgorithmType = Args[15],
			ComputationLoopNumber = computationLoopNumber,
			ComputationOnCluster = ComputationOnCluster
		),
		Symbol(Args[15]) # AlgorithmType
	)

end
