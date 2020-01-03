using FileIO, DataFrames

Data =
DataFrame(load(joinpath(pwd(),"Data", "GoyalDataPrepared.csv")))

Data = Data[:, 3:end]

save(joinpath(pwd(), "Data", "GoyalDataPrepared.jld2"), "GoyalDataPrepared", Data)
