library(glue)
library(magrittr)

validate_head_to_head <- function(game, input){
    inputs <- list(
        player_1 = "{game}_player_1" %>% glue,
        player_2 = "{game}_player_2" %>% glue,
        score_1 =  "{game}_score_1" %>% glue,
        score_2 =  "{game}_score_2" %>% glue
    )
    if(input[[inputs$player_1]] == input[[inputs$player_2]]){
        showNotification("A player cannot play against themselves!", type="error")
    }
    else if(!(input[[inputs$score_1]] >= 0) | !(input[[inputs$score_2]] >= 0)){
        showNotification("Scores must be populated and non-negative!", type="error")
    }
    else (return(TRUE))
    return(FALSE)
}

validate_position <- function(game, input){
    player_order <- "{game}_results" %>% glue
    if(!(length(input[[player_order]]) > 1)){
        showNotification("There are too few players in this match!", type="error")
    }
    else (return(TRUE))
    return(FALSE)
}

validate_data <- function(game, style, input, valid_pin){
    if(valid_pin != input$event_pin){
        showNotification("Event pin is incorrect!", type="error")
        return(FALSE)
    }
    if(style=="h2h"){
        v <- validate_head_to_head(game, input)
        return(v)
    }
    if(style=="position"){
        v <- validate_position(game, input)
        return(v)
    }
}