-- Este SCRIPT no está pensado para ejecutarse todo "de una". Está pensado para ir ejecutando de a secciones con el fin de probar los objetos ya creados
USE CURESA

-- CREACIÓN DE GENÉRICOS PARA ASIGNAR LAS FK CUANDO NO HAY NADA
INSERT INTO datosPaciente.Usuario (contraseña, fechaCreacion, fechaBorrado)
VALUES
('12345678', GETDATE(), NULL)

INSERT INTO datosPaciente.Estudio (fecha, nombre, autorizado, linkDocumentoResultado, imagenResultado, fechaBorrado)
VALUES
(GETDATE(), 'Generico', 0, 'Generico', 'Generico', NULL) 

INSERT INTO datosPaciente.Prestador(nombre, tipoPlan, fechaBorrado)
VALUES
('Generico', 'Generico', NULL)

INSERT INTO datosPaciente.Cobertura(imagenCredencial, nroSocio, fechaRegistro, idPrestador)
VALUES
('Generico', 1, GETDATE(), 1)

-- CSV Pacientes
SELECT * FROM datosPaciente.Paciente
SELECT * FROM datosPaciente.Domicilio
EXEC CargarDatosDesdeCSV_Pacientes

-- CSV Medicos
SELECT * FROM datosAtencion.Especialidad
SELECT * FROM datosAtencion.Medico
EXEC CargarDatosDesdeCSV_Medicos

-- CSV Sedes
SELECT * FROM datosAtencion.SedeAtencion
EXEC CargarDatosDesdeCSV_Sedes

-- CSV Prestador
SELECT * FROM datosPaciente.Prestador
EXEC CargarDatosDesdeCSV_Prestadores

-- Inserción de ejemplo para luego obtener el XML
INSERT INTO datosReserva.EstadoTurno (nombreEstado, fechaBorrado) -- tal cual indica el der
VALUES
    ('Atendido', NULL),
	('Ausente', NULL),
    ('Cancelado', NULL);

INSERT INTO datosReserva.Reserva (fecha, hora, idMedico, idEspecialidad, idEstadoTurno, idPaciente)	-- reservas genericas
VALUES
    ('2023-10-09', '09:00:00', 1, 1, 2, 25111003),
    ('2023-10-10', '14:30:00', 2, 2, 1, 25111004),
    ('2023-10-11', '11:15:00', 3, 3, 2, 25111015),
    ('2023-10-12', '16:45:00', 4, 4, 3, 25111023);

INSERT INTO datosPaciente.Cobertura (imagenCredencial, nroSocio, fechaRegistro, idPrestador, fechaBorrado) -- coberturas genericas
VALUES
    ('imagen1.jpg', 0101, '2023-10-09 08:00:00', 1, NULL),
    ('imagen2.jpg', 0202, '2023-10-09 09:30:00', 2, NULL),
    ('imagen3.jpg', 0303, '2023-10-09 10:45:00', 3, NULL),
	('imagen3.jpg', 0404, '2023-10-09 11:45:00', 6, NULL),
	('imagen3.jpg', 0505, '2023-10-09 12:45:00', 7, NULL);

EXEC GenerarInformeTurnos 'Generico', '2023-01-01', '2023-11-30';

-- Cargar desde JSON
SELECT * FROM datosAtencion.Centro_Autorizaciones
EXEC CargarDatosDesdeJSON
