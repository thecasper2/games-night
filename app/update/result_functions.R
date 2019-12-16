library(glue)
library(magrittr)

get_results <- function(game, style){
    if(style=="h2h"){
        result <- query("
                    select
                    concat(ph.first_name, ' ', ph.last_name) AS home_name,
                    concat(pa.first_name, ' ', pa.last_name) AS away_name,
                    r.* from {game}_results r
                    join player ph on r.home_player_id = ph.player_id
                    join player pa on r.away_player_id = pa.player_id;
                " %>% glue
        )
        result <- result[, -c("home_player_id", "away_player_id")]
        return(result)
    }
    if(style %in% c("position", "catan")){
        result <- query("
                select
                concat(p.first_name, ' ', p.last_name) AS name,
                r.* from {game}_results r
                join player p on r.player_id = p.player_id;
            " %>% glue
        )
        result <- result[, -c("player_id")]
        return(result)
    }
}
