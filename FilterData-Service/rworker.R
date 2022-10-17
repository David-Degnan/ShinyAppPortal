#!/usr/bin/env Rscript  
library(rworker)
library(reticulate)

print("INFO: New Rworker thread started...")
reticulate::use_virtualenv("/venv")

if(!file.exists("redis_config.yml")){
  warning("No redis configuration found, attempting connection to default url: redis://redis1:6379")
  redis_url <- "redis://redis1:6379/0"
} else {
  redis_cfg = yaml::read_yaml(".cfg/redis_config.yml")
  redis_host = redis_cfg[['host']]
  redis_url <- sprintf('redis://%s:%s/%s', 
                       redis_host, 
                       redis_cfg[['port']],
                       redis_cfg[['db']])
}

message("Setting up redis connection at:  ", redis_url)

# Instantiate Rworker object --> link between worker and task manager
consumer <- rworker(name = 'celery', workers = 1, queue = redis_url, backend = redis_url)

#' @param username The SHINYPROXY_USERNAME variable. Important for ensuring the results are returned to the user's subfolder.
#' @param id The universal unique identified (uuid) of the file.
#' @param filterval The provided value for filtering. 
# Create the filter function
filterFun <- function(username,
                      id,
                      filterval) {
  
  # Load libraries
  library(mapDataAccess)
  
  # Connect to minio
  miniocon = map_data_connection("./cfg/minio_config.yml")
  
  # Add shiny proxy username variable to global environment
  Sys.setenv("SHINYPROXY_USERNAME" = username)
  
  # Set status message
  task_progress("Pulling data")
  
  # Add a sleep timer for demo purposes only 
  Sys.sleep(5)
  
  # Pull data
  theData <- get_data(miniocon, id)
  
  # Get tags
  tags <- get_tags(miniocon, id)
  
  # Set status message
  task_progress("Running the filter")
  
  # Add a sleep timer for demo purposes only 
  Sys.sleep(5)
  
  # Run filter
  filteredData <- theData[which(theData[,1] > filterval),]
  
  # Pass filtered data back 
  id2 <- put_file(miniocon, filteredData)
  
  # Set tags
  set_tags(miniocon, id, list("data" = tags$Dataset))
  
  # Return status
  task_progress(paste0("Load filtered data with http://localhost:4200/?data=", id2))
  
}

# Register the task with redis
consumer$task(filterFun, name = "filterFun")

# Set consumer endpoint
consumer$consume()

