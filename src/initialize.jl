function initialize(Model, Prior, Data, InputSetting, AlgorithmType)

	Setting = make_Setting(
		Model, Prior, Data,
		InputSetting, AlgorithmType
	)

	Computation = make_Computation(Prior, Setting)

	ComputationProposal = make_Computation(Prior, Setting)

	ComputationOverTempering =
	make_ComputationOverTempering(Setting)

	AlgorithmComputation =	make_AlgorithmComputation(
		Setting
	)

	return Setting,
 	Computation,
	ComputationProposal,
	ComputationOverTempering,
	AlgorithmComputation

end

function make_Setting(
	Model, Prior, Data,
	InputSetting, AlgorithmType
)

	NumberOfDynamicStateParticle,
	LargestDynamicStateParticle,
	SecondLargestDynamicStateParticle =
	make_NumberOfDynamicStateParticle(
		Model,
		size(Data.Target, 2),
		InputSetting.NumberOfStateParticle
	)

	NumberOf = NumberOfStruct(
		size(Data.Target, 1),
		size(Data.Target, 2),
		InputSetting.NumberOfParameterParticle,
		InputSetting.NumberOfStateParticle,
		make_NumberOfDiscreteState(Model),
		NumberOfDynamicStateParticle,
		LargestDynamicStateParticle,
		SecondLargestDynamicStateParticle,
		make_NumberOfLatent(Prior.Parameter),
		make_NumberOfLatent(Prior.State),
		InputSetting.NumberOfMcmcStep,
		InputSetting.NumberOfMcmcBlock,
		length(Prior.Parameter),
		length(Prior.State),
		InputSetting.NumberOfDensityPoint
	)

	DensityTemperingDifference = make_DensityTemperingDifference(
		InputSetting.NumberOfDensityPoint
	)

	Setting = SettingStruct(
		Model,
		Prior,
		Data,
		InputSetting,
		make_PriorIndex(Prior.Parameter),
		make_PriorIndex(Prior.State),
		NumberOf,
		AlgorithmType,
		InputSetting.McmcUpdateIntervalLength,
		InputSetting.McmcLastUpdateIndex,
		DensityTemperingDifference,
		InputSetting.ResampleThresholdIbis
	)

	return Setting

end

function make_NumberOfDiscreteState(Model)

	if typeof(Model) <: DiscreteParticleFilterStruct

		NumberOfDiscreteState = length(Model.Filter)

	else

		NumberOfDiscreteState = 1

	end

	return NumberOfDiscreteState

end

function make_NumberOfDynamicStateParticle(
	Model,
	NumberOfDataPoint,
	NumberOfStateParticle
)

	if typeof(Model) <: DiscreteParticleFilterStruct

		NumberOfDiscreteState = length(Model.Filter)

		NumberOfDynamicStateParticle = fill(
			NumberOfDiscreteState,
			NumberOfDataPoint + 1
		)

		for dataPoint in 2:NumberOfDataPoint + 1

			NumberOfDynamicStateParticle[dataPoint] =
				NumberOfDiscreteState *
				NumberOfDynamicStateParticle[
					dataPoint - 1
				]

			if NumberOfDynamicStateParticle[dataPoint] ==
				NumberOfStateParticle

				NumberOfDynamicStateParticle[
					dataPoint:end
				] .= NumberOfDynamicStateParticle[
					dataPoint
				]

				break

			elseif NumberOfDynamicStateParticle[dataPoint] >
					NumberOfStateParticle

				NumberOfDynamicStateParticle[
					dataPoint:end
				] .= NumberOfDynamicStateParticle[
					dataPoint - 1
				]

				break

			else

				nothing

			end

		end

		NumberOfDynamicStateParticle =
			NumberOfDynamicStateParticle[2:end]

		DynamicStateParticleSorted = unique(sort(
			NumberOfDynamicStateParticle, rev = true
		))

		LargestDynamicStateParticle =
			DynamicStateParticleSorted[1]

		SecondLargestDynamicStateParticle =
			DynamicStateParticleSorted[2]

	else

		NumberOfDynamicStateParticle = [NaN]

		LargestDynamicStateParticle = 0

		SecondLargestDynamicStateParticle = 0

	end


	return NumberOfDynamicStateParticle,
		LargestDynamicStateParticle,
		SecondLargestDynamicStateParticle

end

function make_DensityTemperingDifference(
	NumberOfDensityPoint
)

	DensityTemperingDifference = fill(NaN, NumberOfDensityPoint)

	for i in 1:NumberOfDensityPoint

		DensityTemperingDifference[i] = (i / NumberOfDensityPoint) ^ 2

	end

	DensityTemperingDifference = [
		DensityTemperingDifference[1],
		diff(DensityTemperingDifference)...
	]

	return DensityTemperingDifference

end

function make_Computation(Prior, Setting)

	Parameter = SharedArray{Float64}(
		Setting.NumberOf.Parameter,
		Setting.NumberOf.ParameterParticle
	)

	StateParticle = SharedArray{Float64}(
		Setting.NumberOf.State,
		Setting.NumberOf.StateParticle,
		Setting.NumberOf.ParameterParticle
	)

	State = SharedArray{Float64}(
		Setting.NumberOf.State,
		Setting.NumberOf.ParameterParticle
	)

	LastStateParticle = SharedArray{Float64}(
		Setting.NumberOf.State,
		Setting.NumberOf.StateParticle,
		Setting.NumberOf.ParameterParticle
	)

	LastState = SharedArray{Float64}(
		Setting.NumberOf.State,
		Setting.NumberOf.ParameterParticle
	)

	Prediction = SharedArray{Float64}(
		Setting.NumberOf.Target,
		Setting.NumberOf.ParameterParticle
	)

	PredictionStateParticle = SharedArray{Float64}(
		Setting.NumberOf.Target,
		Setting.NumberOf.StateParticle,
		Setting.NumberOf.ParameterParticle
	)

	LogLikelihoodIncrement = SharedArray{Float64}(
		Setting.NumberOf.ParameterParticle
	)

	LogLikelihood = SharedArray{Float64}(
		Setting.NumberOf.ParameterParticle
	)

	StateParticleLogWeight = SharedArray{Float64}(
		Setting.NumberOf.StateParticle,
		Setting.NumberOf.ParameterParticle
	)

	LastStateParticleLogWeight = SharedArray{Float64}(
		Setting.NumberOf.StateParticle,
		Setting.NumberOf.ParameterParticle
	)

	TransitionProbabilityMatrix = SharedArray{Float64}(
		Setting.NumberOf.DiscreteState,
		Setting.NumberOf.DiscreteState,
		Setting.NumberOf.ParameterParticle
	)

	ParameterLogWeight = SharedArray{Float64}(
		Setting.NumberOf.ParameterParticle
	)

	for i in 1:Setting.NumberOf.ParameterPrior

		Parameter[Setting.ParameterPriorIndex[i], :] = rand(
			Prior.Parameter[i],
			Setting.NumberOf.ParameterParticle
		)

	end

	Computation = ComputationStruct(
		Parameter,
		State,
		Prediction,
		LogLikelihoodIncrement,
		LogLikelihood,
		StateParticle,
		PredictionStateParticle,
		StateParticleLogWeight,
		LastState,
		LastStateParticle,
		LastStateParticleLogWeight,
		TransitionProbabilityMatrix,
		ParameterLogWeight
	)

	for parameterParticle in 1:Setting.NumberOf.ParameterParticle

		initialize_Computation!(
			Prior, Setting,
			Computation, parameterParticle
		)

	end

	return Computation

end

function make_ComputationOverTempering(Setting)

	TemperingLength = compute_TemperingLength(Setting)

	Parameter = fill(
		NaN,
		Setting.NumberOf.Parameter,
		Setting.NumberOf.ParameterParticle,
		TemperingLength
	)

	StateParticle = fill(
		NaN,
		Setting.NumberOf.State,
		Setting.NumberOf.StateParticle,
		Setting.NumberOf.ParameterParticle,
		TemperingLength
	)

	State = fill(
		NaN,
		Setting.NumberOf.State,
		Setting.NumberOf.ParameterParticle,
		TemperingLength
	)

	LastStateParticle = copy(StateParticle)

	LastState = copy(State)

	Prediction = fill(
		NaN,
		Setting.NumberOf.Target,
		Setting.NumberOf.ParameterParticle,
		TemperingLength
	)

	PredictionStateParticle =
	fill(
		NaN,
		Setting.NumberOf.Target,
		Setting.NumberOf.StateParticle,
		Setting.NumberOf.ParameterParticle,
		TemperingLength
	)

	LogLikelihoodIncrement = fill(
		NaN,
		Setting.NumberOf.ParameterParticle,
		TemperingLength
	)

	LogLikelihood = fill(
		NaN,
		Setting.NumberOf.ParameterParticle,
		TemperingLength
	)

	StateParticleLogWeight = fill(
		NaN,
		Setting.NumberOf.StateParticle,
		Setting.NumberOf.ParameterParticle,
		TemperingLength
	)

	LastStateParticleLogWeight = fill(
		NaN,
		Setting.NumberOf.StateParticle,
		Setting.NumberOf.ParameterParticle,
		TemperingLength
	)

	TransitionProbabilityMatrix = fill(
		NaN,
		Setting.NumberOf.DiscreteState,
		Setting.NumberOf.DiscreteState,
		Setting.NumberOf.ParameterParticle,
		TemperingLength
	)

	ParameterLogWeight = fill(
		NaN,
		Setting.NumberOf.ParameterParticle,
		TemperingLength
	)

	ComputationOverTempering = ComputationStruct(
		Parameter,
		State,
		Prediction,
		LogLikelihoodIncrement,
		LogLikelihood,
		StateParticle,
		PredictionStateParticle,
		StateParticleLogWeight,
		LastState,
		LastStateParticle,
		LastStateParticleLogWeight,
		TransitionProbabilityMatrix,
		ParameterLogWeight
	)

	return ComputationOverTempering

end

function make_AlgorithmComputation(Setting)

	TemperingLength = compute_TemperingLength(Setting)

	EffectiveSampleSizeParameterParticle =
	SharedArray{Float64}(
		TemperingLength
	)

	EffectiveSampleSizeStateParticle = SharedArray{Float64}(
		Setting.NumberOf.ParameterParticle,
		TemperingLength
	)

	AcceptanceBool = SharedArray{Bool}(
		Setting.NumberOf.ParameterParticle,
		TemperingLength
	)

	AcceptanceRatio = SharedArray{Float64}(
		TemperingLength
	)
	AcceptanceRatio .= NaN

	ParameterMean = SharedArray{Float64}(
		Setting.NumberOf.Parameter,
		TemperingLength + 1
	)

	ParameterFullCovariance = SharedArray{Float64}(
		Setting.NumberOf.Parameter,
		Setting.NumberOf.Parameter,
		TemperingLength + 1
	)
	for i in 1:Setting.NumberOf.Parameter
		ParameterFullCovariance[i, i, :] .=
			Setting.Input.McmcVarianceInitialisation
	end

	CovarianceScalingScalar = SharedArray{Float64}(
		TemperingLength
	)
	CovarianceScalingScalar .= 2.38

	ResampleThresholdDpf = SharedArray{Float64}(
		Setting.NumberOf.ParameterParticle,
		Setting.NumberOf.DataPoint
	)
	ResampleThresholdDpf .= NaN

	AlgorithmComputation = AlgorithmComputationStruct(
		EffectiveSampleSizeParameterParticle,
		EffectiveSampleSizeStateParticle,
		AcceptanceBool,
		AcceptanceRatio,
		ParameterMean,
		ParameterFullCovariance,
		CovarianceScalingScalar,
		ResampleThresholdDpf
	)

	return AlgorithmComputation

end

function compute_TemperingLength(Setting)

	if Setting.AlgorithmType == "Mcmc"

		TemperingLength = Setting.NumberOf.McmcStep

	elseif (Setting.AlgorithmType == "IbisData") | (Setting.AlgorithmType == "Filter")

		TemperingLength = Setting.NumberOf.DataPoint

	elseif 	Setting.AlgorithmType == "IbisDensity"

		TemperingLength = Setting.NumberOf.DensityPoint

	else

		error()

	end

	return TemperingLength

end

struct NumberOfStruct{
	T1<:Integer,
	T2<:AbstractArray
}
	Target::T1
	DataPoint::T1
	ParameterParticle::T1
	StateParticle::T1
	DiscreteState::T1
	DynamicStateParticle::T2
	LargestDynamicStateParticle::T1
	SecondLargestDynamicStateParticle::T1
	Parameter::T1
	State::T1
	McmcStep::T1
	McmcBlock::T1
	ParameterPrior::T1
	StatePrior::T1
	DensityPoint::T1
end

struct SettingStruct{
	T1<:ModelStruct,
	T2<:PriorStruct,
	T3<:DataStruct,
	T4<:InputSettingStruct,
	T8<:AbstractArray,
	T9<:AbstractArray,
	T10<:NumberOfStruct,
	T11<:AbstractString,
	T12<:Integer,
	T13<:AbstractArray,
	T14<:Float64
}
	Model::T1
	Prior::T2
	Data::T3
	Input::T4
	ParameterPriorIndex::T8
	StatePriorIndex::T9
	NumberOf::T10
	AlgorithmType::T11
	McmcUpdateIntervalLength::T12
	McmcLastUpdateIndex::T12
	DensityTemperingDifference::T13
	ResampleThresholdIbis::T14
end

struct ComputationStruct{
	T1<:AbstractArray,
	T2<:AbstractArray,
	T3<:AbstractArray,
	T4<:AbstractArray,
	T5<:AbstractArray,
	T6<:AbstractArray,
	T7<:AbstractArray,
	T8<:AbstractArray,
	T9<:AbstractArray,
	T10<:AbstractArray,
	T11<:AbstractArray,
	T12<:AbstractArray,
	T13<:AbstractArray
}
	Parameter::T1
	State::T2
	Prediction::T3
	LogLikelihoodIncrement::T4
	LogLikelihood::T5
	StateParticle::T6
	PredictionStateParticle::T7
	StateParticleLogWeight::T8
	LastState::T9
	LastStateParticle::T10
	LastStateParticleLogWeight::T11
	TransitionProbabilityMatrix::T12
	ParameterLogWeight::T13
end

struct AlgorithmComputationStruct{
	T1<:AbstractArray,
	T2<:AbstractArray,
	T3<:AbstractArray,
	T4<:AbstractArray,
	T5<:AbstractArray,
	T6<:AbstractArray,
	T7<:AbstractArray,
	T8<:AbstractArray
}
	EffectiveSampleSizeParameterParticle::T1
	EffectiveSampleSizeStateParticle::T2
	AcceptanceBool::T3
	AcceptanceRatio::T4
	ParameterMean::T5
	ParameterFullCovariance::T6
	CovarianceScalingScalar::T7
	ResampleThresholdDpf::T8
end
