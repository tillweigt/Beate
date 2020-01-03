NumberOfDataPoint = 100

Target = fill(0.0, 1, NumberOfDataPoint + 1)

State = fill(1, 1, NumberOfDataPoint + 1)

Parameter = [0.0, 0.05, 1.0, 0.05]

TransitionProbabilityMatrix = [[0.95, 0.05] [0.05, 0.95]]

for dataPoint in 1:NumberOfDataPoint

	if State[1, dataPoint] == 1

		State[1, dataPoint + 1] = sample(
			[1, 2],
			weights(TransitionProbabilityMatrix[:, 1])
		)

		Target[1, dataPoint + 1] = rand(Normal(
			Parameter[1],
			Parameter[2]
		))

	else

		State[1, dataPoint + 1] = sample(
			[1, 2],
			weights(TransitionProbabilityMatrix[:, 2])
		)

		Target[1, dataPoint + 1] = rand(Normal(
			Parameter[3],
			Parameter[4]
		))

	end

end

# plot(Target[1, 2:end])
# plot(State[1, 2:end])

MarkovMixture = DataStruct(
	Target[:, 2:end],
	fill(NaN, 1, NumberOfDataPoint),
	State[:, 2:end]
)

save(
	joinpath(pwd(), "Data", "MarkovMixture.jld2"), "MarkovMixture", MarkovMixture
)
