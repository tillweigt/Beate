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

	K = mean(WeightNormalized)

	K <= 0.0 ? println(K) : nothing

	U = rand(Uniform(0.0, K))

	ResampleIndex = fill(0, IndexLength)

	IndexNumber = 1

	ResampleIndexNumber = 1

	while ResampleIndexNumber <= IndexLength

		U = U - WeightNormalized[IndexNumber]

		if U < 0.0

			ResampleIndex[ResampleIndexNumber] =
			IndexNumber

			ResampleIndexNumber += 1

			U = U + K

		end

		IndexNumber += 1

	end

	return ResampleIndex

end
