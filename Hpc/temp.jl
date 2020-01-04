using Distributed

addprocs()

@sync @distributed for i in 1:2
	println(i)
end
