require(DBI)
require(tidycensus)
require(dplyr)

dotenv::load_dot_env()

wh_host <- Sys.getenv('WH_HOST')
wh_db <- Sys.getenv('WH_DB')
wh_user <- Sys.getenv('WH_USER')
wh_pass <- Sys.getenv('WH_PASS')

census_api_key(key = Sys.getenv('census'))

# Connection to Warehouse
wh_con <- dbConnect(odbc::odbc(), driver = "{ODBC Driver 17 for SQL Server}", server = wh_host, database = wh_db, UID = wh_user, pwd = wh_pass)

alco_demo <- get_acs(geography = "county", year = 2019, state = 42, county = "003", variables = c("B01003_001", "B02001_002", "B02001_003", "B02001_004", "B02001_005", "B02001_006", "B02001_007", "B02001_008", "B02001_009", "B02001_010")) %>%
  mutate(var_name = case_when(variable == "B01003_001" ~ "Total",
                              variable == "B02001_002" ~ "White",
                              variable == "B02001_003" ~ "Black or African American",
                              variable == "B02001_004" ~ "American Indian and Alaska Native", 
                              variable == "B02001_005" ~ "Asian",
                              TRUE ~ "Other")) %>%
  dplyr::group_by(GEOID, var_name)%>%
  dplyr::summarise(estimate = sum(estimate), moe = sum(moe))

dbWriteTable(wh_con, SQL('Master.ACLO_Census_Demographics'), alco_demo, overwrite = TRUE)

dbDisconnect(wh_con)