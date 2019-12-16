library(glue)
library(magrittr)

submit_position <- function(game, input){
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
}