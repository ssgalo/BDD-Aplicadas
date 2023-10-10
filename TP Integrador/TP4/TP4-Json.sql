use ClinicaCureSA
go

CREATE TABLE Centro_Autorizaciones (		--si dejamos esta opcion hay que agregarle el esquema 
    Area varchar(30),
    Estudio varchar(30),
    Prestador varchar(30),
    Programa varchar(50),
    [Porcentaje Cobertura] float,
    Costo float,
    [Requiere autorizacion] varchar(5) -- Usamos varchar para guardar 'True' o 'False'
);
go

-- Hice dos formas de traer los datos del .json, uno es solo mostrarlos y otra es copiarlos en una tabla, borrar la menos adecuada despues 

-- 1) Importamos la informacion del .json a nuestra base de datos
DECLARE @jsonEstudiosClinicos NVARCHAR(MAX);
SET @jsonEstudiosClinicos = (
    SELECT * 
    FROM OPENROWSET (BULK 'C:\Users\apoll\OneDrive\Escritorio\Dataset\Centro_Autorizaciones.Estudios clinicos.json', SINGLE_CLOB) as JsonFile
)
SELECT 
	Area,
    Estudio,
    Prestador,
    Programa,
    [Porcentaje Cobertura] AS [Porcentaje Cobertura], -- Mantener el nombre original
    Costo,
    CASE											  -- Agregamos el case para que nos muestre true o false en lugar del 0 o 1
        WHEN [Requiere autorizacion] = 1 THEN 'True'
        ELSE 'False'
    END AS [Requiere autorizacion]
FROM OPENJSON(@jsonEstudiosClinicos)
WITH(
	Area varchar(30) '$.Area',
	Estudio varchar(30) '$.Estudio',
	Prestador varchar(30) '$.Prestador',
	Programa varchar(50) '$.Plan',
	[Porcentaje Cobertura] int '$."Porcentaje Cobertura"',
	Costo money '$.Costo',
	[Requiere autorizacion] bit '$."Requiere autorizacion"'
	)
-- Debido a problemas con los espacios en "Porcentaje Cobertura" y "Requiere autorizacion" debimos agregarle los corchetes por un lado y las comillas dobles.


-- 2) Guardamos la informacion del .json en una tabla
DELETE FROM Centro_Autorizaciones
go

DECLARE @jsonEstudiosClinicos NVARCHAR(MAX);
SET @jsonEstudiosClinicos = (
    SELECT * 
    FROM OPENROWSET (BULK 'C:\Users\apoll\OneDrive\Escritorio\Dataset\Centro_Autorizaciones.Estudios clinicos.json', SINGLE_CLOB) as JsonFile
)
-- Insertar los resultados de la consulta en la tabla recientemente creada
INSERT INTO Centro_Autorizaciones (Area, Estudio, Prestador, Programa, [Porcentaje Cobertura], Costo, [Requiere autorizacion])
SELECT 
    Area,
    Estudio,
    Prestador,
    Programa,
    [Porcentaje Cobertura],
    Costo,
    CASE 
        WHEN [Requiere autorizacion] = 1 THEN 'True'
        ELSE 'False'
    END AS [Requiere autorizacion]
FROM OPENJSON(@jsonEstudiosClinicos)
WITH(
    Area varchar(30) '$.Area',
    Estudio varchar(30) '$.Estudio',
    Prestador varchar(30) '$.Prestador',
    Programa varchar(50) '$.Plan',
    [Porcentaje Cobertura] int '$."Porcentaje Cobertura"',
    Costo money '$.Costo',
    [Requiere autorizacion] bit '$."Requiere autorizacion"'
);
go

select * from Centro_Autorizaciones


