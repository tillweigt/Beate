@sync @everywhere function Observation1(Regressor, Parameter, State)
	Normal(
		Parameter[1] + Parameter[2] * Regressor[1],
		Parameter[3]
	)
end

@sync @everywhere function Observation2(Regressor, Parameter, State)
	Normal(
		Parameter[1] + Parameter[2] * Regressor[1],
		Parameter[4]
	)
end

@sync @everywhere function Observation3(Regressor, Parameter, State)
	Normal(
		Parameter[1] + Parameter[2] * Regressor[1],
		Parameter[5]
	)
end

Model1 = NoFilterStruct(
	Observation = Observation1
)

Model2 = NoFilterStruct(
	Observation = Observation2
)

Model3 = NoFilterStruct(
	Observation = Observation3
)

RealDataMixture =
DiscreteParticleFilterStruct(
	Filter = (
		Model1,
		Model2,
		Model3
	),
	StateIndex = 1:1,
	MixtureStateIndex = 2,
	# TransitionProbabilityMatrixIndex = 4:7,
	# IsTransitionProbabilityMatrixFromState = false,
	TransitionProbabilityMatrixIndex = 3:11,
	IsTransitionProbabilityMatrixFromState = true
)

RealDataMixturePrior =
PriorStruct(
	Parameter = [
		Uniform(-1.0, 1.0),
		Uniform(-1.0, 1.0),
		Uniform(),
		Uniform(),
		Uniform()
	],
	State = [
		Invariant(0.0), Invariant(1.0),
		Dirichlet(fill(1.0, 3)), # TransitionProbability
		Dirichlet(fill(1.0, 3)),
		Dirichlet(fill(1.0, 3))
	]
)
