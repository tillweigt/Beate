abstract type ModelStruct end

struct NoFilterStruct{
	T1<:Function
}<:ModelStruct
	Observation::T1
end

struct KalmanFilterStruct{
	T1<:Function,
	T2<:Function,
	T3<:Function,
	T4<:Function
}<:ModelStruct
	Observation::T1
	ObservationMatrixState::T2
	Transition::T3
	TransitionMatrixState::T4
end

struct DiscreteParticleFilterStruct{
	T1<:Tuple,
	T2<:Bool
}<:ModelStruct
	Filter::T1
	IsTransitionProbabilityMatrixFromState::T2
	IsChangePointModel::T2
end

struct PriorStruct{
	T1<:AbstractArray,
	T2<:AbstractArray
}
	Parameter::T1
	State::T2
end

struct DataStruct{
	T1<:AbstractArray,
	T2<:AbstractArray,
	T3<:AbstractArray
}
	Target::T1
	Regressor::T2
	State::T3
end

function logpdf2(d::UnivariateDistribution, x::AbstractArray)
	return logpdf.(d, x)
end

function logpdf2(d::MultivariateDistribution, x::AbstractArray)
	return logpdf(d, x)
end

@with_kw struct GeneralSettingStruct{
	T1<:Integer,
	T2<:Function
}
	NumberOfParameterParticle::T1 = 1
	NumberOfStateParticle::T1 = 1
	ScoringRule::T2 = logpdf2
end

@with_kw struct IbisSettingStruct{
	T1<:AbstractArray
}
	A::T1 = [1.0]
end

@with_kw struct McmcSettingStruct{
	T1<:Integer
}
	NumberOfMcmcStep::T1 = 1
	NumberOfMcmcBlock::T1 = 1
end

@with_kw struct FilterSettingStruct{
	T1<:AbstractArray
}
	A::T1 = [1.0]
end
