# e2orihjweiopt4 /t'pai39u [0r 
# TRIGERER ANOWtwe;rlgfjwerpoj gpowrj
# Portal Example
# Application: "FilterData"
# Last Updated: October 14, 2022

library(shiny)
library(mapDataAccess)
library(reticulate)

# Register url, this is running in another docker container alongside this one
if(!file.exists("./cfg/redis_config.yml")){
  warning("No redis configuration found, attempting connection to default url: redis://redis1:6379")
  redis_url <- "redis://redis1:6379/0"
} else {
  redis_cfg = yaml::read_yaml("./cfg/redis_config.yml")
  redis_host = redis_cfg[['host']]
  redis_url <- sprintf('redis://%s:%s/%s', 
                       redis_host, 
                       redis_cfg[['port']],
                       redis_cfg[['db']])
}

# Start up celery
reticulate::use_virtualenv("/venv")
clry <- reticulate::import('celery')
celery_app <- clry$Celery('app', broker=redis_url, backend=redis_url)

sendModalAlert <- function(message = "") {
  showModal(modalDialog(
    HTML(paste0('<span style="font-size: 22px;">', message, '</span>')),
    title = "", size = "s", easyClose = TRUE
  ))
}

# Filter data UI
ui <- fluidPage(

    # Application title
    titlePanel("Filter Data App"),

    # Subset iris data by species and sepal length
    sidebarLayout(
        sidebarPanel(
          uiOutput("DatasetUI"), 
          numericInput("RemoveLevel", "Remove values in column 1 below", value = 5),
          actionButton("FilterFun", "Filter data in another container"),
          actionButton("CheckStatus", "Check the status of the filtered data")
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
    TheTable <- reactiveValues(ID = NULL, Unfiltered = NULL, Filtered = NULL, Dataset = NULL, Job = NULL)
    
    # Add the minio connection
    miniocon <- map_data_connection("./cfg/minio_config.yml")
    
    # When the application starts up, check for data in the search string
    observeEvent(input$`__startup__`, {
      
      # Parse the query string at the url header
      query <- parseQueryString(session$clientData$url_search)
      message(paste0("QUERY:", query))
      
      # Set a conditional test. We only care if the "data" parameter exists. 
      cond <- length(query) != 0 && "data" %in% names(query) 
      
      message(paste0("CONDITION: ", cond))
      
      # If true, open the data and put each piece where it belongs
      if (cond) {
        
        message(query)
        
        # Save the ID 
        TheTable$ID <- query$data
        
        # Load the unfiltered data
        TheTable$Unfiltered <- get_data(miniocon, query$data)
        
        # Add the data tag 
        message(paste0("...the tags are:", get_tags(miniocon, query$data)))
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
    
      # Submit filtering task
      TheTable$Job <- celery_app$send_task("filterFun", 
                           kwargs = list(
                             username = Sys.getenv("SHINYPROXY_USERNAME"),
                             id = TheTable$ID, 
                             filterval = input$RemoveLabel
                           ))
      
    })
    
    # Return job status
    observeEvent(input$CheckStatus, {
      if (!is.null(TheTable$Job)) {
        sendModalAlert(TheTable$Job$info)
      } else {
        sendModalAlert("No jobs are currently running.")
      }
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
