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
                tabPanel("a"
                ),
                tabPanel("b"
                )
            )
        )
    )
)

server <- function(input, output) {
    # Get data reactives
    get_players <- reactive({return(query("select * from player;"))})
    get_events <- reactive({return(query("select * from event;"))})
    get_event_players <- reactive({return(query("select * from event_players;"))})
    
    # Create selectors for new events and players
    output$event_selector <- renderUI({
        events <- get_events()
        event_options <- setNames(events$event_id, events$event_name)
        selectInput("selected_event", "Select event", choices = event_options, multiple = FALSE)
    })
    
    output$new_event_players_selector <- renderUI({
        players <- get_players()
        player_options <- setNames(players$player_id, paste(players$first_name, players$last_name))
        selectInput("new_event_players", "Select event players", choices = player_options, multiple = TRUE)
    })
    
    # Create new events and players
    observeEvent(input$submit_new_user, {
        if(nchar(input$new_user_first_name) >= 1 & nchar(input$new_user_last_name) >= 1){
            withProgress(message = 'Creating user', value = 0.5,{
                create_user(input$new_user_first_name, input$new_user_last_name)
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
                showNotification(paste0("Event '", input$new_event_name,"' created!"))
            })
        }
        else if (nchar(input$new_event_name) <= 0){showNotification("Event name too short!")}
        else {showNotification("Event has too few players!")}
    })
}

shinyApp(ui = ui, server = server)
