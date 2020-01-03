Normal1 = NoFilterStruct(
	Observation = function(Regressor, Parameter, State)
		Normal(
			Parameter[1],
			Parameter[2]
		)
	end
)

Normal2 = NoFilterStruct(
	Observation = function(Regressor, Parameter, State)
		Normal(
			Parameter[3],
			Parameter[4]
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
		# Invariant(0.0), Invariant(0.05),
		# Invariant(1.0), Invariant(0.05),
		Uniform(-0.5, 0.5), Uniform(0.0, 0.5), # Observation
		Uniform(0.5, 1.5), Uniform(0.0, 0.5),
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
