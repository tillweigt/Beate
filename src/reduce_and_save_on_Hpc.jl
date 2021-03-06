Path = pwd()
push!(LOAD_PATH, joinpath(Path, "src"))
using FileIO, JLD2, Beate, DataFrames

AlgorithmType = "IbisDataTempering"

ModelChoice = ARGS[1]

NumberOfParameterParticle = ARGS[2]

NumberOfStateParticle = 128

NumberOfMcmcStep = 1

NumberOfDensityPoint = 1

ComputationLoopNumber = ARGS[3]

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
	"_DP_" * string(NumberOfDensityPoint) *
	"_CLN_" * string(ComputationLoopNumber) *
	".jld2"
)

# Setting = load(
# 	File2,
# 	"Setting"
# 	# "Computation",
# 	# "ComputationOverTempering"#,
# 	# "AlgorithmComputation"
# )

ComputationOverTempering = load(
	File2,
	# "Setting",
	# "Computation",
	"ComputationOverTempering"#,
	# "AlgorithmComputation"
)

save(
	joinpath(
		File,
		"temp.jld2"
	),
	# "Data",
	# Setting.Data,
	"State",
	ComputationOverTempering.State,
	"Prediction",
	ComputationOverTempering.Prediction,
	"TransitionProbability",
	ComputationOverTempering.TransitionProbabilityMatrix,
	"Parameter",
	ComputationOverTempering.Parameter
)
