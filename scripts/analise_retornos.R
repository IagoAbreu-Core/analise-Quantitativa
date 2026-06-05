library(tidyverse)
library(tidyquant)
library(patchwork)
library(scales)
library(shiny)

ui <- fluidPage(
  titlePanel("Paniel Ações"),
  sidebarLayout(
    sidebarPanel(
      textInput("tk","Digita código da ação:",value = "AAPL"),
      actionButton("bt","Buscar Dados")
    ),
    mainPanel(
      plotOutput("gf_linha")
    )
  )
)

server <- function(input,output) {
  
  dados_acao <- eventReactive(input$bt, {
    tq_get(input$tk, from = "2026-01-01", get = "stock.prices") |>
      group_by(symbol) |>
      mutate(retorno_acumulado = (close / first(close) -1)) |>
      ungroup()
    
  })
  
  output$gf_linha <- renderPlot({
    g_1 <- ggplot(dados_acao(),
                  aes(x= date,
                      y = close)
    )+
      geom_line(color = "blue")+
      geom_ma(ma_fun = SMA, n = 50, linetype = "dashed")+
      labs(
        title = "Bolsa de Valores",
        subtitle = "Ações de 2026",
        x = "",
        y = ""
      )+
      scale_y_continuous(labels = dollar)+
      theme_minimal()
    
    g_2 <- ggplot(dados_acao(),
                  aes(x = date,
                      y = retorno_acumulado)
    )+
      geom_line(color = "red")+
      geom_hline(yintercept = 0, linetype = "dashed", color = "gray50")+
      labs(
        subtitle = "Retorno Acumulado",
        x = "",
        y = ""
      )+
      scale_y_continuous(labels = percent)+
      theme_minimal()
    
    g_1 / g_2
  })
}

shinyApp(ui, server)
