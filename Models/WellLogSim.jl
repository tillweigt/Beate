@sync @everywhere function Observation(Regressor, Parameter, State)
	Normal(
		State[1],
		Parameter[1]
	)
end

ChangeNothing = NoFilterStruct(
	Observation = Observation
)

ChangeToMean = KalmanFilterStruct(
	Observation = Observation,
	ObservationMatrixState = function(Regressor, Parameter, State)
		reshape([1.0], 1, 1)
	end,
	Transition = function(Regressor, Parameter, State)
		Normal(
			# 0.0,
			Parameter[2],
			# Parameter[2]
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

WellLogSim =
DiscreteParticleFilterStruct(
	Filter = (
		ChangeNothing,
		ChangeToMean
	),
	StateIndex = 1:2,
	MixtureStateIndex = 3,
	# TransitionProbabilityMatrixIndex = 4:7,
	# IsTransitionProbabilityMatrixFromState = false,
	TransitionProbabilityMatrixIndex = 4:7,
	IsTransitionProbabilityMatrixFromState = true
)

WellLogSimPrior =
PriorStruct(
	Parameter = [
		Invariant(0.1), # Observation
		Invariant(0.0),
		Invariant(1.0), # Transition
		# Uniform(), # Observation
		# Uniform(-5.0, 5.0),
		# Uniform(0.0, 10.0), # Transition
		# Invariant(0.9), Invariant(0.1), # TransitionProbability
		# Invariant(0.9), Invariant(0.1)
	],
	State = [
		Invariant(0.0), Invariant(1.0), # Transition
		Invariant(1.0), # MixtureTransition
		Dirichlet(fill(1.0, 2)), # TransitionProbability
		Dirichlet(fill(1.0, 2))
		# Invariant(0.9), Invariant(0.1), # TransitionProbability
		# Invariant(0.9), Invariant(0.1)
	]
)
