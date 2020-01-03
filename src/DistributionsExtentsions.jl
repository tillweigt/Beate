struct Invariant{
	T1<:Real
}<:DiscreteUnivariateDistribution
	Variable::T1
end

function rand(d::Invariant)
	return d.Variable
end

function rand(d::Invariant, n::Int64)
	return fill(d.Variable, n)
end
