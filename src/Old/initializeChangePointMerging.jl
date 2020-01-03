function initialize(Model, Prior, Data, InputSetting)

	Setting = make_Setting(
		Model, Prior, Data,
		InputSetting
	)

	Computation = make_Computation( Prior, Setting)

	ComputationOverTempering =
	make_ComputationOverTempering(Setting)

	AlgorithmComputation =	make_AlgorithmComputation(
		Setting
	)

	return Setting,
 	Computation,
	ComputationOverTempering,
	AlgorithmComputation

end

function make_Setting(
	Model, Prior, Data,
	InputSetting
)

	GeneralSetting,
	IbisSetting,
	McmcSetting,
	FilterSetting = unfold_InputSetting(InputSetting)

	NumberOfDynamicStateParticle,
	LargestDynamicStateParticle,
	SecondLargestDynamicStateParticle =
	make_NumberOfDynamicStateParticle(
		Model,
		size(Data.Target, 2),
		GeneralSetting.NumberOfStateParticle
	)

	NumberOf = NumberOfStruct(
		size(Data.Target, 1),
		size(Data.Target, 2),
		GeneralSetting.NumberOfParameterParticle,
		GeneralSetting.NumberOfStateParticle,
		make_NumberOfDiscreteState(Model),
		NumberOfDynamicStateParticle,
		LargestDynamicStateParticle,
		SecondLargestDynamicStateParticle,
		make_NumberOfLatent(Prior.Parameter),
		make_NumberOfLatent(Prior.State),
		McmcSetting.NumberOfMcmcStep,
		McmcSetting.NumberOfMcmcBlock,
		length(Prior.Parameter),
		length(Prior.State)
	)

	Setting = SettingStruct(
		Model,
		Prior,
		Data,
		GeneralSetting,
		IbisSetting,
		McmcSetting,
		FilterSetting,
		make_PriorIndex(Prior.Parameter),
		make_PriorIndex(Prior.State),
		NumberOf
	)

	return Setting

end

function unfold_InputSetting(InputSetting)

	AllSetting = (
		IbisSettingStruct,
		McmcSettingStruct,
		FilterSettingStruct
	)

	SettingTuple = (InputSetting[1],)

	for i in 1:length(AllSetting)

		if any(
			AllSetting[i] .== map(typeof, InputSetting)
		)

			SettingTuple = (
				SettingTuple...,
				InputSetting[i]
			)

		else

			SettingTuple = (
				SettingTuple...,
				AllSetting[i]()
			)

		end

	end

	return SettingTuple

end

function make_NumberOfDiscreteState(Model)

	if typeof(Model) <: DiscreteParticleFilterStruct

		NumberOfDiscreteState = length(Model.Filter)

	else

		NumberOfDiscreteState = NaN

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

			if Model.IsChangePointModel

				NumberOfDynamicStateParticle[dataPoint] =
					(NumberOfDiscreteState - 1) *
					NumberOfDynamicStateParticle[
						dataPoint - 1
					] + 1

			else

				NumberOfDynamicStateParticle[dataPoint] =
					NumberOfDiscreteState *
					NumberOfDynamicStateParticle[
						dataPoint - 1
					]

			end

		end

		NumberOfDynamicStateParticle =
			NumberOfDynamicStateParticle[2:end]

		TruncationIndex =
			NumberOfDynamicStateParticle .>
			NumberOfStateParticle

		NumberOfDynamicStateParticle[TruncationIndex] .=
			maximum(
				NumberOfDynamicStateParticle[.!TruncationIndex]
			)

	else

		NumberOfDynamicStateParticle = [NaN]

	end

	DynamicStateParticleSorted = unique(sort(
		NumberOfDynamicStateParticle, rev = true
	))

	LargestDynamicStateParticle =
		DynamicStateParticleSorted[1]

	SecondLargestDynamicStateParticle =
		DynamicStateParticleSorted[2]


	return NumberOfDynamicStateParticle,
		LargestDynamicStateParticle,
		SecondLargestDynamicStateParticle

end

function make_Computation(Prior, Setting)

	Parameter = SharedArray{Float64}(
		Setting.NumberOf.Parameter,
		Setting.NumberOf.ParameterParticle
	)

	for i in 1:Setting.NumberOf.ParameterPrior

		Parameter[Setting.ParameterPriorIndex[i], :] = rand(
			Prior.Parameter[i],
			Setting.NumberOf.ParameterParticle
		)

	end

	StateParticle = SharedArray{Float64}(
		Setting.NumberOf.State,
		Setting.NumberOf.StateParticle,
		Setting.NumberOf.ParameterParticle
	)

	for i in 1:Setting.NumberOf.StatePrior
		for j in 1:Setting.NumberOf.ParameterParticle

			StateParticle[Setting.StatePriorIndex[i],  :, j] =
			rand(
				Prior.State[i],
				Setting.NumberOf.StateParticle
			)

		end
	end

	State = SharedArray{Float64}(
		Setting.NumberOf.State,
		Setting.NumberOf.ParameterParticle
	)

	State .= dropdims(
		mean(StateParticle, dims = 2),
		dims = 2
	)

	Prediction = SharedArray{Float64}(
		Setting.NumberOf.Target,
		Setting.NumberOf.ParameterParticle
	)
	Prediction .= NaN

	PredictionStateParticle = SharedArray{Float64}(
		Setting.NumberOf.Target,
		Setting.NumberOf.StateParticle,
		Setting.NumberOf.ParameterParticle
	)
	PredictionStateParticle .= NaN

	LogLikelihoodIncrement = SharedArray{Float64}(
		Setting.NumberOf.ParameterParticle
	)
	LogLikelihoodIncrement .= NaN

	LogLikelihood = SharedArray{Float64}(
		Setting.NumberOf.ParameterParticle
	)
	LogLikelihood .= 0.0

	ParameterWeight = SharedArray{Float64}(
		Setting.NumberOf.ParameterParticle
	)
	ParameterWeight .= log(
		1 / Setting.NumberOf.ParameterParticle
	)

	StateParticleLogWeight = SharedArray{Float64}(
		Setting.NumberOf.StateParticle,
		Setting.NumberOf.ParameterParticle
	)
	StateParticleLogWeight .= log(
		1 / Setting.NumberOf.StateParticle
	)

	Computation = ComputationStruct(
		Parameter,
		State,
		Prediction,
		LogLikelihoodIncrement,
		LogLikelihood,
		StateParticle,
		PredictionStateParticle,
		ParameterWeight,
		StateParticleLogWeight
	)

	return Computation

end

function make_ComputationOverTempering(Setting)

	TemperingLength = Setting.NumberOf.DataPoint

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
		Setting.NumberOf.Target,
		Setting.NumberOf.ParameterParticle,
		TemperingLength
	)

	LogLikelihood = fill(
		NaN,
		Setting.NumberOf.Target,
		Setting.NumberOf.ParameterParticle,
		TemperingLength
	)

	ParameterWeight = fill(
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

	ComputationOverTempering = ComputationStruct(
		Parameter,
		State,
		Prediction,
		LogLikelihoodIncrement,
		LogLikelihood,
		StateParticle,
		PredictionStateParticle,
		ParameterWeight,
		StateParticleLogWeight
	)

	return ComputationOverTempering

end

function make_AlgorithmComputation(Setting)

	TemperingLength = Setting.NumberOf.DataPoint

	EffectiveSampleSizeParameterParticle =
	SharedArray{Float64}(
		TemperingLength
	)

	EffectiveSampleSizeStateParticle = SharedArray{Float64}(
		Setting.NumberOf.ParameterParticle,
		TemperingLength
	)

	AcceptanceRatio = SharedArray{Float64}(
		Setting.NumberOf.McmcBlock,
		Setting.NumberOf.ParameterParticle,
		TemperingLength
	)

	ParameterMean = SharedArray{Float64}(
		Setting.NumberOf.Parameter,
		TemperingLength
	)

	ParameterFullCovariance = SharedArray{Float64}(
		Setting.NumberOf.Parameter,
		Setting.NumberOf.Parameter,
		TemperingLength
	)

	CovarianceScaling = SharedArray{Float64}(
		1,
		TemperingLength
	)

	AlgorithmComputation = AlgorithmComputationStruct(
		EffectiveSampleSizeParameterParticle,
		EffectiveSampleSizeStateParticle,
		AcceptanceRatio,
		ParameterMean,
		ParameterFullCovariance,
		CovarianceScaling
	)

	return AlgorithmComputation

end

struct NumberOfStruct{
	T1<:Integer,
	T2<:AbstractArray
}
	Target::T1
	DataPoint::T1
	ParameterParticle::T1
	StateParticle::T1
	DynamicStateParticle::T2
	LargestDynamicStateParticle::T1
	SecondLargestDynamicStateParticle::T1
	DiscreteState::T1
	Parameter::T1
	State::T1
	McmcStep::T1
	McmcBlock::T1
	ParameterPrior::T1
	StatePrior::T1
end

struct SettingStruct{
	T1<:ModelStruct,
	T2<:PriorStruct,
	T3<:DataStruct,
	T4<:GeneralSettingStruct,
	T5<:IbisSettingStruct,
	T6<:McmcSettingStruct,
	T7<:FilterSettingStruct,
	T8<:AbstractArray,
	T9<:AbstractArray,
	T10<:NumberOfStruct
}
	Model::T1
	Prior::T2
	Data::T3
	General::T4
	Ibis::T5
	Mcmc::T6
	Filter::T7
	ParameterPriorIndex::T8
	StatePriorIndex::T9
	NumberOf::T10
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
	T9<:AbstractArray
}
	Parameter::T1
	State::T2
	Prediction::T3
	LogLikelihoodIncrement::T4
	LogLikelihood::T5
	StateParticle::T6
	PredictionStateParticle::T7
	ParameterWeight::T8
	StateParticleLogWeight::T9
end

struct AlgorithmComputationStruct{
	T1<:AbstractArray,
	T2<:AbstractArray,
	T3<:AbstractArray,
	T4<:AbstractArray,
	T5<:AbstractArray,
	T6<:AbstractArray
}
	EffectiveSampleSizeParameterParticle::T1
	EffectiveSampleSizeStateParticle::T2
	AcceptanceRatio::T3
	ParameterMean::T4
	ParameterFullCovariance::T5
	CovarianceScaling::T6
end
