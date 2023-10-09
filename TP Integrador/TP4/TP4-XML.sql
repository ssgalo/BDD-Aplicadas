use ClinicaCureSA

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
	id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	imagenCredencial NVARCHAR(40) NOT NULL,
	nroSocio INT NOT NULL,
	fechaRegistro DATETIME NOT NULL,
	idPrestador INT NOT NULL,
	fechaBorrado DATETIME NULL,
	CONSTRAINT FK_Prestador FOREIGN KEY (idPrestador) REFERENCES datosPaciente.Prestador(id)
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
	fechaRegistro DATE NULL, --NOT NULL,
	fechaActualizacion DATETIME NULL,
	--idUsuario INT NOT NULL,
	--idEstudio INT NOT NULL,
	idCobertura INT NOT NULL,
	--idDomicilio INT NOT NULL,
	idUsuarioActualizacion INT NULL,
	fechaBorrado DATETIME NULL,
	CONSTRAINT PK_Paciente PRIMARY KEY (nroDocumento),
	--CONSTRAINT FK_Usuario FOREIGN KEY (idUsuario) REFERENCES datosPaciente.Usuario(id),
	--CONSTRAINT FK_Estudio FOREIGN KEY (idEstudio) REFERENCES datosPaciente.Estudio(id),
	CONSTRAINT FK_Cobertura FOREIGN KEY (idCobertura) REFERENCES datosPaciente.Cobertura(id)
	--CONSTRAINT FK_Domicilio FOREIGN KEY (idDomicilio) REFERENCES datosPaciente.Domicilio(id)
)
GO

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


-- Cargo las tablas con datos aleatorios 

INSERT INTO datosPaciente.Prestador(nombre, tipoPlan, fechaBorrado) VALUES
	('Union Personal', 'Classic', NULL),
	('Union Personal', 'Familiar', NULL),
	('Osecac', 'Pmo', NULL),
	('Osecac', 'Azul', NULL),
	('Medicus', 'Family', NULL),
	('Medicus', 'Plan Mujer', NULL),
	('OSDE', 'OSDE 410', NULL)

INSERT INTO datosPaciente.Cobertura (imagenCredencial, nroSocio, fechaRegistro, idPrestador, fechaBorrado)
VALUES
    ('imagen1.jpg', 0101, '2023-10-09 08:00:00', 1, NULL),
    ('imagen2.jpg', 0202, '2023-10-09 09:30:00', 2, NULL),
    ('imagen3.jpg', 0303, '2023-10-09 10:45:00', 3, NULL),
	('imagen3.jpg', 0404, '2023-10-09 11:45:00', 6, NULL),
	('imagen3.jpg', 0505, '2023-10-09 12:45:00', 7, NULL);

INSERT INTO datosPaciente.Paciente (nombre,apellido,apellidoMaterno,fechaNacimiento,tipoDocumento,nroDocumento,sexo,nacionalidad,fotoPerfil,mail,telefonoFijo,idCobertura)
VALUES

    ('Juan','Pérez','López','1990-05-15','DNI',12345678,'Masculino','Argentino','perfil.jpg','juan.perez@email.com','123-456-7890',1),
	('María', 'González', 'Rodríguez', '1985-07-20', 'DNI', 98765432, 'Femenino', 'Mexicana', 'perfil2.jpg', 'maria.gonzalez@email.com', '456-789-0123', 2),
	('Luis', 'Martínez', 'Pérez', '1978-03-10', 'Pasaporte', 543210, 'Masculino', 'Español', 'perfil3.jpg', 'luis.martinez@email.com', '789-012-3456', 5);

INSERT INTO datosReserva.EstadoTurno (nombreEstado, fechaBorrado)
VALUES
    ('Atendido', NULL),
	('Ausente', NULL),
    ('Cancelado', NULL);

INSERT INTO datosAtencion.Especialidad (nombre)
VALUES
    ('Pediatría'),
    ('Ginecología'),
    ('Cardiología'),
    ('Dermatología');

INSERT INTO datosAtencion.Medico (nombre, apellido, nroMatricula, idEspecialidad, fechaBorrado)
VALUES
    ('Juan', 'Pérez', 12345, 1, NULL),
    ('María', 'González', 54321, 2, NULL),
    ('Luis', 'Martínez', 67890, 3, NULL),
    ('Ana', 'Rodríguez', 98765, 4, NULL);

INSERT INTO datosReserva.Reserva (fecha, hora, idMedico, idEspecialidad, idEstadoTurno, idPaciente)
VALUES
    ('2023-10-09', '09:00:00', 1, 1, 2, 543210),
    ('2023-10-10', '14:30:00', 2, 2, 1, 12345678),
    ('2023-10-11', '11:15:00', 3, 3, 2, 98765432),
    ('2023-10-12', '16:45:00', 4, 4, 3, 98765432);


SELECT * FROM datosPaciente.Prestador -- Hay que cargar los datos del csv por el SP que creamos antes
SELECT * FROM datosPaciente.Cobertura
SELECT * FROM datosPaciente.Paciente -- Hay que cargar los datos del csv con el SP que creamos antes
SELECT * FROM datosReserva.Reserva
SELECT * FROM datosAtencion.Medico -- Hay que cargar los datos del csv con el SP que creamos antes
SELECT * FROM datosAtencion.Especialidad	--Hay que cargar la tabla con los nombres de especialidad que se relacionan los excel, ahora son aletaroios 
SELECT * FROM datosReserva.EstadoTurno

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


EXEC GenerarInformeTurnos 'Union Personal', '2023-01-01', '2023-11-30';

--Esto devuelve toda 1 fila con los datos en formato xml, si los clickeas te abre una pestaña nueva y ahi se pueden guardar




-- Teoria de como mostrar el xml

-- for xml auto - automaticamente nos da formato html
-- for xml raw, elements, root - nos da un formato mas cercano a xml
-- for xml raw(''Registro), elements, root('XML')

DECLARE @XmlData XML;

-- Asigna el resultado de la consulta a la variable @XmlData
SELECT @XmlData = (
    SELECT
		ID AS 'Elemento1',
		Nombre AS 'Elemento2',
		Edad AS 'Elemento3'
    FROM TablaAleatoria
    FOR XML RAW('Fila'), ROOT('Datos'), ELEMENTS
);


