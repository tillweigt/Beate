function update_LogLikelihood!(Setting, Computation, parameterParticle, densityPoint)

	if Setting.AlgorithmType == "IbisDensity"

		Computation.LogLikelihood[parameterParticle] +=
			Computation.LogLikelihoodIncrement[parameterParticle] *
			Setting.DensityTemperingDifference[densityPoint]

	else

		if typeof(Setting.Model) <: DiscreteParticleFilterStruct

			Computation.LogLikelihood[parameterParticle] =
				Computation.LogLikelihoodIncrement[parameterParticle]

		else

			Computation.LogLikelihood[parameterParticle] +=
				Computation.LogLikelihoodIncrement[parameterParticle]

		end

	end

	return nothing

end

function update_ParameterLogWeight!(
	Setting,
	Computation,
	parameterParticle

)

	Computation.ParameterLogWeight[parameterParticle] =
		Computation.LogLikelihoodIncrement[parameterParticle] +
		Computation.ParameterLogWeight[parameterParticle]

	return nothing

end

function update_ParameterLogWeight!(
	Setting,
	Computation,
	parameterParticle,
	densityPoint
)

	# to check: only the Increment!
	Computation.ParameterLogWeight[parameterParticle] =
		Setting.DensityTemperingDifference[densityPoint] *
		Computation.LogLikelihoodIncrement[parameterParticle] +
		Computation.ParameterLogWeight[parameterParticle]

	return nothing

end

function update_ComputationOverTempering!(
	Computation,
	ComputationOverTempering,
	TemperingPoint
)

	ComputationOverTempering.Parameter[:, :, TemperingPoint] .=
	Computation.Parameter

	ComputationOverTempering.State[:, :, TemperingPoint] .=
	Computation.State

	ComputationOverTempering.Prediction[:, :, TemperingPoint] .=
	Computation.Prediction

	ComputationOverTempering.PredictionStateParticle[:, :, :, TemperingPoint] .=
	Computation.PredictionStateParticle

	ComputationOverTempering.LogLikelihoodIncrement[
		:, TemperingPoint
	] .= Computation.LogLikelihoodIncrement

	ComputationOverTempering.LogLikelihood[:, TemperingPoint] .=
	Computation.LogLikelihood

	ComputationOverTempering.StateParticle[
		:, :, :, TemperingPoint
	] .= Computation.StateParticle

	ComputationOverTempering.LastState[:, :, TemperingPoint] .=
	Computation.LastState

	ComputationOverTempering.LastStateParticle[
		:, :, :, TemperingPoint
	] .= Computation.LastStateParticle

	ComputationOverTempering.StateParticleLogWeight[
		:, :, TemperingPoint
	] .= Computation.StateParticleLogWeight

	ComputationOverTempering.LastStateParticleLogWeight[
		:, :, TemperingPoint
	] .= Computation.LastStateParticleLogWeight

	ComputationOverTempering.TransitionProbabilityMatrix[
		:, :, :, TemperingPoint
	] .= Computation.TransitionProbabilityMatrix

	ComputationOverTempering.ParameterLogWeight[:, TemperingPoint] .=
	Computation.ParameterLogWeight

	return nothing

end

function compute_TemperingIndex(
	Setting, dataPoint, densityPoint, mcmcStep
)

	if Setting.AlgorithmType == "Mcmc"

		TemperingIndex = mcmcStep

	elseif 	(Setting.AlgorithmType == "IbisData") |
		(Setting.AlgorithmType == "Filter")

		TemperingIndex = dataPoint

	elseif 	Setting.AlgorithmType == "IbisDensity"

		TemperingIndex = densityPoint

	else

		error()

	end

	return TemperingIndex

end

function get_Filter(Model)

	filter! =
	Symbol(
		split(
			string(typeof(Model)),
			"Struct"
		)[1] * "!"
	)

	return getfield(Beate, filter!)

end

function get_ResampleScheme(Model)

	ResampleScheme = getfield(
		Beate,
		Model.ResampleScheme
	)

	return ResampleScheme

end

function compute_weight_minus_maximumweight!(LogWeight, LogWeightIndex)

	LogWeightMaximum = maximum(
		LogWeight[LogWeightIndex]
	)

	LogWeight[LogWeightIndex] .-= LogWeightMaximum

	return LogWeightMaximum

end

function set_MinusInf_to_smallnumber!(Setting, LogWeight)

	LogWeight[isinf.(LogWeight)] .=
		log(eps(0.0) / Setting.NumberOf.StateParticle)

	return nothing

end

function initialize_Computation!(
	Prior, Setting,
	Computation, parameterParticle
)

	for i in 1:Setting.NumberOf.StatePrior

		Computation.StateParticle[Setting.StatePriorIndex[i],  :, parameterParticle] =
		rand(
			Prior.State[i],
			Setting.NumberOf.StateParticle
		)

	end

	if typeof(Setting.Model) <: DiscreteParticleFilterStruct

		Computation.StateParticle[
			Setting.Model.MixtureStateIndex,
			1:Setting.NumberOf.DiscreteState,
			parameterParticle
		] = convert(
			Array,
			1:Setting.NumberOf.DiscreteState
		)

	end

	Computation.State[:, parameterParticle] .= dropdims(
		mean(Computation.StateParticle[:, :, parameterParticle], dims = 2),
		dims = 2
	)

	Computation.Prediction[:, parameterParticle] .= NaN

	Computation.PredictionStateParticle[:, :, parameterParticle] .= NaN

	Computation.LogLikelihoodIncrement[parameterParticle] = 0.0

	Computation.LogLikelihood[parameterParticle] = 0.0

	Computation.StateParticleLogWeight[:, parameterParticle] .= 0.0

	Computation.TransitionProbabilityMatrix[:, :, parameterParticle] .= NaN

	Computation.ParameterLogWeight[parameterParticle] = 0.0

	Computation.LastState[:, parameterParticle] .= NaN

	Computation.LastStateParticle[:, :, parameterParticle] .= NaN

	Computation.LastStateParticleLogWeight[parameterParticle] = NaN

	return nothing

end

function update_AlgorithmComputation!(
	Setting,
	Computation,
	AlgorithmComputation,
	TemperingPoint
)

	compute_AcceptanceRatio!(
		AlgorithmComputation, TemperingPoint
	)

	compute_CovarianceScalingScalar!(
		Setting, AlgorithmComputation, TemperingPoint
	)

	update_ProposalDistribution!(
		Computation,
		AlgorithmComputation,
		TemperingPoint
	)

	return nothing

end

function compute_AcceptanceRatio!(
	AlgorithmComputation, TemperingPoint
)

	AlgorithmComputation.AcceptanceRatio[TemperingPoint] =
		mean(AlgorithmComputation.AcceptanceBool[:, TemperingPoint])

	return nothing

end

function compute_CovarianceScalingScalar!(
	Setting, AlgorithmComputation, TemperingPoint
)

	if (TemperingPoint > 1) &
		Setting.Input.CovarianceScaling

		AR = AlgorithmComputation.AcceptanceRatio[TemperingPoint]

		AlgorithmComputation.CovarianceScalingScalar[TemperingPoint] =
		AlgorithmComputation.CovarianceScalingScalar[TemperingPoint - 1] * (
			0.95 + 0.1 *
			exp(16.0 * (AR - 0.25))
			/
			(
				1 + exp(16.0 * (AR - 0.25))
			)
		)

	end

	return nothing

end

function update_ProposalDistribution!(
	Computation,
	AlgorithmComputation,
	TemperingPoint
)

	AlgorithmComputation.ParameterMean[:, TemperingPoint + 1] =
		mean(
			Computation.Parameter,
			dims = 2
		)

	AlgorithmComputation.ParameterFullCovariance[:, :, TemperingPoint + 1] =
		AlgorithmComputation.CovarianceScalingScalar[TemperingPoint] ^ 2 .*
		cov(
			Computation.Parameter,
			dims = 2
		)

	return nothing

end

function update_EffectiveSampleSize!(
	Setting,
	Computation,
	AlgorithmComputation,
	TemperingPoint
)

	ParameterWeight =
	exp.(Computation.ParameterLogWeight)

	ParameterWeight ./= sum(ParameterWeight)

	ParameterWeight .^= 2

	AlgorithmComputation.EffectiveSampleSizeParameterParticle[TemperingPoint] =
	1 / sum(ParameterWeight)

	AlgorithmComputation.EffectiveSampleSizeParameterParticle[TemperingPoint] /=
	Setting.NumberOf.ParameterParticle

	return nothing

end

function resample_Computation!(
	Setting, Computation
)

	WeightNormalized =
	exp.(Computation.ParameterLogWeight) ./
	sum(exp.(Computation.ParameterLogWeight))

	ResampleSchmeme = get_ResampleScheme(Setting.Input)

	ResampleIndex = ResampleSchmeme(
		WeightNormalized,
		Setting.NumberOf.ParameterParticle
	)

	Computation.Parameter .=
		Computation.Parameter[:, ResampleIndex]

	Computation.StateParticle .=
		Computation.StateParticle[:, :, ResampleIndex]

	Computation.State .=
		Computation.State[:, ResampleIndex]

	Computation.LastStateParticle .=
		Computation.LastStateParticle[:, :, ResampleIndex]

	Computation.LastState .=
		Computation.LastState[:, ResampleIndex]

	Computation.LogLikelihoodIncrement .=
		Computation.LogLikelihoodIncrement[ResampleIndex]

	Computation.LogLikelihood .=
		Computation.LogLikelihood[ResampleIndex]

	Computation.StateParticleLogWeight .=
		0.0
		# Computation.StateParticleLogWeight[:, ResampleIndex]

	Computation.LastStateParticleLogWeight .=
		0.0
		# Computation.LastStateParticleLogWeight[:, ResampleIndex]

	Computation.TransitionProbabilityMatrix .=
		Computation.TransitionProbabilityMatrix[:, :, ResampleIndex]

	Computation.ParameterLogWeight .= 0.0

	return nothing

end
