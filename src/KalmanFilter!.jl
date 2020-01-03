function KalmanFilter!(
	Setting,
	Model,
	AlgorithmComputation,
	Target,
	Regressor,
	Parameter,
	State,
	Prediction,
	LogLikelihoodIncrement,
	args...
)

	# initialize

	StateMean,
	StateCovariance = compute_StateMatrices(
		Model, State
	)

	ObservationCovariance,
	ObservationMatrixState,
	TransitionCovariance,
	TransitionMatrixState = compute_ModelMatrices(
		Model, Regressor, Parameter, State
	)

	StateMean .= mean(Model.Transition(
		Regressor, Parameter, StateMean
	))

	StateCovariance .=
		TransitionMatrixState *
		StateCovariance *
		TransitionMatrixState' +
		TransitionCovariance

	Prediction .= mean(Model.Observation(
		Regressor, Parameter, StateMean
	))

	PredictionCovariance =
		ObservationMatrixState *
		StateCovariance *
		ObservationMatrixState' +
		ObservationCovariance[
			Model.StateMeanEquationIndex,
			Model.StateMeanEquationIndex
		]

	KalmanGain =
		StateCovariance *
		ObservationMatrixState' *
		inv(PredictionCovariance)

	StateMean .=
		StateMean +
		KalmanGain *
		(
			Target[Model.StateMeanEquationIndex] -
			Prediction[Model.StateMeanEquationIndex]
		)

	StateCovariance .=
		StateCovariance -
		KalmanGain *
		ObservationMatrixState *
		StateCovariance

	PredictionCovarianceFull =
	ObservationCovariance

	PredictionCovarianceFull[
		Model.StateMeanEquationIndex,
		Model.StateMeanEquationIndex
	] = PredictionCovariance

	LogLikelihoodIncrement .=
	Setting.Input.ScoringRule(
		MvNormal(
			Prediction,
			PredictionCovarianceFull
		),
		Target
	)

	return nothing
end

function compute_StateMatrices(Model, State)

	StateMeanIndex =
	Model.StateMeanIndex

	StateCovarianceIndex =
	Model.StateCovarianceIndex

	StateCovarianceDimension = convert(
		Int64, sqrt(length(StateCovarianceIndex))
	)

	StateMean = view(State, StateMeanIndex)

	StateCovariance = reshape(
		view(State, StateCovarianceIndex),
		StateCovarianceDimension,
		StateCovarianceDimension
	)

	return StateMean,
	StateCovariance

end

function compute_ModelMatrices(
	Model, Regressor, Parameter, State
)

	ObservationCovariance = CovOrVar(
		Model.Observation(
			Regressor, Parameter, State
		)
	)

	ObservationMatrixState =
	Model.ObservationMatrixState(
		Regressor, Parameter, State
	)

	TransitionCovariance = CovOrVar(
		Model.Transition(
			Regressor, Parameter, State
		)
	)

	TransitionMatrixState =
	Model.TransitionMatrixState(
		Regressor, Parameter, State
	)

	return ObservationCovariance,
	ObservationMatrixState,
	TransitionCovariance,
	TransitionMatrixState

end

function CovOrVar(d::UnivariateDistribution)

	return reshape([var(d)], 1, 1)

end

function CovOrVar(d::MultivariateDistribution)

	return cov(d)

end

function compute_MatrixState(MatrixEntries::Float64)

	MatrixDimension = convert(Int64, ceil(length(MatrixEntries) / 2))

	return reshape(
		[MatrixEntries],
		MatrixDimension,
		MatrixDimension
	)

end

function compute_MatrixState(MatrixEntries::AbstractArray)

	MatrixDimension = convert(Int64, ceil(length(MatrixEntries) / 2))

	return reshape(
		MatrixEntries,
		MatrixDimension,
		MatrixDimension
	)

end
