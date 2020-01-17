@sync @everywhere function Observation(Regressor, Parameter, State)
	Normal(
		Parameter[1] + Parameter[2] * Regressor[1],
		Parameter[3]
	)
end

SimpleRegression = NoFilterStruct(
	Observation = Observation
)

SimpleRegressionPrior =
PriorStruct(
	Parameter = [
		Uniform(-1.0, 1.0),
		Uniform(-1.0, 1.0),
		Uniform()
	],
	State = Array{Distribution}(undef, 0)
)
