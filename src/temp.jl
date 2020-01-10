using FileIO, JLD2

a = 5

write(
	a,
	joinpath(
		"/scratch",
		"tmp",
		"t_weig05",
		"Computation",
		Setting.Input.AlgorithmType,
		Setting.Input.ModelChoice,
	)
)
