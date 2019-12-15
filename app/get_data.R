source("mysql_functions.R")

# Generic data
df_players <- query("select * from player;")
df_events <- query("select * from event;")
df_event_players <- query("select * from event_players;")

# Games data
games <- c("fifa", "rps", "headers_and_volleys", "ticket_to_ride", "catan", "ctr")
results <- list()

for(game in games){
    results[[game]] <- "select * from {game}_results;" %>% glue %>% query
}