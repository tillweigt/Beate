@sync @everywhere function Observation(Regressor, Parameter, State)
	Normal(
		Parameter[1] + State[1] * Regressor[1],
		Parameter[2]
	)
end

ChangeToZero = KalmanFilterStruct(
	Observation = Observation,
	ObservationMatrixState = function(Regressor, Parameter, State)
		reshape([Regressor[1]], 1, 1)
	end,
	Transition = function(Regressor, Parameter, State)
		Normal(
			0.0,
			Parameter[3]
		)
	end,
	TransitionMatrixState = function(Regressor, Parameter, State)
		reshape([0.0], 1, 1)
	end,
	StateMeanIndex = 1:1,
	StateCovarianceIndex = 2:2,
	StateMeanEquationIndex = 1:1
)

ChangeTimeVarying = KalmanFilterStruct(
	Observation = Observation,
	ObservationMatrixState = function(Regressor, Parameter, State)
		reshape([Regressor[1]], 1, 1)
	end,
	Transition = function(Regressor, Parameter, State)
		Normal(
			State[1],
			Parameter[4]
		)
	end,
	TransitionMatrixState = function(Regressor, Parameter, State)
		reshape([1.0], 1, 1)
	end,
	StateMeanIndex = 1:1,
	StateCovarianceIndex = 3:3,
	StateMeanEquationIndex = 1:1
)

RealDataZero =
DiscreteParticleFilterStruct(
	Filter = (
		ChangeToZero,
		ChangeTimeVarying
	),
	StateIndex = 1:3,
	MixtureStateIndex = 4,
	# TransitionProbabilityMatrixIndex = 4:7,
	# IsTransitionProbabilityMatrixFromState = false,
	TransitionProbabilityMatrixIndex = 5:8,
	IsTransitionProbabilityMatrixFromState = true
)

RealDataZeroPrior =
PriorStruct(
	Parameter = [
		# Invariant(0.0),
		# Invariant(0.05), # Observation
		# Invariant(0.0),
		# Invariant(10.0), # Transition
		Uniform(-0.5, 0.5),
		Uniform(0.0, 0.2),
		Uniform(0.0, 0.5),
		Uniform(0.0, 0.5),
		# Invariant(0.9), Invariant(0.1), # TransitionProbability
		# Invariant(0.9), Invariant(0.1)
	],
	State = [
		Invariant(0.0), Invariant(1.0), # Transition
		Invariant(1.0), Invariant(1.0),# MixtureTransition
		Dirichlet(fill(1.0, 2)), # TransitionProbability
		Dirichlet(fill(1.0, 2))
		# Invariant(0.95), Invariant(0.05), # TransitionProbability
		# Invariant(0.95), Invariant(0.05)
	]
)
