function IbisDataTempering(
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
		Model, Prior, Data, InputSetting, "IbisData"
	)

	for dataPoint in 1:Setting.NumberOf.DataPoint

		for parameterParticle in 1:Setting.NumberOf.ParameterParticle

			for dataPoint in 1:dataPoint

				filter_State!(
					Setting,
					Computation,
					AlgorithmComputation,
					dataPoint,
					parameterParticle
				)

				update_LogLikelihood!(
					Setting,
					Computation,
					parameterParticle,
					0 # no densityPoint
				)

			end

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
			dataPoint
		)

		if AlgorithmComputation.EffectiveSampleSizeParameterParticle[dataPoint] < Setting.ResampleThresholdIbis

			resample_Computation!(Setting, Computation)

			# @sync @distributed
			for parameterParticle in 1:Setting.NumberOf.ParameterParticle

				move_Computation!(
					Setting,
					Computation,
					ComputationProposal,
					ComputationOverTempering,
					Prior,
					AlgorithmComputation,
					dataPoint,
					0, # no DensityTempering
					parameterParticle
				)

			end

		end

		update_ComputationOverTempering!(
			Computation,
			ComputationOverTempering,
			dataPoint
		)

		update_AlgorithmComputation!(
			Setting,
			Computation,
			AlgorithmComputation,
			dataPoint
		)

		print_on_the_fly(
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
