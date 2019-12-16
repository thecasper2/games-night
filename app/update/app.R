library(data.table)
library(magrittr)
library(shiny)
library(shinyWidgets)
source("../games/mysql_functions.R")

ui <- fluidPage(
    titlePanel("Games night update scores"),
    sidebarLayout(
        sidebarPanel(width = 3,
            h2("Select event"),
            uiOutput("event_selector"),
            numericInput("event_pin", "Event pin", value=0, min=0, max=9999),
            h2("Create new event"),
            textInput("new_event_name", "New event name:", value=""),
            uiOutput("new_event_players_selector"),
            numericInput("new_event_pin", "New event pin", value=0, min=0, max=9999),
            actionButton("submit_new_event", label="Create new event", icon("refresh")),
            h2("Create new players"),
            textInput("new_user_first_name", "New user first name", value="Mr"),
            textInput("new_user_last_name", "New user last name", value="Chips"),
            actionButton("submit_new_user", label="Create new user", icon("refresh"))
        ),
        mainPanel(
            tabsetPanel(
                tabPanel("FIFA",
                    img(src="fifa.svg", height="15%", width="15%", align = "top"),
                    div(style="display:flex", uiOutput("fifa_player_1"), uiOutput("fifa_score_1")),
                    div(style="display:flex", uiOutput("fifa_player_2"), uiOutput("fifa_score_2")),
                    actionButton("submit_fifa_results", label="Submit results", icon("refresh")),
                    hr(),
                    dataTableOutput("fifa_results_table")
                ),
                tabPanel("Headers and Volleys",
                    img(src="headers_and_volleys.jpg", height="30%", width="30%", align = "top"),
                    uiOutput("headers_and_volleys_results_selector"),
                    actionButton("submit_headers_and_volleys_results", label="Submit results", icon("refresh")),
                    hr(),
                    dataTableOutput("headers_and_volleys_results_table")
                ),
                tabPanel("Catan",
                    img(src="catan.svg", height="15%", width="15%", align = "top"),
                    div(style="display:flex",
                        uiOutput("catan_results_selector"),
                        textInput("catan_victory_points", "Respective victory points", "10,5,5")
                    ),
                    actionButton("submit_catan_results", label="Submit results", icon("refresh")),
                    hr(),
                    dataTableOutput("catan_results_table")
                ),
                tabPanel("CTR",
                    img(src="ctr.png", height="25%", width="25%", align = "top"),
                    uiOutput("ctr_results_selector"),
                    actionButton("submit_ctr_results", label="Submit results", icon("refresh")),
                    hr(),
                    dataTableOutput("ctr_results_table")
                ),
                tabPanel("Ticket to Ride",
                    img(src="ticket_to_ride.jpg", height="30%", width="30%", align = "top"),
                    uiOutput("ticket_to_ride_results_selector"),
                    actionButton("submit_ticket_to_ride_results", label="Submit results", icon("refresh")),
                    hr(),
                    dataTableOutput("ticket_to_ride_results_table")
                ),
                tabPanel("Rock Paper Scissors",
                    img(src="rps.png", height="20%", width="20%", align = "top"),
                    div(style="display:flex", uiOutput("rps_player_1"), uiOutput("rps_score_1")),
                    div(style="display:flex", uiOutput("rps_player_2"), uiOutput("rps_score_2")),
                    actionButton("submit_rps_results", label="Submit results", icon("refresh")),
                    hr(),
                    dataTableOutput("rps_results_table")
                )
            )
        )
    )
)

server <- function(input, output, session) {
    source("validation_functions.R")
    source("submit_functions.R")
    source("result_functions.R")

    ####################
    # Initial data grab
    ####################

    withProgress(message = "Getting data", value = 0.5, {
        data <- reactiveValues(
            players = query("select * from player;"),
            events = query("select * from event;"),
            event_players = query("select * from event_players;")
        )

        results <- reactiveValues(
            fifa = get_results("fifa", "h2h"),
            headers_and_volleys = get_results("headers_and_volleys", "position"),
            catan = get_results("catan", "position"),
            ctr = get_results("ctr", "position"),
            ticket_to_ride = get_results("ticket_to_ride", "position"),
            rps = get_results("rps", "h2h")
        )
    })

    ##############################################
    # Create selectors for new events and players
    ##############################################

    output$event_selector <- renderUI({
        event_options <- setNames(data$events$event_id, data$events$event_name)
        selectInput("selected_event", "Select event", choices = event_options, multiple = FALSE)
    })
    
    output$new_event_players_selector <- renderUI({
        player_options <- setNames(data$players$player_id, paste(data$players$first_name, data$players$last_name))
        selectInput("new_event_players", "Select event players", choices = player_options, multiple = TRUE)
    })

    ################################
    # Create new events and players
    ################################

    observeEvent(input$submit_new_user, {
        if(nchar(input$new_user_first_name) >= 1 & nchar(input$new_user_last_name) >= 1){
            withProgress(message = 'Creating user', value = 0.5,{
                create_user(input$new_user_first_name, input$new_user_last_name)
                data$players <- query("select * from player;")
                showNotification(
                    paste0("User '",input$new_user_first_name, " ", input$new_user_last_name,"' created!")
                )
            })
        }
        else {showNotification("Name is too short!", type="error")}
    })
    
    observeEvent(input$submit_new_event, {
        if((length(input$new_event_players) > 1) & (nchar(input$new_event_name) > 0)){
            withProgress(message = 'Creating event', value = 0.5,{
                create_event(input$new_event_name, input$new_event_players, pin=input$new_event_pin)
                data$events <- query("select * from event;")
                data$event_players <- query("select * from event_players;")
                showNotification(paste0("Event '", input$new_event_name,"' created!"))
            })
        }
        else if (nchar(input$new_event_name) <= 0){showNotification("Event name too short!", type="error")}
        else {showNotification("Event has too few players!", type="error")}
    })

    ###################
    # Eligible players
    ###################

    eligible_players <- reactive({
        req(input$selected_event)
        p <- data$event_players[event_id == input$selected_event]
        p <- data$players[p, on="player_id"]
        opts <- setNames(p$player_id, paste(p$first_name, p$last_name))
        return(opts)
    })

    ###################
    # Games parameters
    ###################

    games <- list(
        fifa = list(name="fifa", style="h2h", metric="goals", order_cols=c("match_id")),
        rps = list(name="rps", style="h2h", metric="wins", order_cols=c("match_id")),
        headers_and_volleys = list(name="headers_and_volleys", style="position", metric=NULL, order_cols=c("match_id", "position")),
        ticket_to_ride = list(name="ticket_to_ride", style="position", metric=NULL, order_cols=c("match_id", "position")),
        catan = list(name="catan", style="catan", metric=NULL, order_cols=c("match_id", "victory_points")),
        ctr = list(name="ctr", style="position", metric=NULL, order_cols=c("match_id", "position"))
    )

    ###################
    # Create functions
    ###################

    create_submit <- function(game){
        # Creates the two observe events:
        # 1) Check the validity of the entry, then give the user a confirmation popup
        # 2) On confirm, submit results, update table and show notification
        vars <- games[[game]]
        observeEvent(input[[paste0("submit_", vars$name, "_results")]], {
            valid_pin <- data$events[event_id == input$selected_event]$pin
            pass <- validate_data(game=vars$name, style=vars$style, input, valid_pin)
            if(pass){
                confirmSweetAlert(
                    session = session,
                    inputId = paste0(vars$name, "_submit_confirm"),
                    type = "warning",
                    title = "Submit results?"
                )
            }
        })
        observeEvent(input[[paste0(vars$name,"_submit_confirm")]], {
            if(isTRUE(input[[paste0(vars$name,"_submit_confirm")]])){
                submit_results(game=vars$name, style=vars$style, metric=vars$metric, input)
                results[[vars$name]] <- get_results(vars$name, vars$style)
                showNotification("Results submitted!")
            }
        })
    }

    create_table <- function(game){
        # Creates results tables for each event
        vars <- games[[game]]
        output[[paste0(vars$name, "_results_table")]] <- renderDataTable({
            results[[vars$name]][event_id == input$selected_event][,-c("event_id")][order(-get(vars$order_cols))]
        })
    }
    
    create_selectors <- function(game, players){
        # Creates the selectors required for submitting stuff for each event
        vars <- games[[game]]
        if(vars$style == "h2h"){
            output[[paste0(vars$name, "_player_1")]] <- renderUI({
                selectInput(
                    paste0(vars$name, "_player_1"), "Select first player",
                    choices = eligible_players(), multiple = FALSE
                )
            })
            output[[paste0(vars$name, "_player_2")]] <- renderUI({
                selectInput(
                    paste0(vars$name, "_player_2"), "Select second player",
                    choices = eligible_players(), multiple = FALSE
                )
            })
            output[[paste0(vars$name, "_score_1")]] <- renderUI({
                numericInput(paste0(vars$name, "_score_1"), "First player score", value=0, min=0, step=1)
            })
            output[[paste0(vars$name, "_score_2")]] <- renderUI({
                numericInput(paste0(vars$name, "_score_2"), "Second player score", value=0, min=0, step=1)
            })
        }
        if(vars$style %in% c("position", "catan")){
            output[[paste0(vars$name, "_results_selector")]] <- renderUI({
                selectInput(
                    paste0(vars$name, "_results"), "Select players in order of finishing position",
                    choices = players(), multiple = TRUE
                )
            })
        }
    }

    #################
    # Creation loops
    #################

    ## Submit actions
    lapply(names(games), FUN = create_submit)
    ## Tables
    lapply(names(games), FUN = create_table)
    ## Selectors
    lapply(names(games), FUN = create_selectors, players=eligible_players)
}

shinyApp(ui = ui, server = server)
