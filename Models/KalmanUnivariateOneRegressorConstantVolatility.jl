function Observation(Regressor, Parameter, State)
	Normal(
		Parameter[1] + State[1] * Regressor[1],
		Parameter[2]
	)
end

KalmanUnivariateOneRegressorConstantVolatility = KalmanFilterStruct(
	Observation, # Observation
	function(Regressor, Parameter, State)
		reshape([Regressor[1]], 1, 1)
	end, # ObservationMatrixState
	function(Regressor, Parameter, State)
		Normal(
			State[1],
			Parameter[3]
		)
	end, # Transition
	function(Regressor, Parameter, State)
		reshape([1.0], 1, 1)
	end, # TransitionMatrixState
	1:1, # StateMeanIndex
	2:2, # StateCovarianceIndex
	1:1 # StateMeanEquationIndex
)

KalmanUnivariateOneRegressorConstantVolatilityPrior =
PriorStruct(
	[
		Normal(0.0, 0.001), Normal(0.1, 0.001), # Observation
		Normal(0.1, 0.001), # Transition
	], # ParameterPrior
	[
		Uniform(), # StateMean
		Uniform() # StateCovariance
	] # StatePrior
)
