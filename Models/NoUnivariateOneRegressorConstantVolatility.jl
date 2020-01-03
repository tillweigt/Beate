function Observation(Regressor, Parameter, State)
	Normal(
		Parameter[1],# + Parameter[2] * Regressor[1],
		Parameter[2]
	)
end

NoUnivariateOneRegressorConstantVolatility = NoFilterStruct(
	Observation,
	(Regressor, Parameter, State) -> Invariant(State[1])
)

NoUnivariateOneRegressorConstantVolatilityPrior =
PriorStruct(
	[
		Uniform(0.0, 100.0),# Uniform(-1.0, 1.0), # ObservationMean
		Uniform(), # ObservationVariance
	], # ParameterPrior
	# Array{Distribution}(undef, 0) # StatePrior
	[Uniform()]
)
