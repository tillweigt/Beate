function get_Parameter_for_simulation(ModelChoice)

	if ModelChoice in (:WellLog, :WellLogSim, :WellLogManyOf1, :WellLogManyOfMany)

		Parameter = [
			0.1,
			0.0,
			1.0
		]

		TransitionProbabilityMatrix = reshape(
			[
				0.9, 0.1,
				0.9, 0.1
			],
			2, 2
		)

	elseif ModelChoice == :RealData

		Parameter = [
			0.0, 0.05, 0.0, 10.0
		]

		TransitionProbabilityMatrix = reshape(
			[
				0.95, 0.05,
				0.95, 0.05
			],
			2, 2
		)

	elseif ModelChoice == :MixtureOfNormal

		Parameter = [
			0.0, 0.1, 0.2, 0.1
		]

		TransitionProbabilityMatrix = reshape(
			[
				0.9, 0.1,
				0.1, 0.9
			],
			2, 2
		)

	elseif ModelChoice == :Kalman

		Parameter = [
			0.0, 0.1, 0.1
		]

		TransitionProbabilityMatrix = reshape(
			[
				0.9, 0.1,
				0.1, 0.9
			],
			2, 2
		)

	elseif ModelChoice == :RealDataTimeVarying

		Parameter = [
			0.0, 0.1, 0.1
		]

		TransitionProbabilityMatrix = reshape(
			[
				0.9, 0.1,
				0.9, 0.1
			],
			2, 2
		)

	else

		stop()

	end

	return Parameter, TransitionProbabilityMatrix

end
