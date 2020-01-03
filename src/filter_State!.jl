function filter_State!(
	Setting,
	Computation,
	AlgorithmComputation,
	dataPoint,
	parameterParticle
)

	filter! = get_Filter(Setting.Model)

	filter!(
		Setting,
		Setting.Model,
		AlgorithmComputation,
		Setting.Data.Target[:, dataPoint],
		Setting.Data.Regressor[:, dataPoint],
		Computation.Parameter[:, parameterParticle],
		view(Computation.State, :, parameterParticle),
		view(Computation.Prediction, :, parameterParticle),
		view(
			Computation.LogLikelihoodIncrement,
			parameterParticle
		),
		view(
			Computation.StateParticle,
			:, :, parameterParticle
		),
		view(
			Computation.PredictionStateParticle,
			:, :, parameterParticle
		),
		view(
			Computation.StateParticleLogWeight,
			:, parameterParticle
		),
		view(Computation.LastState, :, parameterParticle),
		view(
			Computation.LastStateParticle,
			:, :, parameterParticle
		),
		view(
			Computation.LastStateParticleLogWeight,
			:, parameterParticle
		),
		view(
			AlgorithmComputation.ResampleThresholdDpf,
			parameterParticle,
			dataPoint
		),
		view(
			Computation.TransitionProbabilityMatrix,
			:, :, parameterParticle
		),
		dataPoint
	)

	# update_LogLikelihood!(
	# 	Setting,
	# 	Computation,
	# 	parameterParticle
	# )

	return nothing

end
