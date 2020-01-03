using Distributions, LinearAlgebra

function Observation(Regressor, Parameter, State)
	MvNormal(
		Parameter[1:2] .+ [State[1], State[2]] .* [Regressor[1], Regressor[1]],
		Diagonal(Parameter[3:4])
	)
end

KalmanMultivariateTwoRegressorConstantVolatility = KalmanFilterStruct(
	Observation, # Observation
	function(Regressor, Parameter, State)
		[[Regressor[1], 0.0] [0.0, Regressor[1]]]
	end, # ObservationMatrixState
	function(Regressor, Parameter, State)
		MvNormal(
			State[1:2],
			Parameter[5:6]
		)
	end, # Transition
	function(Regressor, Parameter, State)
		[[1.0, 0.0] [0.0, 1.0]]
	end, # TransitionMatrixState
	1:2, # StateMeanIndex
	3:6, # StateCovarianceIndex
	1:2 # StateMeanEquationIndex
)

KalmanMultivariateTwoRegressorConstantVolatilityPrior =
PriorStruct(
	[
		Normal(0.0, 0.001), Normal(0.0, 0.001),
		Normal(0.1, 0.001), Normal(0.1, 0.001), # ObservationMean
		Normal(0.1, 0.001), Normal(0.1, 0.001) # ObservationVariance
	], # ParameterPrior
	[
		[Uniform() for i in 1:2]..., # StateMean
		Normal(1.0, 0.001),
		Invariant(0.0),
		Invariant(0.0),
		Normal(1.0, 0.001) # StateCovariance
	] # StatePrior
)
