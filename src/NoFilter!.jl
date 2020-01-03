function NoFilter!(
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

	Observation =
	Model.Observation(
		Regressor,
		Parameter,
		State
	)

	Prediction .=
	mean(
		Observation
	)

	LogLikelihoodIncrement .= Setting.Input.ScoringRule(
		Observation,
		Target
	)

	return nothing

end
