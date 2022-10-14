# Portal Example
# 
# Last Updated: October 14, 2022

# Shiny infrastructure packages
library(shiny)

# Data management packages: Install here (https://github.com/EMSL-Computing/mapDataAccess)
library(mapDataAccess)

# Load R datasets
library(datasets)

# Filter data UI
ui <- fluidPage(

    # Application title
    titlePanel("Main Portal"),

    # Subset iris data by species and sepal length
    sidebarLayout(
        sidebarPanel(
            selectInput("App", "Select Application", "FilterApp"),
            selectInput("Dataset", "Select Dataset", c("iris", "cars", "trees")),
            actionButton("OpenApp", "Open Application with Dataset")
        ),

        # Show a table of results
        mainPanel(
          HTML("View Selected Dataset:"),
          tableOutput("Table")
        )
    )
)

# Define server logic to make the table
server <- function(session, input, output) {
    
    # Get resulting table
    getTable <- reactive({
      if (input$Dataset == "iris") {return(datasets::iris)} else 
      if (input$Dataset == "cars") {return(datasets::cars)} else {return(datasets::trees)}
    })
   
    # Display table
    output$Table <- renderTable({
      getTable()
    })
    
    # Output table as a csv
    observeEvent(input$ExportToPlotData, {
      
      # Set up minio configuration
      #miniocon <- 
      
      # Generate the url
      #sendURL <- paste0("http://localhost:6400/?", UUID)
      
      #sendSweetAlert(session, "Data Ready! Click link.",
      # a("FilterApp", href = sendURL, target = "_blank"), type = "success"
      #)
      
    })
    
    
}

# Run the application 
shinyApp(ui = ui, server = server)
