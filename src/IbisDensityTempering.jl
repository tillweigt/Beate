function IbisDensityTempering(
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
		Model, Prior, Data, InputSetting, "IbisDensity"
	)

	for densityPoint in 1:Setting.NumberOf.DensityPoint

		Computation.StateParticleLogWeight .= 0.0

		# @sync @distributed
		for parameterParticle in 1:Setting.NumberOf.ParameterParticle

			for dataPoint in 1:Setting.NumberOf.DataPoint

				filter_State!(
					Setting,
					Computation,
					AlgorithmComputation,
					dataPoint,
					parameterParticle
				)

			end

			update_LogLikelihood!(
				Setting,
				Computation,
				parameterParticle,
				densityPoint
			)

			update_ParameterLogWeight!(
				Setting,
				Computation,
				parameterParticle
			)

		end

		update_EffectiveSampleSize!(
			Setting,
			Computation,
			AlgorithmComputation,
			densityPoint
		)

		if AlgorithmComputation.EffectiveSampleSizeParameterParticle[densityPoint] <
			Setting.ResampleThresholdIbis

			resample_Computation!(Setting, Computation)

			@sync @distributed for parameterParticle in 1:Setting.NumberOf.ParameterParticle

				move_Computation!(
					Setting,
					Computation,
					ComputationProposal,
					ComputationOverTempering,
					Prior,
					AlgorithmComputation,
					Setting.NumberOf.DataPoint,
					densityPoint,
					parameterParticle
				)

			end

		end

		update_ComputationOverTempering!(
			Computation,
			ComputationOverTempering,
			densityPoint
		)

		update_AlgorithmComputation!(
			Setting,
			Computation,
			AlgorithmComputation,
			densityPoint
		)

		print_on_the_fly(
			Setting,
			Computation,
			ComputationProposal,
			AlgorithmComputation,
			densityPoint
		)

	end

	return Setting,
	Computation,
	ComputationOverTempering,
	AlgorithmComputation

end
