library(glue)
library(magrittr)

test_numeric <- function(a){return(!is.na(suppressWarnings(as.numeric(a))))}

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

validate_catan <- function(game, input){
    # We check that:
    # - There are more than 1 players selected
    # - There are as many victory points as players
    # - All victory points are numeric
    player_order <- "{game}_results" %>% glue
    vp <- unlist(strsplit(input$catan_victory_points, split=","))
    if(!(length(input[[player_order]]) > 1)){
        showNotification("There are too few players in this match!", type="error")
    }
    else if(length(input[[player_order]]) != length(vp)){
        showNotification("The number of victory points doesn't match the number of players", type="error")
    }
    else if(min(sapply(vp, test_numeric)) < 1){
        showNotification("The victory points are not all numerical", type="error")
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
    if(style=="catan"){
        v <- validate_catan(game, input)
        return(v)
    }
}