function Ibis_density!()
	for densityPoint in 1:NumberOfDensityPoint
		for parameterParticle in 1:NumberOf.ParameterParticle
			for dataPoint in 1:NumberOfDataPoint
				filter_State!()
				resample!()
				move!()
			end
		end
	end

	return nothing

end
