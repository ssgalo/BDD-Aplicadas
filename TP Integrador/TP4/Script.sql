create database pruebaCSV
GO
CREATE SCHEMA datosPaciente
GO
CREATE SCHEMA datosReserva
GO
CREATE SCHEMA datosAtencion

GO

CREATE TABLE datosPaciente.Usuario		-- Listo los SP
(
	id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	contraseña CHAR(8) NOT NULL,
	fechaCreacion DATETIME NOT NULL,
	fechaBorrado DATETIME NULL
) 
GO

CREATE TABLE datosPaciente.Domicilio	-- Listo los SP con 1 duda
(
	id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	calleYNro NVARCHAR(50) NOT NULL,
	piso INT NULL,
	departamento NVARCHAR(10) NULL, 
	codigoPostal NVARCHAR(10) NULL,
	pais NVARCHAR(15) NOT NULL,
	provincia NVARCHAR(15) NOT NULL,
	localidad NVARCHAR(15) NOT NULL,
	nroDocumento INT NOT NULL
)
go

CREATE TABLE datosPaciente.Prestador	-- Listo los SP
(
	id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	nombre NVARCHAR(20) NOT NULL,
	tipoPlan NVARCHAR(10) NOT NULL,
	fechaBorrado DATETIME NULL
)
GO

CREATE TABLE datosPaciente.Cobertura	-- Listo los SP
(
	id INT IDENTITY(1,1) PRIMARY KEY not null,
	imagenCredencial NVARCHAR(40) NOT NULL,
	nroSocio INT NOT NULL,
	fechaRegistro DATETIME NOT NULL,
	idPrestador INT NOT NULL,
	fechaBorrado DATETIME NULL,
	CONSTRAINT FK_Prestador FOREIGN KEY (idPrestador) REFERENCES datosPaciente.Prestador(id)
)
GO

CREATE TABLE datosPaciente.Estudio
(
	id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	fecha DATE NOT NULL,
	nombre NVARCHAR(15) NOT NULL,
	autorizado BIT NOT NULL,
	linkDocumentoResultado NVARCHAR(50) NOT NULL,
	imagenResultado NVARCHAR(40) NOT NULL,
	fechaBorrado DATETIME NULL
)
GO

CREATE TABLE datosPaciente.Paciente 
(
	idHistoriaClinica INT IDENTITY(1,1) NOT NULL,
	nombre NVARCHAR(20) NOT NULL,
	apellido NVARCHAR(20) NOT NULL,
	apellidoMaterno NVARCHAR(20) NOT NULL,
	fechaNacimiento VARCHAR(10) NOT NULL,
	tipoDocumento VARCHAR(9) NOT NULL,
	nroDocumento INT NOT NULL,
	sexo CHAR(9) NOT NULL,
	genero CHAR(6) NULL,
	nacionalidad NVARCHAR(15) NOT NULL,
	fotoPerfil VARCHAR(40) NOT NULL,
	mail VARCHAR(60) NOT NULL,
	telefonoFijo VARCHAR(20) NOT NULL,
	telefonoContactoAlternativo VARCHAR(20) NULL,
	telefonoLaboral VARCHAR(20) NULL,
	fechaRegistro DATE NOT NULL,
	fechaActualizacion DATETIME NULL,
	idUsuario INT NOT NULL,
	idEstudio INT NOT NULL,
	idCobertura INT NOT NULL,
	idUsuarioActualizacion INT NULL,
	fechaBorrado DATETIME NULL
	CONSTRAINT PK_Paciente PRIMARY KEY (nroDocumento),
	CONSTRAINT FK_Usuario FOREIGN KEY (idUsuario) REFERENCES datosPaciente.Usuario(id),
	CONSTRAINT FK_Estudio FOREIGN KEY (idEstudio) REFERENCES datosPaciente.Estudio(id),
	CONSTRAINT FK_Cobertura FOREIGN KEY (idCobertura) REFERENCES datosPaciente.Cobertura(id)
)

-----------------------------------------------------------------------------------
-- Creo un usuario generico, un estudio genérico, una cobertura generica y un prestador genérico

INSERT INTO datosPaciente.Usuario (contraseña, fechaCreacion, fechaBorrado)
VALUES
('12345678', GETDATE(), NULL)
SELECT * FROM datosPaciente.Usuario

INSERT INTO datosPaciente.Estudio (fecha, nombre, autorizado, linkDocumentoResultado, imagenResultado, fechaBorrado)
VALUES
(GETDATE(), 'Generico', 0, 'Generico', 'Generico', NULL) 

INSERT INTO datosPaciente.Prestador(nombre, tipoPlan, fechaBorrado)
VALUES
('Generico', 'Generico', NULL)
SELECT * FROM datosPaciente.Prestador

INSERT INTO datosPaciente.Cobertura(imagenCredencial, nroSocio, fechaRegistro, idPrestador)
VALUES
('Generico', 1, GETDATE(), 1)
SELECT * FROM datosPaciente.Cobertura

-- LUEGO DEJAR DOCUMENTACIÓN DEL BULK INSERT

-- Cosas a tener en cuenta: Este SP es para una carga de registros NUEVOS.
-- No admite la modificación de los ya ingresados.
-- Contemplamos asignar un usuario genérico al ser la primera vez que ingresa, con una contraseña 12345678
-- Luego el usuario deberá cambiar su contraseña

GO
CREATE OR ALTER PROCEDURE datosPaciente.CargarDatosDesdeCSV_Pacientes
AS
BEGIN
	DECLARE @cantRegistrosDomicilio INT;
	DECLARE @cantRegistrosPaciente INT;
	SELECT @cantRegistrosDomicilio = COUNT(*) FROM datosPaciente.Domicilio;
	SELECT @cantRegistrosPaciente = COUNT(*) FROM datosPaciente.Paciente;

	IF @cantRegistrosDomicilio > 0 OR @cantRegistrosPaciente > 0
	BEGIN
		-- PREGUNTAR AL PROFE QUE SE HACE EN ESTE CASO. ESTE SP ES SOLO PARA REGISTROS NUEVOS?
		-- CONVIENE BORRAR LA TABLA Y VOLVER A INSERTAR?
		PRINT 'YA EXISTEN REGISTROS EN LAS TABLAS'
		RETURN;
	END
	
	-- Crear una tabla temporal con la misma estructura que el archivo CSV
	CREATE TABLE #TempTable
	(
		Nombre NVARCHAR(50),  
		Apellido NVARCHAR(50),
		FechadeNacimiento VARCHAR(50),
		tipoDocumento VARCHAR(10),
		Nrodocumento VARCHAR(50),
		Sexo VARCHAR(10),
		genero VARCHAR(10),
		Telefonofijo VARCHAR(20),
		Nacionalidad VARCHAR(30),
		Mail VARCHAR(50),
		CalleyNro NVARCHAR(50),
		Localidad NVARCHAR(50),
		Provincia NVARCHAR(50)
	);

	-- Cargar datos desde el archivo CSV en la tabla temporal
	BULK INSERT #TempTable
	FROM 'C:\Software Santi\BDD-Aplicadas\TP Integrador\TP4\Dataset\Pacientes.csv'
	WITH (
		FIELDTERMINATOR = ';',  
		ROWTERMINATOR = '\n',
		FIRSTROW = 2
	);
	
	INSERT INTO datosPaciente.Domicilio(calleYNro, piso, departamento, codigoPostal, pais, provincia, localidad, nroDocumento)
	SELECT
	CalleyNro,
	NULL,
	NULL,
	NULL,
	CAST(T.Nacionalidad AS NVARCHAR(15)),
	CAST(T.Provincia AS NVARCHAR(15)),
	CAST(T.Localidad AS NVARCHAR(15)),
	CAST(T.Nrodocumento AS int)
	FROM #TempTable T

	-- Realizar transformación de datos y luego insertar en la tabla de destino
	INSERT INTO datosPaciente.Paciente(nombre, apellido, apellidomaterno, fechaNacimiento, tipoDocumento,
				nroDocumento, sexo, genero, nacionalidad, fotoPerfil, mail, telefonoFijo, telefonoContactoAlternativo, telefonoLaboral,
				fechaRegistro, fechaActualizacion, idUsuario, idEstudio, idCobertura, idUsuarioActualizacion)
	SELECT 
		CAST(T.Nombre AS VARCHAR(20)),  
		CAST(T.Apellido AS VARCHAR(20)),
		'No cargado',
		CAST(T.FechadeNacimiento AS varchar(10)),
		CAST(T.tipoDocumento AS VARCHAR(9)),
		CAST(T.Nrodocumento AS INT),
		CAST(T.Sexo AS VARCHAR(9)),
		CAST(T.genero AS VARCHAR(6)),
		CAST(T.Nacionalidad AS VARCHAR(15)),
		'No cargado',
		CAST(T.Mail AS VARCHAR(60)),
		CAST(T.TelefonoFijo AS VARCHAR(20)),
		'No cargado',
		'No cargado',
		GETDATE(),
		NULL,
		1,
		1,
		1,
		NULL
	FROM #TempTable T 
END

EXEC datosPaciente.CargarDatosDesdeCSV_Pacientes
SELECT * FROM datosPaciente.Domicilio
SELECT * FROM datosPaciente.Paciente

-- CÓDIGO DE DASHA PARA MÉDICOS: NO LO PROBÉ

CREATE OR ALTER PROCEDURE CargarDatosDesdeCSV_Medicos
AS
BEGIN
	--Borrar datos anteriores CONSULTAR! Lo agrego porque se supone que se manda uno nuevo actualizado cada mes
	delete from salud.Medico

	-- Crear una tabla temporal con la misma estructura que el archivo CSV
	CREATE TABLE #TempTable
	(
		Nombre VARCHAR(50),  
		Apellidos VARCHAR(50),
		Especialidad VARCHAR(50),
		Numerodecolegiado VARCHAR(50)
	);

	-- Cargar datos desde el archivo CSV en la tabla temporal
	BULK INSERT #TempTable
	FROM 'C:\Users\apoll\OneDrive\Escritorio\Dataset\Medicos.csv'
	WITH (
		FIELDTERMINATOR = ';',  
		ROWTERMINATOR = '\n',
		FIRSTROW = 2
	);

	
	-- Realizar transformación de datos y luego insertar en la tabla de destino
	INSERT INTO salud.Medico(nombre, apellido, idEspecialidad, nroMatricula)
	SELECT 
		CAST(T.Nombre AS VARCHAR(20)),  
		CAST(T.Apellidos AS VARCHAR(20)),
		E.id,
		CAST(Numerodecolegiado as INT)
	FROM #TempTable T INNER JOIN salud.Especialidad E 
	ON T.Especialidad COLLATE Modern_Spanish_CI_AI = E.nombre COLLATE Modern_Spanish_CI_AI;

	SELECT * FROM #TempTable

	-- Eliminar la tabla temporal después de su uso 
	--DROP TABLE #TempTable;		lo comente para poder ver como se guardaban, despues descomentar
END 

		
CREATE OR ALTER PROCEDURE CargarDatosDesdeCSV_Sedes
AS
BEGIN
	-- Crear una tabla temporal con la misma estructura que el archivo CSV
	CREATE TABLE #TempTable
	(
		nombre NVARCHAR(30) NOT NULL,
		direccion NVARCHAR(30) NOT NULL,
		localidad NVARCHAR(30),
		provincia NVARCHAR(30),
	);

	-- Cargar datos desde el archivo CSV en la tabla temporal
	BULK INSERT #TempTable
	FROM 'C:\Dataset\Sedes.csv'
	WITH (
		FIELDTERMINATOR = ';',  
		ROWTERMINATOR = '\n',
		FIRSTROW = 2
		--,ERRORFILE = 'C:\Dataset\ErroresSedes.csv'
	);
		-- Realizar transformación de datos y luego insertar en la tabla de destino
	INSERT INTO datosAtencion.SedeAtencion2(nombre, direccion, fechaBorrado)
	SELECT 
		CAST(T.nombre AS NVARCHAR(30)),  
		CAST(T.direccion AS NVARCHAR(30)),
		NULL
	FROM #TempTable T 

	--SELECT * FROM #TempTable

	-- Eliminar la tabla temporal después de su uso 
	DROP TABLE #TempTable;
END 

CREATE OR ALTER PROCEDURE CargarDatosDesdeCSV_Prestadores
AS
BEGIN
	-- Crear una tabla temporal con la misma estructura que el archivo CSV
	CREATE TABLE #TempTable
	(
		nombre NVARCHAR(30) NOT NULL,
		tipoPlan NVARCHAR(30) NOT NULL,
		fechaBorrado DATETIME NULL,
		campoExtra CHAR NULL,
	);

	-- Cargar datos desde el archivo CSV en la tabla temporal
	FROM 'C:\Dataset\Prestador.csv'
	WITH (
		FIELDTERMINATOR = ';',  
		ROWTERMINATOR = '\n',
		FIRSTROW = 2
	);
	SELECT * FROM #TempTable
		-- Realizar transformación de datos y luego insertar en la tabla de destino
	INSERT INTO datosPaciente.Prestador(nombre, tipoPlan, fechaBorrado)
	SELECT 
		CAST(T.nombre AS NVARCHAR(30)),  
		CAST(T.tipoPlan AS NVARCHAR(30)),
		NULL
	FROM #TempTable T 


	-- Eliminar la tabla temporal después de su uso 
	DROP TABLE #TempTable;	--	lo comente para poder ver como se guardaban, despues descomentar
END 
