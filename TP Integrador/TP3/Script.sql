---- COMIENZO CREACION DE BASE DE DATOS Y ESQUEMAS ----
CREATE DATABASE ClinicaCureSA
GO

USE ClinicaCureSA
GO

CREATE SCHEMA datosPaciente
GO
CREATE SCHEMA datosReserva
GO
CREATE SCHEMA datosAtencion

GO
---- FIN CREACION DE BASE DE DATOS Y ESQUEMAS ----

---- COMIENZO CREACION DE TABLAS ----
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
	nombre NVARCHAR(40) NOT NULL,
	tipoPlan NVARCHAR(40) NOT NULL,
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
	fechaBorrado DATETIME NULL,
	CONSTRAINT PK_Paciente PRIMARY KEY (nroDocumento),
	CONSTRAINT FK_Usuario FOREIGN KEY (idUsuario) REFERENCES datosPaciente.Usuario(id),
	CONSTRAINT FK_Estudio FOREIGN KEY (idEstudio) REFERENCES datosPaciente.Estudio(id),
	CONSTRAINT FK_Cobertura FOREIGN KEY (idCobertura) REFERENCES datosPaciente.Cobertura(id),
	CONSTRAINT FK_Domicilio FOREIGN KEY (idDomicilio) REFERENCES datosPaciente.Domicilio(id)
)
GO

CREATE TABLE datosAtencion.Especialidad
(
	id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	nombre VARCHAR(20) NOT NULL
)
GO

CREATE TABLE datosReserva.EstadoTurno
(
	id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	nombreEstado CHAR(9) NOT NULL,
	fechaBorrado DATETIME NULL
)
GO

CREATE TABLE datosReserva.TipoTurno
(
	id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	nombre VARCHAR(10) NOT NULL,
	fechaBorrado DATETIME NULL
)
GO

CREATE TABLE datosAtencion.SedeAtencion
(
	id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	nombre NVARCHAR(20) NOT NULL,
	direccion NVARCHAR(30) NOT NULL,
	fechaBorrado DATETIME NULL
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

CREATE TABLE datosAtencion.DiasXSede
(
	idSede INT NOT NULL,
	idMedico INT NOT NULL,
	diaSemana NVARCHAR(10) NOT NULL,
	horaInicio TIME NOT NULL,
	horaFin TIME NOT NULL,
	CONSTRAINT PK_DiasXSede PRIMARY KEY (idSede, idMedico, diaSemana),
	CONSTRAINT FK_Sede FOREIGN KEY (idSede) REFERENCES datosAtencion.SedeAtencion(id),
	CONSTRAINT FK_Medico FOREIGN KEY (idMedico) REFERENCES datosAtencion.Medico(id)
)
GO

CREATE TABLE datosReserva.Reserva
(
	id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	fecha DATE NOT NULL,
	hora TIME NOT NULL,
	idMedico INT NOT NULL,
	idEspecialidad INT NOT NULL,
	idDireccionAtencion INT NOT NULL,
	idEstadoTurno INT NOT NULL,
	idTipoTurno INT NOT NULL,
	idPaciente INT NOT NULL,
	CONSTRAINT FK_Especialidad FOREIGN KEY (idEspecialidad) REFERENCES datosAtencion.Especialidad(id),
	CONSTRAINT FK_Direccion FOREIGN KEY (idDireccionAtencion) REFERENCES datosAtencion.SedeAtencion(id),
	CONSTRAINT FK_EstadoTurno FOREIGN KEY (idEstadoTurno) REFERENCES datosReserva.EstadoTurno(id),
	CONSTRAINT FK_TipoTurno FOREIGN KEY (idTipoTurno) REFERENCES datosReserva.TipoTurno(id),
	CONSTRAINT FK_Paciente FOREIGN KEY (idPaciente) REFERENCES datosPaciente.Paciente(nroDocumento)
)
GO
---- FIN CREACION DE TABLAS ----

---- COMIENZO DE STORED PROCEDURES DE USUARIO ----
CREATE PROCEDURE datosPaciente.InsertarUsuario
	@contraseña CHAR(8)
AS
BEGIN
	IF (@contraseña is null or @contraseña = ' ') 
	BEGIN
		RAISERROR('Los parametros no pueden ser nulos o vacíos.', 16, 1);
		RETURN;
	END

	IF (LEN(@contraseña) < 4 OR LEN(@contraseña) > 8 )
	BEGIN
		RAISERROR('La contraseña debe tener entre 4 y 8 caracteres.', 16, 1);
		RETURN;
	END

	INSERT INTO datosPaciente.Usuario (contraseña, fechaCreacion, fechaBorrado)
	VALUES (@contraseña,GETDATE() , NULL);

	IF(@@ERROR = 0)
		PRINT 'Usuario insertado correctamente';
	ELSE
		PRINT 'Ocurrió un error al insertar un registro en Usuario'
END
GO

CREATE PROCEDURE datosPaciente.ModificarUsuario
(
	@id INT,
	@nuevaContraseña CHAR(8)
)
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM datosPaciente.Usuario WHERE id=@id)
	BEGIN
		PRINT 'El usuario con ID ' + CAST(@id AS VARCHAR) + ' no existe'
		RETURN;
	END

	UPDATE datosPaciente.Usuario
	SET contraseña = @nuevaContraseña
	WHERE id = @id

	IF(@@ERROR = 0)
		PRINT 'El usuario con ID ' + cast(@id AS VARCHAR) + ' ha sido modificado correctamente'
	ELSE
		PRINT 'Ocurrió un error al modificar usuario con ID ' + cast(@id AS VARCHAR)
END
GO

CREATE PROCEDURE datosPaciente.EliminarUsuario
	@id INT
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM datosPaciente.Usuario WHERE id=@id)
	BEGIN
		PRINT 'El usuario con ID ' + CAST(@id AS VARCHAR) + ' no existe';
		RETURN;
	END

	DECLARE @fechaBorrado DATETIME = GETDATE()

	UPDATE datosPaciente.Usuario
	SET fechaBorrado = @fechaBorrado
	WHERE id = @id

	IF(@@ERROR = 0)
		PRINT 'El usuario con ID ' + cast(@id AS VARCHAR) + ' ha sido borrado correctamente';
	ELSE
		PRINT 'Ocurrió un error al intentar eliminar usuario con ID ' + cast(@id AS VARCHAR)
END
GO
---- FIN DE STORED PROCEDURES DE USUARIO ----

---- COMIENZO DE STORED PROCEDURES DE DOMICILIO ----
CREATE PROCEDURE datosPaciente.InsertarDomicilio
(
	@calleYNro NVARCHAR(15),
	@piso INT,
	@departamento VARCHAR(10), 
	@codigoPostal VARCHAR(10),
	@pais VARCHAR(15),
	@provincia VARCHAR(15),
	@localidad VARCHAR(15)
)
AS
BEGIN
	IF (@calleYNro is null or @calleYNro = ' '
	 or @piso is null or @departamento is null or @departamento = ' '
	 or @codigoPostal is null or @codigoPostal = ' ' or @pais is null
	 or @pais = ' ' or @provincia is null or @provincia = ' '
	 or @localidad is null or @localidad = ' ') 
	BEGIN
		RAISERROR('Los parametros no pueden ser nulos o vacíos.', 16, 1);
		RETURN;
	END

	INSERT INTO datosPaciente.Domicilio (calleYNro, piso, departamento, codigoPostal, pais, provincia, localidad)
	VALUES (@calleYNro, @piso, @departamento, @codigoPostal, @pais, @provincia, @localidad);

	IF (@@ERROR = 0)
		PRINT 'Domicilio insertado correctamente';
	ELSE
		PRINT 'Ocurrió un error al intentar insertar el registro en Domicilio'
END
GO

CREATE PROCEDURE datosPaciente.ModificarDomi
    @id INT,
	@nuevaCalleYNro NVARCHAR(15) = NULL,
	@nuevoPiso INT = NULL,
	@nuevoDepartamento VARCHAR(10) = NULL, 
	@nuevoCodigoPostal VARCHAR(10) = NULL,
	@nuevoPais VARCHAR(15) = NULL,
	@nuevaProvincia VARCHAR(15) = NULL,
	@nuevaLocalidad VARCHAR(15) = NULL
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM datosPaciente.Domicilio WHERE id = @id)
    BEGIN
        PRINT 'El domicilio con ID ' + CAST(@id AS VARCHAR) + ' no existe.';
        RETURN;
    END

    UPDATE datosPaciente.Domicilio
    SET 
		calleYNro = ISNULL(@nuevaCalleYNro, calleYNro),
        piso = ISNULL(@nuevoPiso, piso),
        departamento = ISNULL(@nuevoDepartamento, departamento),
        codigoPostal = ISNULL(@nuevoCodigoPostal,codigoPostal),
        pais = ISNULL(@nuevoPais, pais),
        provincia = ISNULL(@nuevaProvincia, provincia),
        localidad = ISNULL(@nuevaLocalidad, localidad)
    WHERE id = @id;

	IF(@@ERROR = 0)
		PRINT 'Domicilio con ID ' + CAST(@id AS VARCHAR) + ' modificados correctamente.';
	ELSE
		PRINT 'Ocurrió un error al modificar Domicilio con ID ' + cast(@id AS VARCHAR)
END;
GO

CREATE PROCEDURE datosPaciente.EliminarDomicilio
	@id INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM datosPaciente.Domicilio WHERE id = @id)
    BEGIN
        PRINT 'El domicilio con ID ' + CAST(@id AS VARCHAR) + ' no existe.';
        RETURN;
    END

	DELETE FROM datosPaciente.Domicilio WHERE id=@id;

	IF(@@ERROR = 0)
		PRINT 'El domicilio con ID ' + cast(@id as VARCHAR) + ' ha sido eliminado correctamente';
	ELSE
		PRINT 'Ocurrió un error al intentar eliminar Domicilio con ID ' + cast(@id AS VARCHAR)	
END
GO
---- FIN DE STORED PROCEDURES DE DOMICILIO ----

---- COMIENZO DE STORED PROCEDURES DE PRESTADOR ----
CREATE PROCEDURE datosPaciente.InsertarPrestador
(
    @nombre VARCHAR(20),
    @tipoPlan VARCHAR(10)
)
AS
BEGIN
	IF (@nombre IS NULL or @nombre = ''
	 OR @tipoPlan IS NULL or @tipoPlan = '') 
	BEGIN
		RAISERROR('Los parametros no pueden ser nulos o vacíos.', 16, 1);
		RETURN;
	END

    INSERT INTO datosPaciente.Prestador (nombre, tipoPlan)
    VALUES (@nombre, @tipoPlan);

	IF(@@ERROR = 0)
		PRINT 'Prestador cargado correctamente.';
	ELSE
		PRINT 'Ocurrió un error al intentar insertar Prestador';
END;
GO

CREATE PROCEDURE datosPaciente.ModificarPrestador
(
    @id INT,
    @nuevoNombre VARCHAR(20) = NULL,
    @nuevoTipoPlan VARCHAR(10) = NULL
)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM datosPaciente.Prestador WHERE id = @id)
    BEGIN
        PRINT 'El prestador con ID ' + CAST(@id AS VARCHAR) + ' no existe.';
        RETURN;
    END

    UPDATE datosPaciente.Prestador
    SET
        nombre = ISNULL(@nuevoNombre, nombre),
        tipoPlan = ISNULL(@nuevoTipoPlan, tipoPlan)
    WHERE id = @id;

	IF(@@ERROR = 0)
		PRINT 'Prestador con ID ' + CAST(@id AS VARCHAR) + ' modificado correctamente.';
	ELSE
		PRINT 'Ocurrió un error al intentar modificar Prestador con ID ' + CAST(@id AS VARCHAR)
END
GO

CREATE PROCEDURE datosPaciente.EliminarPrestador
    @id INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM datosPaciente.Prestador WHERE id = @id)
    BEGIN
        PRINT 'El prestador con ID ' + CAST(@id AS VARCHAR) + ' no existe.';
        RETURN;
    END

	DECLARE @fechaBorrado DATETIME = GETDATE()

    UPDATE datosPaciente.Prestador
	SET fechaBorrado = @fechaBorrado
	WHERE id = @id;

	IF(@@ERROR = 0)
		PRINT 'Prestador con ID ' + CAST(@id AS VARCHAR) + ' borrado correctamente.';
	ELSE
		PRINT 'Ocurrió un error al intentar borrar el Prestador con ID ' + CAST(@id AS VARCHAR)
END;
GO
---- FIN DE STORED PROCEDURES DE PRESTADOR ----

---- COMIENZO DE STORED PROCEDURES DE PRESTADOR ----
CREATE OR ALTER PROCEDURE datosPaciente.InsertarCobertura
(
    @imagenCredencial VARCHAR(40),
    @nroSocio INT,
    @fechaRegistro DATE,
    @idPrestador INT
)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM datosPaciente.Prestador WHERE id = @idPrestador)
    BEGIN
        PRINT 'El prestador con ID ' + CAST(@idPrestador AS VARCHAR) + ' no existe.';
        RETURN;
    END

    INSERT INTO datosPaciente.Cobertura (imagenCredencial, nroSocio, fechaRegistro, idPrestador)
    VALUES (@imagenCredencial, @nroSocio, @fechaRegistro, @idPrestador);

	IF(@@ERROR = 0)
		PRINT 'Registro de Cobertura insertado correctamente.';
	ELSE
		PRINT 'Ocurrió un error al intentar insertar un registro en Cobertura';
END
GO

CREATE PROCEDURE datosPaciente.ModificarCobertura
(
    @id INT,
    @nuevaImagenCredencial VARCHAR(40) = NULL,
    @nuevoNroSocio INT = NULL,
    @nuevaFechaRegistro DATE = NULL,
    @nuevoIdPrestador INT = NULL
)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM datosPaciente.Cobertura WHERE id = @id)
    BEGIN
        PRINT 'La cobertura con ID ' + CAST(@id AS VARCHAR) + ' no existe.';
        RETURN;
    END

    IF (@nuevoIdPrestador IS NOT NULL 
	AND NOT EXISTS (SELECT 1 FROM datosPaciente.Prestador WHERE id = @nuevoIdPrestador))
    BEGIN
        PRINT 'El nuevo prestador con ID ' + CAST(@nuevoIdPrestador AS VARCHAR) + ' no existe.';
        RETURN;
    END

    UPDATE datosPaciente.Cobertura
    SET
        imagenCredencial = ISNULL(@nuevaImagenCredencial, imagenCredencial),
        nroSocio = ISNULL(@nuevoNroSocio, nroSocio),
        fechaRegistro = ISNULL(@nuevaFechaRegistro, fechaRegistro),
        idPrestador = ISNULL(@nuevoIdPrestador, idPrestador)
    WHERE id = @id;

	IF(@@ERROR = 0)
		PRINT 'Cobertura con ID ' + CAST(@id AS VARCHAR) + ' modificada correctamente.';
	ELSE
		PRINT 'Ocurrió un error al intentar modificar Cobertura con ID ' + CAST(@id AS VARCHAR)
END;
GO

CREATE PROCEDURE datosPaciente.EliminarCobertura
    @idPrestador INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM datosPaciente.Prestador WHERE id = @idPrestador)
    BEGIN
        PRINT 'El prestador con ID ' + CAST(@idPrestador AS VARCHAR) + ' no existe.';
        RETURN;
    END

    UPDATE datosPaciente.Cobertura
	SET fechaBorrado = GETDATE()
	WHERE id = @idPrestador;

	IF(@@ERROR = 0)
		PRINT 'Coberturas del Prestador con ID ' + CAST(@idPrestador AS VARCHAR) + ' eliminadas correctamente.';
	ELSE
		PRINT 'Ocurrió un error al intentar eliminar Coberturas del Prestador con ID ' + CAST(@idPrestador AS VARCHAR)
END;
GO
---- FIN DE STORED PROCEDURES DE PRESTADOR ----

---- COMIENZO DE STORED PROCEDURES DE ESPECIALIDAD ----
CREATE PROCEDURE datosAtencion.InsertarEspecialidad
	@nombreEspecialidad varchar(20)
AS
BEGIN
	IF @nombreEspecialidad IS NULL OR LEN(@nombreEspecialidad) = 0 OR @nombreEspecialidad = ' '
	BEGIN
		RAISERROR('Los parametros no pueden ser nulos o vacíos.', 16, 1);
		RETURN;
	END

	IF EXISTS (SELECT 1 FROM datosAtencion.Especialidad WHERE nombre = @nombreEspecialidad)
	BEGIN
		RAISERROR('La especialidad ya existe', 16, 1);
		RETURN;
	END

	INSERT INTO datosAtencion.Especialidad(nombre)
	VALUES (@nombreEspecialidad)

	IF(@@ERROR = 0)
		PRINT 'Especialidad ingresada correctamente.';
	ELSE
		PRINT 'Ocurrió un error al intentar insertar un registro en Especialidad'
END
GO

CREATE PROCEDURE datosAtencion.ModificarEspecialidad
(
    @idEspecialidad INT,
    @NuevoNombre VARCHAR(20)
)
AS
BEGIN
    IF (NOT EXISTS (SELECT 1 FROM datosAtencion.Especialidad WHERE ID = @idEspecialidad))
    BEGIN
        PRINT 'La especialidad especificada no existe.';
        RETURN; 
    END

    IF (LEN(@NuevoNombre) = 0)
    BEGIN
        PRINT 'El nuevo nombre no puede estar vacío.';
        RETURN; 
    END

    IF (EXISTS (SELECT 1 FROM datosAtencion.Especialidad WHERE Nombre = @NuevoNombre AND ID != @idEspecialidad))
    BEGIN
        PRINT 'Ya existe la especialidad por la que queres modificar.';
        RETURN;
    END

    UPDATE datosAtencion.Especialidad
    SET Nombre = @NuevoNombre
    WHERE ID = @idEspecialidad;

	IF(@@ERROR = 0)
		PRINT 'Especialidad con ID ' + CAST(@idEspecialidad AS VARCHAR) + ' actualizada correctamente.';
	ELSE
		PRINT 'Ocurrió un error al intentar modificar Especialidad con ID ' + CAST(@idEspecialidad AS VARCHAR)
END
GO

CREATE PROCEDURE datosAtencion.EliminarEspecialidad
    @idEspecialidad INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM datosAtencion.Especialidad WHERE ID = @idEspecialidad)
    BEGIN
        PRINT 'La EspecialidadID especificada no existe.';
        RETURN;
    END

    DELETE FROM datosAtencion.Especialidad WHERE ID = @idEspecialidad;

	IF(@@ERROR = 0)
		PRINT 'Especialidad con ID ' + CAST(@idEspecialidad AS VARCHAR) + ' eliminada correctamente.';
	ELSE
		PRINT 'Ocurrió un error al intentar eliminar Especialidad con ID ' + CAST(@idEspecialidad AS VARCHAR) 
END
GO
---- FIN DE STORED PROCEDURES DE ESPECIALIDAD ----

---- COMIENZO DE STORED PROCEDURES DE SEDE ----
CREATE PROCEDURE datosAtencion.InsertarSede
(
	@nombreSede VARCHAR(20),
	@direccionSede VARCHAR(20)
)
AS
BEGIN
    IF @nombreSede IS NULL OR LEN(@nombreSede) = 0
    BEGIN
        RAISERROR('El nombre de la sede no puede ser nulo o vacío.',16, 1);
        RETURN; 
    END

    IF @direccionSede IS NULL OR LEN(@direccionSede) = 0
    BEGIN
        RAISERROR('La dirección de la sede no puede ser nula o vacía.',16,1);
        RETURN; 
    END
    
    INSERT INTO datosAtencion.SedeAtencion(nombre, direccion)
    VALUES (@nombreSede, @direccionSede);

	IF(@@ERROR = 0)
		PRINT 'Sede insertada correctamente.';
	ELSE
		PRINT 'Ocurrió un error al intentar insertar Sede'
END
GO

CREATE PROCEDURE datosAtencion.ModificarSede
(
    @SedeID INT,
    @NuevoNombreSede VARCHAR(20),
    @NuevaDireccionSede VARCHAR(20)
)
AS
BEGIN
 
    IF NOT EXISTS (SELECT 1 FROM datosAtencion.SedeAtencion WHERE id = @SedeID)
    BEGIN
        RAISERROR('La SedeID especificada no existe.',16,1);
        RETURN;
    END

    IF @NuevoNombreSede IS NULL OR LEN(@NuevoNombreSede) = 0
    BEGIN
        RAISERROR('El nuevo nombre de la sede no puede ser nulo o vacío.', 16, 1);
        RETURN;
    END

    IF @NuevaDireccionSede IS NULL OR LEN(@NuevaDireccionSede) = 0
    BEGIN
        RAISERROR('La nueva dirección de la sede no puede ser nula o vacía.', 16, 1);
        RETURN;
    END

    UPDATE datosAtencion.SedeAtencion
    SET nombre = @NuevoNombreSede, direccion = @NuevaDireccionSede
    WHERE id = @SedeID;

	IF(@@ERROR = 0)
		PRINT 'Sede con ID ' + CAST(@SedeID AS VARCHAR) + ' modificada correctamente.'
	ELSE
		PRINT 'Ocurrió un error al intentar modificar Sede con ID ' + CAST(@SedeID AS VARCHAR)
END
GO

CREATE PROCEDURE datosAtencion.EliminarSede
    @SedeID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM datosAtencion.SedeAtencion WHERE id = @SedeID)
    BEGIN
		PRINT 'La SedeID especificada no existe.'
        RETURN;
    END

    UPDATE datosAtencion.SedeAtencion
    SET fechaBorrado = NULL
    WHERE id = @SedeID;

	IF(@@ERROR = 0)
		PRINT 'Sede con ID ' + CAST(@SedeID AS VARCHAR) + ' borrada correctamente.';
	ELSE
		PRINT 'Ocurrió un error al intentar borrar la Sede con ID ' + CAST(@SedeID AS VARCHAR)
END
GO
---- FIN DE STORED PROCEDURES DE SEDE ----

---- COMIENZO DE STORED PROCEDURES DE DIAXSEDE ----
CREATE PROCEDURE datosAtencion.InsertarHorarioMedico
(
    @idSede INT,
    @idMedico INT,
    @diaSemana VARCHAR(10),
    @horaInicio TIME,
    @horaFin TIME
)
AS
BEGIN
    -- Validar que la Sede exista
    IF (NOT EXISTS (SELECT 1 FROM datosAtencion.SedeAtencion WHERE id = @idSede))
    BEGIN
        RAISERROR('La Sede especificada no existe.',16,1);
        RETURN; 
    END

    -- Validar que el Médico exista
    IF (NOT EXISTS (SELECT 1 FROM datosAtencion.Medico WHERE id = @idMedico))
    BEGIN
        RAISERROR('El Médico especificado no existe.',16,1);
        RETURN; 
    END

    IF (@diaSemana IS NULL OR @horaInicio IS NULL OR @horaFin IS NULL)
    BEGIN
        RAISERROR('Los campos no pueden ser nulos.',16,1);
        RETURN; 
    END

    IF (LEN(@diaSemana) = 0)
    BEGIN
        RAISERROR('El campo "diaSemana" no puede estar vacío.',16,1);
        RETURN;
    END

    INSERT INTO datosAtencion.DiasXSede(idSede, idMedico, diaSemana, horaInicio, horaFin)
    VALUES (@idSede, @idMedico, @diaSemana, @horaInicio, @horaFin);

	IF (@@ERROR = 0)
		PRINT 'Registro de horario de médico insertado correctamente.';
	ELSE
		PRINT 'Ocurrió un error al intentar insertar registro en DiaXSede.'
END
GO

CREATE PROCEDURE datosAtencion.ModificarHorarioMedico
(
    @idSede INT,
    @idMedico INT,
    @diaSemana VARCHAR(10),
    @nuevaHoraInicio TIME,
    @nuevaHoraFin TIME
)
AS
BEGIN
    IF (NOT EXISTS (
        SELECT 1
        FROM datosAtencion.DiasXSede
        WHERE idSede = @idSede
          AND idMedico = @idMedico
          AND diaSemana = @diaSemana
    ))
    BEGIN
        RAISERROR('El registro que intenta modificar no existe.',16,1);
        RETURN; 
    END

    IF (@nuevaHoraInicio IS NULL OR @nuevaHoraFin IS NULL)
    BEGIN
        RAISERROR('Los campos de hora no pueden ser nulos.',16,1);
        RETURN; 
    END

    UPDATE datosAtencion.DiasXSede
    SET horaInicio = @nuevaHoraInicio,
        horaFin = @nuevaHoraFin
    WHERE idSede = @idSede
      AND idMedico = @idMedico
      AND diaSemana = @diaSemana;

	IF (@@ERROR = 0)
		PRINT 'Registro de horario de médico modificado correctamente.';
	ELSE
		PRINT 'Ocurrió un error al intentar modificar el registro de horario médico.';
END
GO

CREATE OR ALTER PROCEDURE datosAtencion.EliminarHorarioMedico
(
    @idSede INT,
    @idMedico INT,
    @diaSemana VARCHAR(10)
)
AS
BEGIN
    IF (NOT EXISTS (
        SELECT 1
        FROM datosAtencion.DiasXSede
        WHERE idSede = @idSede
          AND idMedico = @idMedico
          AND diaSemana = @diaSemana
    ))
    BEGIN
        RAISERROR('El registro que intenta eliminar no existe.',16,1);
        RETURN;
    END

    DELETE FROM datosAtencion.DiasXSede
    WHERE idSede = @idSede
      AND idMedico = @idMedico
      AND diaSemana = @diaSemana;

	IF (@@ERROR = 0)
		PRINT 'Registro de horario de médico eliminado correctamente.';
	ELSE
		PRINT 'Ocurrió un error al intentar insertar registro de horario de médico.'
END
GO
---- FIN DE STORED PROCEDURES DE DIAXSEDE ----

---- COMIENZO DE STORED PROCEDURES DE TIPOTURNO ----
CREATE PROCEDURE datosReserva.InsertarTipoTurno
    @nombre VARCHAR(10)
AS
BEGIN
    -- Validar que @nombre sea "presencial" o "virtual"
    IF (@nombre NOT IN ('Presencial', 'Virtual'))
    BEGIN
        RAISERROR('El nombre del tipo de turno debe ser "presencial" o "virtual".',16,1);
        RETURN; 
    END

    INSERT INTO datosReserva.TipoTurno (nombre)
    VALUES (@nombre);

	IF (@@ERROR = 0)
		PRINT 'Tipo de turno insertado correctamente.';
	ELSE
		PRINT 'Ocurrió un error al intentar insertar registro de Tipo de Turno'
END
GO

CREATE PROCEDURE datosReserva.ModificarTipoTurno
(
    @id INT,
    @nuevoNombre VARCHAR(10)
)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM datosReserva.TipoTurno WHERE id = @id)
    BEGIN
        RAISERROR('El ID del tipo de turno especificado no existe.',16,1);
        RETURN;
    END

    -- Validar que @nuevoNombre sea "presencial" o "virtual"
    IF @nuevoNombre NOT IN ('presencial', 'virtual')
    BEGIN
        RAISERROR('El nuevo nombre del tipo de turno debe ser "presencial" o "virtual".',16,1);
        RETURN; 
    END

    UPDATE datosReserva.TipoTurno
    SET nombre = @nuevoNombre
    WHERE id = @id;

	IF (@@ERROR = 0)
		PRINT 'Nombre del Tipo de Turno modificado correctamente.';
	ELSE
		PRINT 'Ocurrió un error al intentar modificar un registro de Tipo de Turno'
END

GO
CREATE PROCEDURE datosReserva.EliminarTipoTurno
    @id INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM datosReserva.TipoTurno WHERE id = @id)
    BEGIN
        RAISERROR('El ID del tipo de turno especificado no existe.',16,1);
        RETURN; 
    END

    UPDATE datosReserva.TipoTurno
    SET fechaBorrado = GETDATE()
    WHERE id = @id;

	IF(@@ERROR = 0)
		PRINT 'Tipo de turno eliminado correctamente.';
	ELSE
		PRINT 'Ocurrió un error al intentar eliminar el registro de Tipo de Turno'
END
GO

CREATE OR ALTER PROCEDURE datosReserva.InsertarEstadoTurno
    @nombreEstado CHAR(9)
AS
BEGIN
    -- Validar que @nombreEstado sea "Atendido", "Ausente" o "Cancelado"
    IF @nombreEstado NOT IN ('Atendido', 'Ausente', 'Cancelado')
    BEGIN
        RAISERROR('El valor de nombreEstado debe ser "Atendido", "Ausente" o "Cancelado".',16,1);
        RETURN;
    END

    -- Insertar el nuevo estado de turno
    INSERT INTO datosReserva.EstadoTurno (nombreEstado)
    VALUES (@nombreEstado);

    PRINT 'Estado de turno insertado correctamente.';
END

GO
CREATE OR ALTER PROCEDURE datosReserva.ModificarEstadoTurno
    @id INT,
    @nuevoNombreEstado CHAR(9)
AS
BEGIN
    -- Validar que @id exista en la tabla
    IF NOT EXISTS (SELECT 1 FROM datosReserva.EstadoTurno WHERE id = @id)
    BEGIN
        RAISERROR('El ID del estado de turno especificado no existe.',16,1);
        RETURN;
    END

    -- Validar que @nuevoNombreEstado sea "Atendido", "Ausente" o "Cancelado"
    IF @nuevoNombreEstado NOT IN ('Atendido', 'Ausente', 'Cancelado')
    BEGIN
        RAISERROR('El nuevo valor de nombreEstado debe ser "Atendido", "Ausente" o "Cancelado".',16,1);
        RETURN; -- Salir del procedimiento
    END

    -- Realizar la actualización del nombre del estado de turno
    UPDATE datosReserva.EstadoTurno
    SET nombreEstado = @nuevoNombreEstado
    WHERE id = @id;

    PRINT 'Nombre del estado de turno modificado correctamente.';
END	

GO
CREATE OR ALTER PROCEDURE datosReserva.EliminarEstadoTurno
    @id INT
AS
BEGIN
    -- Verificar si el registro existe en la tabla
    IF NOT EXISTS (SELECT 1 FROM datosReserva.EstadoTurno WHERE id = @id)
    BEGIN
        RAISERROR('El ID del estado de turno especificado no existe.',16,1);
        RETURN; 
    END

    -- Realizar la eliminación del registro estableciendo fechaBorrado
    UPDATE datosReserva.EstadoTurno
    SET fechaBorrado = GETDATE()
    WHERE id = @id;

    PRINT 'Estado de turno eliminado correctamente.';
END
GO
---- FIN DE STORED PROCEDURES DE TIPOTURNO ----

---- COMIENZO DE STORED PROCEDURES DE PACIENTE ----
CREATE PROCEDURE datosPaciente.InserPaciente
(
	@nombre VARCHAR(20),
	@apellido VARCHAR(20),
	@apellidoMaterno VARCHAR(20),
	@fechaNacimiento DATE,
	@tipoDocumento VARCHAR(9),
	@nroDocumento INT,
	@sexo CHAR,
	@genero CHAR,
	@nacionalidad VARCHAR(15),
	@fotoPerfil VARCHAR(40),
	@mail VARCHAR(60),
	@telefonoFijo VARCHAR(20),
	@telefonoContactoAlternativo VARCHAR(20),
	@telefonoLaboral VARCHAR(20),
	@fechaRegistro DATE,
	@idUsuario INT,
	@idDomicilio INT,
	@idEstudio INT
)
AS
BEGIN
	IF( @nombre  = '' OR @nombre IS NULL
	 OR @apellido = '' OR @apellido IS NULL
	 OR @apellidoMaterno = '' OR @apellidoMaterno IS NULL
	 OR @fechaNacimiento IS NULL
	 OR @tipoDocumento = '' OR @tipoDocumento IS NULL
	 OR @nroDocumento IS NULL
	 OR @sexo = '' OR @sexo IS NULL OR (@sexo NOT IN ('F', 'M'))
	 OR @genero = ''
	 OR @nacionalidad = '' OR @nacionalidad IS NULL
	 OR @fotoPerfil = '' OR @fotoPerfil IS NULL
	 OR @mail = '' OR @mail IS NULL
	 OR @telefonoFijo = '' OR @telefonoFijo IS NULL
	 OR @telefonoContactoAlternativo = ''
	 OR @telefonoLaboral = ''
	 OR @fechaRegistro = ''
	 OR @idUsuario IS NULL OR @idDomicilio IS NULL
	 OR @idEstudio IS NULL
	 )
	BEGIN
		RAISERROR('Los parametros no pueden ser nulos o vacíos.', 16, 1);
		RETURN;
	END

	-- Verificamos si ya existe un Paciente con el mismo DNI
	IF(EXISTS (SELECT 1 FROM datosPaciente.Paciente WHERE nroDocumento = @nroDocumento))
	BEGIN
		PRINT('Ya existe un paciente registrado con el DNI' + CAST(@nroDocumento AS VARCHAR));
		RETURN;
	END

	INSERT INTO datosPaciente.Paciente (
				nombre,			apellido,		apellidoMaterno,	fechaNacimiento,
				tipoDocumento,	nroDocumento,	sexo,				genero,
				nacionalidad,	fotoPerfil,		mail,				telefonoFijo,
				telefonoContactoAlternativo,	telefonoLaboral,	fechaRegistro, 
				idUsuario,		idEstudio
			)
	VALUES (					
				@nombre,		@apellido,		@apellidoMaterno,	@fechaNacimiento, 
				@tipoDocumento,	@nroDocumento,	@sexo,				@genero, 
				@nacionalidad,	@fotoPerfil,	@mail,				@telefonoFijo,
				@telefonoContactoAlternativo,	@telefonoLaboral,	@fechaNacimiento,
				@idUsuario,		@idEstudio
			)
	
	IF (@@ERROR = 0)
		PRINT 'Registro de Paciente insertado correctamente.';
	ELSE
		PRINT 'Ocurrió un error al intentar insertar registro en Paciente'
END
GO

CREATE PROCEDURE datosPaciente.ModifPaciente
(
	@id INT,
	@nombre VARCHAR(20) = NULL,
	@apellido VARCHAR(20)  = NULL,
	@apellidoMaterno VARCHAR(20) = NULL,
	@fechaNacimiento DATE  = NULL,
	@tipoDocumento VARCHAR(9)  = NULL,
	@nroDocumento INT  = NULL,
	@sexo CHAR  = NULL,
	@genero CHAR = NULL,
	@nacionalidad VARCHAR(15) = NULL,
	@fotoPerfil VARCHAR(40) = NULL,
	@mail VARCHAR(60) = NULL,
	@telefonoFijo VARCHAR(20) = NULL,
	@telefonoContactoAlternativo VARCHAR(20) = NULL,
	@telefonoLaboral VARCHAR(20) = NULL,
	@idUsuarioActualizacion INT = NULL,
	@idDomicilio INT = NULL,
	@idEstudio INT = NULL
)
AS
BEGIN	
    IF NOT EXISTS (SELECT 1 FROM datosPaciente.Paciente WHERE idHistoriaClinica = @id)
    BEGIN
        PRINT 'El paciente con ID ' + CAST(@id AS VARCHAR) + ' no existe.';
        RETURN;
    END

	-- Verificamos si ya existe un Paciente con el mismo DNI
	IF(@nroDocumento IS NOT NULL AND EXISTS (SELECT 1 FROM datosPaciente.Paciente WHERE nroDocumento = @nroDocumento))
	BEGIN
		PRINT('Ya existe un paciente registrado con el DNI' + CAST(@nroDocumento AS VARCHAR));
		RETURN;
	END

	UPDATE datosPaciente.Paciente
	SET		nombre				= ISNULL(@nombre, nombre),
			apellido			= ISNULL(@apellido, nombre),
			apellidoMaterno		= ISNULL(@apellidoMaterno, apellidoMaterno),
			fechaNacimiento		= ISNULL(@fechaNacimiento, fechaNacimiento),
			tipoDocumento		= ISNULL(@tipoDocumento, tipoDocumento),
			nroDocumento		= ISNULL(@nroDocumento, nroDocumento),
			sexo				= ISNULL(@sexo, sexo),
			genero				= ISNULL(@genero, genero),
			nacionalidad		= ISNULL(@nacionalidad, nacionalidad),
			fotoPerfil			= ISNULL(@fotoPerfil, fotoPerfil),
			mail				= ISNULL(@mail, mail),
			telefonoFijo		= ISNULL(@telefonoFijo, telefonoFijo),
			telefonoContactoAlternativo = ISNULL(@telefonoContactoAlternativo, telefonoContactoAlternativo),
			telefonoLaboral		= ISNULL(@telefonoLaboral, telefonoLaboral),
			fechaActualizacion	= GETDATE(),
			idDomicilio			= ISNULL(@idDomicilio, idDomicilio),
			idEstudio			= ISNULL(@idEstudio, idEstudio),
			idUsuarioActualizacion = ISNULL(@idUsuarioActualizacion, idUsuarioActualizacion)
	WHERE	idHistoriaClinica = @id

	IF (@@ERROR = 0)
		PRINT 'Paciente con ID ' + CAST(@id AS VARCHAR) + ' modificado correctamente.';
	ELSE
		PRINT 'Ocurrió un error al intentar modificar Paciente con ID ' + CAST(@id AS VARCHAR)
END
GO

CREATE PROCEDURE datosPaciente.ElimPaciente
    @idHistoriaClinica INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM datosPaciente.Paciente WHERE idHistoriaClinica = @idHistoriaClinica)
    BEGIN
        PRINT 'El paciente con ID ' + CAST(@idHistoriaClinica AS VARCHAR) + ' no existe.';
        RETURN;
    END

    UPDATE datosPaciente.Paciente
	SET fechaBorrado = GETDATE()
	WHERE idHistoriaClinica = @idHistoriaClinica;

	IF (@@ERROR = 0)
		PRINT 'El Paciente con ID ' + CAST(@idHistoriaClinica AS VARCHAR) + ' fue borrado correctamente.';
	ELSE
		PRINT 'Ocurrió un error al intentar insertar Paciente con ID ' + CAST(@idHistoriaClinica AS VARCHAR)
END
GO
---- FIN DE STORED PROCEDURES DE PACIENTE ----

---- COMIENZO DE STORED PROCEDURES DE MEDICO ----
CREATE PROCEDURE datosAtencion.InsertarMedico
(
    @nombre VARCHAR(20),
    @apellido VARCHAR(20),
    @nroMatricula INT,
    @idEspecialidad INT
)
AS
BEGIN
    IF (@nombre IS NULL OR @nombre = ''
	 OR	@apellido IS NULL OR @apellido = ''
	 OR	@nroMatricula IS NULL
	 OR	@idEspecialidad IS NULL
	)
    BEGIN
        RAISERROR('Los parametros no pueden ser nulos o vacíos.', 16, 1);
        RETURN;
    END

    INSERT INTO datosAtencion.Medico (nombre, apellido, nroMatricula, idEspecialidad)
    VALUES (@nombre, @apellido, @nroMatricula, @idEspecialidad);

	IF (@@ERROR = 0)
		PRINT 'Registro de Medico insertado correctamente.';
	ELSE
		PRINT 'Ocurrió un error al intentar insertar un registro en Medico.'
END;
GO

CREATE PROCEDURE datosAtencion.ModifMedico
(
    @id INT,
    @nombre VARCHAR(20),
    @apellido VARCHAR(20),
    @nroMatricula INT,
    @idEspecialidad INT
)
AS
BEGIN
	IF(NOT EXISTS (SELECT 1 FROM datosAtencion.Medico WHERE id = @id))
	BEGIN
		PRINT 'El Medico con ID ' + CAST(@id AS VARCHAR) + ' no existe.';
        RETURN;
	END

    UPDATE datosAtencion.Medico
    SET nombre = ISNULL(@nombre, nombre),
        apellido = ISNULL(@apellido, apellido),
        nroMatricula = ISNULL(@nroMatricula, nroMatricula),
        idEspecialidad = ISNULL(@idEspecialidad, idEspecialidad)
    WHERE id = @id;

	IF (@@ERROR = 0)
		PRINT 'El Medico con ID ' + CAST(@id AS VARCHAR) + ' fue modificado correctamente.';
	ELSE
		PRINT 'Ocurrió un error al intentar insertar un Medico con ID ' + CAST(@id AS VARCHAR)
END;
GO

CREATE PROCEDURE datosAtencion.EliminarMedico
    @id INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM datosAtencion.Medico WHERE id = @id)
    BEGIN
        PRINT 'El Medico con ID ' + CAST(@id AS VARCHAR) + ' no existe.';
        RETURN;
    END

	UPDATE datosAtencion.Medico
    SET fechaBorrado = GETDATE()
    WHERE id = @id;

	IF (@@ERROR = 0)
		PRINT 'El Medico con ID ' + CAST(@id AS VARCHAR) + ' fue borrado correctamente.';
	ELSE
		PRINT 'Ocurrió un error al intentar eliminar un Medico con ID ' + CAST(@id AS VARCHAR)
END;
GO
---- FIN DE STORED PROCEDURES DE MEDICO ----

---- COMIENZO DE STORED PROCEDURES DE RESERVA ----
CREATE PROCEDURE datosReserva.InsertarReserva
(
    @fecha DATE,
    @hora TIME,
    @idMedico INT,
    @idEspecialidad INT,
    @idDireccionAtencion INT,
    @idEstadoTurno INT,
    @idTipoTurno INT,
    @idPaciente INT
)
AS
BEGIN
    IF( @fecha IS NULL
	 OR	@hora IS NULL
	 OR	@idMedico IS NULL
	 OR	@idEspecialidad IS NULL
	 OR	@idDireccionAtencion IS NULL
	 OR	@idEstadoTurno IS NULL
	 OR	@idTipoTurno IS NULL
	 OR	@idPaciente IS NULL
	)
    BEGIN
        RAISERROR('Los parametros no pueden ser nulos o vacíos.', 16, 1);
        RETURN;
    END

    INSERT INTO datosReserva.Reserva (	
			fecha,			hora,			idMedico,		idEspecialidad,	 idDireccionAtencion, 
			idEstadoTurno, idTipoTurno,		idPaciente
			)
    VALUES (
			@fecha,			@hora,			@idMedico,		@idEspecialidad, @idDireccionAtencion,
			@idEstadoTurno, @idTipoTurno,	@idPaciente
		   )

	IF (@@ERROR = 0)
		PRINT 'Registro de Reserva insertado correctamente.';
	ELSE
		PRINT 'Ocurrió un error al intentar insertar un registro en Reserva.'
END;
GO

CREATE PROCEDURE datosReserva.ModificarReserva
(
    @id INT,
    @fecha DATE = NULL,
    @hora TIME = NULL,
    @idMedico INT = NULL,
    @idEspecialidad INT = NULL,
    @idDireccionAtencion INT = NULL,
    @idEstadoTurno INT = NULL,
    @idTipoTurno INT = NULL,
    @idPaciente INT = NULL
)
AS
BEGIN
	IF(NOT EXISTS (SELECT 1 FROM datosReserva.Reserva WHERE id = @id))
	BEGIN
		PRINT 'La Reserva con ID ' + CAST(@id AS VARCHAR) + ' no existe.';
        RETURN
	END

    UPDATE datosReserva.Reserva
    SET fecha = ISNULL(@fecha, fecha),
        hora = ISNULL(@hora, hora),
        idMedico = ISNULL(@idMedico, idMedico),
        idEspecialidad = ISNULL(@idEspecialidad, idEspecialidad),
        idDireccionAtencion = ISNULL(@idDireccionAtencion, idDireccionAtencion),
        idEstadoTurno = ISNULL(@idEstadoTurno, idEstadoTurno),
        idTipoTurno = ISNULL(@idTipoTurno, idTipoTurno),
        idPaciente = ISNULL(@idPaciente, idPaciente)
    WHERE id = @id;

	IF (@@ERROR = 0)
		PRINT 'La Reserva con ID ' + CAST(@id AS VARCHAR) + ' fue modificada correctamente.';
	ELSE
		PRINT 'Ocurrió un error al intentar modificar Reserva con ID ' + CAST(@id AS VARCHAR)
END;
GO

CREATE PROCEDURE datosReserva.EliminarReserva
    @id INT
AS
BEGIN
	IF(NOT EXISTS(SELECT 1 FROM datosReserva.Reserva))
	BEGIN
		PRINT 'La Reserva con ID ' + CAST(@id AS VARCHAR) + ' no existe.';
        RETURN;
	END

    DELETE FROM datosReserva.Reserva
    WHERE id = @id;

	IF (@@ERROR = 0)
		PRINT 'La Reserva con ID ' + CAST(@id AS VARCHAR) + ' fue eliminada correctamente.';
	ELSE
		PRINT 'Ocurrió un error al intentar eliminar Reserva con ID ' + CAST(@id AS VARCHAR)
END;
GO
---- FIN DE STORED PROCEDURES DE RESERVA ----

---- COMIENZO DE STORED PROCEDURES DE ESTUDIO ----
CREATE PROCEDURE datosPaciente.InsertarEstudio
(
    @fecha DATE,
    @nombre VARCHAR(15),
    @autorizado BIT,
    @linkDocumentoResultado VARCHAR(50),
    @imagenResultado VARCHAR(40)
)
AS
BEGIN
    IF (
		@fecha IS NULL OR
		@nombre IS NULL OR
		@autorizado IS NULL OR
		@linkDocumentoResultado IS NULL OR
		@imagenResultado IS NULL
	)
    BEGIN
        RAISERROR('Los parametros no pueden ser nulos o vacíos.', 16, 1)
        RETURN
    END

    INSERT INTO datosPaciente.Estudio (
			fecha,	nombre,		autorizado,		linkDocumentoResultado,		imagenResultado
			)
    VALUES (
			@fecha, @nombre,	@autorizado,	@linkDocumentoResultado,	@imagenResultado
			)

	IF (@@ERROR = 0)
		PRINT 'Registro de Estudio insertado correctamente.';
	ELSE
		PRINT 'Ocurrió un error al intentar insertar registro en Estudio.'
END;
GO

CREATE PROCEDURE datosPaciente.ModificarEstudio
(
    @id INT,
    @fecha DATE = NULL,
    @nombre VARCHAR(15) = NULL,
    @autorizado BIT = NULL,
    @linkDocumentoResultado VARCHAR(50) = NULL,
    @imagenResultado VARCHAR(40) = NULL
)
AS
BEGIN
	IF(NOT EXISTS(SELECT 1 FROM datosPaciente.Estudio))
	BEGIN
		PRINT 'El Estudio con ID ' + CAST(@id AS VARCHAR) + ' no existe.';
        RETURN;
	END

    UPDATE datosPaciente.Estudio
    SET fecha = @fecha,
        nombre = @nombre,
        autorizado = @autorizado,
        linkDocumentoResultado = @linkDocumentoResultado,
        imagenResultado = @imagenResultado
    WHERE id = @id;

	IF (@@ERROR = 0)
		PRINT 'El Estudio con ID ' + CAST(@id AS VARCHAR) + ' fue modificada correctamente.';
	ELSE
		PRINT 'Ocurrió un error al intentar modificar Estudio con ID ' + CAST(@id AS VARCHAR)
END;
GO

CREATE OR ALTER PROCEDURE datosPaciente.EliminarEstudio
    @id INT
AS
BEGIN
	IF(NOT EXISTS(SELECT 1 FROM datosPaciente.Estudio))
	BEGIN
		PRINT 'El Estudio con ID ' + CAST(@id AS VARCHAR) + ' no existe.';
        RETURN;
	END

    UPDATE datosPaciente.Estudio
    SET fechaBorrado = GETDATE()
    WHERE id = @id;

	IF (@@ERROR = 0)
		PRINT 'El Estudio con ID ' + CAST(@id AS VARCHAR) + ' fue borrado correctamente.';
	ELSE
		PRINT 'Ocurrió un error al intentar eliminar Estudio con ID ' + CAST(@id AS VARCHAR)
END;
---- FIN DE STORED PROCEDURES DE ESTUDIO ----
