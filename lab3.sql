USE master;
GO

DROP DATABASE IF EXISTS Attractions;
GO
CREATE DATABASE Attractions;
GO

USE Attractions;
GO
-- 1
CREATE TABLE City (
 id INT PRIMARY KEY,
 name NVARCHAR(50) NOT NULL,
 population INT,
 region NVARCHAR(30)
) AS NODE;

CREATE TABLE Type (
 id INT PRIMARY KEY,
 name NVARCHAR(30) NOT NULL
) AS NODE;

CREATE TABLE Landmark (
 id INT PRIMARY KEY,
 name NVARCHAR(100) NOT NULL,
 about NVARCHAR(200),
 year_built INT,
 enterance_fee DECIMAL(10,2),
 rating DECIMAL(3,1)
) AS NODE;

--2

CREATE TABLE LOCATED_IN (
 landmark_id INT,
 city_id INT,
 PRIMARY KEY(landmark_id, city_id),
 FOREIGN KEY(landmark_id) REFERENCES Landmark(id),
 FOREIGN KEY(city_id) REFERENCES City(id) 
) AS EDGE;

CREATE TABLE IS_TYPE (
 landmark_id INT,
 type_id INT,
 PRIMARY KEY(landmark_id, type_id),
 FOREIGN KEY(landmark_id) REFERENCES Landmark(id),
 FOREIGN KEY(type_id) REFERENCES Type(id) 
) AS EDGE;

CREATE TABLE NEARBY (
 landmark_from_id INT,
 landmark_to_id INT,
 distance_km DECIMAL(5,2),
 PRIMARY KEY(landmark_from_id, landmark_to_id),
 FOREIGN KEY(landmark_from_id) REFERENCES Landmark(id),
 FOREIGN KEY(landmark_to_id) REFERENCES Landmark(id) 
) AS EDGE;

--3
INSERT INTO City (id, name, population, region) VALUES
(1, 'Мир', 2500, 'Гродненская'),
(2, 'Несвиж', 15000, 'Минская'),
(3, 'Брест', 350000, 'Брестская'),
(4, 'Каменюки', 500, 'Брестская'),
(5, 'Нарочь', 3000, 'Минская'),
(6, 'Минск', 2000000, 'Минская'),
(7, 'Птичь', 200, 'Минская'),
(8, 'Полоцк', 85000, 'Витебская'),
(9, 'Гомель', 500000, 'Гомельская'),
(10, 'Новогрудок', 29000, 'Гродненская');  

INSERT INTO Type (id, name) VALUES
(1, 'Замок'),
(2, 'Музей'),
(3, 'Природный парк'),
(4, 'Храм'),
(5, 'Мемориал'),
(6, 'Театр'),
(7, 'Памятник'),
(8, 'Архитектурный ансамбль'),
(9, 'Заповедник'),
(10, 'Парк развлечений');


INSERT INTO Landmark (id, name, about, year_built, enterance_fee, rating) VALUES
(1, 'Мирский замок', 'Объект ЮНЕСКО, шедевр готики и ренессанса', 1520, 15.00, 9.2),
(2, 'Несвижский замок', 'Резиденция Радзивиллов с парковым комплексом', 1583, 20.00, 9.5),
(3, 'Брестская крепость', 'Героическая цитадель ВОВ', 1833, 10.00, 9.7),
(4, 'Беловежская пуща', 'Древний лес с зубрами, объект ЮНЕСКО', NULL, 12.00, 9.8),
(5, 'Нарочанский парк', 'Крупнейшее озеро Беларуси', 1999, 0.00, 8.5),
(6, 'Музей ВОВ в Минске', 'Интерактивные экспозиции о войне', 1944, 8.00, 9.0),
(7, 'Дудутки', 'Этнографический музей под открытым небом', 1994, 18.00, 8.7),
(8, 'Софийский собор', 'Один из древнейших храмов Восточной Европы', 1044, 5.00, 8.9),
(9, 'Гомельский дворец', 'Дворцово-парковый ансамбль Румянцевых', 1785, 7.00, 8.8),
(10, 'Новогрудский замок', 'Первая столица ВКЛ, руины замка', 1250, 6.00, 8.1);

--4

INSERT INTO LOCATED_IN ($from_id, $to_id, landmark_id, city_id)
SELECT 
    (SELECT $node_id FROM Landmark WHERE id = li.landmark_id),
    (SELECT $node_id FROM City WHERE id = li.city_id),
    li.landmark_id,
    li.city_id
FROM (VALUES
    (1,1),(2,2),(3,3),(4,4),(5,5),
    (6,6),(7,7),(8,8),(9,9),(10,10)
) AS li(landmark_id, city_id);


INSERT INTO IS_TYPE ($from_id, $to_id, landmark_id, type_id)
SELECT 
    (SELECT $node_id FROM Landmark WHERE id = it.landmark_id),
    (SELECT $node_id FROM Type WHERE id = it.type_id),
    it.landmark_id,
    it.type_id
FROM (VALUES
    (1,1),(2,1),(3,5),(4,3),(5,3),
    (6,2),(7,2),(8,4),(9,1),(10,1)
) AS it(landmark_id, type_id);


INSERT INTO NEARBY ($from_id, $to_id, landmark_from_id, landmark_to_id, distance_km)
SELECT 
    (SELECT $node_id FROM Landmark WHERE id = n.landmark_from_id),
    (SELECT $node_id FROM Landmark WHERE id = n.landmark_to_id),
    n.landmark_from_id,
    n.landmark_to_id,
    n.distance_km
FROM (VALUES
    (1, 2, 100.0),  
    (2, 6, 120.0),  
    (3, 4, 60.0),   
    (4, 5, 250.0),  
    (5, 7, 80.0),  
    (6, 7, 60.0), 
    (7, 9, 200.0), 
    (8, 10, 150.0), 
    (9, 10, 180.0), 
    (1, 8, 200.0),  
    (2, 5, 140.0),  
    (3, 7, 220.0),  
    (4, 6, 350.0),  
    (5, 6, 120.0),  
    (6, 8, 220.0),  
    (7, 8, 180.0),  
    (1, 3, 240.0),  
    (2, 3, 260.0),  
    (4, 7, 280.0)   
    ) AS n(landmark_from_id, landmark_to_id, distance_km);
--5
SELECT L.name AS [Название достопримечательности], L.rating, T.name as [Тип достопримечательности]
FROM Landmark AS L,
IS_TYPE AS IT,
Type AS T
WHERE 
MATCH(L-(IT)->T)
AND T.name = 'Замок'
AND L.rating >8.5;

SELECT 
L.name AS [Название достопримечательности], 
C.name AS [Название города]
FROM Landmark AS L,
LOCATED_IN AS LI,
City AS C
WHERE 
MATCH(L-(LI)->C)
AND C.region = 'Гродненская';

SELECT 
    L.name AS [Название музея],
    L.enterance_fee AS Стоимость
FROM 
    Landmark AS L, 
    IS_TYPE AS IT, 
    Type AS T
WHERE 
    MATCH(L-(IT)->T)
    AND T.name = 'Музей'
    AND L.enterance_fee > 0;

SELECT 
    L2.name AS [Ближайшие достопримечательности],
    N.distance_km AS [Растояние в километрах]
FROM 
    Landmark AS L1, 
    NEARBY AS N, 
    Landmark AS L2
WHERE 
    MATCH(L1-(N)->L2) 
    AND L1.name = 'Мирский замок';

SELECT 
    L.name AS [Название храма],
    L.year_built AS [Год постройки]
FROM 
    Landmark AS L, 
    IS_TYPE AS IT, 
    Type AS T
WHERE 
    MATCH(L-(IT)->T)
    AND T.name = 'Храм'
    AND L.year_built < 1500;
--6

SELECT 
    L1.id AS StartLandmarkID,
    L1.name AS StartLandmarkName,
    STRING_AGG(L2.name, ' -> ') WITHIN GROUP (GRAPH PATH) AS Path,
    LAST_VALUE(L2.id) WITHIN GROUP (GRAPH PATH) AS FinalLandmarkID,
    SUM(N.distance_km) WITHIN GROUP (GRAPH PATH) AS TotalDistance
FROM
    Landmark L1,
    Landmark FOR PATH L2,
    NEARBY FOR PATH N
WHERE 
    MATCH(SHORTEST_PATH(L1(-(N)->L2){1,3}))
    AND L1.id = 1 -- Мирский замок (который имеет связи)
ORDER BY L1.id;


SELECT 
    L1.id AS StartLandmarkID,
    L1.name AS StartLandmarkName,
    STRING_AGG(L2.name, ' -> ') WITHIN GROUP (GRAPH PATH) AS Path,
    LAST_VALUE(L2.id) WITHIN GROUP (GRAPH PATH) AS FinalLandmarkID,
    SUM(N.distance_km) WITHIN GROUP (GRAPH PATH) AS TotalDistanceKm,
    COUNT(N.$edge_id) WITHIN GROUP (GRAPH PATH) AS HopsCount
FROM
    Landmark AS L1,
    Landmark FOR PATH AS L2,
    NEARBY FOR PATH AS N
WHERE 
    MATCH(SHORTEST_PATH(L1(-(N)->L2)+))
    AND L1.id = 3  -- Мирский замок
ORDER BY 
    TotalDistanceKm;