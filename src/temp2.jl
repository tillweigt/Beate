Path = pwd()
push!(LOAD_PATH, joinpath(Path, "src"))
using FileIO, JLD2, Beate, DataFrames, Plots, Statistics, Distributions

AlgorithmType = "IbisDataTempering"

ModelChoice1 = "1"
ModelChoice = "WellLogManyOf" * ModelChoice1

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
LoopNumber = length(Parameter)

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
Parameter1, Parameter2, Parameter3, StateMean, StateMixture, TransitionProbability = temp(LoopNumber, 500)

function compute_quantile(Variable, prob)

	Quantile = fill(NaN, size(Variable, 1), size(Variable, 3))

	for i in 1:size(Variable, 1)

		Quantile[i, :] = map(
			x -> quantile(x, prob),
			[Variable[i, :, j] for j in 1:size(Variable, 3)]
		)

	end

	return Quantile

end

function compute_and_save_aggregates(
	Variable, VariableName
)

	VariableEnd = Variable[:, :, end]

	VariableMean = mean(Variable, dims = 2)[:, 1, :]

	VariableUpper = compute_quantile(Variable, 0.99)

	VariableLower = compute_quantile(Variable, 0.01)

	save(
		joinpath(
			"C:\\GoogleDrive",
			"Forschung",
			"Paper3",
			"Paper",
			"data",
			"WellLogIbisDataManyOf" *
			VariableName *
			"End" *
			".csv"
		),
		DataFrame(VariableEnd')
	)

	save(
		joinpath(
			"C:\\GoogleDrive",
			"Forschung",
			"Paper3",
			"Paper",
			"data",
			"WellLogIbisDataManyOf" *
			VariableName *
			"Mean" *
			".csv"
		),
		DataFrame(VariableMean')
	)

	save(
		joinpath(
			"C:\\GoogleDrive",
			"Forschung",
			"Paper3",
			"Paper",
			"data",
			"WellLogIbisDataManyOf" *
			VariableName *
			"Upper" *
			".csv"
		),
		DataFrame(VariableUpper')
	)

	save(
		joinpath(
			"C:\\GoogleDrive",
			"Forschung",
			"Paper3",
			"Paper",
			"data",
			"WellLogIbisDataManyOf" *
			VariableName *
			"Lower" *
			".csv"
		),
		DataFrame(VariableLower')
	)

	return nothing

end

compute_and_save_aggregates(Parameter1, ModelChoice1 * "Parameter1")
compute_and_save_aggregates(Parameter2, ModelChoice1 * "Parameter2")
compute_and_save_aggregates(Parameter3, ModelChoice1 * "Parameter3")
compute_and_save_aggregates(StateMean, ModelChoice1 * "StateMean")
compute_and_save_aggregates(StateMixture, ModelChoice1 * "StateMixture")
compute_and_save_aggregates(TransitionProbability[:, 1, 1, :, :], ModelChoice1 * "TransitionProbability11")
compute_and_save_aggregates(TransitionProbability[:, 1, 2, :, :], ModelChoice1 * "TransitionProbability12")
