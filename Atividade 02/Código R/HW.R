# Limpar----

rm(list=ls())

#Diret�rio
setwd("C:/Users/Caio Azevedo/Documents/Documentos Caio/Github/Series-Temporais/Figuras")

# Carregando pacotes a serem utilizados

library(forecast) 
library(dplyr)
library(lattice)
library(xtable)
library(stargazer)

# Exportando os dados dispon�veis no GitHub

site <- "https://raw.githubusercontent.com/caio-azevedo/Series-Temporais/master/Atividade%2002/data/PIB.csv"

dados<- read.table(site, header=T, sep=";", dec = ",", 
                   col.names = c("ano", "mes", "pib"))


# Configurando os dados para o formato de s�ries temporais
attach(dados)

pib90 <-ts(pib, start=c(1990,1), frequency = 12)

plot(pib90)

dev.copy(pdf,"pib90.pdf")
dev.off()

# Fazendo um recorte de tempo nos dados a partir de 2000

pib2010<- window(pib90, start=2010)

# Plotando o gr�fico da s�rie
plot(pib2010)

dev.copy(pdf,"pib2010.pdf")
dev.off()


# Aplicando a Suaviza��o de Holt - Winters erros aditivos----

pib_hw<-hw(pib2010, level = 95, h=10, seasonal = "additive")


plot(pib_hw)


# Gerar uma nova s�rie atrav�s da Suaviza��o Exponencial de Holt-Winters (HW)
pib_prev<- pib_hw[["model"]][["fitted"]]
pib_prev<-data.frame(pib_prev)


#Retirando os valores previstos para fora da amostra----

x<-data.frame(pib_hw, row.names = c(1:10))
x<-x %>% 
  select("Point.Forecast") %>% 
  rename("pib_prev"="Point.Forecast")

pib_prev<-bind_rows(pib_prev, x)



# Juntar as duas s�ries - original e suavizada - em uma matriz para formar um gr�fico �nico
pib2010<-data.frame(pib2010)

# � necess�rio criar um vetor nulo pra completar a s�rie original
# a repeti��o � de acordo com o n�mero de per�odos a ser previsto
nulo<-c(rep(NA,10)) 
nulo<-data.frame(nulo)

nulo<-nulo %>% 
  rename("pib2010"="nulo")

pib2010<-bind_rows(pib2010, nulo)

graf<-cbind(pib2010, pib_prev)
colnames(graf)<-c("S�rie Original", "HW")


# Retornando para o formato temporal----

graf_ts<-ts(graf, start=c(2010,1), frequency = 12)


# Plotar um �nico gr�fico----
xyplot(graf_ts, superpose = TRUE, lwd = 2) 

dev.copy(pdf,"pib.pdf")
dev.off()


#Encontrar os par�metros estimados

parametros<-data.frame(round(pib_hw[["model"]][["par"]], digits = 4))
parametros<-data.frame(parametros[1:3,])
colnames(parametros)<-c("Par�metros estimados")
rownames(parametros)<-c("alpha", "beta", "gamma")

# Estados Iniciais

estado_inic<-data.frame(round(pib_hw[["model"]][["initstate"]]))
colnames(estado_inic)<-c("Estados Iniciais")



#Crit�rios de informa��o

loglik <- pib_hw[["model"]][["loglik"]]
aic <- pib_hw[["model"]][["aic"]]
bic <- pib_hw[["model"]][["bic"]]
aicc <- pib_hw[["model"]][["aicc"]]
mse <- pib_hw[["model"]][["mse"]]
amse <- pib_hw[["model"]][["amse"]]

inf_crit<-data.frame(c(loglik, aic, bic, aicc, mse, amse))
colnames(inf_crit)<-c("Crit�rios de Informa��o")
rownames(inf_crit)<-c("LogLik", "AIC", "BIC", "AICC", "MSE", "AMSE")


# Gerar tabelas da An�lise----


print(xtable(estado_inic, caption = "Estados Iniciais utilizados na Previs�o do Modelo HW", 
             label = "tab2", digits = 0),
      caption.placement = "top",
      include.rownames = TRUE,
      format.args = list(big.mark = ".", decimal.mark = ","))

print(xtable(inf_crit, caption = "Crit�rios de Informa��o do Modelo de HW", 
             label = "tab3"),
      caption.placement = "top",
      include.rownames = TRUE,
      format.args = list(big.mark = ".", decimal.mark = ","))

hw<-data.frame(pib_hw)
print(xtable(hw, caption = "Previs�o para o PIB atrav�s do Modelo de HW", 
             label = "tab4"),
      caption.placement = "top",
      include.rownames = TRUE,
      format.args = list(big.mark = ".", decimal.mark = ","))

