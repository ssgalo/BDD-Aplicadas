USE CURESA

-------------------------------------- TABLA USUARIO --------------------------------------
-- Caso de prueba: Insertar un nuevo usuario
EXEC datosPaciente.InsertarUsuario @contraseña = 'Password'
SELECT * FROM datosPaciente.Usuario WHERE contraseña = 'Password'

-- Caso de prueba: Modificar la contraseña de un usuario existente
EXEC datosPaciente.InsertarUsuario @contraseña = 'Password123'

DECLARE @idUsuario INT
SELECT @idUsuario = id FROM datosPaciente.Usuario WHERE contraseña = 'Password123'
EXEC datosPaciente.ModificarUsuario @id = @idUsuario, @nuevaContraseña = 'NewPassword'

SELECT * FROM datosPaciente.Usuario WHERE id = @idUsuario

-- Caso de prueba: Eliminar un usuario existente
EXEC datosPaciente.InsertarUsuario @contraseña = 'Password124'

DECLARE @idUsuario INT
SELECT @idUsuario = id FROM datosPaciente.Usuario WHERE contraseña = 'Password124'
EXEC datosPaciente.EliminarUsuario @id = @idUsuario

SELECT * FROM datosPaciente.Usuario WHERE id = @idUsuario

-------------------------------------- TABLA COBERTURA --------------------------------------
-- Caso de prueba: Insertar una nueva cobertura
EXEC datosPaciente.InsertarPrestador
    @nombre = 'Prestador test',
    @tipoPlan = 'Plan de Cobertura'

SELECT * FROM datosPaciente.Prestador

DECLARE @idPrestador INT
SELECT @idPrestador = id FROM datosPaciente.Prestador WHERE nombre = 'Prestador test'

EXEC datosPaciente.InsertarCobertura
    @imagenCredencial = 'Credencial123.jpg',
    @nroSocio = 123456,
    @fechaRegistro = '2023-10-16',
    @idPrestador = @idPrestador

SELECT * FROM datosPaciente.Cobertura 

-- Caso de prueba: Modificar una cobertura existente
EXEC datosPaciente.InsertarPrestador
    @nombre = 'Prestador test 2',
    @tipoPlan = 'Plan 2'

DECLARE @idPrestador INT
SELECT @idPrestador = id FROM datosPaciente.Prestador WHERE nombre = 'Prestador test 2'
EXEC datosPaciente.InsertarCobertura
    @imagenCredencial = 'Credencial789.jpg',
    @nroSocio = 789012,
    @fechaRegistro = '2023-10-17',
    @idPrestador = @idPrestador

DECLARE @idCobertura INT
SELECT @idCobertura = id FROM datosPaciente.Cobertura WHERE nroSocio = 789012

EXEC datosPaciente.ModificarCobertura
    @id = @idCobertura,
    @nuevaImagenCredencial = 'NuevaCredencial.jpg',
    @nuevoNroSocio = 654321

SELECT * FROM datosPaciente.Cobertura 

-------------------------------------- TABLA PRESTADOR --------------------------------------

-- Caso de prueba: Eliminar un prestador existente
EXEC datosPaciente.InsertarPrestador
    @nombre = 'Prestador E2',
    @tipoPlan = 'Plan B'

DECLARE @idPrestador INT
SELECT @idPrestador = id FROM datosPaciente.Prestador WHERE nombre = 'Prestador E2'
EXEC datosPaciente.EliminarPrestador @id = @idPrestador

SELECT * FROM datosPaciente.Prestador 


/*
-------------------------------------- TABLA ESTUDIO --------------------------------------
-- Llamamos al procedimiento para insertar un estudio de ejemplo
EXEC datosPaciente.InsertarEstudio
    @fecha = '2023-11-15',
    @nombre = 'Análisis de sangre',
    @autorizado = 1,
    @linkDocumentoResultado = 'https://example.com/resultadodocumento.pdf',
    @imagenResultado = 'resultadoimagen.jpg';

SELECT * FROM datosPaciente.Estudio WHERE nombre = 'Análisis de sangre';

-- Supongamos que ya existe un estudio con ID 1 y queremos modificar sus datos
EXEC datosPaciente.ModificarEstudio
    @id = 1,
    @fecha = '2023-12-20',
    @nombre = 'Radiografía de tórax',
    @autorizado = 0,
    @linkDocumentoResultado = 'https://example.com/nuevoresultado.pdf',
    @imagenResultado = 'nuevaimagen.jpg';

SELECT * FROM datosPaciente.Estudio WHERE id = 1;

-- Supongamos que queremos eliminar el estudio con ID 3
EXEC datosPaciente.EliminarEstudio @id = 3;

SELECT * FROM datosPaciente.Estudio WHERE id = 3;

-------------------------------------- TABLA RESERVA --------------------------------------
-- Llamamos al procedimiento para insertar una reserva de ejemplo
EXEC datosReserva.InsertarReserva
    @fecha = '2023-11-15',
    @hora = '14:30:00',
    @idMedico = 1,
    @idEspecialidad = 2,
    @idDireccionAtencion = 3,
    @idEstadoTurno = 4,
    @idTipoTurno = 5,
    @idPaciente = 6;

SELECT * FROM datosReserva.Reserva WHERE fecha = '2023-11-15' AND hora = '14:30:00';

-- Supongamos que ya existe una reserva con ID 1 y queremos modificar sus datos
EXEC datosReserva.ModificarReserva
    @id = 1,
    @fecha = '2023-12-20',
    @hora = '15:00:00',
    @idMedico = 2,
    @idEspecialidad = 3,
    @idDireccionAtencion = 4,
    @idEstadoTurno = 5,
    @idTipoTurno = 6,
    @idPaciente = 7;

-- Verificamos si los datos de la reserva con ID 1 se han modificado correctamente
SELECT * FROM datosReserva.Reserva WHERE id = 1;

-- Supongamos que queremos eliminar la reserva con ID 3
EXEC datosReserva.EliminarReserva @id = 3;

SELECT * FROM datosReserva.Reserva WHERE id = 3;

-------------------------------------- TABLA ESTADO TURNO --------------------------------------
-- Llamamos al procedimiento para insertar un estado de turno de ejemplo
EXEC datosReserva.InsertarEstadoTurno @nombreEstado = 'Atendido';

SELECT * FROM datosReserva.EstadoTurno WHERE nombreEstado = 'Atendido';

-- Supongamos que ya existe un estado de turno con ID 1 y queremos modificar su nombre
EXEC datosReserva.ModificarEstadoTurno @id = 1, @nuevoNombreEstado = 'Cancelado';

SELECT * FROM datosReserva.EstadoTurno WHERE id = 1;

-- Supongamos que queremos eliminar el estado de turno con ID 1
EXEC datosReserva.EliminarEstadoTurno @id = 1;

SELECT * FROM datosReserva.EstadoTurno WHERE id = 1;

-------------------------------------- TABLA TIPO TURNO --------------------------------------
-- Caso de prueba: Insertar un nuevo tipo de turno
EXEC datosReserva.InsertarTipoTurno @nombre = 'Presencial'

SELECT * FROM datosReserva.TipoTurno WHERE nombre = 'Presencial'

-- Caso de prueba: Modificar un tipo de turno existente
EXEC datosReserva.InsertarTipoTurno @nombre = 'Virtual'

DECLARE @TipoTurnoID INT
SELECT @TipoTurnoID = id FROM datosReserva.TipoTurno WHERE nombre = 'Virtual'
EXEC datosReserva.ModificarTipoTurno
    @id = @TipoTurnoID,
    @nuevoNombre = 'Presencial'

SELECT * FROM datosReserva.TipoTurno WHERE id = @TipoTurnoID

-- Caso de prueba: Eliminar un tipo de turno
EXEC datosReserva.InsertarTipoTurno @nombre = 'Presencial'

DECLARE @TipoTurnoID INT
SELECT @TipoTurnoID = id FROM datosReserva.TipoTurno WHERE nombre = 'Presencial'
EXEC datosReserva.EliminarTipoTurno @id = @TipoTurnoID

SELECT * FROM datosReserva.TipoTurno WHERE id = @TipoTurnoID

-------------------------------------- TABLA DIAS X SEDE --------------------------------------
-- Caso de prueba: Insertar un nuevo horario de médico
EXEC datosAtencion.InsertarSede
    @nombreSede = 'Sede Prueba 1',
    @direccionSede = 'Calle de la Prueba, 123'

EXEC datosAtencion.InsertarMedico
    @nombre = 'Médico de Prueba',
    @apellido = 'Apellido Prueba',
    @nroMatricula = 12345,
    @idEspecialidad = 1  --TIENE QUE EXISTIR LA ESPECIALIDAD!!

DECLARE @SedeID INT
SELECT @SedeID = id FROM datosAtencion.SedeAtencion WHERE nombre = 'Sede Prueba 1'

DECLARE @MedicoID INT
SELECT @MedicoID = id FROM datosAtencion.Medico WHERE nombre = 'Médico de Prueba'

EXEC datosAtencion.InsertarHorarioMedico
    @idSede = @SedeID,
    @idMedico = @MedicoID,
    @diaSemana = 'Lunes',
    @horaInicio = '09:00:00',
    @horaFin = '15:00:00'

SELECT * FROM datosAtencion.DiasXSede WHERE idSede = @SedeID AND idMedico = @MedicoID AND diaSemana = 'Lunes'

-- Caso de prueba: Modificar un horario de médico existente
EXEC datosAtencion.InsertarSede
    @nombreSede = 'Sede Prueba 2',
    @direccionSede = 'Calle de la Prueba, 456'

EXEC datosAtencion.InsertarMedico
    @nombre = 'Médico de Prueba 2',
    @apellido = 'Apellido Prueba',
    @nroMatricula = 54321,
    @idEspecialidad = 2 --TIENE QUE EXISTIR LA ESPECIALIDAD!!

EXEC datosAtencion.InsertarHorarioMedico
    @idSede = 1,  -- Asegúrate de que la sede de prueba exista
    @idMedico = 1,  -- Asegúrate de que el médico de prueba exista
    @diaSemana = 'Martes',
    @horaInicio = '10:00:00',
    @horaFin = '16:00:00'

DECLARE @SedeID INT
SELECT @SedeID = id FROM datosAtencion.SedeAtencion WHERE nombre = 'Sede Prueba 2'

DECLARE @MedicoID INT
SELECT @MedicoID = id FROM datosAtencion.Medico WHERE nombre = 'Médico de Prueba 2'

EXEC datosAtencion.ModificarHorarioMedico
    @idSede = @SedeID,
    @idMedico = @MedicoID,
    @diaSemana = 'Martes',
    @nuevaHoraInicio = '11:00:00',
    @nuevaHoraFin = '17:00:00'

SELECT * FROM datosAtencion.DiasXSede WHERE idSede = @SedeID AND idMedico = @MedicoID AND diaSemana = 'Martes'

-- Caso de prueba: Eliminar un horario de médico
DECLARE @SedeID INT
SELECT @SedeID = id FROM datosAtencion.SedeAtencion WHERE nombre = 'Sede Prueba 2'

-- Paso 5: Obtener el ID del médico insertado
DECLARE @MedicoID INT
SELECT @MedicoID = id FROM datosAtencion.Medico WHERE nombre = 'Médico de Prueba 2'

-- Paso 6: Ejecutar el SP para eliminar el horario de médico
EXEC datosAtencion.EliminarHorarioMedico
    @idSede = @SedeID,
    @idMedico = @MedicoID,
    @diaSemana = 'Martes'

SELECT * FROM datosAtencion.DiasXSede WHERE idSede = @SedeID AND idMedico = @MedicoID AND diaSemana = 'Miércoles'

-------------------------------------- TABLA SEDE DE ATENCIÓN --------------------------------------
-- Caso de prueba: Insertar una nueva sede de atención
EXEC datosAtencion.InsertarSede
    @nombreSede = 'Sede Prueba 1',
    @direccionSede = 'F. Varela 123'

SELECT * FROM datosAtencion.SedeAtencion WHERE nombre = 'Sede Prueba 1'

-- Caso de prueba: Modificar una sede de atención existente
EXEC datosAtencion.InsertarSede
    @nombreSede = 'Sede Prueba 2',
    @direccionSede = 'F. Varela 456'

DECLARE @SedeID INT
SELECT @SedeID = id FROM datosAtencion.SedeAtencion WHERE nombre = 'Sede Prueba 2'

EXEC datosAtencion.ModificarSede
    @SedeID = @SedeID,
    @NuevoNombreSede = 'Nueva Sede Prueba',
    @NuevaDireccionSede = 'F. Varela 789'

SELECT * FROM datosAtencion.SedeAtencion WHERE id = @SedeID

-- Caso de prueba: Eliminar una sede de atención
EXEC datosAtencion.InsertarSede
    @nombreSede = 'Sede Prueba 3',
    @direccionSede = 'Calle de la Prueba, 111'

DECLARE @SedeID INT
SELECT @SedeID = id FROM datosAtencion.SedeAtencion WHERE nombre = 'Sede Prueba 3'

EXEC datosAtencion.EliminarSede
    @SedeID = @SedeID

SELECT * FROM datosAtencion.SedeAtencion WHERE id = @SedeID


-------------------------------------- TABLA MEDICO --------------------------------------
-- Llamamos al procedimiento para insertar un médico de ejemplo
EXEC datosAtencion.InsertarMedico
    @nombre = 'Juan',
    @apellido = 'Pérez',
    @nroMatricula = 12345,
    @idEspecialidad = 1;

SELECT * FROM datosAtencion.Medico WHERE nroMatricula = 12345;

-- Supongamos que ya existe un médico con ID 1 y queremos modificar sus datos
EXEC datosAtencion.ModifMedico
    @id = 1,
    @nombre = 'NuevoNombre',
    @apellido = 'NuevoApellido',
    @nroMatricula = 54321,
    @idEspecialidad = 2;

SELECT * FROM datosAtencion.Medico WHERE id = 1;

-- Supongamos que queremos eliminar al médico con ID 3
EXEC datosAtencion.EliminarMedico @id = 3;

SELECT * FROM datosAtencion.Medico WHERE id = 3;

-------------------------------------- TABLA ESPECIALIDAD --------------------------------------
-- Caso de prueba: Insertar una nueva especialidad
EXEC datosAtencion.InsertarEspecialidad
    @nombreEspecialidad = 'Cardiología'

SELECT * FROM datosAtencion.Especialidad WHERE nombre = 'Cardiología'

-- Caso de prueba: Modificar una especialidad existente
EXEC datosAtencion.InsertarEspecialidad
    @nombreEspecialidad = 'Oftalmología'

DECLARE @idEspecialidad INT
SELECT @idEspecialidad = id FROM datosAtencion.Especialidad WHERE nombre = 'Oftalmología'

EXEC datosAtencion.ModificarEspecialidad
    @idEspecialidad = @idEspecialidad,
    @NuevoNombre = 'Nueva Oftalmología'

SELECT * FROM datosAtencion.Especialidad WHERE id = @idEspecialidad

-- Caso de prueba: Eliminar una especialidad
EXEC datosAtencion.InsertarEspecialidad
    @nombreEspecialidad = 'Dermatología'

DECLARE @idEspecialidad INT
SELECT @idEspecialidad = id FROM datosAtencion.Especialidad WHERE nombre = 'Dermatología'

EXEC datosAtencion.EliminarEspecialidad
    @idEspecialidad = @idEspecialidad

SELECT * FROM datosAtencion.Especialidad WHERE id = @idEspecialidad
*/
