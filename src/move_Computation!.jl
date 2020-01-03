function move_Computation!(
	Setting,
	Computation,
	ComputationProposal,
	ComputationOverTempering,
	Prior,
	AlgorithmComputation,
	dataPoint,
	densityPoint,
	parameterParticle
)

	for mcmcStep in 1:Setting.NumberOf.McmcStep

		for mcmcBlock in 1:Setting.NumberOf.McmcBlock

			initialize_Computation!(
				Prior, Setting,
				ComputationProposal, parameterParticle
			)

			if Setting.AlgorithmType == "IbisDensity"

				ComputationProposal.LogLikelihood[parameterParticle] =
				Computation.LogLikelihood[parameterParticle] -
				Computation.LogLikelihoodIncrement[parameterParticle] *
				Setting.DensityTemperingDifference[densityPoint]
				
			end

			set_TransitionProbabilityMatrixProposal!(
				Setting,
				Computation,
				ComputationProposal,
				parameterParticle
			)

			LogProposalRatio =
			propose_Parameter!(
				Setting,
				Computation,
				ComputationProposal,
				AlgorithmComputation,
				dataPoint,
				densityPoint,
				parameterParticle,
				mcmcStep
			)

			LogProbabilityOfPriorAtParameterProposal =
			compute_LogProbabilityOfPriorAtParameter(
				Setting, Prior, ComputationProposal, parameterParticle
			)

			if !isinf(LogProbabilityOfPriorAtParameterProposal)

				for dataPoint in 1:dataPoint

					filter_State!(
						Setting,
						ComputationProposal,
						AlgorithmComputation,
						dataPoint,
						parameterParticle
					)

					# ComputationProposal.LogLikelihood[parameterParticle] =
					# ComputationProposal.LogLikelihoodIncrement[parameterParticle]

				end

				update_LogLikelihood!(
					Setting,
					ComputationProposal,
					parameterParticle,
					densityPoint
				)

				compute_AcceptanceBool!(
					Setting,
					Computation,
					ComputationProposal,
					Prior,
					AlgorithmComputation,
					LogProposalRatio,
					LogProbabilityOfPriorAtParameterProposal,
					dataPoint,
					densityPoint,
					parameterParticle,
					mcmcStep,
					mcmcBlock
				)

				update_Computation!(
					Setting,
					Computation,
					ComputationProposal,
					AlgorithmComputation,
					dataPoint,
					densityPoint,
					parameterParticle,
					mcmcStep
				)

			end

		end

		if Setting.AlgorithmType == "Mcmc"

			update_ComputationOverTempering!(
				Computation,
				ComputationOverTempering,
				mcmcStep
			)

			update_AlgorithmComputation!(
				Setting,
				Computation,
				ComputationProposal,
				ComputationOverTempering,
				AlgorithmComputation,
				mcmcStep
			)

			print_on_the_fly(
				Setting,
				Computation,
				ComputationProposal,
				AlgorithmComputation,
				mcmcStep
			)

		end

	end

	return nothing

end

function set_TransitionProbabilityMatrixProposal!(
	Setting,
	Computation,
	ComputationProposal,
	parameterParticle
)

	if typeof(Setting.Model) <: DiscreteParticleFilterStruct

		if Setting.Model.IsTransitionProbabilityMatrixFromState

			ComputationProposal.StateParticle[
				Setting.Model.TransitionProbabilityMatrixIndex, :, parameterParticle
			] .=
			Computation.StateParticle[
				Setting.Model.TransitionProbabilityMatrixIndex, :, parameterParticle
			]

			ComputationProposal.State[
				Setting.Model.TransitionProbabilityMatrixIndex, parameterParticle
			] .=
			Computation.State[
				Setting.Model.TransitionProbabilityMatrixIndex, parameterParticle
			]

			# ???
			# ComputationProposal.StateParticleLogWeight[
			# 	:, parameterParticle
			# ] .=
			# Computation.StateParticleLogWeight[
			# 	:, parameterParticle
			# ]

		end

	end

	return nothing

end

function propose_Parameter!(
	Setting,
	Computation,
	ComputationProposal,
	AlgorithmComputation,
	dataPoint,
	densityPoint,
	parameterParticle,
	mcmcStep
)

	TemperingIndex = compute_TemperingIndex(
		Setting, dataPoint, densityPoint, mcmcStep
	)

	if Setting.Input.McmcFullCovariance

		DistributionParameter = MvNormal(
			Computation.Parameter[:, parameterParticle],
			AlgorithmComputation.ParameterFullCovariance[:, :, TemperingIndex]
		)

	else

		DistributionParameter = MvNormal(
			Computation.Parameter[:, parameterParticle],
			Diagonal(diag(
				AlgorithmComputation.ParameterFullCovariance[:, :, TemperingIndex]
			))
		)

	end

	ComputationProposal.Parameter[:, parameterParticle] =
	rand(DistributionParameter)

	if Setting.Input.McmcFullCovariance

		DistributionParameterProposal = MvNormal(
			ComputationProposal.Parameter[:, parameterParticle],
			AlgorithmComputation.ParameterFullCovariance[:, :, TemperingIndex]
		)

	else

		DistributionParameterProposal = MvNormal(
			ComputationProposal.Parameter[:, parameterParticle],
			Diagonal(diag(
				AlgorithmComputation.ParameterFullCovariance[:, :, TemperingIndex]
			))
		)

	end

	LogProposalRatio =
	Setting.Input.ScoringRule(
		DistributionParameterProposal,
		Computation.Parameter[:, parameterParticle]
	) -
	Setting.Input.ScoringRule(
		DistributionParameter,
		ComputationProposal.Parameter[:, parameterParticle]
	)

	return LogProposalRatio

end

function compute_LogProbabilityOfPriorAtParameter(
	Setting, Prior, Computation, parameterParticle
)

	LogProbabilityOfPriorAtParameter = 0.0

	for i in 1:Setting.NumberOf.ParameterPrior

		LogProbabilityOfPriorAtParameter +=
		Setting.Input.ScoringRule(
			Prior.Parameter[i],
			Computation.Parameter[
				Setting.ParameterPriorIndex[i],
				parameterParticle
			]
		)

	end

	return LogProbabilityOfPriorAtParameter

end

function compute_AcceptanceBool!(
	Setting,
	Computation,
	ComputationProposal,
	Prior,
	AlgorithmComputation,
	LogProposalRatio,
	LogProbabilityOfPriorAtParameterProposal,
	dataPoint,
	densityPoint,
	parameterParticle,
	mcmcStep,
	mcmcBlock
)

	TemperingIndex = compute_TemperingIndex(
		Setting, dataPoint, densityPoint, mcmcStep
	)

	LogProbabilityOfPriorAtParameter =
	compute_LogProbabilityOfPriorAtParameter(
		Setting, Prior, Computation, parameterParticle
	)

	AcceptanceProbability = LogProposalRatio +
		LogProbabilityOfPriorAtParameterProposal -
		LogProbabilityOfPriorAtParameter +
		ComputationProposal.LogLikelihood[parameterParticle] -
		Computation.LogLikelihood[parameterParticle]

	if !AlgorithmComputation.AcceptanceBool[
			parameterParticle, TemperingIndex
		]

		AlgorithmComputation.AcceptanceBool[
			parameterParticle, TemperingIndex
		] =
		AcceptanceProbability > log(rand(Uniform()))

	end

	return nothing

end

function update_Computation!(
	Setting,
	Computation,
	ComputationProposal,
	AlgorithmComputation,
	dataPoint,
	densityPoint,
	parameterParticle,
	mcmcStep
)

	TemperingIndex = compute_TemperingIndex(
		Setting, dataPoint, densityPoint, mcmcStep
	)

	if AlgorithmComputation.AcceptanceBool[
		parameterParticle, TemperingIndex
	]

		Computation.Parameter[:, parameterParticle] .= ComputationProposal.Parameter[:, parameterParticle]

		Computation.StateParticle[:, :, parameterParticle] .= ComputationProposal.StateParticle[:, :, parameterParticle]

		Computation.State[:, parameterParticle] .= ComputationProposal.State[:, parameterParticle]

		Computation.LastStateParticle[:, :, parameterParticle] .=
			ComputationProposal.LastStateParticle[:, :, parameterParticle]

		Computation.LastState[:, parameterParticle] .= ComputationProposal.LastState[:, parameterParticle]

		# Computation.Prediction[:, parameterParticle] .= ComputationProposal.Prediction[:, parameterParticle]

		# Computation.PredictionStateParticle[:, :, parameterParticle] .=
		# 	ComputationProposal.PredictionStateParticle[:, :, parameterParticle]

		# Computation.LogLikelihoodIncrement[parameterParticle] =
		# 	ComputationProposal.LogLikelihoodIncrement[parameterParticle]

		Computation.LogLikelihood[parameterParticle] = ComputationProposal.LogLikelihood[parameterParticle]

		# Computation.StateParticleLogWeight[:, parameterParticle] .=
		# 	ComputationProposal.StateParticleLogWeight[:, parameterParticle]

		# Computation.LastStateParticleLogWeight[:, parameterParticle] .=
		# 	ComputationProposal.LastStateParticleLogWeight[:, parameterParticle]

		Computation.TransitionProbabilityMatrix[:, :, parameterParticle] .=
			ComputationProposal.TransitionProbabilityMatrix[:, :, parameterParticle]

	end

	return nothing

end

function update_AlgorithmComputation!(
	Setting,
	Computation,
	ComputationProposal,
	ComputationOverTempering,
	AlgorithmComputation,
	mcmcStep
)

	if (mcmcStep > Setting.McmcUpdateIntervalLength)

		compute_AcceptanceRatio_for_Mcmc!(
			Setting, AlgorithmComputation, mcmcStep
		)

		compute_CovarianceScalingScalar!(
			Setting, AlgorithmComputation, mcmcStep
		)

		update_ProposalDistribution!(
			Setting,
			Computation,
			ComputationProposal,
			ComputationOverTempering,
			AlgorithmComputation,
			mcmcStep
		)

	end

	return nothing

end

function compute_AcceptanceRatio_for_Mcmc!(
	Setting, AlgorithmComputation, mcmcStep
)

	if (mcmcStep > Setting.McmcUpdateIntervalLength)

		AlgorithmComputation.AcceptanceRatio[mcmcStep] =
		mean(AlgorithmComputation.AcceptanceBool[
			1,
			Setting.McmcUpdateIntervalLength +
			1:mcmcStep
		])

	end
	# AlgorithmComputation.AcceptanceRatio[mcmcStep] =
	# 	mean(AlgorithmComputation.AcceptanceBool[1, 1:mcmcStep])

	return nothing

end

function update_ProposalDistribution!(
	Setting,
	Computation,
	ComputationProposal,
	ComputationOverTempering,
	AlgorithmComputation,
	mcmcStep
)

	if (mcmcStep >= Setting.McmcLastUpdateIndex)

		AlgorithmComputation.ParameterMean[:, mcmcStep + 1:end] .=
			mean(ComputationOverTempering.Parameter[:,
				1,
				Setting.McmcUpdateIntervalLength +
				1:mcmcStep
				],
				dims = 2
			)

		AlgorithmComputation.ParameterFullCovariance[:, :, mcmcStep + 1:end] .=
			AlgorithmComputation.CovarianceScalingScalar[mcmcStep] ^ 2 .*
			cov(ComputationOverTempering.Parameter[:,
				1,
				Setting.McmcUpdateIntervalLength +
				1:mcmcStep
				],
				dims = 2
			)

	end
	# if (mcmcStep >= Setting.McmcUpdateIntervalLength) &
	# 	(mcmcStep <= Setting.McmcLastUpdateIndex)
	#
	# 	AlgorithmComputation.ParameterMean[:, mcmcStep + 1:end] .=
	# 		mean(ComputationOverTempering.Parameter[:,
	# 			1,
	# 			mcmcStep - Setting.McmcUpdateIntervalLength +
	# 			1:mcmcStep
	# 			],
	# 			dims = 2
	# 		)
	#
	# 	AlgorithmComputation.ParameterFullCovariance[:, :, mcmcStep + 1:end] .=
	# 		AlgorithmComputation.CovarianceScalingScalar[mcmcStep] ^ 2 .*
	# 		cov(ComputationOverTempering.Parameter[:,
	# 			1,
	# 			mcmcStep - Setting.McmcUpdateIntervalLength +
	# 			1:mcmcStep
	# 			],
	# 			dims = 2
	# 		)
	#
	# end

	return nothing

end
