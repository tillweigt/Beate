function Filter(
	Model,
	Prior,
	Data,
	InputSetting
)

	Setting,
	Computation,
	ComputationProposal,
	ComputationOverTempering,
	AlgorithmComputation = initialize(
		Model, Prior, Data, InputSetting, "Filter"
	)

	for dataPoint in 1:Setting.NumberOf.DataPoint

		filter_State!(
			Setting,
			Computation,
			AlgorithmComputation,
			dataPoint,
			1 # only one parameterParticle
		)

		update_LogLikelihood!(
			Setting,
			Computation,
			1, # only one parameterParticle
			0 # no densityPoint
		)

		update_ComputationOverTempering!(
			Computation,
			ComputationOverTempering,
			dataPoint
		)

		save_print_on_the_fly(
			Setting,
			Computation,
			ComputationProposal,
			AlgorithmComputation,
			dataPoint
		)

	end

	return Setting,
	Computation,
	ComputationOverTempering,
	AlgorithmComputation

end
