function run_Algorithm(
	Model,
	Prior,
	Data,
	InputSetting,
	AlgorithmType
)

	Algorithm =
	getfield(
		Beate,
		AlgorithmType
	)

	Output =
	Algorithm(
		Model,
		Prior,
		Data,
		InputSetting
	)

	save_Output(
		Output...
	)

	return Output

end

function make_PriorIndex(Prior)

	PriorIndex = [0:0]

	for i in 1:length(Prior)

		push!(
			PriorIndex,
			PriorIndex[end][end] + 1:PriorIndex[end][end] + length(Prior[i])
		)

	end

	return PriorIndex[2:end]

end

function make_NumberOfLatent(Prior)

	NumberOfLatent = 0

	for prior in Prior
		NumberOfLatent += length(prior)
	end

	return NumberOfLatent

end

function print_and_save_on_the_fly(
	Setting,
	Computation,
	ComputationProposal,
	AlgorithmComputation,
	TemperingPoint
)

	if !iszero(Setting.Input.PrintEach)
		if iszero(mod(TemperingPoint, Setting.Input.PrintEach))

			printstyled(
				color = :green,
				"TemperingPoint: ", TemperingPoint,
				"\n"
			)

			println(
				"CovarianceScalingScalar: ",
				AlgorithmComputation.CovarianceScalingScalar[TemperingPoint]
			)

			println(
				"MeanOfParameter: ",
				mean(Computation.Parameter, dims = 2)
			)

			println(
				"StandardDeviationOfParameter: ",
				std(Computation.Parameter, dims = 2)
			)

			println(
				"McmcProposalStandardDeviation: ",
				sqrt.(diag(
					AlgorithmComputation.ParameterFullCovariance[:, :, TemperingPoint + 1]
				))
			)

			# println(
			# 	"ParameterFullCovariance: ",
			# 	AlgorithmComputation.ParameterFullCovariance[:, :, TemperingPoint]
			# )

			println(
				"AcceptanceRatio: ",
				AlgorithmComputation.AcceptanceRatio[TemperingPoint]
			)

			println(
				"EffectiveSampleSizeParameterParticle: ",
				AlgorithmComputation.EffectiveSampleSizeParameterParticle[TemperingPoint]
			)

			println(
				"State: ",
				mean(Computation.State, dims = 2)
			)

			println(
				"TransitionProbabilityMatrix: ",
				mean(Computation.TransitionProbabilityMatrix, dims = 3)
			)

			println(
				"LogLikelihoodIncrement: ",
				log(mean(exp.(Computation.LogLikelihoodIncrement)))
			)

			println(
				"LogLikelihood: ",
				log(mean(exp.(Computation.LogLikelihood)))
			)

			println(
				"LogLikelihoodProposal: ",
				log(mean(exp.(ComputationProposal.LogLikelihood)))
			)

			# println(
			# 	"ResampleThresholdDpf: ",
			# 	mean(
			# 		AlgorithmComputation.ResampleThresholdDpf[:,
			# 			TemperingPoint
			# 		]
			# 	)
			# )

		end
	end

	save_print_on_the_fly(
		Setting,
		Computation,
		ComputationProposal,
		AlgorithmComputation,
		TemperingPoint
	)

	return nothing

end

function save_print_on_the_fly(
	Setting,
	Computation,
	ComputationProposal,
	AlgorithmComputation,
	TemperingPoint
)

	open(
		joinpath(
			Setting.Input.Path,
			"ComputationDiagnostics",
			"test" *
			".txt"
		),
		"a"
	) do File

		write(
			File,
			"\n", "\n",
			"TemperingPoint: ", string(TemperingPoint)
		)

	end

	return nothing

end

function save_Output(
	Setting,
	Computation,
	ComputationOverTempering,
	AlgorithmComputation
)

	if Setting.Input.SaveOutput

		File = joinpath(
			Setting.Input.Path,
			"Output",
			"test"
		)

		try
			mkdir(
				File
			)
		catch
		end

		save(
			joinpath(
				File,
				"test" *
				".jld2"
			),
			"Setting", Setting,
			"Computation", Computation,
			"ComputationOverTempering", ComputationOverTempering,
			"AlgorithmComputation", AlgorithmComputation
		)

	end

	return nothing

end
