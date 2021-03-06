# Limpar

rm(list=ls())

#Diret�rio
setwd("C:/Users/Caio Azevedo/Documents/Documentos Caio/Github/Series-Temporais/Atividade 03/Figuras")

# Carregando pacotes a serem utilizados

library(forecast) 
library(dplyr)
library(urca)
library(xtable)
library(stargazer)
library(FinTS)
library(normtest)


# Exportando os dados dispon�veis no GitHub

site <- "https://raw.githubusercontent.com/caio-azevedo/Series-Temporais/master/Atividade%2002/data/passageiros_embarcados.csv"

dados<- read.table(site, header=T, sep=";", dec = ",", 
                   col.names = c("data", "pas", ""))


# Configurando os dados para o formato de s�ries temporais
attach(dados)

pas69 <-ts(pas, start=c(1969), frequency = 1)


#Teste de Estacionaridade - Dicker Fuller ----

#Vari�vel dependente � um Passeio aleat�rio

df1<-ur.df(pas69, type = c("none"), lags=0)
summary(df1)

#Vari�vel dependente � um Passeio aleat�rio com deslocamento

df2<-ur.df(pas69, type = c("drift"), lags=0)
summary(df2)


# Vari�vel dependente � um passeio aleat�rio com deslocamento em torno de uma tend�ncia estoc�stica

df3<-ur.df(pas69, type = c("trend"), lags=0)
summary(df3)

# Tirando a primeira diferen�a da s�rie para torn�-la estacion�ria

dpas<-diff(pas69)


# Refazendo teste de raiz unit�ria (Dicker-Fuller) para a s�rie diferenciada
# lags = 0 significa que n�o estamos fazendo o teste ADF

df<-ur.df(diff(pas69), type = c("trend"), lags = 0)
summary(df)

# Essa fun��o indica quantas diferen�as s�o necess�rias para que a s�rie se torne estacion�ria
#pelo resultados anterior chegamos que somente uma diferen�a j� bastava

ndiffs(pas69, test=c("adf"),type=c("trend"), lags=0)

# Plotando os gr�ficos da s�rie original e transformada lado-a-lado

par(mfrow=c(2,1))
plot(pas69, col="blue", main="S�rie Original", bty="l",xlab="Ano", ylab="")
plot(diff(pas69), col="blue", main="S�rie Defasada em um per�odo", bty="l",xlab="Ano", ylab="")

dev.copy(pdf,"pas.pdf")
dev.off()

# Identifica��o do Modelo atrav�s dos Correlogramas


par(mfrow=c(2,1))
acf(diff(pas69), main="Fun��o de Auto-Correla��o", xlab="Defasagem", ylab="")
pacf(diff(pas69), main="Fun��o de Auto-Correla��o Parcial", xlab="Defasagem", ylab="")

dev.copy(pdf,"cor.pdf")
dev.off()

# Escolher a ordem do modelo em c(p,d,q)
model_1<-arima(pas69, order = c(1,1,2)) 
model_2<-arima(pas69, order = c(1,1,1)) 
model_3<-arima(pas69, order = c(0,1,2)) 
model_4<-arima(pas69, order = c(0,1,1)) 
model_5<-arima(pas69, order = c(1,1,0)) 


#Crit�rio AIC
#Pelo crit�rio AIC model_5 foi escolhido, logo um MA(1)

aic<-AIC(model_1, model_2, model_3, model_4, model_5)


#Crit�rio BIC
# Igualmente ao crit�rio AIC, o BIC sugeriu um MA(1)

bic<-BIC(model_1, model_2, model_3, model_4, model_5)


#Juntando os dois crit�rios e exportando em Latex
inf<-cbind(aic, bic)

print(xtable(inf, caption = "Crit�rios de Informa��o AIC e BIC",
             label = "tabinf", digits = 2),
      caption.placement = "top",
      include.rownames = TRUE,
      format.args = list(big.mark = ".", decimal.mark = ","))


# Teste para os coeficientes estimados dos modelos

stargazer(model_4,model_5, decimal.mark = ",", digit.separator = ".")

stargazer(model_1,model_2,model_3, decimal.mark = ",", digit.separator = ".")


# Diagn�stico


tsdiag(model_5)

dev.copy(pdf,"diag5.pdf")
dev.off()

tsdiag(model_4)

dev.copy(pdf,"diag4.pdf")
dev.off()


# Teste de auto-correla��o

Box.test(model_5$residuals, lag=16,type="Ljung-Box", fitdf = 1)
Box.test(model_4$residuals, lag=2,type="Ljung-Box", fitdf = 1)


# Teste de heterocedasticidade condicional

ArchTest(model_5$residuals, lags = 16)
ArchTest(model_4$residuals, lags = 2)


# Teste de normalidade

jb.norm.test(model_5$residuals)
jb.norm.test(model_4$residuals)


# Gr�fico kernel da densidade dos erros

par(mfrow=c(2,1))

plot(density(model_5$residuals, kernel = c("gaussian")),
     main="Modelo ARIMA(1,1,0)", xlab="", ylab="")

plot(density(model_4$residuals, kernel = c("gaussian")),
     main="Modelo ARIMA(0,1,1)", xlab="", ylab="")

dev.copy(pdf,"den5.pdf")
dev.off()





# Previs�o
par(mfrow=c(2,1))
plot(forecast(model_5, h=5, level=0.95),main="Modelo ARIMA(1,1,0)", xlab="Ano", ylab="")
plot(forecast(model_4, h=5, level=0.95),main="Modelo ARIMA(0,1,1)", xlab="Ano", ylab="")

dev.copy(pdf,"prev.pdf")
dev.off()

# Acur�cia
accuracy(model_5)
accuracy(model_4)

acuracia<-rbind(accuracy(model_5),accuracy(model_4))
rownames(acuracia)<-c("ARIMA(1,1,0)", "ARIMA(0,1,1)")

print(xtable(acuracia, caption = "Medidas de Acur�cia",
             label = "tabacur", digits = 4),
      caption.placement = "top",
      include.rownames = TRUE,
      include.colnames = TRUE,
      format.args = list(big.mark = ".", decimal.mark = ","))


# Boxplot dos res�duos dos modelos estimados para verificar a exist�ncia de outliers

par(mfrow=c(1,2))
boxplot(model_5$residuals, main="Modelo ARIMA(1,1,0)")
boxplot(model_4$residuals, main="Modelo ARIMA(0,1,1)")

dev.copy(pdf,"boxplot.pdf")
dev.off()
