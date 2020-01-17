function MultinomialResampling(WeightNormalized, IndexLength)

	ResampleIndex = 1:length(WeightNormalized)

	if any(isnan.(WeightNormalized))
		println("WeightNormalized: ", WeightNormalized)
	end

	return sample(
		ResampleIndex,
		weights(WeightNormalized),
		IndexLength
	)

end

function StratifiedResampling(WeightNormalized, IndexLength)

	K = sum(WeightNormalized) / IndexLength

	U = rand(Uniform(0.0, K))

	ResampleIndex = fill(
		argmax(WeightNormalized),
		IndexLength
	)

	ResampleIndexNumber = 1

	for IndexNumber in 1:length(WeightNormalized)

		U -= WeightNormalized[IndexNumber]

		if U < 0.0

			ResampleIndex[ResampleIndexNumber] =
			IndexNumber

			ResampleIndexNumber += 1

			U += K

		end

	end

	return ResampleIndex

end
