# Portal Example
# Application: Main Portal
# Last Updated: October 14, 2022

# Shiny infrastructure packages
library(shiny)

# Data management packages: Install here (https://github.com/EMSL-Computing/mapDataAccess)
library(mapDataAccess)

# Load R datasets
library(datasets)

sendModalAlert <- function(message = "") {
  showModal(modalDialog(
    HTML(paste0('<span style="font-size: 22px;">', message, '</span>')),
    title = "", size = "s", easyClose = TRUE
  ))
}

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
    observeEvent(input$OpenApp, {
      
      # Set up minio configuration
      miniocon <- map_data_connection("./cfg/minio_config.yml")
      
      # Put data up on minio and save the ID 
      id <- put_data(miniocon, getTable())
      
      # Add a tag of which dataset 
      set_tags(miniocon, id, list("data" = input$Dataset))
      
      # Generate the url
      sendURL <- paste0("http://localhost:4200/?", id)
      
      sendModalAlert(paste0("Data Ready! Go to link:", sendURL))
      
    })
    
    
}

# Run the application 
shinyApp(ui = ui, server = server)
