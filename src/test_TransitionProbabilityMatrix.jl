using Plots

N = 10

temp = fill(NaN, 2, 2, 499, N)

for i in 1:N

	println(i)

	include(joinpath(Path,"src", "main.jl"))

	temp[:, :, :, i] = Output[3].TransitionProbabilityMatrix

end

plot(temp[1, 2, 100:end, :], legend = false)

include(joinpath(Path,"src", "main.jl"))

plot(Output[3].TransitionProbabilityMatrix[2, 2, 200:end])
