# Limpar

rm(list=ls())

#Diret�rio
setwd("C:/Users/Caio Azevedo/Documents/Documentos Caio/Github/Series-Temporais/Figuras")

# Carregando pacotes a serem utilizados

library(forecast) 
library(dplyr)
library(lattice)
library(xtable)

# Exportando os dados dispon�veis no GitHub

site <- "https://raw.githubusercontent.com/caio-azevedo/Series-Temporais/master/Atividade%2002/data/passageiros_embarcados.csv"

dados<- read.table(site, header=T, sep=";", dec = ",", 
                   col.names = c("data", "pas", ""))


# Configurando os dados para o formato de s�ries temporais
attach(dados)

pas69 <-ts(pas, start=c(1969), frequency = 1)

plot(pas69)

dev.copy(pdf,"pas69.pdf")
dev.off()



# Aplicando a suaviza��o exponencial de Holt

pas_holt<-holt(pas69, level = 95, h=10)


plot(pas_holt)


# Gerar uma nova s�rie atrav�s da Suaviza��o Exponencial de Holt (SEH)
pas_prev<- pas_holt[["model"]][["fitted"]]
pas_prev<-data.frame(pas_prev)


#Retirando os valores previstos da SEH para fora da amostra

x<-data.frame(pas_holt, row.names = c(1:10))
x<-x %>% 
  select("Point.Forecast") %>% 
  rename("pas_prev"="Point.Forecast")

pas_prev<-bind_rows(pas_prev, x)



# Juntar as duas s�ries - original e suavizada - em uma matriz para formar um gr�fico �nico
pas69<-data.frame(pas69)

# � necess�rio criar um vetor nulo pra completar a s�rie original
# a repeti��o � de acordo com o n�mero de per�odos a ser previsto
nulo<-c(rep(NA,10)) 
nulo<-data.frame(nulo)

nulo<-nulo %>% 
  rename("pas69"="nulo")

pas69<-bind_rows(pas69, nulo)

graf<-cbind(pas69, pas_prev)
colnames(graf)<-c("S�rie Original", "Holt")


# Retornando para o formato temporal

graf_ts<-ts(graf, start=c(1969), frequency = 1)


# Plotar um �nico gr�fico
xyplot(graf_ts, superpose = TRUE, lwd = 2) 

dev.copy(pdf,"pas.pdf")
dev.off()


#Encontrar os par�metros estimados

parametros<-data.frame(round(pas_holt[["model"]][["par"]], digits = 4))
parametros<-data.frame(parametros[1:2,])
colnames(parametros)<-c("Par�metros estimados")
rownames(parametros)<-c("alpha", "beta")

# Estados Iniciais

estado_inic<-data.frame(round(pas_holt[["model"]][["initstate"]], digits = 2))
colnames(estado_inic)<-c("Estados Iniciais")

#Crit�rios de informa��o

loglik <- pas_holt[["model"]][["loglik"]]
aic <- pas_holt[["model"]][["aic"]]
bic <- pas_holt [["model"]][["bic"]]
aicc <- pas_holt[["model"]][["aicc"]]
mse <- pas_holt[["model"]][["mse"]]
amse <- pas_holt[["model"]][["amse"]]

inf_crit<-data.frame(c(loglik, aic, bic, aicc, mse, amse))
colnames(inf_crit)<-c("Crit�rios de Informa��o")
rownames(inf_crit)<-c("LogLik", "AIC", "BIC", "AICC", "MSE", "AMSE")

print(xtable(estado_inic, caption = "Estados Iniciais utilizados na Previs�o da SEH", 
             label = "tab2.2", digits = 0),
      caption.placement = "top",
      include.rownames = TRUE,
      format.args = list(big.mark = ".", decimal.mark = ","))

print(xtable(inf_crit, caption = "Crit�rios de Informa��o da SEH", 
             label = "tab2.3"),
      caption.placement = "top",
      include.rownames = TRUE,
      format.args = list(big.mark = ".", decimal.mark = ","))

holt<-data.frame(pas_holt)
print(xtable(holt, caption = "Previs�o para a quantidade de passageiros embarcados
             atrav�s do Modelo de Holt",
             label = "tab2.4", digits = 0),
      caption.placement = "top",
      include.rownames = TRUE,
      format.args = list(big.mark = ".", decimal.mark = ","))







