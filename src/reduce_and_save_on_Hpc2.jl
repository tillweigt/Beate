Path = pwd()
push!(LOAD_PATH, joinpath(Path, "src"))
using FileIO, JLD2, Beate, DataFrames

AlgorithmType = "IbisDataTempering"

ModelChoice = ARGS[1]

NumberOfParameterParticle = ARGS[2]

NumberOfStateParticle = 128

NumberOfMcmcStep = 1

NumberOfDensityPoint = 1

ComputationLoopNumber = eval(Meta.parse(ARGS[3]))

File = joinpath(
	"/scratch",
	"tmp",
	"t_weig05",
	"Computation",
	AlgorithmType,
	ModelChoice
)

File2 = joinpath(
	File,
	"PP_" * string(NumberOfParameterParticle) *
	"_SP_" * string(NumberOfStateParticle) *
	"_MS_" * string(NumberOfMcmcStep) *
	"_DP_" * string(NumberOfDensityPoint)
)

Parameter = missing

State = missing

TransitionProbabilityMatrix = missing

for loopNumber in ComputationLoopNumber

	ComputationOverTempering = load(
		File2 *
		"_CLN_" * string(loopNumber) *
		".jld2",
		"ComputationOverTempering"
	)

	if loopNumber == ComputationLoopNumber[1]

		Parameter = (ComputationOverTempering.Parameter,)

		State = (ComputationOverTempering.State,)

		TransitionProbabilityMatrix = (ComputationOverTempering.TransitionProbabilityMatrix,)

	else

		Parameter = (Parameter..., ComputationOverTempering.Parameter)

		State = (State..., ComputationOverTempering.State)

		TransitionProbabilityMatrix = (TransitionProbabilityMatrix..., ComputationOverTempering.TransitionProbabilityMatrix)

	end

end

save(
	joinpath(
		File,
		"JoinedAndReduced.jld2"
	),
	"Parameter",
	Parameter
	"State",
	State,
	"TransitionProbabilityMatrix",
	TransitionProbabilityMatrix
)
