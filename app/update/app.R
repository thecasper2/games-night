library(data.table)
library(magrittr)
library(shiny)
source("../games/mysql_functions.R")

ui <- fluidPage(
    titlePanel("Games night update scores"),
    sidebarLayout(
        sidebarPanel(
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
                    div(style="display:flex",
                        uiOutput("fifa_player_1"),
                        uiOutput("fifa_score_1")
                    ),
                    div(style="display:flex",
                        uiOutput("fifa_player_2"),
                        uiOutput("fifa_score_2")
                    )
                ),
                tabPanel("Headers and Volleys", uiOutput("headers_and_volleys_results_selector")),
                tabPanel("Catan"),
                tabPanel("CTR", uiOutput("ctr_results_selector")),
                tabPanel("Ticket to Ride", uiOutput("ticket_to_ride_results_selector")),
                tabPanel("Rock Paper Scissors",
                    div(style="display:flex",
                        uiOutput("rps_player_1"),
                        uiOutput("rps_score_1")
                    ),
                    div(style="display:flex",
                        uiOutput("rps_player_2"),
                        uiOutput("rps_score_2")
                    )
                )
            )
        )
    )
)

server <- function(input, output) {
    # Get data reactives
    withProgress(message = "Connecting to server...", value = 0.5, {
        data <- reactiveValues(
            players = query("select * from player;"),
            events = query("select * from event;"),
            event_players = query("select * from event_players;")
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
        else {showNotification("Name is too short!")}
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
        else if (nchar(input$new_event_name) <= 0){showNotification("Event name too short!")}
        else {showNotification("Event has too few players!")}
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
            multiple = TRUE
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
            multiple = TRUE
        )
    })
    output$fifa_score_2 <- renderUI({
        numericInput("fifa_score_2", "Second player score", value=0, min=0, step=1)
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

    # Catan
    # CTR
    output$ctr_results_selector <- renderUI({
        selectInput(
            "ctr_results",
            "Select players in order of finishing position",
            choices = eligible_players(),
            multiple = TRUE
        )
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
    # Rock Paper Scissors
    output$rps_player_1 <- renderUI({
        selectInput(
            "rps_player_1",
            "Select first player",
            choices = eligible_players(),
            multiple = TRUE
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
            multiple = TRUE
        )
    })
    output$rps_score_2 <- renderUI({
        numericInput("rps_score_2", "Second player score", value=0, min=0, step=1)
    })
}

shinyApp(ui = ui, server = server)
