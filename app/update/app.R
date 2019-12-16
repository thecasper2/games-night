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
            textInput("event_password", "Event password", value=""),
            h2("Create new event"),
            textInput("new_event_name", "New event name:", value=""),
            uiOutput("new_event_players_selector"),
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
                    div(style="display:flex",
                        uiOutput("fifa_player_1"),
                        uiOutput("fifa_score_1")
                    ),
                    div(style="display:flex",
                        uiOutput("fifa_player_2"),
                        uiOutput("fifa_score_2")
                    ),
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
                    div(style="display:flex",
                        uiOutput("rps_player_1"),
                        uiOutput("rps_score_1")
                    ),
                    div(style="display:flex",
                        uiOutput("rps_player_2"),
                        uiOutput("rps_score_2")
                    ),
                    actionButton("ps_results", label="Submit results", icon("refresh")),
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

    # Get data reactives
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
    
    # Create selectors for new events and players
    output$event_selector <- renderUI({
        event_options <- setNames(data$events$event_id, data$events$event_name)
        selectInput("selected_event", "Select event", choices = event_options, multiple = FALSE)
    })
    
    output$new_event_players_selector <- renderUI({
        player_options <- setNames(data$players$player_id, paste(data$players$first_name, data$players$last_name))
        selectInput("new_event_players", "Select event players", choices = player_options, multiple = TRUE)
    })
    
    # Create new events and players
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
                create_event(input$new_event_name, input$new_event_players)
                data$events <- query("select * from event;")
                data$event_players <- query("select * from event_players;")
                showNotification(paste0("Event '", input$new_event_name,"' created!"))
            })
        }
        else if (nchar(input$new_event_name) <= 0){showNotification("Event name too short!", type="error")}
        else {showNotification("Event has too few players!", type="error")}
    })

    # Eligible players
    eligible_players <- reactive({
        req(input$selected_event)
        p <- data$event_players[event_id == input$selected_event]
        p <- data$players[p, on="player_id"]
        opts <- setNames(p$player_id, paste(p$first_name, p$last_name))
        return(opts)
    })

    # FIFA
    output$fifa_player_1 <- renderUI({
        selectInput(
            "fifa_player_1",
            "Select first player",
            choices = eligible_players(),
            multiple = FALSE
        )
    })
    output$fifa_score_1 <- renderUI({
        numericInput("fifa_score_1", "First player score", value=0, min=0, step=1)
    })
    output$fifa_player_2 <- renderUI({
        selectInput(
            "fifa_player_2",
            "Select second player",
            choices = eligible_players(),
            multiple = FALSE
        )
    })
    output$fifa_score_2 <- renderUI({
        numericInput("fifa_score_2", "Second player score", value=0, min=0, step=1)
    })
    ## submit
    observeEvent(input$submit_fifa_results, {
        pass <- validate_data("fifa", "h2h", input)
        if(pass){
            confirmSweetAlert(
                session = session,
                inputId = "fifa_submit_confirm",
                type = "warning",
                title = "Submit FIFA results?"
            )
        }
    })
    observeEvent(input$fifa_submit_confirm, {
        if(isTRUE(input$fifa_submit_confirm)){
                submit_results(game="fifa", style="h2h", metric="goals", input=input)
                results$fifa <- get_results("fifa", "h2h")
                showNotification("Results submitted!")
        }
    })
    ## table
    output$fifa_results_table <- renderDataTable({
        results$fifa[event_id == input$selected_event][,-c("event_id")][order(-match_id)]
    })

    # Headers and Volleys
    output$headers_and_volleys_results_selector <- renderUI({
        selectInput(
            "headers_and_volleys_results",
            "Select players in order of finishing position",
            choices = eligible_players(),
            multiple = TRUE
        )
    })
    ## submit
    observeEvent(input$submit_headers_and_volleys_results, {
        pass <- validate_data("headers_and_volleys", "position", input)
        if(pass){
            confirmSweetAlert(
                session = session,
                inputId = "headers_and_volleys_submit_confirm",
                type = "warning",
                title = "Submit Headers and Volleys results?"
            )
        }
    })
    observeEvent(input$headers_and_volleys_submit_confirm, {
        if(isTRUE(input$headers_and_volleys_submit_confirm)){
            submit_results(game="headers_and_volleys", style="position", input=input)
            results$headers_and_volleys <- get_results("headers_and_volleys", "position")
            showNotification("Results submitted!")
        }
    })
    ## table
    output$headers_and_volleys_results_table <- renderDataTable({
        results$headers_and_volleys[event_id == input$selected_event][,-c("event_id")][order(-match_id, position)]
    })

    # Catan
    ## table
    output$catan_results_table <- renderDataTable({
        results$catan[event_id == input$selected_event][,-c("event_id")][order(-match_id, victory_points)]
    })

    # CTR
    output$ctr_results_selector <- renderUI({
        selectInput(
            "ctr_results",
            "Select players in order of finishing position",
            choices = eligible_players(),
            multiple = TRUE
        )
    })
    ## submit
    observeEvent(input$submit_ctr_results, {
        pass <- validate_data("ctr", "position", input)
        if(pass){
            confirmSweetAlert(
                session = session,
                inputId = "ctr_submit_confirm",
                type = "warning",
                title = "Submit CTR results?"
            )
        }
    })
    observeEvent(input$ctr_submit_confirm, {
        if(isTRUE(input$ctr_submit_confirm)){
            submit_results(game="ctr", style="position", input=input)
            results$ctr <- get_results("ctr", "position")
            showNotification("Results submitted!")
        }
    })
    ## table
    output$ctr_results_table <- renderDataTable({
        results$ctr[event_id == input$selected_event][,-c("event_id")][order(-match_id, position)]
    })

    # Ticket to ride
    output$ticket_to_ride_results_selector <- renderUI({
        selectInput(
            "ticket_to_ride_results",
            "Select players in order of finishing position",
            choices = eligible_players(),
            multiple = TRUE
        )
    })
    ## submit
    observeEvent(input$submit_ticket_to_ride_results, {
        pass <- validate_data("ticket_to_ride", "position", input)
        if(pass){
            confirmSweetAlert(
                session = session,
                inputId = "ticket_to_ride_submit_confirm",
                type = "warning",
                title = "Submit Ticket to Ride results?"
            )
        }
    })
    observeEvent(input$ticket_to_ride_submit_confirm, {
        if(isTRUE(input$ticket_to_ride_submit_confirm)){
            submit_results(game="ticket_to_ride", style="position", input=input)
            results$ticket_to_ride <- get_results("ticket_to_ride", "position")
            showNotification("Results submitted!")
        }
    })
    ## table
    output$ticket_to_ride_results_table <- renderDataTable({
        results$ticket_to_ride[event_id == input$selected_event][,-c("event_id")][order(-match_id, position)]
    })

    # Rock Paper Scissors
    output$rps_player_1 <- renderUI({
        selectInput(
            "rps_player_1",
            "Select first player",
            choices = eligible_players(),
            multiple = FALSE
        )
    })
    output$rps_score_1 <- renderUI({
        numericInput("rps_score_1", "First player score", value=0, min=0, step=1)
    })
    output$rps_player_2 <- renderUI({
        selectInput(
            "rps_player_2",
            "Select second player",
            choices = eligible_players(),
            multiple = FALSE
        )
    })
    output$rps_score_2 <- renderUI({
        numericInput("rps_score_2", "Second player score", value=0, min=0, step=1)
    })
    ## submit
    observeEvent(input$submit_rps_results, {
        pass <- validate_data("rps", "h2h", input)
        if(pass){
            confirmSweetAlert(
                session = session,
                inputId = "rps_submit_confirm",
                type = "warning",
                title = "Submit Rock Paper Scissors results?"
            )
        }
    })
    observeEvent(input$rps_submit_confirm, {
        if(isTRUE(input$rps_submit_confirm)){
            submit_results(game="rps", style="h2h", metric="wins", input)
            results$rps <- get_results("rps", "h2h")
            showNotification("Results submitted!")
        }
    })
    ## table
    output$rps_results_table <- renderDataTable({
        results$rps[event_id == input$selected_event][,-c("event_id")][order(-match_id)]
    })
}

shinyApp(ui = ui, server = server)
