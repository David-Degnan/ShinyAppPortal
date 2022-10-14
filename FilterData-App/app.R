# MOAP Project
# Dummy app "FilterData" for Container 1
# Last Updated: October 14, 2022

library(datasets)
library(shiny)
library(shinyWidgets)
library(uuid)

# Filter data UI
ui <- fluidPage(

    # Application title
    titlePanel("Filter Data App"),

    # Subset iris data by species and sepal length
    sidebarLayout(
        sidebarPanel(
            selectInput("Species", "Select Species", iris$Species, selected = iris$Species,
                        multiple = T),
            sliderInput("SepalLength", "Set Sepal Length", min(iris$Sepal.Length), 
                        max(iris$Sepal.Length), value = c(min(iris$Sepal.Length), max(iris$Sepal.Length)),
                        step = 0.1),
            actionButton("ExportToPlotData", "Export to Plot Data App")
        ),

        # Show a table of results
        mainPanel(
           tableOutput("Table")
        )
    )
)

# Define server logic to make the table
server <- function(session, input, output) {
    
    # Get resulting table
    getTable <- reactive({
      return(
        iris[iris$Species %in% input$Species & iris$Sepal.Length >= min(input$SepalLength) &
               iris$Sepal.Length <= max(input$SepalLength),]
      )
    })
   
  
    # Display table
    output$Table <- renderTable({
      getTable()
    })
    
    # Output table as a csv
    observeEvent(input$ExportToPlotData, {
      
      # Create the UUID
      UUID <- UUIDgenerate()
      
      # Generate the filepath
      filepath <- file.path("/data", paste0(UUID, "_data.csv"))
      
      # Write the table as a csv
      write.csv(getTable(), filepath, quote = F, row.names = F)
      
      # Append commands csv
      CMDS <- read.csv("/data/CMDS.csv")
      CMDS <- data.frame(rbind(CMDS, c(UUID, paste0("?data=", filepath))))
      colnames(CMDS) <- c("UUID", "Parameters")
      write.csv(CMDS, "/data/CMDS.csv", quote = F, row.names = F)
      
      # Generate the url
      sendURL <- paste0("http://localhost:6400/?", UUID)
      
      sendSweetAlert(session, "Data Ready! Click link.",
       a("FilterApp", href = sendURL, target = "_blank"), type = "success"
      )
      
    })
    
    
}

# Run the application 
shinyApp(ui = ui, server = server)
