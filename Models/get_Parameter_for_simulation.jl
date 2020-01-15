function get_Parameter_for_simulation(ModelChoice)

	if ModelChoice == :DpfUnivariateOneRegressorConstantVolatility

		Parameter = [
			0.0, 0.1,
			1.0, 0.1,
			0.1
		]

		TransitionProbabilityMatrix = reshape(
			[
				0.0, 1.0, 0.0,
				0.0, 1.0, 0.0,
				0.0, 1.0, 0.0
			],
			3, 3
		)

	elseif ModelChoice == :NoUnivariateOneRegressorConstantVolatility

		Parameter = [
			1.0,# 0.0,
			0.1
		]

		TransitionProbabilityMatrix = missing

	elseif ModelChoice == :KalmanUnivariateOneRegressorConstantVolatility

		Parameter = [
			0.0, 0.1,
			0.1
		]

		TransitionProbabilityMatrix = missing

	elseif ModelChoice == :NoMultivariateOneRegressorConstantVolatility

		Parameter = [
			1.0, 1.0,
			0.0, 0.0,
			0.1, 0.1
		]

		TransitionProbabilityMatrix = missing

	elseif ModelChoice == :KalmanMultivariateOneRegressorConstantVolatility

		Parameter = [
			0.0, 0.0,
			1.0,
			0.1, 0.1
		]

		TransitionProbabilityMatrix = missing

	elseif ModelChoice == :KalmanMultivariateTwoRegressorConstantVolatility

		Parameter = [
			0.0, 0.0,
			0.1, 0.1,
			0.1, 0.1
		]

		TransitionProbabilityMatrix = missing

	elseif ModelChoice == :WellLog

		Parameter = [
			0.05,
			0.0,
			1.0
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
			0.0, 0.05, 1.0, 0.05
		]

		TransitionProbabilityMatrix = reshape(
			[
				0.9, 0.1,
				0.1, 0.9
			],
			2, 2
		)

	else

		stop()

	end

	return Parameter, TransitionProbabilityMatrix

end
