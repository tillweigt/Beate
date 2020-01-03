function DiscreteParticleFilter!(
	Setting,
	Model,
	AlgorithmComputation,
	Target,
	Regressor,
	Parameter,
	State,
	Prediction,
	LogLikelihoodIncrement,
	StateParticle,
	PredictionStateParticle,
	StateParticleLogWeight,
	LastState,
	LastStateParticle,
	LastStateParticleLogWeight,
	ResampleThresholdDpf,
	TransitionProbabilityMatrix,
	dataPoint
)

	set_LastStateParticle_and_LastStateParticleLogWeight!(
		StateParticle, StateParticleLogWeight,
		LastStateParticle, LastStateParticleLogWeight
	)

	update_TransitionProbabilityMatrix!(
		Setting,
		Parameter,
		State,
		TransitionProbabilityMatrix
	)

	propagate_StateParticle!(
		Setting,
		AlgorithmComputation,
		Target,
		Regressor,
		Parameter,
		StateParticle,
		PredictionStateParticle,
		StateParticleLogWeight,
		dataPoint,
		LastStateParticle,
		LastStateParticleLogWeight
	)

	# LogWeightMaxmimum =
	# compute_weight_minus_maximumweight!(
	# 	StateParticleLogWeight,
	# 	1:Setting.NumberOf.DynamicStateParticle[dataPoint]
	# )

	# set_MinusInf_to_smallnumber!(
	# 	Setting, StateParticleLogWeight
	# )

	update_StateParticleLogWeight!(
		Setting,
		Parameter,
		State,
		StateParticle,
		StateParticleLogWeight,
		LastStateParticle,
		LastStateParticleLogWeight,
		TransitionProbabilityMatrix,
		dataPoint
	)

	compute_PredictionStateParticle!(
		Setting,
		Parameter,
		State,
		StateParticle,
		PredictionStateParticle,
		LastStateParticle,
		LastStateParticleLogWeight,
		TransitionProbabilityMatrix,
		dataPoint
	)

	assign_weightedmean_of_Particle!(
		Setting,
		State,
		Prediction,
		LogLikelihoodIncrement,
		StateParticle,
		PredictionStateParticle,
		StateParticleLogWeight,
		dataPoint,
		LastState,
		LastStateParticle,
		LastStateParticleLogWeight
	)

	update_State_of_TransitionProbabilityMatrix!(
		Setting,
		State,
		StateParticle,
		StateParticleLogWeight,
		dataPoint,
		LastStateParticle
	)

	resample_Computation_optimal!(
		Setting, StateParticle, StateParticleLogWeight,
		ResampleThresholdDpf, dataPoint
	)

	return nothing

end

function set_LastStateParticle_and_LastStateParticleLogWeight!(
	StateParticle, StateParticleLogWeight,
	LastStateParticle, LastStateParticleLogWeight
)

	LastStateParticle .= StateParticle

	LastStateParticleLogWeight .= StateParticleLogWeight

	return nothing

end

function update_TransitionProbabilityMatrix!(
	Setting,
	Parameter,
	State,
	TransitionProbabilityMatrix
)

	if Setting.Model.IsTransitionProbabilityMatrixFromState

		TransitionProbabilityMatrix .=
		reshape(
			State[Setting.Model.TransitionProbabilityMatrixIndex],
			Setting.NumberOf.DiscreteState,
			Setting.NumberOf.DiscreteState
		)

	else

		TransitionProbabilityMatrix .=
		reshape(
			Parameter[Setting.Model.TransitionProbabilityMatrixIndex],
			Setting.NumberOf.DiscreteState,
			Setting.NumberOf.DiscreteState
		)

	end

	TransitionProbabilityMatrix ./=
	sum(TransitionProbabilityMatrix, dims = 1)

	return nothing

end

function propagate_StateParticle!(
	Setting,
	AlgorithmComputation,
	Target,
	Regressor,
	Parameter,
	StateParticle,
	PredictionStateParticle,
	StateParticleLogWeight,
	dataPoint,
	LastStateParticle,
	LastStateParticleLogWeight
)

	propagate_DiscreteStateParticle!(
		Setting, StateParticle,
		dataPoint,
		LastStateParticle, LastStateParticleLogWeight
	)

	AllFilter! = get_AllFilter(Setting)

	for stateParticle in 1:Setting.NumberOf.DynamicStateParticle[dataPoint]

		FilterIndex = convert(
			Int64,
			StateParticle[
				Setting.Model.MixtureStateIndex,
				stateParticle
			]
		)

		AllFilter![FilterIndex](
			Setting,
			Setting.Model.Filter[FilterIndex],
			AlgorithmComputation,
			Target,
			Regressor,
			Parameter,
			view(StateParticle, :, stateParticle),
			view(
				PredictionStateParticle,
				 :, stateParticle
			),
			view(StateParticleLogWeight, stateParticle)
		)

	end

	return nothing

end

function propagate_DiscreteStateParticle!(
	Setting, StateParticle,
	dataPoint,
	LastStateParticle, LastStateParticleLogWeight
)

	if dataPoint == 1
		DynamicStateParticleLastIndexLength =
			Setting.NumberOf.DiscreteState
	elseif Setting.NumberOf.DynamicStateParticle[dataPoint - 1] ==
		Setting.NumberOf.LargestDynamicStateParticle
		DynamicStateParticleLastIndexLength =
			Setting.NumberOf.SecondLargestDynamicStateParticle
	else
		DynamicStateParticleLastIndexLength =
			Setting.NumberOf.DynamicStateParticle[
				dataPoint - 1
			]
	end

	LastStateParticle[
		Setting.Model.MixtureStateIndex,
		1:Setting.NumberOf.DynamicStateParticle[
			dataPoint
		]
	] =
	repeat(
		StateParticle[
			Setting.Model.MixtureStateIndex,
			1:DynamicStateParticleLastIndexLength
		],
		inner = Setting.NumberOf.DiscreteState
	)

	LastStateParticleLogWeight[
		1:Setting.NumberOf.DynamicStateParticle[
			dataPoint
		]
	] = LastStateParticleLogWeight[
		repeat(
			1:DynamicStateParticleLastIndexLength,
			inner = Setting.NumberOf.DiscreteState
		)
	]

	StateParticle[
		Setting.Model.MixtureStateIndex,
		1:Setting.NumberOf.DynamicStateParticle[
			dataPoint
		]
	] = repeat(
		1:Setting.NumberOf.DiscreteState,
		outer = DynamicStateParticleLastIndexLength
	)

	StateParticle[
		Setting.Model.StateIndex,
		1:Setting.NumberOf.DynamicStateParticle[
			dataPoint
		]
	] =
	StateParticle[
		Setting.Model.StateIndex,
		repeat(
			1:DynamicStateParticleLastIndexLength,
			inner = Setting.NumberOf.DiscreteState
		)
	]

	return nothing

end

function get_AllFilter(Setting)

	AllFilter! = map(
		state -> get_Filter(
			Setting.Model.Filter[state]
		),
		1:Setting.NumberOf.DiscreteState
	)

	return AllFilter!

end

function update_StateParticleLogWeight!(
	Setting,
	Parameter,
	State,
	StateParticle,
	StateParticleLogWeight,
	LastStateParticle,
	LastStateParticleLogWeight,
	TransitionProbabilityMatrix,
	dataPoint
)

	TransitionLogProbabilityMatrix =
	log.(TransitionProbabilityMatrix)

	for stateParticle in 1:Setting.NumberOf.DynamicStateParticle[dataPoint]

		StateParticleLogWeight[stateParticle] =
			LastStateParticleLogWeight[stateParticle] +
			TransitionLogProbabilityMatrix[
				convert(
					Int64,
					StateParticle[
						Setting.Model.MixtureStateIndex,
						stateParticle
					]
				),
				convert(
					Int64,
					LastStateParticle[
						Setting.Model.MixtureStateIndex,
						stateParticle
					]
				)
			] +
			StateParticleLogWeight[stateParticle]

	end

	return nothing

end

function compute_PredictionStateParticle!(
	Setting,
	Parameter,
	State,
	StateParticle,
	PredictionStateParticle,
	LastStateParticle,
	LastStateParticleLogWeight,
	TransitionProbabilityMatrix,
	dataPoint
)

	LastStateParticleWeightNormalized,
	NotToUse =
	compute_WeightNormalized(
		Setting, LastStateParticleLogWeight, dataPoint
	)

	PredictionStateParticleWeight = fill(
		NaN,
		Setting.NumberOf.DynamicStateParticle[dataPoint]
	)

	for stateParticle in 1:Setting.NumberOf.DynamicStateParticle[dataPoint]

		PredictionStateParticleWeight[stateParticle] =
		LastStateParticleWeightNormalized[stateParticle] .*
		TransitionProbabilityMatrix[
			convert(
				Int64,
				StateParticle[
					Setting.Model.MixtureStateIndex,
					stateParticle
				]
			),
			convert(
				Int64,
				LastStateParticle[
					Setting.Model.MixtureStateIndex,
					stateParticle
				]
			)
		]

	end

	PredictionStateParticleWeightNormalized =
		PredictionStateParticleWeight ./
		sum(PredictionStateParticleWeight) .*
		Setting.NumberOf.DynamicStateParticle[dataPoint]

	for stateParticle in 1:Setting.NumberOf.DynamicStateParticle[dataPoint]

		PredictionStateParticle[:, stateParticle] =
			PredictionStateParticleWeightNormalized[stateParticle] .*
			PredictionStateParticle[:, stateParticle]
	end

	return nothing

end

function assign_weightedmean_of_Particle!(
	Setting,
	State,
	Prediction,
	LogLikelihoodIncrement,
	StateParticle,
	PredictionStateParticle,
	StateParticleLogWeight,
	dataPoint,
	LastState,
	LastStateParticle,
	LastStateParticleLogWeight
)

	StateIndex = union(
		Setting.Model.StateIndex,
		Setting.Model.MixtureStateIndex
	)

	StateParticleIndex = 1:Setting.NumberOf.DynamicStateParticle[dataPoint]

	LastStateParticleWeightNormalized =
	reshape(
		compute_WeightNormalized(
			Setting, LastStateParticleLogWeight, dataPoint
		)[1],
		1, Setting.NumberOf.DynamicStateParticle[dataPoint]
	)

	StateParticleWeightNormalized=
	reshape(
		compute_WeightNormalized(
			Setting, StateParticleLogWeight, dataPoint
		)[1],
		1, Setting.NumberOf.DynamicStateParticle[dataPoint]
	)

	LastState[StateIndex] .= dropdims(
		sum(
			LastStateParticle[
				StateIndex,
				StateParticleIndex
			] .*
			LastStateParticleWeightNormalized,
			dims = 2
		),
		dims = 2
	)

	State[StateIndex] .= dropdims(
		sum(
			StateParticle[
				StateIndex,
				StateParticleIndex
			] .*
			StateParticleWeightNormalized,
			dims = 2
		),
		dims = 2
	)

	Prediction .= dropdims(
		mean(
			PredictionStateParticle[
				:,
				StateParticleIndex
			],
			dims = 2
		), dims = 2
	)

	LogLikelihoodIncrement .= log(mean(exp.(
		StateParticleLogWeight[StateParticleIndex]
	)))

	return nothing

end

function update_State_of_TransitionProbabilityMatrix!(
	Setting,
	State,
	StateParticle,
	StateParticleLogWeight,
	dataPoint,
	LastStateParticle
)

	if Setting.Model.IsTransitionProbabilityMatrixFromState

		StateParticleWeight, NotToUse =
		compute_WeightNormalized(
			Setting, StateParticleLogWeight, dataPoint
		)

		TransitionProbabilityMatrixTemp = fill(
			eps(0.0),
			Setting.NumberOf.DiscreteState,
			Setting.NumberOf.DiscreteState
		)

		for stateParticle in 1:Setting.NumberOf.DynamicStateParticle[dataPoint]

			TransitionProbabilityMatrixTemp[
				convert(
					Int64,
					StateParticle[
						Setting.Model.MixtureStateIndex,
						stateParticle
					]
				),
				convert(
					Int64,
					LastStateParticle[
						Setting.Model.MixtureStateIndex,
						stateParticle
					]
				)
			] +=
			StateParticleWeight[stateParticle]

		end

		State[Setting.Model.TransitionProbabilityMatrixIndex] +=
		reshape(
			TransitionProbabilityMatrixTemp,
			Setting.NumberOf.DiscreteState^2
		)

	end

	return nothing

end

function resample_Computation_optimal!(
	Setting, StateParticle, StateParticleLogWeight,
	ResampleThresholdDpf, dataPoint
)

	if Setting.NumberOf.DynamicStateParticle[dataPoint] ==
		Setting.NumberOf.LargestDynamicStateParticle

		StateParticleWeightNormalized,
		NormalizingConstant =
		compute_WeightNormalized(
			Setting, StateParticleLogWeight, dataPoint
		)

		# if false
		if (
				sum(StateParticleWeightNormalized .> 0) >
				Setting.NumberOf.SecondLargestDynamicStateParticle
			) |
			any(
				StateParticleWeightNormalized .!=
				1 / Setting.NumberOf.DynamicStateParticle[dataPoint]
			)

			ResampleThresholdDpf .=
			Setting.NumberOf.SecondLargestDynamicStateParticle

			ResampleIndex =
			compute_DiscreteStateParticleResampleIndex(
				Setting,
				StateParticleWeightNormalized,
				ResampleThresholdDpf,
				dataPoint
			)

		else

			compute_ResampleThresholdDpf!(
				Setting,
				StateParticleWeightNormalized,
				ResampleThresholdDpf,
				dataPoint,
				StateParticleLogWeight
			)

			ResampleIndex =
			compute_DiscreteStateParticleResampleIndex(
				Setting,
				StateParticleWeightNormalized,
				ResampleThresholdDpf,
				dataPoint
			)

		end

		resample_StateParticle_and_StateParticleLogWeight!(
			Setting,
			StateParticle,
			StateParticleLogWeight,
			ResampleThresholdDpf,
			ResampleIndex,
			NormalizingConstant
		)

	end

	return nothing

end

function compute_WeightNormalized(
	Setting, LogWeight, dataPoint
)

	Weight =
	exp.(
		LogWeight[
			1:Setting.NumberOf.DynamicStateParticle[dataPoint]
		]
	)

	NormalizingConstant = sum(
		Weight
	)

	WeightNormalized =
		Weight ./ NormalizingConstant

	if all(iszero.(WeightNormalized)) |
		all(isinf.(WeightNormalized)) |
		all(isnan.(WeightNormalized))

		Weight .= 1 / Setting.NumberOf.DynamicStateParticle[dataPoint]

		NormalizingConstant = sum(
			Weight
		)

		WeightNormalized =
			Weight ./ NormalizingConstant

		LogWeight[
			1:Setting.NumberOf.DynamicStateParticle[dataPoint]
		] .=
		log(1 / Setting.NumberOf.DynamicStateParticle[dataPoint])

	end

	# test
	if any(isinf.(WeightNormalized)) | any(isnan.(WeightNormalized))
		println("WeightNormalized: ", WeightNormalized)
		error()
	end

	return WeightNormalized,
		NormalizingConstant

end

function compute_ResampleThresholdDpf!(
	Setting,
	StateParticleWeightNormalized,
	ResampleThresholdDpf,
	dataPoint,
	StateParticleLogWeight
)

	StateParticleWeightNormalizedSorted =
	sort(StateParticleWeightNormalized)

	LowestPossibleParticleIndex = 1

	HighestPossibleParticleIndex =
	Setting.NumberOf.DynamicStateParticle[dataPoint]

	ParticleIndex = sample(
		LowestPossibleParticleIndex:HighestPossibleParticleIndex
	)

	while LowestPossibleParticleIndex <= HighestPossibleParticleIndex

		NumberOfWeightLargerOrEqualThanWeightAtParticleIndex =
		sum(
			StateParticleWeightNormalizedSorted .>=
			StateParticleWeightNormalizedSorted[ParticleIndex]
		)

		SumOfWeightSmallerThanAtParticleIndex =
		sum(
			StateParticleWeightNormalizedSorted[
				StateParticleWeightNormalizedSorted .<
				StateParticleWeightNormalizedSorted[ParticleIndex]
			]
		)

		ConditionValue =
			SumOfWeightSmallerThanAtParticleIndex /
			StateParticleWeightNormalizedSorted[ParticleIndex] +
			NumberOfWeightLargerOrEqualThanWeightAtParticleIndex

		ResampleThresholdDpfTemp =
		(
			Setting.NumberOf.SecondLargestDynamicStateParticle -
			NumberOfWeightLargerOrEqualThanWeightAtParticleIndex
		) /
		SumOfWeightSmallerThanAtParticleIndex

		if isnan(ConditionValue) |
			iszero(ResampleThresholdDpfTemp) |
			isnan(ResampleThresholdDpfTemp) |
			isinf(ResampleThresholdDpfTemp)

			ConditionValueIsLowerThanSecondLargestDynamicStateParticle =
				false

		else

			ConditionValueIsLowerThanSecondLargestDynamicStateParticle =
				ConditionValue <=
				Setting.NumberOf.SecondLargestDynamicStateParticle

		end

		if ConditionValueIsLowerThanSecondLargestDynamicStateParticle |
			(ParticleIndex == Setting.NumberOf.LargestDynamicStateParticle)

			if ParticleIndex == Setting.NumberOf.LargestDynamicStateParticle

				NumberOfWeightLargerOrEqualThanWeightAtParticleIndex =
				# sum(
				# 	StateParticleWeightNormalizedSorted .>
				# 	StateParticleWeightNormalizedSorted[ParticleIndex]
				# )
				length(
					StateParticleWeightNormalizedSorted[ParticleIndex:end]
				)

				SumOfWeightSmallerThanAtParticleIndex =
				sum(
					# StateParticleWeightNormalizedSorted[
					# 	StateParticleWeightNormalizedSorted .<=
					# 	StateParticleWeightNormalizedSorted[ParticleIndex]
					# ]
					StateParticleWeightNormalizedSorted[1:ParticleIndex - 1]
				)

			end

			HighestPossibleParticleIndex = ParticleIndex

			ResampleThresholdDpf .=
			(
				Setting.NumberOf.SecondLargestDynamicStateParticle -
				NumberOfWeightLargerOrEqualThanWeightAtParticleIndex
			) /
			SumOfWeightSmallerThanAtParticleIndex

			if length(
				LowestPossibleParticleIndex:HighestPossibleParticleIndex
			) == 1

				break

			end

		else

			LowestPossibleParticleIndex = ParticleIndex + 1

			if length(
				LowestPossibleParticleIndex:HighestPossibleParticleIndex
			) == 0

				break

			end

		end

		ParticleIndex = sample(
			LowestPossibleParticleIndex:HighestPossibleParticleIndex
		)

	end

	# if (ParticleIndex == Setting.NumberOf.LargestDynamicStateParticle) &
	# 	isnan.(ResampleThresholdDpf)
	#
	# 	ResampleThresholdDpf .=
	# 	Setting.NumberOf.SecondLargestDynamicStateParticle
	#
	# end

	# test
	if iszero.(ResampleThresholdDpf) | isinf.(ResampleThresholdDpf) | isnan.(ResampleThresholdDpf)
		println("ParticleIndex: ", ParticleIndex)
		println("ResampleThresholdDpf: ", ResampleThresholdDpf)
		error()
	end

	# test
	Temp = StateParticleWeightNormalizedSorted .* ResampleThresholdDpf
	Temp[Temp .> 1.0] .= 1.0
	if (
			round(sum(Temp)) !=
			Setting.NumberOf.SecondLargestDynamicStateParticle
		)
		println("round(sum(Temp)): ", round(sum(Temp)))
		println("ResampleThresholdDpf: ", ResampleThresholdDpf)
		println("ParticleIndex: ", ParticleIndex)
		println(
			"StateParticleWeightNormalizedSorted: ",
			StateParticleWeightNormalizedSorted
	 	)
		error()
	end

	return nothing

end

function compute_DiscreteStateParticleResampleIndex(
	Setting,
	StateParticleWeightNormalized,
	ResampleThresholdDpf,
	dataPoint
)

	ResampleIndexSet1 =
		StateParticleWeightNormalized .>=
		1 ./ ResampleThresholdDpf

	ResampleIndexSet2 = compute_ResampleIndex(
		Setting,
		StateParticleWeightNormalized[.!ResampleIndexSet1],
		Setting.NumberOf.SecondLargestDynamicStateParticle -
		(
			Setting.NumberOf.LargestDynamicStateParticle -
			length(StateParticleWeightNormalized[.!ResampleIndexSet1])
		)
	)

	ParticleIndex = convert(
		Array,
		1:Setting.NumberOf.DynamicStateParticle[dataPoint]
	)

	ResampleIndexSet1 = ParticleIndex[ResampleIndexSet1]

	SubParticleIndex = setdiff(ParticleIndex, ResampleIndexSet1)

	ResampleIndexSet2 = SubParticleIndex[ResampleIndexSet2]

	ResampleIndex = (
		Set1 = ResampleIndexSet1,
		Set2 = ResampleIndexSet2
	)

	return ResampleIndex

end

function compute_ResampleIndex(
	Setting,
	WeightNormalized,
	IndexLength
)

	ResampleSchmeme = get_ResampleScheme(Setting.Model)

	if iszero(length(WeightNormalized))

		ResampleIndex = Array{Int64}(undef, 0)

	else

		ResampleIndex = ResampleSchmeme(
			WeightNormalized,
			IndexLength
		)

	end

	return ResampleIndex

end

function resample_StateParticle_and_StateParticleLogWeight!(
	Setting,
	StateParticle,
	StateParticleLogWeight,
	ResampleThresholdDpf,
	ResampleIndex,
	NormalizingConstant
)

	if length(
		[
			ResampleIndex.Set1...,
			ResampleIndex.Set2...
		]
	) != Setting.NumberOf.SecondLargestDynamicStateParticle
		println("ResampleIndex.Set1...: ", ResampleIndex.Set1...)
		println("ResampleIndex.Set2...: ", ResampleIndex.Set2...)
	end


	StateParticle[
		:,
		1:Setting.NumberOf.SecondLargestDynamicStateParticle
	] =
	StateParticle[
		:,
		[
			ResampleIndex.Set1...,
			ResampleIndex.Set2...
		]
	]

	StateParticleLogWeight[
		1:length(ResampleIndex.Set1)
	] = StateParticleLogWeight[
		ResampleIndex.Set1
	]

	StateParticleLogWeight[
		length(ResampleIndex.Set1) +
		1:Setting.NumberOf.SecondLargestDynamicStateParticle
	] .= log(1 ./ ResampleThresholdDpf .* NormalizingConstant)

	return nothing

end
