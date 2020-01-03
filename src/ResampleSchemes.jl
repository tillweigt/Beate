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
