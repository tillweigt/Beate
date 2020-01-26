Path = pwd()
push!(LOAD_PATH, joinpath(Path, "src"))
using FileIO, JLD2, Beate, DataFrames, Plots, Statistics, Distributions

AlgorithmType = "IbisDataTempering"

ModelChoice = "JumpVol"

NumberOfDataPoint = 121

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

Data = get_Data(
	[:DividendYield], # RegressorName
	Symbol(ModelChoice), Path,
	1, # NumberOfTarget
	0, # NumberOfDataPoint
	missing, missing,
	[0.1, 0.9, 0.05], # Parameter for exogenuous Regressor Simulation
	false,
	880,
	1000
)

histogram(Parameter[21][1, :, end])

StateMean = map(
	i -> mean(State[i][1, :, :], dims = 1)[1, :],
	1:25
)
StateMean = [StateMean..., Data.Target[1, :],
	mean(Output[1][3].State[1, :, :], dims = 1)[1, :]
]
StateMeanAndTarget = DataFrame(StateMean)

save(
	joinpath(
		"C:\\GoogleDrive",
		"Forschung",
		"Paper3",
		"Paper",
		"data",
		"StateMeanAndTarget.csv"
	),
	StateMeanAndTarget
)

StateMixtureMean = map(
	i -> mean(State[i][3, :, :], dims = 1)[1, :],
	1:25
)
StateMixtureMean = [StateMixtureMean..., Data.Target[1, :]]
StateMixtureMeanAndTarget = DataFrame(StateMixtureMean)

save(
	joinpath(
		"C:\\GoogleDrive",
		"Forschung",
		"Paper3",
		"Paper",
		"data",
		"StateMixtureMeanAndTarget.csv"
	),
	StateMixtureMeanAndTarget
)

plot(mean(State[1][1, :, :], dims = 1)')
for i in 2:24
plot!(mean(State[i][1, :, :], dims = 1)')
end
plot!(mean(State[25][1, :, :], dims = 1)')
plot!(Data.Target[1, :])
