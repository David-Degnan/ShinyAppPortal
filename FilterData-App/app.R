# MOAP Project
# Dummy app "FilterData"
# Last Updated: October 14, 2022

library(datasets)
library(shiny)
library(mapDataAccess)

# Filter data UI
ui <- fluidPage(

    # Application title
    titlePanel("Filter Data App"),

    # Subset iris data by species and sepal length
    sidebarLayout(
        sidebarPanel(
          selectInput("Dataset", "Select Dataset", c("iris", "cars", "trees")), 
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
    FilteredTable <- reactiveValues(Table = NULL)
  
    # Get resulting table
    getTable <- reactive({
      if (input$Dataset == "iris") {return(datasets::iris)} else 
      if (input$Dataset == "cars") {return(datasets::cars)} else {return(datasets::trees)}
    })
      
    # Display table
    output$Table <- renderTable({
      if (is.null(FilteredTable$Table)) {return(getTable())} else {FilteredTable$Table}
    })
    
    # Output table as a csv
    observeEvent(input$FilterFun, {
      
      # Pull the data
      data <- getTable()
      
      # Remove values
      FilteredTable$Table <- data[which(data[,1] > input$RemoveLevel),]
      
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
