function GenericMcmcMove!(
	Setting,
	Computation,
	AlgorithmComputation,
	dataPoint
)

	for mcmcstep in 1:Setting.NumberOf.McmcStep
		for parameterParticle in 1:Setting.NumberOf.ParameterParticle
			for mcmcBlock in 1:Setting.NumberOf.McmcBlock

				propose_Parameter!()

				if !isinf(ProposalProbability)

					for dataPoint in 1:Setting.NumberOf.DataPoint
						filter_State!(
							Setting,
							Computation,
							AlgorithmComputation,
							dataPoint,
							1 # only one parameterParticle
						)
					end

					compute_RejectBool!()

					reject_Parameter!()

				end

			end
		end

		compute_AcceptanceRatio!()
		
		update_ProposalDistribution!()

	end

	return nothing

end
