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
        win = ifelse(gd > 0, 1, 0),
        draw = ifelse(gd == 0, 1, 0),
        loss = ifelse(gd < 0, 1, 0)
    )]
    # Aggregate into results table
    results_table <- results_table[,
        lapply(.SD, sum, na.rm=TRUE),
        by=.(event_id, player_id),
        .SDcols=c("gf", "ga", "gd", "win", "draw", "loss")
    ]
    # Assign points
    results_table[, points := (win*3) + draw]
    results_table[, event_points := rank(points), by=.(event_id)]
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
    x <- x[, c("event_id", "player_id", "event_points")]
    y <- y[, c("event_id", "player_id", "event_points")]
    z <- rbind(x, y)
    z <- z[, .(event_points = sum(event_points)), by=.(event_id, player_id)]
    return(z)
}