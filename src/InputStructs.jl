abstract type ModelStruct end

@with_kw struct NoFilterStruct{
	T1<:Function,
	T2<:Function
}<:ModelStruct
	Observation::T1
	Transition::T2 = (Regressor, Parameter, State) -> Invariant(State[1])
end

@with_kw struct KalmanFilterStruct{
	T1<:Function,
	T2<:Function,
	T3<:Function,
	T4<:Function,
	T5<:AbstractArray,
	T6<:AbstractArray,
	T7<:AbstractArray
}<:ModelStruct
	Observation::T1
	ObservationMatrixState::T2
	Transition::T3
	TransitionMatrixState::T4
	StateMeanIndex::T5
	StateCovarianceIndex::T6
	StateMeanEquationIndex::T7
end

@with_kw struct DiscreteParticleFilterStruct{
	T1<:Tuple,
	T2<:AbstractArray,
	T3<:Integer,
	T4<:AbstractArray,
	T5<:Bool,
	T6<:Symbol
}<:ModelStruct
	Filter::T1
	StateIndex::T2
	MixtureStateIndex::T3
	TransitionProbabilityMatrixIndex::T4
	IsTransitionProbabilityMatrixFromState::T5
	ResampleScheme::T6 = :MultinomialResampling
end

@with_kw struct PriorStruct{
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
	return logpdf.(d, x)[1]
end

function logpdf2(d::MultivariateDistribution, x::AbstractArray)
	return logpdf(d, x)[1]
end

@with_kw struct InputSettingStruct{
	T1<:Integer,
	T2<:Function,
	T3<:Symbol,
	T4<:Bool,
	T5<:Float64,
	T6<:AbstractString
}
	NumberOfParameterParticle::T1 = 1
	NumberOfStateParticle::T1 = 1
	ScoringRule::T2 = logpdf2
	NumberOfMcmcStep::T1 = 1
	NumberOfMcmcBlock::T1 = 1
	NumberOfDensityPoint::T1 = 1
	McmcUpdateIntervalLength::T1 = 1
	McmcLastUpdateIndex::T1 = 1
	ResampleScheme::T3 = :MultinomialResampling
	PrintEach::T1 = 0
	CovarianceScaling::T4 = false
	McmcVarianceInitialisation::T5 = 1.0
	McmcFullCovariance::T4 = true
	ResampleThresholdIbis::T5 = 1.1
	Path::T6 = pwd()
	SaveOutput::T4 = true
	ModelChoice::T6
	AlgorithmType::T6
	ComputationLoopNumber::T1 = 1
end
