using Distributed

iszero(length(ARGS)) ? ComputationOnCluster = false : ComputationOnCluster = true

if !ComputationOnCluster

	Args = fill("", 20)

	Args[1] = "NParallel"
	Args[2] = "WellLog2" # ModelChoice
	Args[3] = "128" # NumberOfStateParticle = 128,
	Args[4] = "1" # NumberOfMcmcStep = 1,
	Args[5] = "500" # NumberOfParameterParticle = 50,
	Args[6] = "1" # PrintEach = 1,
	Args[7] = "false" # CovarianceScaling = false,
	Args[8] = "true" # McmcFullCovariance = true,
	Args[9] = "1000" # McmcUpdateIntervalLength = 500,
	Args[10] = "3000" # McmcLastUpdateIndex = 1000,
	Args[11] = "fill(1.0, 10)" # McmcVarianceInitialisation = 0.001,
	Args[12] = "1.1" # ResampleThresholdIbis = 1.1,
	Args[13] = "1" # NumberOfDensityPoint = 10,
	Args[14] = "true" # SaveOutput = true
	Args[15] = "IbisDataTempering" # AlgotirhmType
	Args[16] = "1" # ComputationLoopNumber
	Args[17] = "880" # DataStart
	Args[18] = "1000" # DataEnd
	Args[19] = "0" # NumberOfDataPoint
	Args[20] = "false"

else

	Args = ARGS

end

include(joinpath(Path, "Data", "get_Data.jl"))

Data = get_Data(
	[:DividendYield], # RegressorName
	Symbol(ModelChoice), Path,
	1, # NumberOfTarget
	parse(Int64, Args[19]), # NumberOfDataPoint
	Model, Prior,
	[0.1, 0.9, 0.05], # Parameter for exogenuous Regressor Simulation
	parse(Bool, Args[20]),
	parse(Int64, Args[17]),
	parse(Int64, Args[18])
)

using Plots

plot(Data.Target')
