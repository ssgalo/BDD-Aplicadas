---- COMIENZO ENUNCIADO ----
/*
Se proveen maestros de Médicos, Pacientes, Prestadores y Sedes en formato CSV. También se 
dispone de un archivo JSON que contiene la parametrización del mecanismo de autorización 
según estudio y obra social, además de porcentaje cubierto, etc. Ver archivo “Datasets para 
importar” en Miel.
Se requiere que importe toda la información antes mencionada a la base de datos. Genere los 
objetos necesarios (store procedures, funciones, etc.) para importar los archivos antes 
mencionados. Tenga en cuenta que cada mes se recibirán archivos de novedades con la misma 
estructura pero datos nuevos para agregar a cada maestro. Considere este comportamiento al 
generar el código. Debe admitir la importación de novedades periódicamente.
La estructura/esquema de las tablas a generar será decisión suya. Puede que deba realizar 
procesos de transformación sobre los maestros recibidos para adaptarlos a la estructura 
requerida. 
Los archivos CSV/JSON no deben modificarse. En caso de que haya datos mal cargados, 
incompletos, erróneos, etc., deberá contemplarlo y realizar las correcciones en el fuente SQL. 
(Sería una excepción si el archivo está malformado y no es posible interpretarlo como JSON o 
CSV). Documente las correcciones que haga indicando número de línea, contenido previo y 
contenido nuevo. Esto se cotejará para constatar que cumpla correctamente la consigna.
Adicionalmente se requiere que el sistema sea capaz de generar un archivo XML detallando los 
turnos atendidos para informar a la Obra Social. El mismo debe constar de los datos del paciente 
(Apellido, nombre, DNI), nombre y matrícula del profesional que lo atendió, fecha, hora, 
especialidad. Los parámetros de entrada son el nombre de la obra social y un intervalo de fechas.
*/
---- FIN ENUNCIADO ----

---- COMIENZO DATOS ENTREGA ----
/*
	Fecha de Entrega: 10/10/2023
	Número de grupo: 12
	Nombre de la Materia: Bases de Datos Aplicadas
	
	Integrantes del grupo:
	Santiago Galo 		- 43473506
	Juan Manuel Pergola - 39515920
	Dasha Apollaro		- 44448125
	Johnathan Portillo	- 43458310
*/
---- FIN DATOS ENTREGA ----

-- ACLARACIÓN: El siguiente TP N4 tiene también el código de creación de tablas y esquemas al igual que el TP N3.
-- Sin embargo, tiene algunas modificaciones en las constraints y primary keys para que la importación de los datos pueda hacerse correctamente.

-- drop database CURESA

---- COMIENZO CREACION DE BASE DE DATOS Y ESQUEMAS ----
create database CURESA COLLATE Modern_Spanish_CI_AI;
go
use CURESA

GO
CREATE SCHEMA datosPaciente
GO
CREATE SCHEMA datosReserva
GO
CREATE SCHEMA datosAtencion
---- FIN CREACION DE BASE DE DATOS Y ESQUEMAS ----
GO

IF OBJECT_ID('datosPaciente.Usuario') IS NOT NULL
BEGIN
    DROP TABLE datosPaciente.Usuario
    IF OBJECT_ID('datosPaciente.Usuario') IS NOT NULL
	RAISERROR('Ocurrió un error al intentar eliminar la tabla datosPaciente.Usuario', 16, 1);
    ELSE
        PRINT 'Tabla datosPaciente.Usuario eliminada correctamente.'
END
GO
CREATE TABLE datosPaciente.Usuario		
(
	id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	contraseña CHAR(8) NOT NULL,
	fechaCreacion DATETIME NOT NULL,
	fechaBorrado DATETIME NULL
) 
GO

IF OBJECT_ID('datosPaciente.Domicilio') IS NOT NULL
BEGIN
    DROP TABLE datosPaciente.Domicilio
    IF OBJECT_ID('datosPaciente.Domicilio') IS NOT NULL
	RAISERROR('Ocurrió un error al intentar eliminar la tabla datosPaciente.Domicilio.', 16, 1);
    ELSE
        PRINT 'Tabla datosPaciente.Domicilio eliminada correctamente.'
END
GO
CREATE TABLE datosPaciente.Domicilio	
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

IF OBJECT_ID('datosPaciente.Prestador') IS NOT NULL
BEGIN
    DROP TABLE datosPaciente.Prestador
    IF OBJECT_ID('datosPaciente.Prestador') IS NOT NULL
	RAISERROR('Ocurrió un error al intentar eliminar la tabla datosPaciente.Prestador.', 16, 1);
    ELSE
        PRINT 'Tabla datosPaciente.Prestador eliminada correctamente.'
END
GO
CREATE TABLE datosPaciente.Prestador	
(
	id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	nombre NVARCHAR(40) NOT NULL,
	tipoPlan NVARCHAR(40) NOT NULL,
	fechaBorrado DATETIME NULL
)
GO

IF OBJECT_ID('datosPaciente.Cobertura') IS NOT NULL
BEGIN
    DROP TABLE datosPaciente.Cobertura
    IF OBJECT_ID('datosPaciente.Cobertura') IS NOT NULL
	RAISERROR('Ocurrió un error al intentar eliminar la tabla datosPaciente.Cobertura.', 16, 1);
    ELSE
        PRINT 'Tabla datosPaciente.Cobertura eliminada correctamente.'
END
GO
CREATE TABLE datosPaciente.Cobertura	
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

IF OBJECT_ID('datosPaciente.Estudio') IS NOT NULL
BEGIN
    DROP TABLE datosPaciente.Estudio
    IF OBJECT_ID('datosPaciente.Estudio') IS NOT NULL
	RAISERROR('Ocurrió un error al intentar eliminar la tabla datosPaciente.Estudio.', 16, 1);
    ELSE
        PRINT 'Tabla datosPaciente.Estudio eliminada correctamente.'
END
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

IF OBJECT_ID('datosPaciente.Paciente') IS NOT NULL
BEGIN
    DROP TABLE datosPaciente.Paciente
    IF OBJECT_ID('datosPaciente.Paciente') IS NOT NULL
	RAISERROR('Ocurrió un error al intentar eliminar la tabla datosPaciente.Paciente.', 16, 1);
    ELSE
        PRINT 'Tabla datosPaciente.Paciente eliminada correctamente.'
END
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
GO

IF OBJECT_ID('datosReserva.EstadoTurno') IS NOT NULL
BEGIN
    DROP TABLE datosReserva.EstadoTurno
    IF OBJECT_ID('datosReserva.EstadoTurno') IS NOT NULL
	RAISERROR('Ocurrió un error al intentar eliminar la tabla datosReserva.EstadoTurno.', 16, 1);
    ELSE
        PRINT 'Tabla datosReserva.EstadoTurno eliminada correctamente.'
END
GO
CREATE TABLE datosReserva.EstadoTurno
(
	id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	nombreEstado CHAR(9) NOT NULL,
	fechaBorrado DATETIME NULL
)
GO

IF OBJECT_ID('datosAtencion.Especialidad') IS NOT NULL
BEGIN
    DROP TABLE datosAtencion.Especialidad
    IF OBJECT_ID('datosAtencion.Especialidad') IS NOT NULL
	RAISERROR('Ocurrió un error al intentar eliminar la tabla datosAtencion.Especialidad.', 16, 1);
    ELSE
        PRINT 'Tabla datosAtencion.Especialidad eliminada correctamente.'
END
GO
CREATE TABLE datosAtencion.Especialidad
(
	id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	nombre VARCHAR(20) NOT NULL
)
GO

IF OBJECT_ID('datosAtencion.SedeAtencion') IS NOT NULL
BEGIN
    DROP TABLE datosAtencion.SedeAtencion
    IF OBJECT_ID('datosAtencion.SedeAtencion') IS NOT NULL
	RAISERROR('Ocurrió un error al intentar eliminar la tabla datosAtencion.SedeAtencion.', 16, 1);
    ELSE
        PRINT 'Tabla datosAtencion.SedeAtencion eliminada correctamente.'
END
GO
CREATE TABLE datosAtencion.SedeAtencion
(
	id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	nombre NVARCHAR(20) NOT NULL,
	direccion NVARCHAR(30) NOT NULL,
	fechaBorrado DATETIME NULL
)
GO

IF OBJECT_ID('datosAtencion.Medico') IS NOT NULL
BEGIN
    DROP TABLE datosAtencion.Medico
    IF OBJECT_ID('datosAtencion.Medico') IS NOT NULL
	RAISERROR('Ocurrió un error al intentar eliminar la tabla datosAtencion.Medico.', 16, 1);
    ELSE
        PRINT 'Tabla datosAtencion.Medico eliminada correctamente.'
END
GO
CREATE TABLE datosAtencion.Medico
(
	id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	nombre NVARCHAR(20) NOT NULL,
	apellido NVARCHAR(20) NOT NULL,
	nroMatricula INT NOT NULL,
	idEspecialidad INT NOT NULL,
	fechaBorrado DATETIME NULL,
	CONSTRAINT FK_Especialidad FOREIGN KEY (idEspecialidad) REFERENCES datosAtencion.Especialidad(id)
)
GO

-- hay campos comentados a modo de simplificar el codigo ya que no necesitamos de dichos campos para esta parte del trabajo
IF OBJECT_ID('datosReserva.Reserva') IS NOT NULL
BEGIN
    DROP TABLE datosReserva.Reserva
    IF OBJECT_ID('datosReserva.Reserva') IS NOT NULL
	RAISERROR('Ocurrió un error al intentar eliminar la tabla datosReserva.Reserva.', 16, 1);
    ELSE
        PRINT 'Tabla datosReserva.Reserva eliminada correctamente.'
END
GO
CREATE TABLE datosReserva.Reserva
(
	id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	fecha DATE NOT NULL,
	hora TIME NOT NULL,
	idMedico INT NOT NULL,
	idEspecialidad INT NOT NULL,
	--idDireccionAtencion INT NOT NULL,
	idEstadoTurno INT NOT NULL,
	--idTipoTurno INT NOT NULL,
	idPaciente INT NOT NULL,
	CONSTRAINT FK_Especialidad FOREIGN KEY (idEspecialidad) REFERENCES datosAtencion.Especialidad(id),
	--CONSTRAINT FK_Direccion FOREIGN KEY (idDireccionAtencion) REFERENCES datosAtencion.SedeAtencion(id),
	CONSTRAINT FK_EstadoTurno FOREIGN KEY (idEstadoTurno) REFERENCES datosReserva.EstadoTurno(id),
	--CONSTRAINT FK_TipoTurno FOREIGN KEY (idTipoTurno) REFERENCES datosReserva.TipoTurno(id),
	CONSTRAINT FK_Paciente FOREIGN KEY (idPaciente) REFERENCES datosPaciente.Paciente(nroDocumento)
)
GO

-- Tabla creada para almacenar el JSON
IF OBJECT_ID('datosAtencion.Centro_Autorizaciones') IS NOT NULL
BEGIN
    DROP TABLE datosAtencion.Centro_Autorizaciones
    IF OBJECT_ID('datosAtencion.Centro_Autorizaciones') IS NOT NULL
	RAISERROR('Ocurrió un error al intentar eliminar la tabla datosAtencion.Centro_Autorizaciones.', 16, 1);
    ELSE
        PRINT 'Tabla datosAtencion.Centro_Autorizaciones eliminada correctamente.'
END
GO
CREATE TABLE datosAtencion.Centro_Autorizaciones (
    Area varchar(30),
    Estudio varchar(30),
    Prestador varchar(30),
    Programa varchar(50),
    [Porcentaje Cobertura] decimal(5,2),
    Costo money,
    [Requiere autorizacion] varchar(5) -- Usamos varchar para guardar 'True' o 'False'
);
GO

---------------------------------------------------------------------------------



--EXEC CargarDatosDesdeCSV_Prestadores -- NO ME FUNCIONA asi que cargo genericos

----------------------------------------------------------------------------------
-- Creacion de los SP para cargar los datos desde CSV

-- LUEGO DEJAR DOCUMENTACIÓN DEL BULK INSERT

-- Cosas a tener en cuenta: Este SP es para una carga de registros NUEVOS.
-- No admite la modificación de los ya ingresados.
-- Contemplamos asignar un usuario genérico al ser la primera vez que ingresa, con una contraseña 12345678
-- Luego el usuario deberá cambiar su contraseña


IF OBJECT_ID('CargarDatosDesdeCSV_Pacientes') IS NOT NULL
BEGIN
    DROP PROCEDURE CargarDatosDesdeCSV_Pacientes
    IF OBJECT_ID('CargarDatosDesdeCSV_Pacientes') IS NOT NULL
	RAISERROR('Ocurrió un error al intentar eliminar el procedure CargarDatosDesdeCSV_Pacientes.', 16, 1);
    ELSE
        PRINT 'Procedure CargarDatosDesdeCSV_Pacientes eliminada correctamente.'
END
GO
CREATE OR ALTER PROCEDURE CargarDatosDesdeCSV_Pacientes
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
	FROM 'C:\importar\Pacientes.csv'
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

	DROP TABLE #TempTable;
END
go

IF OBJECT_ID('CargarDatosDesdeCSV_Medicos') IS NOT NULL
BEGIN
    DROP PROCEDURE CargarDatosDesdeCSV_Medicos
    IF OBJECT_ID('CargarDatosDesdeCSV_Medicos') IS NOT NULL
	RAISERROR('Ocurrió un error al intentar eliminar el procedure CargarDatosDesdeCSV_Medicos.', 16, 1);
    ELSE
        PRINT 'Procedure CargarDatosDesdeCSV_Medicos eliminada correctamente.'
END
GO
CREATE OR ALTER PROCEDURE CargarDatosDesdeCSV_Medicos
AS
BEGIN
	--Borrar datos anteriores CONSULTAR! Lo agrego porque se supone que se manda uno nuevo actualizado cada mes
	delete from datosAtencion.Medico
	delete from datosAtencion.Especialidad

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
	FROM 'C:\importar\Medicos.csv'
	WITH (
		FIELDTERMINATOR = ';',  
		ROWTERMINATOR = '\n',
		FIRSTROW = 2
	);

	INSERT INTO datosAtencion.Especialidad (nombre)
	SELECT 
	DISTINCT(Especialidad) 
	FROM #tempTable T

	-- Realizar transformación de datos y luego insertar en la tabla de destino
	INSERT INTO datosAtencion.Medico(nombre, apellido, idEspecialidad, nroMatricula)
	SELECT 
		CAST(T.Nombre AS VARCHAR(20)),  
		CAST(T.Apellidos AS VARCHAR(20)),
		E.id,
		CAST(Numerodecolegiado as INT)
	FROM #TempTable T INNER JOIN datosAtencion.Especialidad E 
	ON T.Especialidad COLLATE Modern_Spanish_CI_AI = E.nombre COLLATE Modern_Spanish_CI_AI;


	-- Eliminar la tabla temporal después de su uso 
	DROP TABLE #TempTable;		
END 
go

IF OBJECT_ID('CargarDatosDesdeCSV_Sedes') IS NOT NULL
BEGIN
    DROP PROCEDURE CargarDatosDesdeCSV_Sedes
    IF OBJECT_ID('CargarDatosDesdeCSV_Sedes') IS NOT NULL
	RAISERROR('Ocurrió un error al intentar eliminar el procedure CargarDatosDesdeCSV_Sedes.', 16, 1);
    ELSE
        PRINT 'Procedure CargarDatosDesdeCSV_Sedes eliminada correctamente.'
END
GO
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
	FROM 'C:\importar\Sedes.csv'
	WITH (
		FIELDTERMINATOR = ';',  
		ROWTERMINATOR = '\n',
		FIRSTROW = 2
		--,ERRORFILE = 'C:\Dataset\ErroresSedes.csv'
	);
		-- Realizar transformación de datos y luego insertar en la tabla de destino
	INSERT INTO datosAtencion.SedeAtencion(nombre, direccion, fechaBorrado)
	SELECT 
		CAST(T.nombre AS NVARCHAR(30)),  
		CAST(T.direccion AS NVARCHAR(30)),
		NULL
	FROM #TempTable T 

	--SELECT * FROM #TempTable

	-- Eliminar la tabla temporal después de su uso 
	DROP TABLE #TempTable;
END 
go

IF OBJECT_ID('CargarDatosDesdeCSV_Prestadores') IS NOT NULL
BEGIN
    DROP PROCEDURE CargarDatosDesdeCSV_Prestadores
    IF OBJECT_ID('CargarDatosDesdeCSV_Prestadores') IS NOT NULL
	RAISERROR('Ocurrió un error al intentar eliminar el procedure CargarDatosDesdeCSV_Prestadores.', 16, 1);
    ELSE
        PRINT 'Procedure CargarDatosDesdeCSV_Prestadores eliminada correctamente.'
END
GO
CREATE OR ALTER PROCEDURE CargarDatosDesdeCSV_Prestadores
AS
BEGIN
	-- Crear una tabla temporal con la misma estructura que el archivo CSV
	CREATE TABLE #TempTable
	(
		nombre NVARCHAR(40) NOT NULL,
		tipoPlan NVARCHAR(40) NOT NULL
	);

	-- Cargar datos desde el archivo CSV en la tabla temporal
	BULK INSERT #TempTable
	FROM 'C:\importar\Prestador.csv'
	WITH (
		FIELDTERMINATOR = ';',  
		ROWTERMINATOR = '\n',
		FIRSTROW = 2
	);
	
	-- Realizar transformación de datos y luego insertar en la tabla de destino
	INSERT INTO datosPaciente.Prestador(nombre, tipoPlan, fechaBorrado)
	SELECT 
		CAST(T.nombre AS NVARCHAR(30)),  
		CAST(REPLACE(T.tipoPlan, ';;', '') AS NVARCHAR(30)),
		NULL
	FROM #TempTable T 


	-- Eliminar la tabla temporal después de su uso 
	DROP TABLE #TempTable;	--	lo comente para poder ver como se guardaban, despues descomentar
END 
go

-----------------------------------------------------------------------------------
-- Importar contenido del archivo JSON a nuestra tabla datosAtencion.Centro_Autorizaciones

-- Vaciamos la tabla
IF OBJECT_ID('CargarDatosDesdeJSON') IS NOT NULL
BEGIN
    DROP PROCEDURE CargarDatosDesdeJSON
    IF OBJECT_ID('CargarDatosDesdeJSON') IS NOT NULL
	RAISERROR('Ocurrió un error al intentar eliminar el procedure CargarDatosDesdeJSON.', 16, 1);
    ELSE
        PRINT 'Procedure CargarDatosDesdeJSON eliminada correctamente.'
END
GO
CREATE OR ALTER PROCEDURE CargarDatosDesdeJSON
AS
BEGIN
	DELETE FROM datosAtencion.Centro_Autorizaciones

	-- Guardamos nuestro json en una variable
	DECLARE @jsonEstudiosClinicos NVARCHAR(MAX);
	SET @jsonEstudiosClinicos = (
		SELECT * 
		FROM OPENROWSET (BULK 'C:\importar\Centro_Autorizaciones.Estudios clinicos.json', SINGLE_CLOB) as JsonFile
	)
	-- Insertar los resultados de la consulta en la tabla creada
	INSERT INTO datosAtencion.Centro_Autorizaciones (Area, Estudio, Prestador, Programa, [Porcentaje Cobertura], Costo, [Requiere autorizacion])
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
END
GO
--select * from datosAtencion.Centro_Autorizaciones

-----------------------------------------------------------------------------------
-- Generar archivo XML detallando los turnos atendidos para informar a la Obra Social
IF OBJECT_ID('GenerarInformeTurnos') IS NOT NULL
BEGIN
    DROP PROCEDURE GenerarInformeTurnos
    IF OBJECT_ID('GenerarInformeTurnos') IS NOT NULL
	RAISERROR('Ocurrió un error al intentar eliminar el procedure GenerarInformeTurnos.', 16, 1);
    ELSE
        PRINT 'Procedure GenerarInformeTurnos eliminada correctamente.'
END
GO
CREATE OR ALTER PROCEDURE GenerarInformeTurnos(
    @NombreObraSocial NVARCHAR(255),
    @FechaInicio DATE,
    @FechaFin DATE
)
AS
BEGIN
    SELECT 
        P.Apellido AS 'ApellidoPaciente',
        P.Nombre AS 'NombrePaciente',
        P.nroDocumento AS 'DNIPaciente',
        r.fecha, 
        r.hora, 
        m.nombre AS 'NombreProfesional', 
        m.nroMatricula AS 'MatriculaProfesional', 
        e.nombre AS especialidad
    FROM datosReserva.Reserva AS r
    INNER JOIN datosAtencion.Medico AS m ON r.idMedico = m.id
    INNER JOIN datosAtencion.Especialidad AS e ON r.idEspecialidad = e.id
    INNER JOIN datosPaciente.Paciente AS P ON r.idPaciente = P.nroDocumento
    WHERE r.idPaciente IN (
        SELECT P.nroDocumento 
        FROM datosPaciente.Paciente AS P
        INNER JOIN datosPaciente.Cobertura AS C ON P.idCobertura = C.id
        INNER JOIN datosPaciente.Prestador AS PR ON C.idPrestador = PR.id
        WHERE PR.nombre = @NombreObraSocial
    )
    AND r.idEstadoTurno = 1
	AND r.fecha BETWEEN @FechaInicio AND @FechaFin
    FOR xml raw('Registro'), elements, root('XML');
END
GO
--Esto devuelve toda 1 fila con los datos en formato xml, si los clickeas te abre una pestaña nueva y ahi se pueden guardar

-----------------------------------------------------------------------------------
-- Creo un usuario generico, un estudio genérico, una cobertura generica y un prestador genérico 






