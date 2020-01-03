function Ibis_data!()
	for dataPoint in 1:NumberOfDataPoint
		for parameterParticle in 1:NumberOf.ParameterParticle
			filter_State!()
			resample!()
			move!()
		end
	end

	return nothing

end
