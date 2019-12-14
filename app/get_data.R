source("mysql.R")

df_players <- query("select * from player;")
df_events <- query("select * from event;")
df_event_players <- query("select * from event_players;")
