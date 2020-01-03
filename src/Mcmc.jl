function Mcmc(
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
		Model, Prior, Data, InputSetting, "Mcmc"
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
			1,
			0 # no densityPoint
		)

	end

	move_Computation!(
		Setting,
		Computation,
		ComputationProposal,
		ComputationOverTempering,
		Prior,
		AlgorithmComputation,
		Setting.NumberOf.DataPoint,
		0, # no DensityTempering
		1 # only one parameterParticle
	)

	return Setting,
	Computation,
	ComputationOverTempering,
	AlgorithmComputation

end
