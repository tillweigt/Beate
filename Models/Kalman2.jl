@sync @everywhere function Observation(Regressor, Parameter, State)
	Normal(
		State[1],
		Parameter[1]
	)
end

Kalman2 = KalmanFilterStruct(
	Observation = Observation,
	ObservationMatrixState = function(Regressor, Parameter, State)
		reshape([1.0], 1, 1)
	end,
	Transition = function(Regressor, Parameter, State)
		Normal(
			State[1],
			Parameter[2]
		)
	end,
	TransitionMatrixState = function(Regressor, Parameter, State)
		reshape([1.0], 1, 1)
	end,
	StateMeanIndex = 1:1,
	StateCovarianceIndex = 2:2,
	StateMeanEquationIndex = 1:1
)

# RealDataTimeVarying =
# DiscreteParticleFilterStruct(
# 	Filter = (
# 		ChangeNothing,
# 		ChangeTimeVarying
# 	),
# 	StateIndex = 1:2,
# 	MixtureStateIndex = 3,
# 	# TransitionProbabilityMatrixIndex = 4:7,
# 	# IsTransitionProbabilityMatrixFromState = false,
# 	TransitionProbabilityMatrixIndex = 4:7,
# 	IsTransitionProbabilityMatrixFromState = true
# )

Kalman2Prior =
PriorStruct(
	Parameter = [
		# Invariant(0.0),
		# Invariant(0.05), # Observation
		# Invariant(0.0),
		# Invariant(10.0), # Transition
		# Uniform(-1.0, 1.0),
		Uniform(),
		Uniform(),
		# Invariant(0.9), Invariant(0.1), # TransitionProbability
		# Invariant(0.9), Invariant(0.1)
	],
	State = [
		Invariant(0.0), Invariant(1.0), # Transition
		# Invariant(1.0),# MixtureTransition
		# Dirichlet(fill(1.0, 2)), # TransitionProbability
		# Dirichlet(fill(1.0, 2))
		# Invariant(0.95), Invariant(0.05), # TransitionProbability
		# Invariant(0.95), Invariant(0.05)
	]
)
