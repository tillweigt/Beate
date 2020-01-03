using Distributions

UnivariateNormal = NoFilterStruct(
	function(Regressor, Parameter, State)
		Normal(Parameter[1], Parameter[2])
		# MvNormal(Parameter, [[1.0, 0.0] [0.0, 1.0]])
	end
)
UnivariateNormalPrior = PriorStruct(
	[Uniform(), Uniform()],
	Array{Distribution}(undef, 0)
)

MultivariateNormal = NoFilterStruct(
	function(Regressor, Parameter, State)
		MvNormal(Parameter, [[1.0, 0.0] [0.0, 1.0]])
	end
)
# MultivariateNormalPrior = PriorStruct(
# 	[Uniform(), Uniform()],
# 	Array{Distribution}(undef, 0)
# )

LocalLevel = KalmanFilterStruct(
	function(Regressor, Parameter, State)
		Normal(
			State[1],
			Parameter[1]
		)
	end,
	function(Parameter, State) 1.0 end,
	function(Regressor, Parameter, State)
		Normal(
			State[1],
			Parameter[2]
		)
	end,
	function(Parameter, State) 1.0 end,
	1:1,
	2:2
)

LocalLevelPrior = PriorStruct(
	[Uniform(), Uniform()],
	[Uniform(), Uniform()]
)

WellLog = DiscreteParticleFilterStruct(
	tuple(
		NoFilterStruct(
			function(Regressor, Parameter, State)
				Normal(State[1], Parameter[1])
			end
		),
		KalmanFilterStruct(
			function(Regressor, Parameter, State)
				Normal(State[1], Parameter[1])
			end,
			function(Parameter, State) 1.0 end,
			function(Regressor, Parameter, State)
				Normal(
					Parameter[2],
					Parameter[3]
					# State[1],
					# Parameter[2]
				)
			end,
			function(Parameter, State) 0.0 end,
			1:1,
			2:2
		)
	),
	1:1,
	3:6,
	7,#3,
	true,#false,
	:MutinomialResampling
)

WellLogPrior = PriorStruct(
	[
		Normal(0.1, 0.00001),
		Normal(0.0, 0.00001),
		Normal(1.0, 0.00001)#,
		# Uniform(0.89, .91),
		# Uniform(0.09, 0.11),
		# Uniform(0.89, .91),
		# Uniform(0.09, 0.11)
	],
	[
		Uniform(),
		Uniform(),
		[Dirichlet(fill(1/2, 2)) for i in 1:2]...,
		Uniform()
	]
)

MarkovMixture = DiscreteParticleFilterStruct(
	tuple(
		NoFilterStruct(
			function(Regressor, Parameter, State)
				Normal(Parameter[1], Parameter[2])
			end
		),
		NoFilterStruct(
			function(Regressor, Parameter, State)
				Normal(Parameter[3], Parameter[4])
			end
		)
	),
	1:1,
	2:5,
	6,
	true,
	:MutinomialResampling
)

MarkovMixturePrior = PriorStruct(
	[
		Normal(0.0, 0.00001),
		Normal(0.05, 0.00001),
		Normal(1.0, 0.00001),
		Normal(0.05, 0.0001)#,
		# Normal(0.95, 0.00001),
		# Normal(0.05, 0.00001),
		# Normal(0.05, 0.00001),
		# Normal(0.95, 0.0001)
	],
	[
		Uniform(),
		[Dirichlet(fill(1/2, 2)) for i in 1:2]...,
		Uniform()
	]
)
