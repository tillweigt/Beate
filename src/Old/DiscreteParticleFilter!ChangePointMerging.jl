function DiscreteParticleFilter!(
	Setting,
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
	dataPoint
)

	LastStateParticle,
	LastStateParticleLogWeight = copy_StateParticle(
		StateParticle, StateParticleLogWeight
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
		LastStatParticle,
		LastStateParticleLogWeight
	)

	compute_DiscreteStateParticleLogWeight!(
		Setting,
		Parameter,
		StateParticle,
		StateParticleLogWeight,
		LastStateParticle,
		LastStateParticleLogWeight
	)

	merge_identical_particles!()

	resample_StateParticle!(
		Setting, StateParticle, StateParticleLogWeight, dataPoint
	)

	update_State!(
		Setting,
		State,
		StateParticle,
		dataPoint
	)

	return nothing

end

function copy_StateParticle(
	StateParticle, StateParticleLogWeight
)

	LastStateParticle = copy(StateParticle)

	LastStateParticleLogWeight = copy(StateParticleLogWeight)

	return LastStateParticle,
	LastStateParticleLogWeight

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
	LastStatParticle,
	LastStateParticleLogWeight
)

	propagate_DiscreteStateParticle!(
		Setting, StateParticle,
		dataPoint,
		LastStatParticle, LastStateParticleLogWeight
	)

	AllFilter! = get_AllFilter(Setting)

	for stateParticle in 1:Setting.NumberOf.DynamicStateParticle[dataPoint]

		AllFilter![StateParticle[end, stateParticle]](
			Setting,
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

		if Setting.Model.IsChangePointModel

			if dataPoint == 1
				LastIndexPointDataPointMinusOne =
					Setting.NumberOf.DiscreteState
			else
				LastIndexPointDataPointMinusOne =
					Setting.NumberOf.DynamicStateParticle[dataPoint - 1]
			end

			StateParticleLogWeight[
				Setting.NumberOf.DynamicStateParticle[dataPoint]
			] *= LastIndexPointDataPointMinusOne

		end

	end

	return nothing

end

function propagate_DiscreteStateParticle!(
	Setting, StateParticle,
	dataPoint,
	LastStatParticle, LastStateParticleLogWeight
)

	if dataPoint == 1
		IndexDataPointMinusOne =
			1:Setting.NumberOf.DiscreteState
	else
		IndexDataPointMinusOne =
			1:Setting.NumberOf.DynamicStateParticle[
				dataPoint - 1
			]
	end

	if Setting.Model.IsChangePointModel

		DiscreteStateParticlePropagation = repeat(
			convert(
				Array,
				1:Setting.NumberOf.DiscreteState - 1
			),
			outer = convert(
				Int64,
				(
					Setting.NumberOf.DynamicStateParticle[
						dataPoint
					] - 1
				) /
				(Setting.NumberOf.DiscreteState - 1)
			)
		)
		push!(
			DiscreteStateParticlePropagation,
			Setting.NumberOf.DiscreteState
		)

		DiscreteLastStateParticlePropagation = repeat(
			StateParticle[
				end,
				1:IndexDataPointMinusOne
			],
			inner = Setting.NumberOf.DiscreteState - 1
		)
		push!(
			DiscreteLastStateParticlePropagation,
			Setting.NumberOf.DiscreteState
		)

	else

		DiscreteStateParticlePropagation = repeat(
			convert(
				Array,
				1:Setting.NumberOf.DiscreteState
			),
			outer = convert(
				Int64,
				Setting.NumberOf.DynamicStateParticle[
					dataPoint
				] /
				Setting.NumberOf.DiscreteState
			)
		)

		DiscreteLastStateParticlePropagation = repeat(
			StateParticle[
				end,
				1:IndexDataPointMinusOne
			],
			inner = Setting.NumberOf.DiscreteState
		)

	end

	StateParticle[
		end,
		1:Setting.NumberOf.DynamicStateParticle[
			dataPoint
		]
	] = DiscreteStateParticlePropagation

	StateParticle[
		1:end - 1,
		1:Setting.NumberOf.DynamicStateParticle[
			dataPoint
		]
	] = StateParticle[
		1:end - 1,
		DiscreteStateParticlePropagation
	]

	LastStateParticle[
		end,
		1:Setting.NumberOf.DynamicStateParticle[
			dataPoint
		]
	] = DiscreteLastStateParticlePropagation

	LastStateParticleLogWeight[
		1:Setting.NumberOf.DynamicStateParticle[
			dataPoint
		]
	] = LastStateParticleLogWeight[
		DiscreteLastStateParticlePropagation
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

function compute_DiscreteStateParticleLogWeight!(
	Setting,
	Parameter,
	StateParticle,
	StateParticleLogWeight,
	LastStateParticle,
	LastStateParticleLogWeight
)

	TransitionProbabilityMatrix =
	make_TransitionProbabilityMatrix(
		Setting,
		StateParticle
	)

	for stateParticle in 1:Setting.NumberOf.DynamicStateParticle[dataPoint]

		StateParticleLogWeight[stateParticle] =
			LastStateParticleLogWeight[stateParticle] +
			TransitionProbabilityMatrix[
				LastStateParticle[end, stateParticle],
				StateParticle[end, stateParticle]
			] +
			StateParticleLogWeight[stateParticle]

	end

	return nothing

end

function make_TransitionProbabilityMatrix(
	Setting,
	StateParticle
)

	TransitionProbabilityMatrix = fill(
		NaN,
		Setting.NumberOf.DiscreteState,
		Setting.NumberOf.DiscreteState
	)

	if Setting.Model.IsTransitionProbabilityMatrixFromState



	else

		if Setting.Model.IsChangePointModel

			ParameterIndex =
				Setting.NumberOf.Parameter -
				Setting.NumberOf.DisrceteState^2 +
				1:Setting.NumberOf.Parameter



		else

			ParameterIndex =
				Setting.NumberOf.Parameter -
				Setting.NumberOf.DisrceteState^2 +
				1:Setting.NumberOf.Parameter

		end

		TransitionProbabilityMatrix = reshape(
			Parameter[ParameterIndex],
			Setting.NumberOf.DisrceteState,
			Setting.NumberOf.DisrceteState
		)

	end

	return TransitionProbabilityMatrix

end

function resample_StateParticle!(
	Setting, StateParticle, StateParticleLogWeight, dataPoint
)

	if Setting.NumberOf.DynamicStateParticle[dataPoint] ==
		Setting.NumberOf.LargestDynamicStateParticle
		# Setting.NumberOf.DiscreteState >
		# Setting.NumberOf.StateParticle

		StateParticleWeight = compute_StateParticleWeight(
			Setting, StateParticleLogWeight
		)

		ResampleThreshold = compute_ResampleThreshold(
			Setting,
			StateParticleWeight,
			dataPoint
		)

		ResampleIndex =
		compute_DiscreteStateParticleResampleIndex(
			Setting,
			StateParticleWeight,
			ResampleThreshold,
			dataPoint
		)

		resample!(
			StateParticle,
			StateParticleLogWeight,
			ResampleThreshold,
			ResampleIndex
		)

	end

	return nothing

end

function compute_StateParticleWeight(
	Setting, StateParticleLogWeight
)

	StateParticleWeight = exp.(
		StateParticleLogWeight[
			1:Setting.NumberOf.DynamicStateParticle[dataPoint]
		]
	)

	return StateParticleWeight

end

function compute_ResampleThreshold(
	Setting,
	StateParticleWeight,
	dataPoint
)

	StateParticleWeightSorted = sort(StateParticleWeight)

	NumberOfParticleWeightLargerThanAtParticleIndex = NaN

	SumOfParticleWeightSmallerOrEqualThanAtParticleIndex = NaN

	LowestPossibleParticleIndex = 1

	HighestPossibleParticleIndex =
	Setting.NumberOf.DynamicStateParticle[dataPoint]

	ParticleIndex = sample(
		LowestPossibleParticleIndex:HighestPossibleParticleIndex
	)

	while LowestPossibleParticleIndex < HighestPossibleParticleIndex

		NumberOfParticleWeightLargerThanAtParticleIndex =
			Setting.NumberOf.DynamicStateParticle[dataPoint] -
			ParticleIndex

		SumOfParticleWeightSmallerOrEqualThanAtParticleIndex =
		sum(
			StateParticleWeightSorted[1:ParticleIndex]
		)

		IsLowerThanTargetNumberOfStateParticle =
			SumOfParticleWeightSmallerOrEqualThanAtParticleIndex /
			ParticleIndex +
			NumberOfParticleWeightLargerThanAtParticleIndex <=
			Setting.NumberOf.StateParticle /
			Setting.NumberOf.DiscreteState

		if IsLowerThanTargetNumberOfStateParticle

			LowestPossibleParticleIndex += 1

		else

			HighestPossibleParticleIndex -= 1

		end

		ParticleIndex = sample(
			LowestPossibleParticleIndex:HighestPossibleParticleIndex
		)

	end

	ResampleThreshold =
		(
			Setting.NumberOf.StateParticle /
			Setting.NumberOf.DiscreteState -
			NumberOfParticleWeightLargerThanAtParticleIndex
		) /
		SumOfParticleWeightSmallerOrEqualThanAtParticleIndex

	return ResampleThreshold

end

function compute_ResampleIndex(
	Setting,
	StateParticleWeight,
	ResampleThreshold,
	dataPoint
)

	ResampleIndexSet1 =
		StateParticleWeight .>=
		1 / ResampleThreshold

	ResampleIndexSet2 = compute_ResampleIndex(
		Setting,
		StateParticleWeight[.!ResampleIndexSet1]
	)

	ParticleIndex = convert(
		Array,
		1:Setting.NumberOf.DynamicStateParticle[dataPoint]
	)

	ResampleIndexSet1 = ParticleIndex[ResampleIndexSet1]

	ResampleIndexSet2 = ParticleIndex[ResampleIndexSet2]

	ResampleIndex = (
		Set1 = ResampleIndexSet1,
		Set2 = ResampleIndexSet2
	)

	return ResampleIndex

end

function compute_ResampleIndex(
	Setting,
	Weight
)

	ResampleSchmeme = get_ResamplingSchmeme(Setting)

	WeightNormalized = Weight / sum(Weight)

	ResampleIndex = ResampleSchmeme(WeightNormalized)

	return ResampleIndex

end

function resample!(
	StateParticle,
	StateParticleLogWeight,
	ResampleThreshold,
	ResampleIndex
)

	StateParticle[
		1:Setting.NumberOf.DynamicStateParticle[dataPoint]
	] =
	StateParticle[
		ResampleIndex.Set1..., ResampleIndex.Set2...
	]

	StateParticleLogWeight[ResampleIndex.Set2] .=
		log(1 / ResampleThreshold)

	return nothing

end

function update_State!(
	Setting,
	State,
	StateParticle,
	dataPoint
)

	StateParticleIndex =
		1:Setting.NumberOf.DynamicStateParticle[dataPoint]

	NotTransitionProbabilityMatrixIndex =
		1:Setting.NumberOf.State -
		Setting.NumberOf.DiscreteState^2

	State .= mean(StateParticle[
		NotTransitionProbabilityMatrixIndex,
		StateParticleIndex
	])

	update_TransitionProbabilityMatrix!(
		Setting,
		State,
		StateParticleLogWeight
	)

	return nothing

end

function update_TransitionProbabilityMatrix!(
	Setting,
	State,
	StateParticleLogWeight
)

	if Setting.Model.IsTransitionProbabilityMatrixFromState

		StateParticleWeight = exp.(StateParticleLogWeight)

		for discreteState in 1:Setting.NumberOf.DiscreteState

			Index = (1:Setting.NumberOf.DiscreteState) .+
			(discreteState - 1) * Setting.NumberOf.DiscreteState

			StateParticleWeightNormalized[Index] = # Normalized???
			StateParticleWeight[Index] ./
			sum(StateParticleWeight[Index])

		end

		for stateParticle in 1:Setting.NumberOf.DynamicStateParticle[dataPoint]

			TransitionProbabilityMatrixIndex =
				(LastStateParticle[end, stateParticle] - 1) *
				Setting.NumberOf.DiscreteState +
				StateParticle[end, stateParticle]

			State[TransitionProbabilityMatrixIndex] +=
				StateParticleWeightNormalized[
					TransitionProbabilityMatrixIndex
				]

			# have to nomralize the TransitionProbabilityMatrix in everey step

		end

		# TransitionProbabilityMatrixIndex =
		# 	Setting.NumberOf.State -
		# 	Setting.NumberOf.DiscreteState^2 +
		# 	1:Setting.NumberOf.State
		#
		# State[TransitionProbabilityMatrixIndex] =
		# 	StateParticleLogWeight[
		# 		TransitionProbabilityMatrixIndex
		# 	]
	end

	return nothing

end
