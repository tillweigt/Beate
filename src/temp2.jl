Path = pwd()
push!(LOAD_PATH, joinpath(Path, "src"))
using FileIO, JLD2, Beate, DataFrames, Plots, Statistics, Distributions

AlgorithmType = "IbisDataTempering"

ModelChoice = "WellLogManyOf1"

NumberOfDataPoint = 100

File = joinpath(
	Path,
	"Output",
	"Computation",
	AlgorithmType,
	ModelChoice,
	"JoinedAndReduced.jld2"
)

Parameter, State, TransitionProbabilityMatrix = load(
	File,
	"Parameter",
	"State",
	"TransitionProbabilityMatrix"
)

function temp()
Parameter1 = fill(NaN, 5, 1000, 100)
for loopNumber in 1:5

	Parameter1[loopNumber, :, :] = Parameter[loopNumber][1, :, :]
	Parameter2[loopNumber, :, :] = Parameter[loopNumber][2, :, :]
	Parameter3[loopNumber, :, :] = Parameter[loopNumber][3, :, :]

end
return Parameter1
end
Parameter1 = temp()

IndexCol1 = 1
IndexCol2 = 1

histogram(TransitionProbabilityMatrix[1][IndexCol1, IndexCol2, :, end])
histogram!(TransitionProbabilityMatrix[3][IndexCol1, IndexCol2, :, end])
histogram!(TransitionProbabilityMatrix[5][IndexCol1, IndexCol2, :, end])

plot(mean(TransitionProbabilityMatrix[1][IndexCol1, IndexCol2, :, :], dims = 1)[1, :])
plot!(mean(TransitionProbabilityMatrix[3][IndexCol1, IndexCol2, :, :], dims = 1)[1, :])
plot!(mean(TransitionProbabilityMatrix[5][IndexCol1, IndexCol2, :, :], dims = 1)[1, :])


PriorGrid[[1, 6, 11, 16]]
