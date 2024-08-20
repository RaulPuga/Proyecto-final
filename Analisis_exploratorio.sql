-- Exploración inicial--
select * from hotel_reservations;

"Número de categorías diferentes "
select distinct hotel  from hotel_reservations;
select distinct meal  from hotel_reservations where meal != 'Undefined';
select distinct market_segment  from hotel_reservations;
select distinct distribution_channel  from hotel_reservations where distribution_channel != 'Undefined';
select distinct reserved_room_type  from hotel_reservations;
select distinct assigned_room_type  from hotel_reservations;
select distinct agent  from hotel_reservations;
select distinct company  from hotel_reservations;
select distinct customer_type  from hotel_reservations;
select distinct arrival_date_year  from hotel_reservations;
select max(adr), min(adr)  from hotel_reservations where adr >0;
select max(adr), min(adr), round(avg(adr),2)  from hotel_reservations where adr >0;

select hotel, is_canceled, lead_time, arrival_date_year from hotel_reservations limit 7
-- cancelación por hotel --
SELECT 
  hotel, 
  COUNT(*) AS total_reservations, 
  ROUND(AVG(is_canceled::numeric), 2) AS tasa_de_cancelacion
FROM 
  hotel_reservations2
GROUP BY 
  hotel;
-- Número de reservas por hotel --
select count (hotel)
from hotel_reservations 
WHERE hotel = 'Resort Hotel';

select count (hotel)
from hotel_reservations 
WHERE hotel = 'City Hotel';

-- Reservas con meses de anticiapación -- 
select *
from hotel_reservations 
WHERE  lead_time > 30;

select *
from hotel_reservations 
WHERE  lead_time > 60

select *
from hotel_reservations 
WHERE  lead_time > 90;

-- Número de reservas por año
SELECT COUNT(*)
FROM hotel_reservations
WHERE arrival_date_year = 2015

SELECT COUNT(*)
FROM hotel_reservations
WHERE arrival_date_year = 2016

SELECT COUNT(*)
FROM hotel_reservations
WHERE arrival_date_year = 2017

-- crear nueva variable -- 
SELECT CONCAT(arrival_date_year,'-', arrival_date_month, '-', arrival_date_day_of_month) AS arrival_date
FROM hotel_reservations

CREATE TABLE hotel_reservations2
AS
SELECT *, CONCAT(arrival_date_year,'-', arrival_date_month, '-', arrival_date_day_of_month) as arrival_date 
FROM hotel_reservations

-- Crear agrupamientos -- 
-- Estaciones del año -- 
ALTER TABLE hotel_reservations2
ADD arrival_season VARCHAR(20);

UPDATE hotel_reservations2
SET arrival_season = CASE
    WHEN arrival_date_month IN ('January', 'February', 'March') THEN 'Verano'
    WHEN arrival_date_month IN ('April', 'May', 'June') THEN 'Otoño'
    WHEN arrival_date_month IN ('July', 'August', 'September') THEN 'Invierno'
    ELSE 'Primavera'
END;


ALTER TABLE hotel_reservations2
ADD tiempo_reserva VARCHAR(20);

UPDATE hotel_reservations2
SET tiempo_reserva = CASE
    WHEN lead_time < 31 then 'Corto'
    WHEN lead_time between 31 and 90 then 'Mediano'
    ELSE 'Largo'
end;

SELECT  *, CAST(arrival_date AS DATE) AS arrival_date_v2 
FROM hotel_reservations2

-- Calculo día de reserva -- 
ALTER TABLE hotel_reservations2
ADD booking_date DATE;

UPDATE hotel_reservations2
SET booking_date = arrival_date::date - lead_time::integer;

-- Fecha máxima y minima de reserva -- 
select max (booking_date), min(booking_date)
From hotel_reservations2;

-- Pago promedio de clientes por hotel por año -- 
SELECT  distinct (hotel), round (AVG(adr),2), arrival_date_year
FROM hotel_reservations2
group by arrival_date_year, hotel
order by hotel, arrival_date_year

-- cantidad de reservas --
-- Año --
SELECT 
    EXTRACT(YEAR FROM booking_date) AS year,
    hotel,
    COUNT(*) AS total_reservations
FROM hotel_reservations2
GROUP BY EXTRACT(YEAR FROM booking_date), hotel
ORDER BY year, hotel;

-- Mes --
SELECT 
    EXTRACT(YEAR FROM booking_date) AS year,
    EXTRACT(MONTH FROM booking_date) AS month,
    hotel,
    COUNT(*) AS total_reservations
FROM hotel_reservations2
where is_canceled = '0'
GROUP BY EXTRACT(YEAR FROM booking_date), EXTRACT(MONTH FROM booking_date), hotel
ORDER BY year, month, hotel;


-- Canceladas -- 
SELECT 
    EXTRACT(YEAR FROM booking_date) AS year,
    hotel,
    COUNT(*) AS total_reservations
FROM hotel_reservations2
where is_canceled = '1'
GROUP BY EXTRACT(YEAR FROM booking_date), hotel
ORDER BY year, hotel;

select * from hotel_reservations2 where is_canceled = '1'
select * from hotel_reservations2 where is_canceled = '0'


--- compración cancelación y reservas por año y mes ---- 

WITH reservas AS (
    SELECT 
        EXTRACT(YEAR FROM booking_date) AS year,
        EXTRACT(MONTH FROM booking_date) AS month,
        hotel,
        COUNT(*) AS total_reservations
    FROM hotel_reservations2
    WHERE is_canceled = '0'  -- Asumiendo que '0' representa no cancelado
    GROUP BY EXTRACT(YEAR FROM booking_date), EXTRACT(MONTH FROM booking_date), hotel
),
cancelaciones AS (
    SELECT 
        EXTRACT(YEAR FROM booking_date) AS year,
        EXTRACT(MONTH FROM booking_date) AS month,
        hotel,
        COUNT(*) AS total_cancellations
    FROM hotel_reservations2
    WHERE is_canceled = '1'  -- Asumiendo que '1' representa cancelado
    GROUP BY EXTRACT(YEAR FROM booking_date), EXTRACT(MONTH FROM booking_date), hotel
)
-- Comparar reservas y cancelaciones
SELECT
    r.year,
    r.month,
    r.hotel,
    r.total_reservations,
    COALESCE(c.total_cancellations, 0) AS total_cancellations,
    r.total_reservations - COALESCE(c.total_cancellations, 0) AS net_reservations
FROM reservas r
LEFT JOIN cancelaciones c
    ON r.year = c.year
    AND r.month = c.month
    AND r.hotel = c.hotel
ORDER BY r.year, r.month, r.hotel;


--- cancelaciones contra reservas 2020 ---  
WITH reservas AS (
    SELECT 
        EXTRACT(YEAR FROM booking_date) AS year,
        hotel,
        COUNT(*) AS total_reservations
    FROM hotel_reservations2
    GROUP BY EXTRACT(YEAR FROM booking_date), hotel
),
cancelaciones AS (
    SELECT 
        EXTRACT(YEAR FROM booking_date) AS year,
        hotel,
        COUNT(*) AS total_cancellations
    FROM hotel_reservations2
    WHERE is_canceled = '1'  -- Asumiendo que '1' representa cancelado
    GROUP BY EXTRACT(YEAR FROM booking_date), hotel
)
-- Comparar reservas y cancelaciones
SELECT
    r.year,
    r.hotel,
    r.total_reservations,
    COALESCE(c.total_cancellations, 0) AS total_cancellations,
    r.total_reservations - COALESCE(c.total_cancellations, 0) AS net_reservations
FROM reservas r
LEFT JOIN cancelaciones c
    ON r.year = c.year
    AND r.hotel = c.hotel
ORDER BY r.year, r.hotel;

--- 1. Las reservas que se hacen con mayor anticipación tienen mucho riesgo de cancelarse ---
ALTER TABLE hotel_reservations2
ADD COLUMN lead_time_range VARCHAR(20);

UPDATE hotel_reservations2
SET lead_time_range = CASE
    WHEN lead_time BETWEEN 0 AND 15 THEN '0-15'
    WHEN lead_time BETWEEN 16 AND 30 THEN '16-30'
    WHEN lead_time BETWEEN 31 AND 60 THEN '31-60'
    WHEN lead_time BETWEEN 61 AND 90 THEN '61-90'
    WHEN lead_time BETWEEN 91 AND 180 THEN '91-180'
    WHEN lead_time BETWEEN 181 AND 360 THEN '181-360'
    ELSE '360+'
END;

--- Tasa de cancelación --- 
SELECT
  ROUND(CAST(AVG(is_canceled::float) AS numeric), 2) as tasa_de_cancelacion,
  lead_time_range
FROM
  hotel_reservations2
GROUP BY
  lead_time_range
order by lead_time_range asc;

--- 2 reservas con hijos menor riesgo de cancelar -- 
ALTER TABLE hotel_reservations2
ADD COLUMN has_children BOOLEAN;

UPDATE hotel_reservations2
SET has_children = CASE
    WHEN children > 0 THEN TRUE
    ELSE FALSE
END;

--- Calcular tasa ---
SELECT
  has_children,
  ROUND(CAST(AVG(is_canceled::float) AS numeric), 2) as tasa_de_cancelacion
FROM
  hotel_reservations2
GROUP BY
  has_children;

-- Tasa por tipo de hotel ---
SELECT
  hotel,
  has_children,
  ROUND(CAST(AVG(is_canceled::float) AS numeric), 2) as tasa_de_cancelacion
FROM
  hotel_reservations2
GROUP BY
  hotel, has_children;

--- 3. los usuarios con cambios tienen menor riesgo de cancelar --- 
ALTER TABLE hotel_reservations2
ADD COLUMN changes VARCHAR(50);

UPDATE hotel_reservations2
SET changes = CASE
    WHEN booking_changes = 0 THEN 'Sin Cambios'
    WHEN booking_changes BETWEEN 1 AND 9 THEN 'Entre 1 y 10 cambios'
    ELSE '10 cambios o más'
END;

-- Tasa de cancelación -- 
SELECT
  changes,
  hotel,
  ROUND(CAST(AVG(is_canceled::float) AS numeric), 2) as tasa_de_cancelacion
FROM
  hotel_reservations2
GROUP BY
  changes, hotel
ORDER BY
  changes, hotel;

--- 4 Cuando el usuario ha realizado una solicitud especial el riesgo de cancelación es menor ---
SELECT
  total_of_special_requests,
  ROUND(CAST(AVG(is_canceled::float) AS numeric), 2) as tasa_de_cancelacion
FROM
  hotel_reservations2
GROUP BY
  total_of_special_requests
ORDER BY
  total_of_special_requests;

--- 5 Las reservas que tienen un adr (precio por noche) bajo el riesgo es menor ---
ALTER TABLE hotel_reservations2
ADD COLUMN adr_segment VARCHAR(50);

UPDATE hotel_reservations2
SET adr_segment = CASE
    WHEN adr <= 100 THEN '0-100'
    WHEN adr <= 200 THEN '101-200'
    WHEN adr <= 300 THEN '201-300'
    WHEN adr <= 400 THEN '301-400'
    ELSE 'Más de 400'
END;

--- Calculo de la tasa de cancelación --- 
SELECT
  adr_segment,
  ROUND(CAST(AVG(is_canceled::float) AS numeric), 2) as tasa_de_cancelacion
FROM
  hotel_reservations2
GROUP BY
  adr_segment
ORDER BY
  adr_segment;

--  6 calculo de la tasa de cancelación por tipo de cuarto apartado -- 
SELECT
  reserved_room_type,
  ROUND(CAST(AVG(is_canceled::float) AS numeric), 2) as tasa_de_cancelacion
FROM
  hotel_reservations2
GROUP BY
  reserved_room_type
ORDER BY
  reserved_room_type;