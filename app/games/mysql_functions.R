library(data.table)
library(glue)
library(magrittr)
library(RMySQL)

db_variables <- list(
    user="root",
    password="example",
    dbname="adolphin",
    host="db",
    port=3306
)

con <- function(db_variables){
    # Creates a connection to a MySQL database
    connection <- RMySQL::dbConnect(
        MySQL(),
        user=db_variables$user,
        password=db_variables$password,
        dbname=db_variables$dbname,
        host=db_variables$host,
        port=db_variables$port)
    return(connection)
}

query <- function(query_string, data=TRUE){
    # Returns the result of a query to the default MySQL connection
    connection <- con(db_variables)
    d <- dbSendQuery(connection, query_string) 
    if(data){
        result <- d %>% fetch %>% as.data.table
        RMySQL::dbDisconnect(connection)
        return(result)   
    }
}

create_user <- function(first_name, last_name){
    # Creates a new user in the player table
    "INSERT INTO player (first_name, last_name) VALUES ('{first_name}', '{last_name}');" %>%
        glue %>% query(data=FALSE)
}

create_event <- function(event_name, player_ids){
    # Creates a new event with the selected players
    "INSERT INTO event (event_name) VALUES ('{event_name}');" %>%
        glue %>% query(data=FALSE)
    
    event_id <- query(
        "select event_id from event 
        where event_id = (select max(event_id) from event);"
    )[[1]]
    
    # Insert each selected player into the event players
    for(player_id in player_ids){
        "INSERT INTO event_players (event_id, player_id) VALUES  ({event_id}, {player_id});" %>%
            glue %>% query(data=FALSE)
    }
}