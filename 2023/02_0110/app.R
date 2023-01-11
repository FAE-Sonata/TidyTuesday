setwd("C:/HY/R_exploration/TidyTuesday")

libraries_needed<-c("stringr", "lubridate", "magrittr", "data.table", "shiny",
                    "ggplot2")
lapply(libraries_needed,require,character.only=T)
rm(libraries_needed)
COLLECTED_REGIONS<-c("US", "CA")
US_CA_LIMITS<-list(lat=c(15,85), long=c(-180,-50))
load("2023/02_0110/tues.RData")

# Server logic ------------------------------------------------------------
# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("how_many by state / province (log scale)"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      selectInput(inputId="subnational1_code",
                  label="State/Province",
                  choices=unique(PFW_2021_public$subnational1_code) %>% sort,
                  selected="US-VA")
      # selectInput(inputId="region",
      #             label="Region:",
      #             choices=unique(actual_vs_pr_results$Region)),
      # selectInput(inputId="system",
      #             label="Electoral system:",
      #             choices=SYSTEM_CHOICES)
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("bar_graph")
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  output$bar_graph <- renderPlot({
    how_many_dt<-PFW_2021_public[subnational1_code==input$subnational1_code,]
    how_many_df<-as.data.frame(how_many_dt) # small, OK
    FONT_ADJUST<-1
    p<-ggplot(how_many_df, aes(x = how_many)) + #  log(how_many, base=10))) +
      # geom_boxplot(outlier.colour="black", outlier.shape=16,
      #              outlier.size=2, notch=FALSE)
      geom_histogram()
    p
  })
}

# Run the application 
shinyApp(ui = ui, server = server)