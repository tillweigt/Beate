using Plots

Output = include(joinpath(pwd(), "src", "main.jl"))
temp = Output[3]

plot(Data.Target[1, :])
plot!(temp.Prediction[1, 1, :])

plot(Data.State[1, :])
plot!(temp.State[6, 1, :])

temp2 = reshape(temp.State[2:5, 1, :], 2, 2, size(Data.Target, 2))
for i in 1:size(Data.Target, 2)
	temp2[:, :, i] ./= sum(temp2[:, :, i], dims = 1)
end
plot(temp2[:, 2, :]')

N = 10
temp3 = fill(NaN, 2, 2, N)
for j in 1:N
	print(j)
	Output2 = include(joinpath(pwd(), "src", "main.jl"))
	temp = Output2[3]
	temp2 = reshape(temp.State[3:6, 1, :], 2, 2, size(Data.Target, 2))
	for i in 1:size(Data.Target, 2)
		temp2[:, :, i] ./= sum(temp2[:, :, i], dims = 1)
	end
	temp3[:, :, j] = temp2[: , :, end]
end
scatter(temp3[2, 2, :])

plot(temp.State[3:6, 1, 1:50]')

plot(temp.StateParticleLogWeight[258, 1, 15])

plot(temp.StateParticle[6, 256, 1, 15])
