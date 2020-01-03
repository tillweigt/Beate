using Distributions, Plots

NumberOfDataPoint = 100

Target = fill(0.0, 1, NumberOfDataPoint + 1)

State = fill(0.0, 2, NumberOfDataPoint + 1)

State[2, 1] = 1.0

Parameter = [0.01, 0.0, 0.01]

TransitionProbabilityMatrix = [[0.95, 0.05] [0.05, 0.95]]

for dataPoint in 1:NumberOfDataPoint

	if State[2, dataPoint] == 1

		State[1, dataPoint + 1] = State[1, dataPoint]

		State[2, dataPoint + 1] = sample(
			[1, 2],
			weights(TransitionProbabilityMatrix[:, 1])
		)

	else

		State[1, dataPoint + 1] = rand(Normal(
			# Parameter[2], Parameter[3]
			State[1, dataPoint], Parameter[3]
		))

		State[2, dataPoint + 1] = sample(
			[1, 2],
			weights(TransitionProbabilityMatrix[:, 2])
		)

	end

	Target[1, dataPoint + 1] = rand(Normal(
		State[1, dataPoint + 1],
		Parameter[1]
	))

end

plot(Target[1, 2:end])
plot(State[2, 2:end])

# struct DataStruct{
# 	T1<:AbstractArray,
# 	T2<:AbstractArray,
# 	T3<:AbstractArray
# }
# 	Target::T1
# 	Regressor::T2
# 	State::T3
# end

# WellLog = DataStruct(
# 	Target[:, 2:end],
# 	fill(NaN, 1, NumberOfDataPoint),
# 	State[:, 2:end]
# )
#
# save(joinpath(pwd(), "Data", "WellLog.jld2"), "WellLog", WellLog)
