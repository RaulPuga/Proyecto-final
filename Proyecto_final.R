### Caso práctico final
## Limpiar base de datos original
datos <- read.csv("/Users/raulguevarapuga/Desktop/Universidades/Universidad de colima/Diplomado analisis de datos/Proyecto final/hotel_bookings.csv", header = TRUE, sep = ",")
any(is.na(datos))
sum(is.na(datos))
datos[!complete.cases(datos),]
datos_si_na <- na.omit (datos)
write.csv(datos_si_na, "/Users/raulguevarapuga/Desktop/Universidades/Universidad de colima/Diplomado analisis de datos/Proyecto final/base_datos_sin_na.CSV", row.names = FALSE)
getwd()
data_clean <- datos_si_na
data_clean[is.na(data_clean)] <- 0
write.csv(datos_si_na, "/Users/raulguevarapuga/Desktop/Universidades/Universidad de colima/Diplomado analisis de datos/Proyecto final/Hotel_l.csv", row.names = FALSE)
data_clean$agent[data_clean$columna == "A"] <- "Z"

# Análisis estadístico
# Leer base de datos modificada en SQL
datos <- read.csv("/Users/raulguevarapuga/Desktop/Universidades/Universidad de colima/Diplomado analisis de datos/Proyecto final/base_datos.csv", header = TRUE, sep = ",")

## Resumen variable precio
summary(datos$adr)
hist(datos$adr, main="Histograma de Variable", xlab="Valores", ylab="Frecuencia")
plot(density(datos$adr), main="Densidad de Variable", xlab="Valores", ylab="Densidad")
x_lim <- range(datos$adr)  # Obtener el rango de la variable adr
ticks <- seq(floor(min(x_lim)/500)*500, ceiling(max(x_lim)/500)*500, by = 500)
axis(1, at = ticks)

## Modelo de minimos cuadrados ordinarios

modelo_simple <- lm(is_canceled ~ children + reserved_room_type + booking_changes + adr + total_of_special_requests + lead_time , data = datos)
summary(modelo_simple)

# Transfoar variables
datos$adr <- scale(datos$adr)
datos$lead_time <- scale(datos$lead_time)
datos$has_children <- ifelse(datos$changes == TRUE, 1, 0)

# Ajuste del modelo

modelo_ajustado <- lm(is_canceled ~ changes + adr + children + lead_time_range + total_of_special_requests +reserved_room_type + arrival_season + required_car_parking_spaces + customer_type  + previous_cancellations + agent, data = datos)
summary(modelo_ajustado)

# Comparación de modelos
## Comparar R2
r2_1 <- summary(modelo_simple)$r.squared
r2_2 <- summary(modelo_ajustado)$r.squared
r2_1
r2_2

# AIC penaliza por la complejidad del modelo. Un AIC más bajo indica un mejor modelo en términos de ajuste y simplicidad
AIC(modelo_simple)
AIC(modelo_ajustado)


## reducción dimencional 
datos <- read.csv("/Users/raulguevarapuga/Desktop/Universidades/Universidad de colima/Diplomado analisis de datos/Proyecto final/base_datos.csv", header = TRUE, sep = ",")

datos_numericos <- datos[, sapply(datos, is.numeric)]
datos_numericos <- datos_numericos[, -c(1,3,4,5)]
datos_normalizados <- scale(datos_numericos)
pca_result <- prcomp(datos_normalizados, center = TRUE, scale. = TRUE)
summary(pca_result)

# Gráficar los PCA 
library(ggplot2)
pca_result <- prcomp(datos_normalizados, center = TRUE, scale. = TRUE)
var_explained <- summary(pca_result)$importance[2, ]
pca_df <- data.frame(
  Component = paste0("PC", 1:length(var_explained)),
  Variance_Explained = var_explained
)
ggplot(pca_df, aes(x = Component, y = Variance_Explained)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  labs(title = "Varianza Explicada por cada Componente Principal",
       x = "Componente Principal",
       y = "Varianza Explicada") +
  theme_minimal()

#Ordenar barras de mayor a menor
pca_df <- pca_df[order(-pca_df$Variance_Explained), ]
ggplot(pca_df, aes(x = reorder(Component, -Variance_Explained), y = Variance_Explained)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  labs(title = "Varianza Explicada por cada Componente Principal",
       x = "Componente Principal",
       y = "Varianza Explicada") +
  theme_minimal()



# Análisis de cargas de los componentes pricipales
pca_loadings <- pca_result$rotation

# Mostrar las cargas
print(pca_loadings)
