create database pruebaCSV2

use pruebaCSV2

GO
CREATE SCHEMA datosPaciente
GO
CREATE SCHEMA datosReserva
GO
CREATE SCHEMA datosAtencion

GO

CREATE TABLE datosPaciente.Usuario		
(
	id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	contraseña CHAR(8) NOT NULL,
	fechaCreacion DATETIME NOT NULL,
	fechaBorrado DATETIME NULL
) 
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

CREATE TABLE datosPaciente.Prestador	
(
	id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	nombre NVARCHAR(20) NOT NULL,
	tipoPlan NVARCHAR(10) NOT NULL,
	fechaBorrado DATETIME NULL
)
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

CREATE TABLE datosReserva.EstadoTurno
(
	id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	nombreEstado CHAR(9) NOT NULL,
	fechaBorrado DATETIME NULL
)
GO

CREATE TABLE datosAtencion.Especialidad
(
	id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	nombre VARCHAR(20) NOT NULL
)
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

CREATE TABLE datosReserva.Reserva --hay campos comentados a modo de simplificar el codigo ya que no necesitamos de dichos campos para esta parte del trabajo 
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
CREATE TABLE datosAtencion.Centro_Autorizaciones (
    Area varchar(30),
    Estudio varchar(30),
    Prestador varchar(30),
    Programa varchar(50),
    [Porcentaje Cobertura] float,
    Costo float,
    [Requiere autorizacion] varchar(5) -- Usamos varchar para guardar 'True' o 'False'
);
go

---------------------------------------------------------------------------------
-- Carga de datos en las tablas: 
SELECT * FROM datosPaciente.Prestador -- No me funciona el SP
SELECT * FROM datosPaciente.Cobertura
SELECT * FROM datosPaciente.Paciente -- 
SELECT * FROM datosAtencion.Especialidad	
SELECT * FROM datosAtencion.Medico
SELECT * FROM datosReserva.EstadoTurno
SELECT * FROM datosReserva.Reserva --FALTA


--EXEC CargarDatosDesdeCSV_Prestadores -- NO ME FUNCIONA asiq cargo genericos
INSERT INTO datosPaciente.Prestador(nombre, tipoPlan, fechaBorrado) VALUES
	('Union Personal', 'Classic', NULL),
	('Union Personal', 'Familiar', NULL),
	('Osecac', 'Pmo', NULL),
	('Osecac', 'Azul', NULL),
	('Medicus', 'Family', NULL),
	('Medicus', 'Plan Mujer', NULL),
	('OSDE', 'OSDE 410', NULL)

INSERT INTO datosPaciente.Cobertura (imagenCredencial, nroSocio, fechaRegistro, idPrestador, fechaBorrado) -- coberturas genericas
VALUES
    ('imagen1.jpg', 0101, '2023-10-09 08:00:00', 1, NULL),
    ('imagen2.jpg', 0202, '2023-10-09 09:30:00', 2, NULL),
    ('imagen3.jpg', 0303, '2023-10-09 10:45:00', 3, NULL),
	('imagen3.jpg', 0404, '2023-10-09 11:45:00', 6, NULL),
	('imagen3.jpg', 0505, '2023-10-09 12:45:00', 7, NULL);
go

EXEC datosPaciente.CargarDatosDesdeCSV_Pacientes -- carga las listas: Paciente y Domicilio
go


INSERT INTO datosAtencion.Especialidad (nombre)	--tal cual los que figuran en la tabla de medicos
VALUES
    ('CLINICA MEDICA'),
    ('MEDICINA FAMILIAR'),
    ('ALERGIA'),
    ('CARDIOLOGIA'),
	('DERMATOLOGIA'),
	('ENDOCRINLOGIA'),
	('FONOAUDIOLOGIA'),
	('GASTROENTEROLOGIA'),
	('GINECOLOGIA'),
	('HEPATOLOGÍA'),
	('KINESIOLOGIA'),
	('NEUROLOGIA'),
	('NUTRICION'),
	('OBSTETRICIA'),
	('OFTALMOLOGIA'),
	('TRAUMATOLOGIA'),
	('UROLOGIA');
go

EXEC CargarDatosDesdeCSV_Medicos
go

INSERT INTO datosReserva.EstadoTurno (nombreEstado, fechaBorrado) -- tal cual indica el der
VALUES
    ('Atendido', NULL),
	('Ausente', NULL),
    ('Cancelado', NULL);
go

INSERT INTO datosReserva.Reserva (fecha, hora, idMedico, idEspecialidad, idEstadoTurno, idPaciente)	-- reservas genericas
VALUES
    ('2023-10-09', '09:00:00', 1, 1, 2, 25111003),
    ('2023-10-10', '14:30:00', 2, 2, 1, 25111004),
    ('2023-10-11', '11:15:00', 3, 3, 2, 25111015),
    ('2023-10-12', '16:45:00', 4, 4, 3, 25111023);
go


-----------------------------------------------------------------------------------
-- Creo un usuario generico, un estudio genérico, una cobertura generica y un prestador genérico 

INSERT INTO datosPaciente.Usuario (contraseña, fechaCreacion, fechaBorrado)
VALUES
('12345678', GETDATE(), NULL)
SELECT * FROM datosPaciente.Usuario

INSERT INTO datosPaciente.Estudio (fecha, nombre, autorizado, linkDocumentoResultado, imagenResultado, fechaBorrado)
VALUES
(GETDATE(), 'Generico', 0, 'Generico', 'Generico', NULL) 

----------------------------------------------------------------------------------
-- Creacion de los SP para cargar los datos desde CSV

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
	FROM 'C:\Dataset\Pacientes.csv'
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
go


CREATE OR ALTER PROCEDURE CargarDatosDesdeCSV_Medicos
AS
BEGIN
	--Borrar datos anteriores CONSULTAR! Lo agrego porque se supone que se manda uno nuevo actualizado cada mes
	delete from datosAtencion.Medico

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
	FROM 'C:\Dataset\Medicos.csv'
	WITH (
		FIELDTERMINATOR = ';',  
		ROWTERMINATOR = '\n',
		FIRSTROW = 2
	);

	
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
go

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
	BULK INSERT #TempTable
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
go

-----------------------------------------------------------------------------------
-- Importar contenido del archivo JSON a nuestra tabla datosAtencion.Centro_Autorizaciones

-- Vaciamos la tabla
DELETE FROM datosAtencion.Centro_Autorizaciones
go

-- Guardamos nuestro json en una variable
DECLARE @jsonEstudiosClinicos NVARCHAR(MAX);
SET @jsonEstudiosClinicos = (
    SELECT * 
    FROM OPENROWSET (BULK 'C:\Users\apoll\OneDrive\Escritorio\Dataset\Centro_Autorizaciones.Estudios clinicos.json', SINGLE_CLOB) as JsonFile
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
go

select * from datosAtencion.Centro_Autorizaciones

-----------------------------------------------------------------------------------
-- Generar archivo XML detallando los turnos atendidos para informar a la Obra Social

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

EXEC GenerarInformeTurnos 'Union Personal', '2023-01-01', '2023-11-30';

--Esto devuelve toda 1 fila con los datos en formato xml, si los clickeas te abre una pestaña nueva y ahi se pueden guardar

