
packages_to_use <- c( "caret", "shiny", "LiblineaR", "readr", "dplyr")


install_load <- function(packages){
  to_install <- packages[!(packages %in% installed.packages()[, "Package"])] # identify unavailable packages
  
  if (length(to_install)){  # install unavailable packages 
    install.packages(to_install, repos='http://cran.us.r-project.org', dependencies = TRUE) # install those that have not yet been installed
  }
  
  for(package in packages){  # load all of the packges 
    suppressMessages(library(package, character.only = TRUE))
  }
}



load("RegularizedLogisticRegression.rda")    # Load saved model

source("featureMapping.R")                         #  a function for feature engineering. 
                                                   #  You can include data imputation, data manipulation, data cleaning,
                                                   #  feature transformation, etc.,  functions


shinyServer(function(input, output) {

  options(shiny.maxRequestSize = 800*1024^2)   # This is a number which specifies the maximum web request size, 
                                               # which serves as a size limit for file uploads. 
                                               # If unset, the maximum request size defaults to 5MB.
                                               # The value I have put here is 80MB
  
  
  output$sample_input_data_heading = renderUI({   # show only if data has been uploaded
    inFile <- input$file1
    
    if (is.null(inFile)){
      return(NULL)
    }else{
      tags$h4('Sample data')
    }
   })

  output$sample_input_data = renderTable({    # show sample of uploaded data
    inFile <- input$file1
    
    if (is.null(inFile)){
      return(NULL)
    }else{
      input_data =  readr::read_csv(input$file1$datapath, col_names = TRUE)
      
      colnames(input_data) = c("Test1", "Test2", "Label")
      
      input_data$Label = as.factor(input_data$Label )
      
      levels(input_data$Label) <- c("Failed", "Passed")
      head(input_data)
    }
  })
  
  

predictions<-reactive({
    
    inFile <- input$file1
    
    if (is.null(inFile)){
      return(NULL)
    }else{
      withProgress(message = 'Predictions in progress. Please wait ...', {
      input_data =  readr::read_csv(input$file1$datapath, col_names = TRUE)
      
      colnames(input_data) = c("Test1", "Test2", "Label")
      
      input_data$Label = as.factor(input_data$Label )
      
      levels(input_data$Label) <- c("Failed", "Passed")
      
      mapped = feature_mapping(input_data)
      
      df_final = cbind(input_data, mapped)
      prediction = predict(my_model, df_final)
      
      input_data_with_prediction = cbind(input_data,prediction )
      input_data_with_prediction
      
      })
    }
  })
  

output$sample_prediction_heading = renderUI({  # show only if data has been uploaded
  inFile <- input$file1

  if (is.null(inFile)){
    return(NULL)
  }else{
    tags$h4('Sample predictions')
  }
})

output$sample_predictions = renderTable({   # the last 6 rows to show
 pred = predictions()
tail(pred)

})


# Downloadable csv of predictions ----

output$downloadData <- downloadHandler(
  filename = function() {
    paste("input_data_with_predictions", ".csv", sep = "")
  },
  content = function(file) {
    write.csv(predictions(), file, row.names = FALSE)
  })

})

