using Distributions, LinearAlgebra

function Observation(Regressor, Parameter, State)
	MvNormal(
		Parameter[1:2] .+ [State[1], Parameter[3]] .* [Regressor[1], Regressor[1]],
		Diagonal(Parameter[4:5])
	)
end

KalmanMultivariateOneRegressorConstantVolatility = KalmanFilterStruct(
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

KalmanMultivariateOneRegressorConstantVolatilityPrior =
PriorStruct(
	[
		Normal(0.0, 0.001), Normal(0.0, 0.001),
		Normal(1.0, 0.001), # ObservationMean
		Normal(0.1, 0.001), Normal(0.1, 0.001) # ObservationVariance
	], # ParameterPrior
	[
		Uniform(), # StateMean
		Uniform() # StateCovariance
	] # StatePrior
)
