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
      dateInput("dt","Data de início:",
                value = "2026-01-01",
                format = "yyyy-mm-dd",
                language = "pt-BR"),
      selectInput("tp_gf","O que você que visualizar?",
                  choices = c("Ambos" = "ambos",
                              "Apenas Preço" = "preco",
                              "Apenas Retorno acumulado" = "r_acumulado")),
      actionButton("bt","Buscar Dados"),
      br(),br(),
      downloadButton("bt_s","Salvar Gráfico")
    ),
    mainPanel(
      plotOutput("gf_linha")
    )
  )
)

server <- function(input,output) {
  
  dados_acao <- eventReactive(input$bt, {
    
    str_split(input$tk, pattern = ",\\s*") |> unlist() |> toupper() |>
      tq_get(from = input$dt, get = "stock.prices") |>
        group_by(symbol) |>
          mutate(retorno_acumulado = (close / first(close) -1)) |>
            ungroup()
    
  })
  
  grafico_final <- reactive({
    g_1 <- ggplot(dados_acao(),
                  aes(x= date,
                      y = close,
                      colour = symbol)
                  )+
      geom_line()+
      geom_ma(ma_fun = SMA, n = 50, linetype = "dashed")+
      labs(
        title = "Bolsa de Valores",
        colour = "Ações",
        x = "",
        y = ""
      )+
      scale_y_continuous(labels = dollar)
    
    g_2 <- ggplot(dados_acao(),
                  aes(x = date,
                      y = retorno_acumulado,
                      colour = symbol)
                  )+
      geom_line()+
      geom_hline(yintercept = 0, linetype = "dashed", color = "gray50")+
      labs(
        title = "Retorno Acumulado",
        colour = "Ações",
        x = "",
        y = ""
      )+
      scale_y_continuous(labels = percent)
    
    
    if(input$tp_gf == "preco") {
      return(g_1)
    }else if(input$tp_gf == "r_acumulado") {
      return(g_2)
    }else {
      return(g_1 / g_2)
    }
    
  })
  
  output$gf_linha <- renderPlot({grafico_final()})
  
  output$bt_s <- downloadHandler(
    filename = function() {
      paste0("grafico_", str_replace_all(input$tk, ", ", "_"), ".png")
    },
    content = function(file) {
      ggsave(file, plot = grafico_final(), width = 10, height = 7, dpi = 300)
    }
  )
  
}

shinyApp(ui, server)
