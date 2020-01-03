using Plots

plot(Data.Regressor[1, :])

plot(Data.Target[1, :])
plot!(Output[3].Prediction[1, 1, :])

plot(Data.State[1, :])
plot!(Output[3].State[1, 1, :])

plot(Data.State[3, :])
plot!(round.(Output[3].State[3, 1, :], digits = 8))

plot(Output[3].StateParticleLogWeight[:, 1, end])

plot(Output[3].LogLikelihoodIncrement[1, :])

plot(Output[3].LogLikelihood[1, :])

Output[3].TransitionProbabilityMatrix

plot(Output[4].ResampleThreshold')
