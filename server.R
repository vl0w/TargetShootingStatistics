library(shiny)

shinyServer(function(input, output) {  
  getResults <- reactive({
    tempResultFile <- tempfile()
    download.file("http://vl0w.duckdns.org/shooting/results.txt",destfile=tempResultFile, method="curl")
    results <- read.csv(tempResultFile, sep=";", colClasses=c("Date","character","numeric","character","character"))
    ordered = results[order(results[,"Date"]),]
    return (ordered)
  })
  
  getResultsForRequest <- function(){
    results = getResults()
    selectedCategory = getCategoryDescription(input$select_category)
    results = subset(results,Category==selectedCategory)
    
    if(!is.null(input$dates)){
      dateFrom = as.Date(input$dates[1])
      dateTo = as.Date(input$dates[2])
      results = subset(results, Date>=dateFrom & Date<=dateTo)
    }
    
    return (results)
  }
  
  output$fromDate <- renderText({
    return(format(input$dates[1]))
  })
  
  output$toDate <- renderText({
    return(format(input$dates[2]))
  })
  
  output$mean <- renderText({
    mean=mean(getResultsForRequest()$Result)
    return(mean)
  })
  
  output$amountOfRecords <- renderText({
    amount = length(getResultsForRequest()$Result);
    return(amount)
  })
  
  output$best <- renderText({
    max = max(getResultsForRequest()$Result);
    return(max)
  })
  
  output$worst <- renderText({
    min = min(getResultsForRequest()$Result);
    return(min)
  })
  
  output$summary <- renderDataTable({
    results = getResultsForRequest()
    return(results)
  })
  
  output$trendPlot <- renderPlot({
    results = getResultsForRequest()
    plot(results$Date,results$Result,xlab="Date",ylab="Result")
    abline(h=mean(results$Result), lwd=4, col="blue")
    abline(lm(results$Result~results$Date), lwd=3, col="green")
    title("Trend Analysis")
  })
  
  output$histogram <- renderPlot({
    results = getResultsForRequest()
    hist(results$Result,main="Histogram",xlab="Result")
    title("Histogram")
  })
})

overviewText <- function(property,value){
  htmlProperty = paste(paste("<b>",property),":</b>")
  return(paste(htmlProperty,value))
}

getCategoryDescription <- function(id){
  sId = toString(id)
  switch(sId, 
         "1002"="CB10 S 1",
         "1003"="CB10 S 10",
         "1005"="CB10 S 20",
         "1010"="CB10 S 40",
         "1011"="CB10 S 40 Final",
         "1020"="CB10 S 60",
         "1021"="CB10 S 60 Final",
         "1030"="CB10 S Final 1",
         "1031"="CB10 S Final 10",
         "485"="CB30 S 1",
         "490"="CB30 S 10",
         "495"="CB30 S 20",
         "500"="CB30 S 30",
         "507"="CB30 K 1",
         "508"="CB30 K 10",
         "509"="CB30 K 20",
         "510"="CB30 K 30",
         "520"="CB30 Match",
         "529"="CB30 K Final 10",
         "530"="CB30 S Final 10",
         "531"="CB30 Match Final",
         "90"="AR10 S 1",
         "100"="AR10 S 10",
         "110"="AR10 S 20",
         "120"="AR10 S 40",
         "130"="AR10 S 60",
         "140"="AR10 S Final",
        {"Unknown Category"}
  )
}