function Observation(Regressor, Parameter, State)
	Normal(
		Parameter[1] + State[1] * Regressor[1],
		Parameter[2]
	)
end

ChangeNothing = NoFilterStruct(
	Observation = Observation
)

ChangeToZero = KalmanFilterStruct(
	Observation = Observation, # Observation
	ObservationMatrixState = function(Regressor, Parameter, State)
		reshape([Regressor[1]], 1, 1)
	end,
	Transition = function(Regressor, Parameter, State)
		Normal(
			Parameter[3],
			Parameter[4]
		)
	end,
	TransitionMatrixState = function(Regressor, Parameter, State)
		reshape([0.0], 1, 1)
	end,
	StateMeanIndex = 1:1,
	StateCovarianceIndex = 2:2,
	StateMeanEquationIndex = 1:1
)

ChangeUnitRoot = KalmanFilterStruct(
	Observation = Observation,
	ObservationMatrixState = function(Regressor, Parameter, State)
		reshape([Regressor[1]], 1, 1)
	end,
	Transition = function(Regressor, Parameter, State)
		Normal(
			State[1],
			Parameter[5]
		)
	end,
	TransitionMatrixState = function(Regressor, Parameter, State)
		reshape([0.0], 1, 1)
	end,
	StateMeanIndex = 1:1,
	StateCovarianceIndex = 3:3,
	StateMeanEquationIndex = 1:1
)

DpfUnivariateOneRegressorConstantVolatility =
DiscreteParticleFilterStruct(
	Filter = (
		ChangeNothing,
		ChangeToZero,
		ChangeUnitRoot
	),
	StateIndex = 1:3,
	MixtureStateIndex = 4,
	# TransitionProbabilityMatrixIndex =  5:13,
	# IsTransitionProbabilityMatrixFromState =  false,
	TransitionProbabilityMatrixIndex = 5:13,
	IsTransitionProbabilityMatrixFromState = true
)

DpfUnivariateOneRegressorConstantVolatilityPrior =
PriorStruct(
	Parameter = [
		Invariant(0.0), Invariant(0.1), # Observation
		Invariant(1.0), Invariant(0.1), # ChangeToZero
		Invariant(0.1)#, # ChangeUnitRoot
		# Invariant(0.0), Invariant(0.0), Invariant(1.0), # TransitionProbability
		# Invariant(0.0), Invariant(0.0), Invariant(1.0), # TransitionProbability
		# Invariant(0.0), Invariant(0.0), Invariant(1.0) # TransitionProbability
	],
	State = [
		Invariant(1.0), # StateMean
		Invariant(1.0), # StateCovariance of ChangeToZero
		Invariant(1.0), # StateCovariance of ChangeUnitRoot
		Categorical(fill(1/3, 3)), # MixtureState
		Dirichlet(fill(1.0, 3)), # TransitionProbability
		Dirichlet(fill(1.0, 3)),
		Dirichlet(fill(1.0, 3))
		# Invariant(1.0), Invariant(0.0), Invariant(0.0), # TransitionProbability
		# Invariant(1.0), Invariant(0.0), Invariant(0.0),
		# Invariant(1.0), Invariant(0.0), Invariant(0.0)
	]
)
