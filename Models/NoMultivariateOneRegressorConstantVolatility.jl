using Distributions, LinearAlgebra

function Observation(Regressor, Parameter, State)
	MvNormal(
		Parameter[1:2] .+ Parameter[3:4]' * [Regressor[1], Regressor[1]],
		Diagonal(Parameter[5:6])
	)
end

NoMultivariateOneRegressorConstantVolatility = NoFilterStruct(
	Observation,
	(Regressor, Parameter, State) -> Invariant(State[1])
)

NoMultivariateOneRegressorConstantVolatilityPrior =
PriorStruct(
	[
		Normal(1.0, 0.001), Normal(1.0, 0.001),
		Normal(0.0, 0.001), Normal(0.0, 0.001), # ObservationMean
		Normal(0.1, 0.001), Normal(0.1, 0.001) # ObservationVariance
	], # ParameterPrior
	Array{Distribution}(undef, 0) # StatePrior
)
