using Plots

plot(Data.Target')

plot!(mean(Output[3].State[1, :, :], dims = 1)[1, :])
