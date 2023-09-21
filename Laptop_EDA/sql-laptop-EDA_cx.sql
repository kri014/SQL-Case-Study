-- 1. Create backup
USE campus_x
SELECT * FROM laptop 
-- creating table 
CREATE TABLE laptops_backup LIKE laptop
-- inserting data in backup 
INSERT INTO laptops_backup 
SELECT * FROM laptop 

SELECT * FROM laptops_backup

-- 2. Check number of rows

SELECT COUNT(*) FROM laptop 

-- 3. Check memory consumption for reference
SELECT * FROM information_schema.TABLES
WHERE TABLE_SCHEMA="campus_x"
AND TABLE_NAME="laptop"

-- memory occupy (ROM)- DATA_LENGTH -272 kb
SELECT DATA_LENGTH/1024 FROM information_schema.TABLES
WHERE TABLE_SCHEMA="campus_x"
AND TABLE_NAME="laptop"

-- 4. Drop non important cols
SELECT * FROM laptop
-- here unnamed columns is unwanted so dropping the columns 
ALTER TABLE laptop DROP COLUMN `Unnamed: 0` 

-- 5. Drop null values
-- first dropping the rows which are having all value null 

SELECT * FROM laptop 
WHERE Company IS NULL AND TypeName IS NULL AND Inches IS NULL
AND ScreenResolution IS NULL AND Cpu IS NULL AND Ram IS NULL
AND Memory IS NULL AND Gpu IS NULL AND OpSys IS NULL AND
WEIGHT IS NULL AND Price IS NULL

-- index of all the null rows 
SELECT `index` FROM laptop 
WHERE Company IS NULL AND TypeName IS NULL AND Inches IS NULL
AND ScreenResolution IS NULL AND Cpu IS NULL AND Ram IS NULL
AND Memory IS NULL AND Gpu IS NULL AND OpSys IS NULL AND
WEIGHT IS NULL AND Price IS NULL
-- delete the rows with this index 
DELETE FROM laptop 
WHERE `index` IN (SELECT `index` FROM laptop 
				WHERE Company IS NULL AND TypeName IS NULL AND Inches IS NULL
				AND ScreenResolution IS NULL AND Cpu IS NULL AND Ram IS NULL
				AND Memory IS NULL AND Gpu IS NULL AND OpSys IS NULL AND
				WEIGHT IS NULL AND Price IS NULL)
                
SELECT COUNT(*) FROM LAPTOP 
-- now only 1273 rows left  around 30 rows deleted 

-- 6. Drop Duplicates
-- In our data no duplicates are there 
-- but we create a data with duplicates and droping we do 
CREATE TABLE duplicates (
id INTEGER PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(255) NOT NULL,
gender VARCHAR(255) NOT NULL,
age INTEGER NOT NULL)

INSERT INTO duplicates values 
(1,"nitish","male",30),
(2,"ankit","male",31),
(3,"neha","female",21),
(4,"nitish","male",30),
(5,"nitish","male",30),
(6,"neha","female",21),
(7,"rahul","male",23),
(8,"amit","male",29)

SELECT * FROM duplicates

-- groupby by each colums to get the duplicates counts 
-- here neha and nitish are dplicates rows
SELECT name,gender,age,COUNT(*)
FROM duplicates 
GROUP BY name,gender,age
HAVING COUNT(*) >1

-- selecting the id comes once where combination of name,gender,age  
SELECT min(id)
FROM duplicates 
GROUP BY name,gender,age

DELETE FROM duplicates 
WHERE id NOT IN (SELECT min(id)
				FROM duplicates 
				GROUP BY name,gender,age)
SELECT * FROM duplicates 
-- No duplicates remains in the table 

-- 7. Clean RAM -> Change col data type
USE campus_x
SELECT * FROM LAPTOP
-- checking each colums with distinct 

SELECT DISTINCT Company FROM laptop  
SELECT DISTINCT TypeName FROM laptop

-- changing the inch col to decimal 
ALTER TABLE laptop MODIFY COLUMN Inches DECIMAL(10,1) 

SELECT DISTINCT Inches FROM Laptop
-- Inch is numerical colums so distinct is not required it requires in categorical 

SELECT * FROM laptop

UPDATE laptop l1
SET Ram = (SELECT REPLACE (Ram,"GB","") FROM laptop l2 WHERE l1.index=l2.index)

SELECT * FROM laptop 

ALTER TABLE laptop MODIFY COLUMN Ram INTEGER 

SELECT DATA_LENGTH/1024 FROM information_schema.TABLES
WHERE TABLE_SCHEMA="campus_x"
AND TABLE_NAME="laptop"
-- memory redues from 272 to 256

-- modify in weight col-> replacing kg to empty
SELECT * FROM laptop 
SELECT REPLACE(Weight,"kg","") FROM laptop 

UPDATE laptop t1
SET Weight =(SELECT REPLACE(Weight,"kg","") FROM laptop t2 WHERE t1.index=t2.index )

ALTER TABLE laptop MODIFY COLUMN Weight DECIMAL(10,2) 

-- price col
SELECT * FROM laptop

UPDATE laptop t1
SET Price =(SELECT ROUND(Price) 
             FROM laptop t2 WHERE t1.index=t2.index )
             
ALTER TABLE laptop MODIFY COLUMN Price INTEGER


SELECT DATA_LENGTH/1024 FROM information_schema.TABLES
WHERE TABLE_SCHEMA="campus_x"
AND TABLE_NAME="laptop"
-- memory reduces from 256 to 240 

SELECT * FROM laptop 

-- OpSys col
SELECT DISTINCT OpSys FROM laptop 
-- here we form a col with Osname with the help of OpSys
-- mac
-- window
-- linux
-- no os
-- Android chrome(others)

SELECT OpSys,
CASE 
   WHEN OpSys LIKE "%mac%" THEN "macos"
   WHEN OpSys LIKE "%window%" THEN "windows"
   WHEN OpSys LIKE "%Linux%"  THEN "linux"
   WHEN OpSys ="No OS" THEN "N/A"
   ELSE "others"
END AS "os_brand"
FROM laptop

UPDATE laptop
SET OpSys = CASE 
   WHEN OpSys LIKE "%mac%" THEN "macos"
   WHEN OpSys LIKE "%window%" THEN "windows"
   WHEN OpSys LIKE "%Linux%"  THEN "linux"
   WHEN OpSys ="No OS" THEN "N/A"
   ELSE "others"
END ;

SELECT * FROM laptop 

-- GPU col 
-- create two cols name as gpu_brand, gpu_name
ALTER TABLE laptop 
ADD COLUMN gpu_brand VARCHAR(255) AFTER Gpu,
ADD COLUMN gpu_name VARCHAR(255) AFTER gpu_brand 

UPDATE laptop t1
SET gpu_brand= (SELECT SUBSTRING_INDEX(GPU," ",1) 
                 FROM laptop t2 WHERE t1.index=t2.index)

SELECT * FROM laptop
SELECT REPLACE(Gpu,gpu_brand,"") FROM laptop

UPDATE laptop t1
SET gpu_name= (SELECT REPLACE(Gpu,gpu_brand,"") 
                 FROM laptop t2 WHERE t1.index=t2.index)
SELECT * FROM laptop 

ALTER TABLE laptop DROP COLUMN Gpu

SELECT * FROM laptop
 
-- Cpu col 
-- create three cols from Cpu-> Cpu_brand,cpu_name,cpu_speed

ALTER TABLE laptop 
ADD COLUMN cpu_brand VARCHAR(255) AFTER Cpu,
ADD COLUMN cpu_name VARCHAR(255) AFTER cpu_brand,
ADD COLUMN cpu_speed DECIMAL(10,1) AFTER cpu_name

SELECT * FROM laptop

SELECT SUBSTRING_INDEX(CPU," ",1) FROM laptop

UPDATE laptop l1
SET cpu_brand=(SELECT SUBSTRING_INDEX(CPU," ",1) 
                 FROM laptop l2 WHERE l1.index=l2.index)
                 
SELECT * FROM laptop

SELECT CAST(REPLACE(SUBSTRING_INDEX(Cpu," ",-1),"GHz","")
                  AS DECIMAL(10,1)) 
                  FROM laptop 

UPDATE laptop l1
SET cpu_speed=(SELECT CAST(REPLACE(SUBSTRING_INDEX(Cpu," ",-1),"GHz","")  
			  AS DECIMAL(10,1)) 
			  FROM laptop l2 WHERE l1.index=l2.index)

SELECT * FROM laptop

SELECT SUBSTRING_INDEX(REPLACE(Cpu,cpu_brand,"")," ",-1), 
REPLACE(Cpu,cpu_brand,""),
REPLACE(REPLACE(Cpu,cpu_brand,""),SUBSTRING_INDEX(REPLACE(Cpu,cpu_brand,"")," ",-1),"")
FROM laptop 

SELECT 
REPLACE(REPLACE(Cpu,cpu_brand,""),SUBSTRING_INDEX(REPLACE(Cpu,cpu_brand,"")," ",-1),"")
FROM laptop 

UPDATE laptop l1
SET cpu_name=(SELECT 
                REPLACE(REPLACE(Cpu,cpu_brand,""),
				        SUBSTRING_INDEX(REPLACE(Cpu,cpu_brand,"")," ",-1),"")
				FROM laptop  l2 
                WHERE l1.index=l2.index)

SELECT * FROM laptop

ALTER TABLE laptop DROP COLUMN Cpu

SELECT * FROM laptop 
-- ScreenResolution col
SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution," ",-1),"x",1),
       SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution," ",-1),"x",-1) 
FROM laptop 

ALTER TABLE laptop
ADD COLUMN resolution_width INTEGER AFTER ScreenResolution,
ADD COLUMN resolution_height INTEGER AFTER resolution_width

SELECT * FROM laptop

UPDATE laptop l1
SET resolution_width= SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution," ",-1),"x",1),
resolution_height= SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution," ",-1),"x",-1) 

SELECT * FROM laptop 

ALTER TABLE laptop
ADD COLUMN touch_screen INTEGER AFTER resolution_height

SELECT * FROM laptop 

SELECT ScreenResolution LIKE "%Touch%" FROM laptop

UPDATE laptop
SET touch_screen = ScreenResolution LIKE "%Touch%"

SELECT * FROM laptop 

ALTER TABLE laptop
DROP COLUMN ScreenResolution

SELECT * FROM laptop 

-- cpu_name 
SELECT cpu_name,SUBSTRING_INDEX(trim(cpu_name)," ",2) FROM laptop

UPDATE laptop
SET cpu_name=SUBSTRING_INDEX(trim(cpu_name)," ",2)

SELECT DISTINCT cpu_name  FROM laptop

-- Memory col

SELECT * FROM laptop 

ALTER TABLE laptop 
ADD COLUMN memory_type VARCHAR(255) AFTER memory

ALTER TABLE laptop 
ADD COLUMN primary_storage INTEGER AFTER memory_type,
ADD COLUMN secondry_storage INTEGER AFTER primary_storage

SELECT DISTINCT Memory FROM laptop

SELECT Memory,
CASE 
   WHEN Memory LIKE "%SSD%" AND Memory LIKE "%HDD%" THEN "Hybrid"
   WHEN Memory LIKE "%SSD%" THEN "SSD"
   WHEN Memory LIKE "%HDD%" THEN "HDD"
   WHEN Memory LIKE "%Flash Storage%" THEN "Flash Storage"
   WHEN Memory LIKE "%Hybrid%" THEN "Hybrid"
   WHEN Memory LIKE "%Flash Storage%" AND Memory LIKE "%HDD%" THEN "Hybrid"
   ELSE Null
END AS "memory_type"
FROM laptop

UPDATE laptop
SET memory_type=CASE 
   WHEN Memory LIKE "%SSD%" AND Memory LIKE "%HDD%" THEN "Hybrid"
   WHEN Memory LIKE "%SSD%" THEN "SSD"
   WHEN Memory LIKE "%HDD%" THEN "HDD"
   WHEN Memory LIKE "%Flash Storage%" THEN "Flash Storage"
   WHEN Memory LIKE "%Hybrid%" THEN "Hybrid"
   WHEN Memory LIKE "%Flash Storage%" AND Memory LIKE "%HDD%" THEN "Hybrid"
   ELSE Null
END;

SELECT * FROM laptop

SELECT Memory, 
REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,"+",1),'[0-9]+'),
CASE WHEN Memory LIKE "%+%" THEN REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,"+",-1),"[0-9]+") ELSE 0 END
FROM laptop

UPDATE laptop
SET primary_storage=REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,"+",1),'[0-9]+'),
secondry_storage=CASE WHEN Memory LIKE "%+%" THEN REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,"+",-1),"[0-9]+") ELSE 0 END

SELECT * FROM laptop;
SELECT primary_storage,
CASE WHEN primary_storage <=2 THEN primary_storage*1024 ELSE primary_storage END,
CASE WHEN secondry_storage <=2 THEN secondry_storage*1024 ELSE secondry_storage END
FROM laptop

UPDATE laptop
SET primary_storage=CASE WHEN primary_storage <=2 THEN primary_storage*1024 ELSE primary_storage END,
secondry_storage=CASE WHEN secondry_storage <=2 THEN secondry_storage*1024 ELSE secondry_storage END

SELECT * FROM laptop

ALTER TABLE laptop DROP COLUMN Memory

ALTER TABLE laptop DROP COLUMN gpu_name

SELECT DATA_LENGTH/1024 FROM information_schema.TABLES
WHERE TABLE_SCHEMA="campus_x"
AND TABLE_NAME="laptop"