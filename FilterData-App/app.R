# MOAP Project
# Dummy app "FilterData"
# Last Updated: October 14, 2022

library(shiny)
library(mapDataAccess)

# Filter data UI
ui <- fluidPage(

    # Application title
    titlePanel("Filter Data App"),

    # Subset iris data by species and sepal length
    sidebarLayout(
        sidebarPanel(
          uiOutput("DatasetUI"), 
          numericInput("RemoveLevel", "Remove values in column 1 below", value = 5),
          actionButton("FilterFun", "Filter data in another container")
        ),

        # Show a table of results
        mainPanel(
           tableOutput("Table")
        )
    )
)

# Define server logic to make the table
server <- function(session, input, output) {
  
    # Store a reactive value to hold results
    TheTable <- reactiveValues(Unfiltered = NULL, Filtered = NULL, Dataset = NULL)
    
    # Add the minio connection
    miniocon <- map_data_connection("./cfg/minio_config.yml")
    
    # When the application starts up, check for data in the search string
    observeEvent(input$`__startup__`, {
      
      # Parse the query string at the url header
      query <- parseQueryString(session$clientData$url_search)
      
      # Set a conditional test. We only care if the "data" parameter exists. 
      cond <- length(query) != 0 && "data" %in% names(query) 
      
      # If true, open the data and put each piece where it belongs
      if (cond) {
        
        # Load the unfiltered data
        TheTable$Unfiltered <- get_data(miniocon, query$data)
        
        # Add the data tag 
        TheTable$Dataset <- get_tags(miniocon, query$data)$data
        
      }
    
    })
    
    # Render reactive ui
    output$DatasetUI <- renderUI(
      textInput("Dataset", "Loaded Dataset", TheTable$Dataset)
    )
  
    # Display table
    output$Table <- renderTable({
      if (is.null(TheTable$Filtered)) {
        if (is.null(TheTable$Unfiltered)) {return(NULL)} else {TheTable$Unfiltered}
      } else {TheTable$Filtered}
    })
    
    # Output table as a csv
    observeEvent(input$FilterFun, {
      
      # Pull the data
      data <- TheTable$Unfiltered
      
      # Remove values
      TheTable$Filtered <- data[which(data[,1] > input$RemoveLevel),]
      
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
