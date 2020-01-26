Path = pwd()
push!(LOAD_PATH, joinpath(Path, "src"))
using Beate
using FileIO, DataFrames, StatsBase, Distributions, Plots, Statistics

Data = load(
	joinpath(
		Path,
		"Data",
		"WellLogManyOf1" *
		".jld2"
	),
	"WellLogManyOf1"
)

DataDf = DataFrame(
	Target = Data.Target[1, :],
	StateMean = Data.State[1, :],
	StateMixture = Data.State[3, :]
)

save(
	joinpath(
		"C:\\GoogleDrive",
		"Forschung",
		"Paper3",
		"Paper",
		"data",
		"WellLog1Realization.csv"
	),
	DataDf
)
