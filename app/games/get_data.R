source("mysql_functions.R")

# Generic data
df_players <- query("select * from player;")
df_players[, full_name := paste(first_name, last_name)]
df_events <- query("select * from event;")
df_event_players <- query("select * from event_players;")

# Games data
games <- c("fifa", "rps", "headers_and_volleys", "ticket_to_ride", "catan", "ctr")
raw_results <- list()

for(game in games){
    raw_results[[game]] <- "select * from {game}_results;" %>% glue %>% query
}

# Transform raw results to scored results
source("transform_functions.R")

results <- list(
    fifa = head2head_results(raw_results[["fifa"]], metric="goals"),
    rps = head2head_results(raw_results[["rps"]], metric="wins"),
    headers_and_volleys = multiplayer_results(raw_results[["headers_and_volleys"]], metric="position", positive = "low"),
    ticket_to_ride = multiplayer_results(raw_results[["ticket_to_ride"]], metric="position", positive = "low"),
    catan = multiplayer_results(raw_results[["catan"]], metric="victory_points", positive = "high"),
    ctr = multiplayer_results(raw_results[["ctr"]], metric="position", positive = "low")
)

final_results <- create_final_results(results)
if(nrow(final_results) > 0){
    final_results <- final_results[df_players, on="player_id"][,-c("first_name", "last_name")]
}
