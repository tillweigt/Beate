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

function temp(LoopNumber)
	Parameter1 = fill(NaN, LoopNumber, 1000, 100)
	Parameter2 = fill(NaN, LoopNumber, 1000, 100)
	Parameter3 = fill(NaN, LoopNumber, 1000, 100)
	StateMean = fill(NaN, LoopNumber, 1000, 100)
	StateMixture = fill(NaN, LoopNumber, 1000, 100)
	TransitionProbability = fill(NaN, LoopNumber, 2, 2, 1000, 100)
	for loopNumber in 1:5

		Parameter1[loopNumber, :, :] = Parameter[loopNumber][1, :, :]
		Parameter2[loopNumber, :, :] = Parameter[loopNumber][2, :, :]
		Parameter3[loopNumber, :, :] = Parameter[loopNumber][3, :, :]

		StateMean[loopNumber, :, :] = State[loopNumber][1, :, :]

		StateMixture[loopNumber, :, :] = State[loopNumber][3, :, :]

		TransitionProbability[loopNumber, :, :, :, :] =
		TransitionProbabilityMatrix[loopNumber]

	end
	return Parameter1, Parameter2, Parameter3, StateMean, StateMixture, TransitionProbability
end
Parameter1, Parameter2, Parameter3, State2, MixtureState, TransitionProbability = temp(5)

save(
	joinpath(
		"C:\\GoogleDrive",
		"Forschung",
		"Paper3",
		"Paper",
		"data",
		"WellLogFilterManyOf1Parameter1.csv"
	),
	DataFrame(Parameter1)
)
