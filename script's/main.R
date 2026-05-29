library(tidyquant)
library(tidyverse)
library(patchwork)
library(scales)

dados <- tq_get(c("TSLA","AAPL","AMZN"),from = "2026-01-01")

dados <- dados |> group_by(symbol) |>
  mutate(retorno_acumulado = (close / first(close) -1)) |>
  ungroup()

g_1 <- ggplot(dados,
       aes(x= date,
           y = close,
           colour = symbol)
       )+
  geom_line()+
  geom_ma(ma_fun = SMA, n = 50, linetype = "dashed")+
  labs(
    title = "Bolsa de Valores",
    subtitle = "Ações de 2026",
    colour = "Ações",
    x = "",
    y = ""
  )+
  scale_y_continuous(labels = dollar)

g_2 <- ggplot(dados,
              aes(x = date,
                  y = retorno_acumulado,
                  colour = symbol)
              )+
  geom_line()+
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50")+
  labs(
    subtitle = "Retorno Acumulado",
    colour = "Ações",
    x = "",
    y = ""
    )+
  scale_y_continuous(labels = percent)

ggsave(filename = "Rplot.pdf", plot = g_1 / g_2, width = 8, height = 6)
