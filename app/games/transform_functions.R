library(glue)
library(magrittr)

head2head_results <- function(df_results, metric="goals"){
    # Creates a summarised league table for head to head type games
    # e.g. FIFA, or Rock Paper Scissors
    
    # Define metric cols
    metric_cols <- c("home_{metric}", "away_{metric}")
    for(i in seq(length(metric_cols))){
        metric_cols[i] <- metric_cols[i] %>% glue
    }
    
    # melt to results table
    melt_cols <- c("match_id", "event_id", metric_cols)
    results_table <- melt(df_results, id=melt_cols, variable.name = "home_away", value.name="player_id")
    # Sum goals and stuff
    results_table[,`:=` (
        gf = ifelse(home_away == "home_player_id", get(metric_cols[1]), get(metric_cols[2])),
        ga = ifelse(home_away == "home_player_id", get(metric_cols[2]), get(metric_cols[1]))
    )]
    results_table[, gd := gf - ga]
    results_table[,`:=` (
        win = as.integer(ifelse(gd > 0, 1, 0)),
        draw = as.integer(ifelse(gd == 0, 1, 0)),
        loss = as.integer(ifelse(gd < 0, 1, 0))
    )]
    # Aggregate into results table
    results_table <- results_table[,
        lapply(.SD, sum, na.rm=TRUE),
        by=.(event_id, player_id),
        .SDcols=c("gf", "ga", "gd", "win", "draw", "loss")
    ]
    # Assign points
    results_table[, points := as.integer((win*3) + draw)]

    results_table[, event_points := as.integer(rank(
        points + (gd / 10000) + (gf / 100000)
    )), by=.(event_id)] # Hack to order by gd and gf
    return(results_table[order(event_id, -points, -gd)])
}


multiplayer_results <- function(df_results, metric="position", positive="low"){
    # Creates a summarised league table for multiplayer type games
    # e.g. Crash Team Racing, Headers and Volleys, Catan, and Ticket to Ride
    # The variable metric tells us what we are scoring using
    # The variable positive says whether a "low" or "high" metric score is a positive result,
    # for example a low CTR position is good, but a high Catan victory points is good
    
    if(positive=="low"){
        multiplier <- -1
    }
    else if (positive=="high"){
        multiplier <- 1
    }
    
    results_table <- df_results[, .(
        average_result = mean(get(metric)),
        total_games = .N
    ), by=.(event_id, player_id)]
    results_table[, event_points := rank(multiplier*average_result), by=.(event_id)]
    return(results_table[order(event_id, -multiplier*average_result)])
}

merge_results <- function(x, y){
    # Take two results tables and combine them to get total event points
    x <- x[, c("event_id", "player_id", "event_points", "game_name")]
    y <- y[, c("event_id", "player_id", "event_points", "game_name")]
    z <- rbind(x, y)
    #z <- z[, .(event_points = sum(event_points)), by=.(event_id, player_id)]
    return(z)
}

create_final_results <- function(results){
    ## Creates a list of final results for games where final results exist.
    ## If no results exist, then an empty data.table is returned
    temp_results <- list()
    for(name in names(results)){
        if(nrow(results[[name]]) > 0){
            temp_results[[name]] <- results[[name]]
            temp_results[[name]][["game_name"]] <- name
        }
    }
    if(length(temp_results) == 0){return(data.table())}
    final_results <- Reduce(merge_results, temp_results)[order(event_id, -event_points)]
    return(final_results)
}
