library(glue)
library(magrittr)

submit_head_to_head <- function(game, metric, input){
    withProgress(message = "Submitting results...", value = 0.5, {
        game_string <- "{game}_results" %>% glue
        variables_string <- "event_id, home_player_id, away_player_id, home_{metric}, away_{metric}" %>% glue
        event_id <- input$selected_event
        home_player_id <- input[["{game}_player_1" %>% glue]]
        away_player_id <- input[["{game}_player_2" %>% glue]]
        home_score <- input[["{game}_score_1" %>% glue]]
        away_score <- input[["{game}_score_2" %>% glue]]
        values_string <- "{event_id}, {home_player_id}, {away_player_id}, {home_score}, {away_score}" %>% glue
        submit_results(variables_string, values_string, game=game)
        Sys.sleep(1.5)
    })
}

submit_position <- function(game, input){
    withProgress(message = "Submitting results...", value = 0.5, {
        game_string <- "{game}_results" %>% glue
        variables_string <- "match_id, event_id, player_id, position"
        match_id <- get_next_match_id(game)
        event_id <- input$selected_event
        for(i in seq(length(input[[game_string]]))){
            player_id <- input[[game_string]][[i]]
            position <- i
            values_string <- "{match_id}, {event_id}, {player_id}, {position}" %>% glue
            submit_results(variables_string, values_string, game=game)
        }
        Sys.sleep(2)
    })
}