# Proyecto Final
## Título:
### Análisis de las cancelaciones en los hoteles City and Resort

## Introducción:
### Los hoteles City and Resort, recopilaron datos de sus cancelaciones en los últimos 3 años, con el fin de conocer los principales factores que influyen en esta variable, para ello contratan a un especialista en análisis de datos, quien a continuación les muetra los resultados. 
El trabajo se dividirá de la siguiente forma:
- Objetivo general y específicos
- Selección  y justificación de datos
- Descripción de la base de datos
- Análisis exploratorio
- Visualización de datos
- Interpretación de resultados y conclusiones
- Referencias

## Objetivo General:

### Determinar los factores que influyen en la cancelaciones de las reservaciones, mediante una análisis de datos, con el fin de tomar mejores decisiones. 

 ### Objetivos específicos:
1. Organizar y manipular datos utilizando SQL:

2. Tomar decisiones de negocio basadas en data:

3. Visualizar datos en una herramienta de Business Intelligence (BI):

4. Organizar y comunicar hallazgos:

 
## Selección  y justificación de datos:
### La base de datos seleccionada es: Reservaciones Hoteleras la cual contiene 31 variables (columnas) y 119,000 observaciones (renglones)
### Justificación :  Se seleccionó esta base de datos, porque me encanta la aplicación del análisis de datos para resolver problemas y facilitar la toma de decisiones dentro de las empresas.

### Variables de la base de datos

| Variable |Significado |
| --------- | ------- |
hotel	| Tipo de hotel
is_canceled	| "1= Cancelada, 0= no cancelada"
lead_time |	Días hasta la llegada del cliente
arrival_date_year |	Año de llegada
arrival_date_month|	Mes de llegada
arrival_date_week_number |	Número de semana
arrival_date_day_of_month	| Día de llegada
stays_in_weekend_nights	| Número noches en fin de semana 
stays_in_week_nights	| Número de noches en semana
adults	| Número de adultos
children |	Número de niños
babies	| Número de bébes 
meal	| Tipos de comidas reservadas
country	| País de origen
market_segment	| Segmento de mercado
distribution_channel	| Canal de reserva
is_repeated_guest	| "1= repetido, 0= no repetido"
previous_cancellations |	Número de reservas previas canceladas
previous_bookings_not_canceled	| Número de reservas previas no canceladas
reserved_room_type	| Tipo de habitación reservada
assigned_room_type	| Tipo de habitación asignada
booking_changes	| Número de cambios realizados
agent |	Agente que reserva
company	| Id de la agencia de viaje que hizo la reserva
days_in_waiting_list	| Número de días hasta la confirmación
customer_type	| Tipo de reserva
adr	|  Tarifa media diaria
required_car_parking_spaces	| Número de plazas de parking que neceita el cliente
total_of_special_requests	| Número de peticiones especiales
reservation_status	| Estado de la última reserva
reservation_status_date	| Estatus de reserva



## Análisis exploratorio
### Se realizó un análisis exploratorio en SQL, determinando el número de hoteles, los tipos de comidas, los tiempos de llegada, entre otros datos los cuales se resumen en la imágen siguiente:

![Historia 1 (6)](https://github.com/user-attachments/assets/76d3f2d3-0c97-4e47-a8a6-80f56f783659)

### En la primera gráfica observamos que el 66% de las reservas se hicieron para el hotel City y las demás para el hotel Resort; Los meses de mayo, julio y agosto registraron el mayor número de reservas; El tipo de cuarto más demandado por los clientes es el A para ambos hoteles; El hotel que más reservas canceladas presentó fue el City en cada uno de los 3 años analizados; El precio promedio de la tarifa fue aumentando año con año como se esperaría que lo hiciera.

## El especialista podría pasar horas haciendo un análisis exploratorio, sin embargo, sin un objetivo o rumbo en específico no se llegaría a nigún lado, es por ello que planteó las siguientes 5 hipótesis:
![Historia 1 (7)](https://github.com/user-attachments/assets/a2177699-5fb0-47c0-8bd4-491fcc8a3a10)

### Con respecto a la primera hipótesis podemos afirmar que las reservas hechas con mayor día de anticipación, tiene una tasa de cancelación más alta; En cuanto a la H2 la relación no está clara; La H3 se confirma ya que las reservaciones con mayores cambios, presentan una tasa menor de cancelación; La H4 Se confirma, cuando un cliente no hace una solicitud esoecial la probabilidad de cancelar es la más alta y va bajando conforme el cliente empieza a realizar más número de pedidos especiales; y finalmente H5 no se encontró una relación clara por lo que se rechaza.

##### Para este ánlisis se crearon las variables:
| Variable |Significado |
| --------- | ------- |
season	| Se clasificaron los meses en las estaciones del año
Agrupación días de reserva | Se agruparon los días anticipados de reserva
Número de cambios| Cambios hechos por los clientes a su reserva
Categoría de pagos por noche | Se agrupo la tarifa de pago en categorías
Hijos | Dummy de hijos

###### Para interactuar con las gráficas realizadas en los dashboards, da click  [aquí](https://public.tableau.com/app/profile/ra.l.guevara8285/viz/Proyectofinal_17242857659270/Historia1)

## Visualización de datos
### Primeramente se analizó las propiedades de la única variable continua en la base de datos, donde podemos ver sus medidas de tendencia central y su distribución, la cuál no es uniforma, es decir, que la mayoría de clientes pagan menos de $500 en promedio por noche.
````
summary(datos$adr)

 Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
  -6.38   69.29   94.59  101.83  126.00 5400.00 
````
````
plot(density(datos$adr), main="Densidad de Variable", xlab="Valores", ylab="Densidad")
````
![image](https://github.com/user-attachments/assets/adb902d5-828a-42d7-a543-af0bd2f8d4dc)

### Posteriormente se realizo un modelo de regresión

````
modelo_simple <- lm(is_canceled ~ children + reserved_room_type + booking_changes + adr + total_of_special_requests + lead_time , data = datos)
summary(modelo_simple)
````
<img width="590" alt="Captura de Pantalla 2024-08-23 a la(s) 8 57 47" src="https://github.com/user-attachments/assets/5822d51a-d787-4490-9bfb-1b9bb20b7284">

### Podemo ver que la mayoría de las variables son significativas, es decir, que ayudan a explicar las cancelaciones, sin embargo, El Multiple R-squared:  0.1602, es muy bajo, significando que el modelo tiene un poco poder de predicción, por lo que se pasará a ajustar el modelo para aumentar su precisión:

````
modelo_ajustado <- lm(is_canceled ~ changes + adr + children + lead_time_range + total_of_special_requests +reserved_room_type + arrival_season + required_car_parking_spaces + customer_type  + previous_cancellations + agent, data = datos)
summary(modelo_ajustado)
````
<img width="609" alt="Captura de Pantalla 2024-08-23 a la(s) 9 05 26" src="https://github.com/user-attachments/assets/6ca3999c-472d-421e-8f18-2e02d8ca0bc8">

### Después de transfomar algunas variables y probar combinaciones diferentes, se logró aumentar la predicción del modelo, conservando el nivel de significancia de la mayoría de las variables, para mayor ilustración de la mejora del modelo, a continuación se presentan dos pruebas realizadas.

````
>  summary(modelo_simple)$r.squared
[1] 0.1602006
>  summary(modelo_ajustado)$r.squared
[1] 0.3443084
````
### En la primera prueba vemos El Multiple R-squared, el cual aumentó más de doble.

````
> AIC(modelo_simple)
[1] 144183.1
> AIC(modelo_ajustado)
[1] 115332.3
````
### En la segunda prueba entre menor sea el valor, significa que el modelo se ajusta mejor y tiene un mayor poder de predicción.
### Finalmente se aplico un modelo de reducción dimensional, también conocido como modelo de componentes principales (PCA), a continuación se detalla el proceso
### 1. Se seleccionan las variables númericas
````
datos_numericos <- datos[, sapply(datos, is.numeric)]
````
### 2. Se normalizan las variables
````
datos_normalizados <- scale(datos_numericos)
````
### 3. Se corre el modelo
````
pca_result <- prcomp(datos_normalizados, center = TRUE, scale. = TRUE)
````
### 4. Se muestra el resultado
````
summary(pca_result)
````
<img width="643" alt="Captura de Pantalla 2024-08-23 a la(s) 9 16 33" src="https://github.com/user-attachments/assets/b1f13d2a-d748-4baf-9218-60acbce2f2fa">

### 5. Se gráfica los componentes principales
````
pca_df <- pca_df[order(-pca_df$Variance_Explained), ]
ggplot(pca_df, aes(x = reorder(Component, -Variance_Explained), y = Variance_Explained)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  labs(title = "Varianza Explicada por cada Componente Principal",
       x = "Componente Principal",
       y = "Varianza Explicada") +
  theme_minimal()

````
![image](https://github.com/user-attachments/assets/3cd28586-1ac9-4954-97bd-d3a9bd70954f)

### 6. Se Análiza la carga de los componentes principales
````
pca_loadings <- pca_result$rotation
print(pca_loadings)
````
<img width="693" alt="Captura de Pantalla 2024-08-23 a la(s) 9 18 25" src="https://github.com/user-attachments/assets/0e205158-b2f3-4213-bf0d-c0a1aa67111b">

## Conclusiones:
La variables Número de cambios en la reserva, si tienen hijos los clientes, el tiempo que transcurre desde la reserva hasta el día de llegada, los requerimientos especiales, el tipo de cuarto reservado, la tarifa que pagan, la temporada de llegada y las cancelaciones previas, han demostrado un poder explicativo significativo de las cancelaciones en un 34%, sumado a esto con las pruebas de hipotesis de se descubrió que la probabilidad de que una reservación sea cancelada aumenta cuando pasa mucho tiempo hasta la llegadad de los clientes, los usuarios no hacen ningún cambio y ninguna solictud especial.

Se recomienda a los hoteles capacitar al personal de recpción quienes normalemnte atiende las reservas para que puedan comentarle a los clientes que pueden hacer alguna petición en especial, que si hay algún cambio antes de cancelar, pueden llamar para informar el cambio sin penalización y cuando las reservaciones se hagan con mucho tiempo de anticipación darles un seguimiento mediante llamada o mensaje para brindar la confianza a los clientes.

## Referencias:
- DeVito. (2022, 1 septiembre). 01 - Descarga e Instalación de PosgreSQL | Curso de Base de Datos PostgresSQL [Vídeo]. YouTube. https://www.youtube.com/watch?v=gEJcMrk3E-Q
- Jose Alejandro De Souza. (2024, 2 enero). Aprende Tableau desde cero: Tutorial para principiantes [Vídeo]. YouTube. https://www.youtube.com/watch?v=cYw8OvkwVVI
- Knaflic, C. N. (2015). Storytelling with Data.
- Ferrari, L. P., & Pirozzi, E. (2023). Learn PostgreSQL - Second Edition: Use, Manage and Build Secure and Scalable Databases with PostgreSQL 16.
- Puga, J. L. (2012). Introducción al análisis de datos con R y R Commander. en psicología y educación. http://repositorio.ual.es/bitstream/10835/1658/1/R_Rcmdr_Psi_Edu.pdf
- SQLBolt - Learn SQL - Introduction to SQL. (s. f.). SQLBolt - Learn SQL With Simple, Interactive Exercises. https://sqlbolt.com/
- StatQuest with Josh Starmer. (2018). StatQuest: Principal Component Analysis (PCA), Step-by-Step [Vídeo]. YouTube. https://www.youtube.com/watch?v=FgakZw6K1QQ
- W3Schools.com. (s. f.). https://www.w3schools.com/sql/default.asp




