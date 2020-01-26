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
length(Parameter)

function temp(LoopNumber, NumberOfParticle)
	Parameter1 = fill(NaN, LoopNumber, NumberOfParticle, 100)
	Parameter2 = fill(NaN, LoopNumber, NumberOfParticle, 100)
	Parameter3 = fill(NaN, LoopNumber, NumberOfParticle, 100)
	StateMean = fill(NaN, LoopNumber, NumberOfParticle, 100)
	StateMixture = fill(NaN, LoopNumber, NumberOfParticle, 100)
	TransitionProbability = fill(NaN, LoopNumber, 2, 2, NumberOfParticle, 100)
	for loopNumber in 1:LoopNumber

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
Parameter1, Parameter2, Parameter3, State2, MixtureState, TransitionProbability = temp(50, 500)

Parameter1End = Parameter1[:, :, end]
Parameter2End = Parameter2[:, :, end]
Parameter3End = Parameter3[:, :, end]

Parameter1Mean = mean(Parameter1, dims = 2)[:, 1, :]
Parameter2Mean = mean(Parameter2, dims = 2)[:, 1, :]
Parameter3Mean = mean(Parameter3, dims = 2)[:, 1, :]

Parameter1Upper =

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
