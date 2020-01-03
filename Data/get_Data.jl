function get_Data(
	RegressorName,
	ModelChoice,
	Path,
	NumberOfTarget
)

	Data = load(
		joinpath(Path, "Data", "GoyalDataPrepared.jld2"),
		"GoyalDataPrepared"
	)

	if NumberOfTarget == 1

		Target = reshape(Data.ExcessReturn[2:end], 1, size(Data, 1) - 1)

		Regressor = convert(Matrix, Data[1:end - 1, RegressorName])'

	else

		Target = convert(Matrix, Data[2:end, [:ExcessReturn, RegressorName...]])'

		Regressor = convert(Matrix, Data[1:end - 1, RegressorName])'

	end

	return DataStruct(
		Target,
		Regressor,
		fill(NaN, 1, size(Data, 1) - 1)
	)

end

function get_Data(
	ModelChoice, Path,
	NumberOfTarget, NumberOfDataPoint,
	Model, Prior,
	ParameterRegressor, Parameter, TransitionProbabilityMatrix
)

	Regressor = simulate_Regressor(
		ParameterRegressor, NumberOfTarget, NumberOfDataPoint
	)

	Data = simulate_Data(
		Model, Prior, Regressor, Parameter, TransitionProbabilityMatrix,
		NumberOfTarget, NumberOfDataPoint
	)

	save(
		joinpath(Path, "Data", string(ModelChoice) * ".jld2"),
		string(ModelChoice),
		Data
	)

	return Data

end

function simulate_Regressor(
	Parameter, NumberOfTarget, NumberOfDataPoint
)

	Regressor = fill(NaN, 1, NumberOfDataPoint)

	Regressor[1, 1] = Parameter[1] / (1 - Parameter[2])

	if NumberOfTarget == 3

		Regressor = fill(NaN, NumberOfTarget - 1, NumberOfDataPoint)

		Regressor[1, 1] = Parameter[1] / (1 - Parameter[2])

		Regressor[2, 1] = Parameter[4] / (1 - Parameter[5])

	elseif NumberOfTarget > 3

		stop()

	end

	for dataPoint in 2:NumberOfDataPoint

		Regressor[1, dataPoint] = rand(Normal(
			Parameter[1] + Parameter[2] * Regressor[1, dataPoint - 1],
			Parameter[3]
		))

		if NumberOfTarget == 3

			Regressor[2, dataPoint] = rand(Normal(
				Parameter[4] + Parameter[5] * Regressor[2, dataPoint - 1],
				Parameter[6]
			))

		elseif NumberOfTarget > 3

			stop()

		end

	end

	return Regressor

end

function get_Data(ModelChoice, Path)

	Data = load(
		joinpath(Path, "Data", string(ModelChoice) * ".jld2"),
		string(ModelChoice)
	)

	return Data

end

function simulate_Data(
	Model, Prior, Regressor, Parameter, TransitionProbabilityMatrix,
	NumberOfTarget, NumberOfDataPoint
)

	Target,
	State,
	MixtureState = initialize_variables(
		Model, Prior, NumberOfTarget, NumberOfDataPoint
	)

	if typeof(Model) <: DiscreteParticleFilterStruct

		NumberOfDiscreteState = length(Model.Filter)

	end

	for dataPoint in 2:NumberOfDataPoint

		if typeof(Model) <: DiscreteParticleFilterStruct

			MixtureState[dataPoint] = sample(
				1:NumberOfDiscreteState,
				weights(TransitionProbabilityMatrix[:, convert(Int64, MixtureState[dataPoint - 1])])
			)

			State[:, dataPoint] .= rand(Model.Filter[
				convert(Int64, MixtureState[dataPoint])
			].Transition(Regressor[:, dataPoint], Parameter, State[:, dataPoint - 1]))

			Target[:, dataPoint] .= rand(Model.Filter[
				convert(Int64, MixtureState[dataPoint])
			].Observation(Regressor[:, dataPoint - 1], Parameter, State[:, dataPoint]))

		elseif typeof(Model) <: KalmanFilterStruct

			State[:, dataPoint] .= rand(Model.Transition(Regressor[:, dataPoint - 1], Parameter, State[:, dataPoint - 1]))

			Target[:, dataPoint] .= rand(Model.Observation(Regressor[:, dataPoint - 1], Parameter, State[:, dataPoint]))

		elseif typeof(Model) <: NoFilterStruct

			Target[:, dataPoint] .= rand(Model.Observation(Regressor[:, dataPoint - 1], Parameter, State[:, dataPoint]))

		else

			stop()

		end

	end

	if typeof(Model) <: DiscreteParticleFilterStruct

		State = vcat(State, reshape(MixtureState, 1, length(MixtureState)))

	end

	return DataStruct(
		Target[:, 2:end],
		Regressor[:, 1:end - 1],
		State[:, 2:end]
	)

end


function initialize_variables(
	Model, Prior, NumberOfTarget, NumberOfDataPoint
)

	NumberOfState = make_NumberOfLatent(Prior.State)

	NumberOfStatePrior = length(Prior.State)

	StatePriorIndex = make_PriorIndex(Prior.State)

	Target = fill(NaN, NumberOfTarget, NumberOfDataPoint)
	State = fill(NaN, NumberOfState, NumberOfDataPoint)

	for i in 1:NumberOfStatePrior

		State[StatePriorIndex[i], 1] .= rand(
			Prior.State[i]
		)

	end

	if typeof(Model) <: DiscreteParticleFilterStruct

		MixtureState = State[Model.MixtureStateIndex, :]

		State = State[Model.StateIndex, :]

	elseif typeof(Model) <: KalmanFilterStruct

		MixtureState = fill(NaN, NumberOfDataPoint)

		State = State[Model.StateMeanIndex, :]

	elseif typeof(Model) <: NoFilterStruct

		MixtureState = fill(NaN, NumberOfDataPoint)

		State = fill(NaN, 1, NumberOfDataPoint)

	else

		stop()

	end

	return Target, State, MixtureState

end
