library(readxl)
library(tidyverse)
PredictorData2017 = read_excel(
  path = 
  "C:/GoogleDrive/Forschung/Software/BeateOld/data/PredictorData2017.xlsx"
)
CayDataCurrent = read_csv(
  file = 
  "C:/GoogleDrive/Forschung/Software/BeateOld/data/cay_current.csv"
)
names(CayDataCurrent)[1] = "Date"
CayPrepared = CayDataCurrent %>%
  mutate_all(
    funs(as.numeric(.))
  ) %>%
  mutate(
    Date = as.Date(paste0(Date, "01"), format = "%Y%m%d")
  ) %>%
  dplyr::select(
    Date, Cay = X5
  )
  
DatAddYearAndMonth = PredictorData2017 %>%
  mutate_all(
    funs(as.numeric(.))
  ) %>%
  rename(
    Date = yyyymm
  ) %>%
  mutate(
    Date = paste0(Date, "01")
  ) %>%
  mutate(
    Date = as.Date(Date, format = "%Y%m%d")
  ) %>%
  mutate(
    Year = as.integer(format(Date, "%Y")),
    Month = as.integer(format(Date, "%m"))
  )

DatComputePredictor = DatAddYearAndMonth %>%
  rename(
    StockVariance = svar,
    CrossSectionalPremium = csp,
    BookToMarketRatio = `b/m`,
    NetEquityExpansion= ntis,
    LongTermYield = lty,
    LongTermRateOfReturns = ltr,
    Inflation = infl,
    TreasuryBillRate = tbl
  ) %>%
  mutate(
    ExcessReturn = CRSP_SPvw - Rfree,
    DividendPriceRatio = log(D12) - log(Index),
    LaggedIndex = lag(Index),
    DividendYield = log(D12) - log(LaggedIndex),
    EarningsPriceRatio = log(E12) - log(Index),
    DividendPayoutRatio = log(D12) - log(E12),
    TermSpread = LongTermYield - TreasuryBillRate,
    DefaultYieldSpread = BAA - AAA,
    DefaultReturnSpread = corpr - LongTermRateOfReturns
  ) %>%
  # full_join(
  #   CayPrepared
  # ) %>% # only quarterly
  dplyr::select(
    -c(
      Index, D12, E12, AAA, BAA, corpr, LaggedIndex,
      Rfree, CRSP_SPvw, CRSP_SPvwx
    )
  )

DatPrepared = DatComputePredictor %>%
  dplyr::filter(
    Year >= 1927
  ) %>%
  dplyr::select(
    -c(
      CrossSectionalPremium,
      Year,
      Month
    )
  )

if (sum(is.na(DatPrepared)) != 0) stop()

write.csv(
  DatPrepared,
  file = 
  "C:/GoogleDrive/Forschung/Software/Beate/Data/GoyalDataPrepared.csv"
)

dat = DatPrepared %>%
  dplyr::select(date = Date, return = ExcessReturn, dy = DividendYield) %>%
  mutate(
    year = as.integer(format(date, "%Y")),
    month = as.integer(format(date, "%m"))
  )

cor(dat$return[-1], dat$dy[-1091])

temp = DatPrepared %>%
  mutate(ExcessReturn = lag(ExcessReturn)) %>%
  select(-Date) %>%
  na.omit() %>%
  cor()
temp[,8]

View(dat %>% filter(year %in% c(2007:2018)))

ggplot(
  dat %>% filter(year %in% c(1990:2018)),
  aes(date, return)
) + geom_point() + geom_line()
