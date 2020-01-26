Normal1 = NoFilterStruct(
	Observation = function(Regressor, Parameter, State)
		Normal(
			0.0,
			Parameter[1]
		)
	end
)

Normal2 = NoFilterStruct(
	Observation = function(Regressor, Parameter, State)
		Normal(
			0.0,
			Parameter[2]
		)
	end
)

MixtureOfNormal =
DiscreteParticleFilterStruct(
	Filter = (
		Normal1,
		Normal2
	),
	StateIndex = 1:1,
	MixtureStateIndex = 2,
	# TransitionProbabilityMatrixIndex = 5:8,
	# IsTransitionProbabilityMatrixFromState = false,
	TransitionProbabilityMatrixIndex = 3:6,
	IsTransitionProbabilityMatrixFromState = true
)

MixtureOfNormalPrior =
PriorStruct(
	Parameter = [
		# Invariant(0.0), Invariant(0.1),
		# Invariant(0.2), Invariant(0.1),
		Uniform(0.0, 2.0), # Observation
		Uniform(0.0, 2.0),
		# Invariant(0.9), Invariant(0.1), # TransitionProbability
		# Invariant(0.1), Invariant(0.9)
	],
	State = [
		Invariant(NaN), # NotToUse
		Invariant(1.0), # MixtureTransition
		Dirichlet(fill(2.0, 2)), # TransitionProbability
		Dirichlet(fill(2.0, 2))
		# Invariant(0.9), Invariant(0.1), # TransitionProbability
		# Invariant(0.1), Invariant(0.9)
	]
)
