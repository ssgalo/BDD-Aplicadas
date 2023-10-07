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

CREATE TABLE datosPaciente.Usuario		-- Listo los SP
(
	id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	contraseña CHAR(8) NOT NULL,
	fechaCreacion DATETIME NOT NULL,
	fechaBorrado DATETIME NOT NULL
) 
GO

CREATE TABLE datosPaciente.Domicilio	-- Listo los SP con 1 duda
(
	id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	calle VARCHAR(15) NOT NULL,
	numero INT NOT NULL,
	piso INT NULL,
	departamento VARCHAR(10) NULL, 
	codigoPostal VARCHAR(10) NOT NULL,
	pais VARCHAR(15) NOT NULL,
	provincia VARCHAR(15) NOT NULL,
	localidad VARCHAR(15) NOT NULL
)
go

CREATE TABLE datosPaciente.Prestador	-- Listo los SP
(
	id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	nombre VARCHAR(20) NOT NULL,
	tipoPlan VARCHAR(10) NOT NULL,
	fechaBorrado DATETIME NULL
)
GO

CREATE TABLE datosPaciente.Cobertura	-- Listo los SP
(
	id INT IDENTITY(1,1) PRIMARY KEY not null,
	imagenCredencial VARCHAR(40) NOT NULL,
	nroSocio INT NOT NULL,
	fechaRegistro DATETIME NOT NULL,
	idPrestador INT NOT NULL,
	fechaBorrado DATETIME NOT NULL,
	CONSTRAINT FK_Prestador FOREIGN KEY (idPrestador) REFERENCES datosPaciente.Prestador(id)
)
GO

CREATE TABLE datosPaciente.Estudio
(
	id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	fecha DATE NOT NULL,
	nombre VARCHAR(15) NOT NULL,
	autorizado BIT NOT NULL,
	linkDocumentoResultado VARCHAR(50) NOT NULL,
	imagenResultado VARCHAR(40) NOT NULL,
	fechaBorrado DATETIME NULL
)
GO

CREATE TABLE datosPaciente.Paciente 
(
	idHistoriaClinica INT IDENTITY(1,1) NOT NULL,
	nombre VARCHAR(20) NOT NULL,
	apellido VARCHAR(20) NOT NULL,
	apellidoMaterno VARCHAR(20) NOT NULL,
	fechaNacimiento DATE NOT NULL,
	tipoDocumento VARCHAR(9) NOT NULL,
	nroDocumento INT NOT NULL,
	sexo CHAR NOT NULL,
	genero CHAR NULL,
	nacionalidad VARCHAR(15) NOT NULL,
	fotoPerfil VARCHAR(40) NOT NULL,
	mail VARCHAR(60) NOT NULL,
	telefonoFijo VARCHAR(20) NOT NULL,
	telefonoContactoAlternativo VARCHAR(20) NULL,
	telefonoLaboral VARCHAR(20) NULL,
	fechaRegistro DATE NOT NULL,
	fechaActualizacion DATETIME NULL,
	idUsuario INT NOT NULL,
	idDomicilio INT NOT NULL,
	idEstudio INT NOT NULL,
	idUsuarioActualizacion INT NULL,
	fechaBorrado DATETIME NULL
	CONSTRAINT PK_Paciente PRIMARY KEY (nroDocumento),
	CONSTRAINT FK_Usuario FOREIGN KEY (idUsuario) REFERENCES datosPaciente.Usuario(id),
	CONSTRAINT FK_Domicilio FOREIGN KEY (idDomicilio) REFERENCES datosPaciente.Domicilio(id),
	CONSTRAINT FK_Estudio FOREIGN KEY (idEstudio) REFERENCES datosPaciente.Estudio(id)
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
	nombre VARCHAR(20) NOT NULL,
	direccion VARCHAR(20) NOT NULL,
	fechaBorrado DATETIME NULL
)
GO

CREATE TABLE datosAtencion.Medico
(
	id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	nombre VARCHAR(20) NOT NULL,
	apellido VARCHAR(20) NOT NULL,
	nroMatricula INT NOT NULL,
	idEspecialidad INT NOT NULL,
	fechaBorrado DATETIME NULL,
	CONSTRAINT FK_Especialidad FOREIGN KEY (idEspecialidad) REFERENCES datosAtencion.Especialidad(id)
)
GO

CREATE TABLE datosAtencion.DiasXSede
(
	idSede INT,
	idMedico INT,
	diaSemana VARCHAR(10),
	horaInicio TIME,
	horaFin TIME,
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


CREATE OR ALTER PROCEDURE datosPaciente.InsertarUsuario
	@contraseña CHAR(8)
AS
BEGIN
	-- Verificar que los parámetros no sean nulos o vacíos
	IF (@contraseña is null or @contraseña = ' ') 
	BEGIN
		RAISERROR('Los parametros no pueden ser nulos o vacíos.', 16, 1);
		RETURN;
	END

	-- Verificar que la contraseña esté entre 4 y 8 caracteres
	IF LEN(@contraseña) < 4 OR LEN(@contraseña) > 8 
	BEGIN
		RAISERROR('La contraseña debe tener entre 4 y 8 caracteres.', 16, 1);
		RETURN;
	END

	DECLARE @fechaCreacion DATETIME = GETDATE();

	-- Insertar el nuevo usuario en la tabla
	INSERT INTO datosPaciente.Usuario (contraseña, fechaCreacion, fechaBorrado)
	VALUES (@contraseña,@fechaCreacion , NULL);

	PRINT 'Usuario insertado correctamente';
END
GO

--EXEC salud.InserUsu ' '';

CREATE OR ALTER PROCEDURE datosPaciente.ModificarUsuario
	@id INT,
	@nuevaContraseña CHAR(8)
AS
BEGIN
	-- Verificar que el usuario con dicho ID exista
	IF not exists (select 1 from datosPaciente.Usuario where id=@id)
	BEGIN
		PRINT 'El usuario con ID ' + CAST(@id AS VARCHAR) + ' no existe';
		RETURN;
	END

	--Actualizar contraseña y fecha de creacion del usuario
	UPDATE datosPaciente.Usuario
	SET contraseña = @nuevaContraseña
	WHERE id = @id

	PRINT 'El usuario con ID ' + cast(@id AS VARCHAR) + ' ha sido modificado correctamente';
END
GO

--EXEC salud.ModifUsu 1, 'nueva123', '2023-10-05'; -- No se si esta fecha le pasa como parametro o si nosotros cargamos con la fecha actual

CREATE OR ALTER PROCEDURE datosPaciente.EliminarUsuario
	@id INT
AS
BEGIN
	-- Verificar que el usuario con dicho ID exista
	IF not exists (select 1 from datosPaciente.Usuario where id=@id)
	BEGIN
		PRINT 'El usuario con ID ' + CAST(@id AS VARCHAR) + ' no existe';
		RETURN;
	END

	DECLARE @fechaBorrado DATETIME = GETDATE()

	-- Borrado logico de Usuario
	UPDATE datosPaciente.Usuario
	SET fechaBorrado = @fechaBorrado
	WHERE id = @id

	PRINT 'El usuario con ID ' + cast(@id AS VARCHAR) + ' ha sido borrado correctamente';
END
GO
--EXEC salud.ElimiUsu 1;


CREATE OR ALTER PROCEDURE datosPaciente.InsertarDomicilio
	@calle varchar(15),
	@numero int,
	@piso int,
	@departamento varchar(10), 
	@codigoPostal varchar(10),
	@pais varchar(15),
	@provincia varchar(15),
	@localidad varchar(15)
AS
BEGIN
	-- Verificar que los parámetros no sean nulos o vacíos
	IF (@calle is null or @calle = ' ' or @numero is null
		or @piso is null or @departamento is null or @departamento = ' '
		or @codigoPostal is null or @codigoPostal = ' ' or @pais is null
		or @pais = ' ' or @provincia is null or @provincia = ' '
		or @localidad is null or @localidad = ' ') 
	BEGIN
		RAISERROR('Los parametros no pueden ser nulos o vacíos.', 16, 1);
		RETURN;
	END

	-- Insertar el nuevo domicilio en la tabla
	INSERT INTO datosPaciente.Domicilio (calle, numero, piso, departamento, codigoPostal, pais, provincia, localidad)
	VALUES (@calle, @numero, @piso, @departamento, @codigoPostal, @pais, @provincia, @localidad);

	PRINT 'Domicilio insertado correctamente';

END
GO
--EXEC salud.InserDomi 'Calle1',123,2,'Dpto A','12345','Arg','Bs As','Ituzaingo';

CREATE OR ALTER PROCEDURE datosPaciente.ModificarDomi
    @id int,
	@nuevaCalle varchar(15) = NULL,
	@nuevoNumero int = NULL,
	@nuevoPiso int = NULL,
	@nuevoDepartamento varchar(10) = NULL, 
	@nuevoCodigoPostal varchar(10) = NULL,
	@nuevoPais varchar(15) = NULL,
	@nuevaProvincia varchar(15) = NULL,
	@nuevaLocalidad varchar(15) = NULL
AS
BEGIN
    -- Verificar que el domicilio con dicho ID  existe
    IF NOT EXISTS (SELECT 1 FROM datosPaciente.Domicilio WHERE id = @id)
    BEGIN
        PRINT 'El domicilio con ID ' + CAST(@id AS VARCHAR) + ' no existe.';
        RETURN;
    END

    -- Actualizar los datos
    UPDATE datosPaciente.Domicilio
    SET 
		calle = ISNULL(@nuevaCalle, calle),
        numero = ISNULL(@nuevoNumero, numero),
        piso = ISNULL(@nuevoPiso, piso),
        departamento = ISNULL(@nuevoDepartamento, departamento),
        codigoPostal = ISNULL(@nuevoCodigoPostal,codigoPostal),
        pais = ISNULL(@nuevoPais, pais),
        provincia = ISNULL(@nuevaProvincia, provincia),
        localidad = ISNULL(@nuevaLocalidad, localidad)
    WHERE id = @id;

    -- Confirmar la modificación
    PRINT 'Domicilio con ID ' + CAST(@id AS VARCHAR) + ' modificados correctamente.';
END;
GO
-- EXEC salud.ModifDomi 1, 'Olivera', 111


CREATE OR ALTER PROCEDURE datosPaciente.EliminarDomicilio
	@id int
AS
BEGIN
    -- Verificar que el domicilio con dicho ID  existe
    IF NOT EXISTS (SELECT 1 FROM datosPaciente.Domicilio WHERE id = @id)
    BEGIN
        PRINT 'El domicilio con ID ' + CAST(@id AS VARCHAR) + ' no existe.';
        RETURN;
    END

	-- Eliminar domicilio
	DELETE FROM datosPaciente.Domicilio WHERE id=@id;

	print 'El domicilio con ID ' + cast(@id as VARCHAR) + ' ha sido eliminado correctamente';
END

-- EXEC salud.ElimiDomi 1;
GO

CREATE PROCEDURE datosPaciente.InsertarPrestador
    @nombre VARCHAR(20),
    @tipoPlan VARCHAR(10)
AS
BEGIN
    -- Insertar el nuevo prestador en la tabla
    INSERT INTO datosPaciente.Prestador (nombre, tipoPlan)
    VALUES (@nombre, @tipoPlan);

    PRINT 'Prestador cargado correctamente.';
END;
GO

-- EXEC salud.InserPrestador'Maria', @tipoPlan = 'Plan B';

CREATE OR ALTER PROCEDURE datosPaciente.ModificarPrestador
    @id INT,
    @nuevoNombre VARCHAR(20) = NULL,
    @nuevoTipoPlan VARCHAR(10) = NULL
AS
BEGIN
    -- Verificar que el prestador con dicho ID  existe
    IF NOT EXISTS (SELECT 1 FROM datosPaciente.Prestador WHERE id = @id)
    BEGIN
        PRINT 'El prestador con ID ' + CAST(@id AS VARCHAR) + ' no existe.';
        RETURN;
    END

    -- Actualizar el nombre y el tipo de plan del prestador 
    UPDATE datosPaciente.Prestador
    SET
        nombre = ISNULL(@nuevoNombre, nombre),
        tipoPlan = ISNULL(@nuevoTipoPlan, tipoPlan)
    WHERE id = @id;

    PRINT 'Prestador con ID ' + CAST(@id AS VARCHAR) + ' modificado correctamente.';
END
GO
-- EXEC salud.ModifPrestador 2, 'Messi';

CREATE OR ALTER PROCEDURE datosPaciente.EliminarPrestador
    @id INT
AS
BEGIN
    -- Verificar que el prestador con dicho ID  existe
    IF NOT EXISTS (SELECT 1 FROM datosPaciente.Prestador WHERE id = @id)
    BEGIN
        PRINT 'El prestador con ID ' + CAST(@id AS VARCHAR) + ' no existe.';
        RETURN;
    END

	DECLARE @fechaBorrado DATETIME = GETDATE()

    -- Borrado logico del prestador
    UPDATE datosPaciente.Prestador
	SET fechaBorrado = @fechaBorrado
	WHERE id = @id;

    PRINT 'Prestador con ID ' + CAST(@id AS VARCHAR) + ' eliminado correctamente.';
END;

-- EXEC salud.ElimPrestador 2;
go

CREATE OR ALTER PROCEDURE datosPaciente.InsertarCobertura
    @imagenCredencial VARCHAR(40),
    @nroSocio INT,
    @fechaRegistro DATE,
    @idPrestador INT
AS
BEGIN
    -- Verificar que el prestador con dicho ID existe en la tabla Prestador
    IF NOT EXISTS (SELECT 1 FROM datosPaciente.Prestador WHERE id = @idPrestador)
    BEGIN
        PRINT 'El prestador con ID ' + CAST(@idPrestador AS VARCHAR) + ' no existe.';
        RETURN;
    END

    -- Insertar el nuevo registro en la tabla Cobertura
    INSERT INTO datosPaciente.Cobertura (imagenCredencial, nroSocio, fechaRegistro, idPrestador)
    VALUES (@imagenCredencial, @nroSocio, @fechaRegistro, @idPrestador);

    PRINT 'Registro de Cobertura insertado correctamente.';
END
GO
--EXEC salud.InserCobertura 'nombre_imagen',  12345, '2023-10-06', 1;

CREATE OR ALTER PROCEDURE datosPaciente.ModificarCobertura
    @id INT,
    @nuevaImagenCredencial VARCHAR(40) = NULL,
    @nuevoNroSocio INT = NULL,
    @nuevaFechaRegistro DATE = NULL,
    @nuevoIdPrestador INT = NULL
AS
BEGIN
    -- Verificar que la cobertura con dicho ID existe
    IF NOT EXISTS (SELECT 1 FROM datosPaciente.Cobertura WHERE id = @id)
    BEGIN
        PRINT 'La cobertura con ID ' + CAST(@id AS VARCHAR) + ' no existe.';
        RETURN;
    END

    -- Verificar que el nuevo prestador con dicho ID existe en la tabla Prestador
    IF @nuevoIdPrestador IS NOT NULL AND NOT EXISTS (SELECT 1 FROM datosPaciente.Prestador WHERE id = @nuevoIdPrestador)
    BEGIN
        PRINT 'El nuevo prestador con ID ' + CAST(@nuevoIdPrestador AS VARCHAR) + ' no existe.';
        RETURN;
    END

    -- Actualizar los campos 
    UPDATE datosPaciente.Cobertura
    SET
        imagenCredencial = ISNULL(@nuevaImagenCredencial, imagenCredencial),
        nroSocio = ISNULL(@nuevoNroSocio, nroSocio),
        fechaRegistro = ISNULL(@nuevaFechaRegistro, fechaRegistro),
        idPrestador = ISNULL(@nuevoIdPrestador, idPrestador)
    WHERE id = @id;

    PRINT 'Cobertura con ID ' + CAST(@id AS VARCHAR) + ' modificada correctamente.';
END;
GO
-- EXEC salud.ModifCobertura 1, 'nueva'

CREATE OR ALTER PROCEDURE datosPaciente.EliminarCobertura
    @idPrestador INT
AS
BEGIN
    -- Verificar que el prestador con dicho ID existe en la tabla Prestador
    IF NOT EXISTS (SELECT 1 FROM datosPaciente.Prestador WHERE id = @idPrestador)
    BEGIN
        PRINT 'El prestador con ID ' + CAST(@idPrestador AS VARCHAR) + ' no existe.';
        RETURN;
    END

   DECLARE @fechaBorrado DATETIME = GETDATE()

    -- Borrado logico de todas las coberturas asociadas al prestador
    UPDATE datosPaciente.Cobertura
	SET fechaBorrado = @fechaBorrado
	WHERE id = @idPrestador;

    PRINT 'Coberturas del prestador con ID ' + CAST(@idPrestador AS VARCHAR) + ' eliminadas correctamente.';
END;

-- EXEC salud.ElimCobertura 1
GO

-- select * from salud.Cobertura
-- select * from salud.Prestador

CREATE OR ALTER PROCEDURE datosAtencion.InsertarEspecialidad
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
	VALUES
	(@nombreEspecialidad)

	PRINT 'Especialidad ingresada correctamente.';
END

--SELECT * FROM datosAtencion.Especialidad
--EXEC datosAtencion.InsertarEspecialidad 'Traumatología'

GO
CREATE PROCEDURE datosAtencion.ModificarEspecialidad
    @idEspecialidad INT,
    @NuevoNombre VARCHAR(20)
AS
BEGIN
    -- Verificar si la especialidad existe
    IF NOT EXISTS (SELECT 1 FROM datosAtencion.Especialidad WHERE ID = @idEspecialidad)
    BEGIN
        PRINT 'La especialidad especificada no existe.';
        RETURN; 
    END

    -- Validar que el nuevo nombre no esté vacío
    IF LEN(@NuevoNombre) = 0
    BEGIN
        PRINT 'El nuevo nombre no puede estar vacío.';
        RETURN; 
    END

    -- Verificar si el nuevo nombre ya existe en otra fila
    IF EXISTS (SELECT 1 FROM datosAtencion.Especialidad WHERE Nombre = @NuevoNombre AND ID != @idEspecialidad)
    BEGIN
        PRINT 'Ya existe la especialidad por la que queres modificar.';
        RETURN;
    END

    -- Realizar la actualización
    UPDATE datosAtencion.Especialidad
    SET Nombre = @NuevoNombre
    WHERE ID = @idEspecialidad;

    PRINT 'Especialidad actualizada correctamente.';
END

GO
CREATE PROCEDURE datosAtencion.EliminarEspecialidad
    @idEspecialidad INT
AS
BEGIN
    -- Verificar si la @idEspecialidad existe
    IF NOT EXISTS (SELECT 1 FROM datosAtencion.Especialidad WHERE ID = @idEspecialidad)
    BEGIN
        PRINT 'La EspecialidadID especificada no existe.';
        RETURN;
    END

    -- Eliminar la especialidad
    DELETE FROM datosAtencion.Especialidad WHERE ID = @idEspecialidad;

    PRINT 'Especialidad eliminada correctamente.';
END

GO
CREATE OR ALTER PROCEDURE datosAtencion.InsertarSede
	@nombreSede VARCHAR(20),
	@direccionSede VARCHAR(20)
AS
BEGIN
	-- Validar que @nombreSede no sea nulo o vacío
    IF @nombreSede IS NULL OR LEN(@nombreSede) = 0
    BEGIN
        RAISERROR('El nombre de la sede no puede ser nulo o vacío.',16, 1);
        RETURN; 
    END

    -- Validar que @direccionSede no sea nulo o vacío
    IF @direccionSede IS NULL OR LEN(@direccionSede) = 0
    BEGIN
        RAISERROR('La dirección de la sede no puede ser nula o vacía.',16,1);
        RETURN; 
    END

    
    INSERT INTO datosAtencion.SedeAtencion(nombre, direccion)
    VALUES (@nombreSede, @direccionSede);

    PRINT 'Sede insertada correctamente.';
END

GO
CREATE OR ALTER PROCEDURE datosAtencion.ModificarSede
    @SedeID INT,
    @NuevoNombreSede VARCHAR(20),
    @NuevaDireccionSede VARCHAR(20)
AS
BEGIN
 
    IF NOT EXISTS (SELECT 1 FROM datosAtencion.SedeAtencion WHERE id = @SedeID)
    BEGIN
        RAISERROR('La SedeID especificada no existe.',16,1);
        RETURN;
    END

    IF @NuevoNombreSede IS NULL OR LEN(@NuevoNombreSede) = 0
    BEGIN
        RAISERROR('El nuevo nombre de la sede no puede ser nulo o vacío.');
        RETURN;
    END

    IF @NuevaDireccionSede IS NULL OR LEN(@NuevaDireccionSede) = 0
    BEGIN
        RAISERROR('La nueva dirección de la sede no puede ser nula o vacía.');
        RETURN; -- Salir del procedimiento
    END

    UPDATE datosAtencion.SedeAtencion
    SET nombre = @NuevoNombreSede, direccion = @NuevaDireccionSede
    WHERE id = @SedeID;

    PRINT 'Sede modificada correctamente.';
END

GO
CREATE OR ALTER PROCEDURE datosAtencion.EliminarSede
    @SedeID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM datosAtencion.SedeAtencion WHERE id = @SedeID)
    BEGIN
        RETURN;
    END

    UPDATE datosAtencion.SedeAtencion
    SET fechaBorrado = NULL
    WHERE id = @SedeID;

    PRINT 'Sede eliminada correctamente.';
END

GO
CREATE OR ALTER PROCEDURE datosAtencion.InsertarHorarioMedico
    @idSede INT,
    @idMedico INT,
    @diaSemana VARCHAR(10),
    @horaInicio TIME,
    @horaFin TIME
AS
BEGIN
    -- Validar que la Sede exista
    IF NOT EXISTS (SELECT 1 FROM datosAtencion.SedeAtencion WHERE id = @idSede)
    BEGIN
        RAISERROR('La Sede especificada no existe.',16,1);
        RETURN; 
    END

    -- Validar que el Médico exista
    IF NOT EXISTS (SELECT 1 FROM datosAtencion.Medico WHERE id = @idMedico)
    BEGIN
        RAISERROR('El Médico especificado no existe.',16,1);
        RETURN; 
    END

    -- Validar que los campos no sean nulos o vacíos
    IF @diaSemana IS NULL OR @horaInicio IS NULL OR @horaFin IS NULL
    BEGIN
        RAISERROR('Los campos no pueden ser nulos.',16,1);
        RETURN; 
    END

    IF LEN(@diaSemana) = 0
    BEGIN
        RAISERROR('El campo "diaSemana" no puede estar vacío.',16,1);
        RETURN;
    END

    -- Insertar el nuevo registro
    INSERT INTO datosAtencion.DiasXSede(idSede, idMedico, diaSemana, horaInicio, horaFin)
    VALUES (@idSede, @idMedico, @diaSemana, @horaInicio, @horaFin);

    PRINT 'Registro de horario de médico insertado correctamente.';
END

GO
CREATE OR ALTER PROCEDURE datosAtencion.ModificarHorarioMedico
    @idSede INT,
    @idMedico INT,
    @diaSemana VARCHAR(10),
    @nuevaHoraInicio TIME,
    @nuevaHoraFin TIME
AS
BEGIN
    -- Verificar si el registro existe en la tabla
    IF NOT EXISTS (
        SELECT 1
        FROM datosAtencion.DiasXSede
        WHERE idSede = @idSede
          AND idMedico = @idMedico
          AND diaSemana = @diaSemana
    )
    BEGIN
        RAISERROR('El registro que intenta modificar no existe.',16,1);
        RETURN; 
    END

    -- Validar que los campos no sean nulos o vacíos
    IF @nuevaHoraInicio IS NULL OR @nuevaHoraFin IS NULL
    BEGIN
        RAISERROR('Los campos de hora no pueden ser nulos.',16,1);
        RETURN; 
    END

    -- Realizar la actualización del registro
    UPDATE datosAtencion.DiasXSede
    SET horaInicio = @nuevaHoraInicio,
        horaFin = @nuevaHoraFin
    WHERE idSede = @idSede
      AND idMedico = @idMedico
      AND diaSemana = @diaSemana;

    PRINT 'Registro de horario de médico modificado correctamente.';
END

GO
CREATE OR ALTER PROCEDURE datosAtencion.EliminarHorarioMedico
    @idSede INT,
    @idMedico INT,
    @diaSemana VARCHAR(10)
AS
BEGIN
    -- Verificar si el registro existe en la tabla
    IF NOT EXISTS (
        SELECT 1
        FROM datosAtencion.DiasXSede
        WHERE idSede = @idSede
          AND idMedico = @idMedico
          AND diaSemana = @diaSemana
    )
    BEGIN
        RAISERROR('El registro que intenta eliminar no existe.',16,1);
        RETURN;
    END

    -- Realizar la eliminación del registro
    DELETE FROM datosAtencion.DiasXSede
    WHERE idSede = @idSede
      AND idMedico = @idMedico
      AND diaSemana = @diaSemana;

    PRINT 'Registro de horario de médico eliminado correctamente.';
END

GO
CREATE OR ALTER PROCEDURE datosReserva.InsertarTipoTurno
    @nombre VARCHAR(10)
AS
BEGIN
    -- Validar que @nombre sea "presencial" o "virtual"
    IF @nombre NOT IN ('Presencial', 'Virtual')
    BEGIN
        RAISERROR('El nombre del tipo de turno debe ser "presencial" o "virtual".',16,1);
        RETURN; 
    END

    -- Insertar el nuevo tipo de turno
    INSERT INTO datosReserva.TipoTurno (nombre)
    VALUES (@nombre);

    PRINT 'Tipo de turno insertado correctamente.';
END

GO
CREATE OR ALTER PROCEDURE datosReserva.ModificarTipoTurno
    @id INT,
    @nuevoNombre VARCHAR(10)
AS
BEGIN
    -- Validar que @id exista en la tabla
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

    -- Realizar la actualización del nombre del tipo de turno
    UPDATE datosReserva.TipoTurno
    SET nombre = @nuevoNombre
    WHERE id = @id;

    PRINT 'Nombre del tipo de turno modificado correctamente.';
END

GO
CREATE OR ALTER PROCEDURE datosReserva.EliminarTipoTurno
    @id INT
AS
BEGIN
    -- Verificar si el registro existe en la tabla
    IF NOT EXISTS (SELECT 1 FROM datosReserva.TipoTurno WHERE id = @id)
    BEGIN
        RAISERROR('El ID del tipo de turno especificado no existe.',16,1);
        RETURN; 
    END

    -- Realizar la eliminación del registro estableciendo fechaBorrado
    UPDATE datosReserva.TipoTurno
    SET fechaBorrado = GETDATE()
    WHERE id = @id;

    PRINT 'Tipo de turno eliminado correctamente.';
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

