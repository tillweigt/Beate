using Distributed

iszero(length(ARGS)) ? ComputationOnCluster = false : ComputationOnCluster = true

if !ComputationOnCluster

	Args = fill("", 20)

	Args[1] = "NParallel"
	Args[2] = "JumpVol" # ModelChoice
	Args[3] = "128" # NumberOfStateParticle = 128,
	Args[4] = "1" # NumberOfMcmcStep = 1,
	Args[5] = "1000" # NumberOfParameterParticle = 50,
	Args[6] = "1" # PrintEach = 1,
	Args[7] = "false" # CovarianceScaling = false,
	Args[8] = "true" # McmcFullCovariance = true,
	Args[9] = "1000" # McmcUpdateIntervalLength = 500,
	Args[10] = "3000" # McmcLastUpdateIndex = 1000,
	Args[11] = "fill(0.01, 10)" # McmcVarianceInitialisation = 0.001,
	Args[12] = "1.1" # ResampleThresholdIbis = 1.1,
	Args[13] = "1" # NumberOfDensityPoint = 10,
	Args[14] = "true" # SaveOutput = true
	Args[15] = "IbisDataTempering" # AlgotirhmType
	Args[16] = "1" # ComputationLoopNumber
	Args[17] = "1000" # DataStart
	Args[18] = "1091" # DataEnd
	Args[19] = "0" # NumberOfDataPoint
	Args[20] = "false"

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

for preRun in 1:5

	run_Algorithm(
		Model,
		Prior,
		get_Data(
			[:DividendYield], # RegressorName
			Symbol(ModelChoice), Path,
			1, # NumberOfTarget
			parse(Int64, Args[19]), # NumberOfDataPoint
			Model, Prior,
			[0.1, 0.9, 0.05], # Parameter for exogenuous Regressor Simulation
			parse(Bool, Args[20]),
			parse(Int64, Args[17]),
			parse(Int64, Args[18])
		),
		InputSettingStruct(
			NumberOfStateParticle = parse(Int64, Args[3]),
			NumberOfMcmcStep = 1,
			NumberOfParameterParticle = 1,
			PrintEach = 0,
			CovarianceScaling = false,
			McmcFullCovariance = false,
			McmcUpdateIntervalLength = parse(Int64, Args[9]),
			McmcLastUpdateIndex = parse(Int64, Args[10]),
			McmcVarianceInitialisation =
			eval(Meta.parse(Args[11])),
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

if parse(Int64, Args[16]) > 1

	InputPmap = [
		(
			Model,
			Prior,
			get_Data(
				[:DividendYield], # RegressorName
				Symbol(ModelChoice), Path,
				1, # NumberOfTarget
				parse(Int64, Args[19]), # NumberOfDataPoint
				Model, Prior,
				[0.1, 0.9, 0.05], # Parameter for exogenuous Regressor Simulation
				parse(Bool, Args[20]),
				parse(Int64, Args[17]),
				parse(Int64, Args[18])
			),
			InputSettingStruct(
				NumberOfStateParticle = parse(Int64, Args[3]),
				NumberOfMcmcStep = parse(Int64, Args[4]),
				NumberOfParameterParticle = parse(Int64, Args[5]),
				PrintEach = parse(Int64, Args[6]),
				CovarianceScaling = parse(Bool, Args[7]),
				McmcFullCovariance = parse(Bool, Args[8]),
				McmcUpdateIntervalLength = parse(Int64, Args[9]),
				McmcLastUpdateIndex = parse(Int64, Args[10]),
				McmcVarianceInitialisation =
				eval(Meta.parse(Args[11])),
				ResampleThresholdIbis = parse(Float64, Args[12]),
				NumberOfDensityPoint = parse(Int64, Args[13]),
				Path = Path,
				SaveOutput = parse(Bool, Args[14]),
				ModelChoice = ModelChoice,
				AlgorithmType = Args[15],
				ComputationLoopNumber = computationLoopNumber,
				ComputationOnCluster = ComputationOnCluster
			),
			Symbol(Args[15])
		) # AlgorithmType
		for computationLoopNumber in 1:parse(Int64, Args[16])
	]

	@everywhere function run_Algorithm_parallel(InputPmap)

		run_Algorithm(
			InputPmap...
		)

		return nothing

	end

	pmap(
		run_Algorithm_parallel,
		InputPmap
	)

else

	Output = run_Algorithm(
		Model,
		Prior,
		get_Data(
			[:DividendYield], # RegressorName
			Symbol(ModelChoice), Path,
			1, # NumberOfTarget
			parse(Int64, Args[19]), # NumberOfDataPoint
			Model, Prior,
			[0.1, 0.9, 0.05], # Parameter for exogenuous Regressor Simulation
			parse(Bool, Args[20]),
			parse(Int64, Args[17]),
			parse(Int64, Args[18])
		),
		InputSettingStruct(
			NumberOfStateParticle = parse(Int64, Args[3]),
			NumberOfMcmcStep = parse(Int64, Args[4]),
			NumberOfParameterParticle = parse(Int64, Args[5]),
			PrintEach = parse(Int64, Args[6]),
			CovarianceScaling = parse(Bool, Args[7]),
			McmcFullCovariance = parse(Bool, Args[8]),
			McmcUpdateIntervalLength = parse(Int64, Args[9]),
			McmcLastUpdateIndex = parse(Int64, Args[10]),
			McmcVarianceInitialisation =
			eval(Meta.parse(Args[11])),
			ResampleThresholdIbis = parse(Float64, Args[12]),
			NumberOfDensityPoint = parse(Int64, Args[13]),
			Path = Path,
			SaveOutput = parse(Bool, Args[14]),
			ModelChoice = ModelChoice,
			AlgorithmType = Args[15],
			ComputationLoopNumber = 1,
			ComputationOnCluster = ComputationOnCluster
		),
		Symbol(Args[15]) # AlgorithmType
	)

end
