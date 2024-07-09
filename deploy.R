library(rjson)
library(rsconnect)

credentials <- fromJSON(file="rsconnect.json")

app_name <- 'entre_claree_et_ecrins'
app_dir <- '.'

rsconnect::setAccountInfo(
    name   = credentials$name,
    token  = credentials$token,
    secret = credentials$secret
)
rsconnect::deployApp(appName = app_name, appDir = app_dir, account = credentials$account, forceUpdate = T, launch.browser = T)
