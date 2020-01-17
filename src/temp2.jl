WeightNormalized = [0.00138768, 4.89222e-112, 0.00701292, 1.22782e-64, 5.08768e-173, 4.70524e-64, 0.00624018, 1.80958e-111, 3.05958e-67, 1.07865e-175, 1.54622e-66, 3.04698e-128, 1.26256e-236, 1.16766e-127, 1.10682e-66,
3.20966e-175, 7.49026e-66, 0.00589008, 2.07653e-111, 0.0297668, 4.77633e-64, 1.97915e-172, 1.83037e-63, 0.0313062, 9.07843e-111, 0.00153146, 5.39912e-112, 0.00773955, 1.35504e-64, 5.61483e-173, 5.19276e-64, 0.00688674, 1.99707e-111, 3.86134e-67, 1.36131e-175, 1.95141e-66, 3.84543e-128, 1.59342e-236, 1.47364e-127, 1.39686e-66, 4.05074e-175, 9.45307e-66, 0.00513796, 1.81137e-111, 0.0259657, 4.16643e-64, 1.72642e-172, 1.59665e-63, 0.0273086, 7.91917e-111, 0.00126022, 4.44287e-112, 0.00636878, 1.11505e-64, 4.62038e-173, 4.27306e-64, 0.00566701, 1.64337e-111, 2.49325e-67, 8.78989e-176, 1.26002e-66, 2.48298e-128, 1.02886e-236, 9.51521e-128, 9.01949e-67, 2.61554e-175, 6.1038e-66, 0.00647851, 2.28398e-111, 0.0327405, 5.2535e-64, 2.17687e-172, 2.01323e-63, 0.0344338, 9.98539e-111]

a, b = argmax(WeightNormalized)

println(sort(WeightNormalized))

length(unique(WeightNormalized))



function test()

	IndexLength = 27 - (81 - length(WeightNormalized))

	K = sum(WeightNormalized) / IndexLength

	U = rand(Uniform(0.0, K))

	ResampleIndex = fill(0, IndexLength)

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

test()
