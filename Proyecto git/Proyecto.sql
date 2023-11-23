CREATE DATABASE IF NOT EXISTS ParqueaderoDB;
USE ParqueaderoDB;

-- Creación de la tabla Vehiculos
CREATE TABLE Vehiculos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    placa VARCHAR(20) NOT NULL,
    hora_entrada DATETIME NOT NULL
);

-- Creación de la tabla Tarifas
CREATE TABLE Tarifas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    valor_por_hora DECIMAL(10, 2) NOT NULL
);

-- Creación de la tabla Puestos
CREATE TABLE Puestos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ocupado BOOLEAN NOT NULL DEFAULT FALSE
);




-- Insertar tarifa
INSERT INTO Tarifas (valor_por_hora) VALUES (5.00);

-- Insertar puestos de parqueadero (suponiendo 10 puestos)
INSERT INTO Puestos (ocupado) VALUES 
    (FALSE), (FALSE), (FALSE), (TRUE), (FALSE), 
    (TRUE), (FALSE), (FALSE), (TRUE), (FALSE);

-- Insertar algunos vehículos de ejemplo
INSERT INTO Vehiculos (placa, hora_entrada) VALUES 
    ('ABC123', '2023-11-22 09:30:00'),
    ('XYZ789', '2023-11-22 10:15:00'),
    ('DEF456', '2023-11-22 11:00:00');
    
    
    
    
DELIMITER //
CREATE PROCEDURE RegistrarEntradaVehiculo(
    IN placaVehiculo VARCHAR(20)
)
BEGIN
    DECLARE puestoLibre INT;

    -- Buscar un puesto libre
    SELECT id INTO puestoLibre FROM Puestos WHERE ocupado = FALSE LIMIT 1;

    -- Si se encontró un puesto libre, registrar la entrada del vehículo
    IF puestoLibre IS NOT NULL THEN
        -- Marcar el puesto como ocupado
        UPDATE Puestos SET ocupado = TRUE WHERE id = puestoLibre;

        -- Insertar el vehículo en la tabla Vehiculos
        INSERT INTO Vehiculos (placa, hora_entrada) VALUES (placaVehiculo, NOW());
        SELECT 'Entrada registrada correctamente.' AS mensaje;
    ELSE
        SELECT 'No hay puestos disponibles en este momento.' AS mensaje;
    END IF;
END //
DELIMITER ;



DELIMITER //

CREATE PROCEDURE RegistrarSalidaVehiculo(
    IN placaVehiculo VARCHAR(20)
)
BEGIN
    DECLARE vehiculoID INT;
    DECLARE costo DECIMAL(10, 2);
    DECLARE horaEntrada DATETIME;
    DECLARE tiempoEstacionado INT;

    -- Obtener el ID del vehículo por la placa
    SELECT id, hora_entrada INTO vehiculoID, horaEntrada FROM Vehiculos WHERE placa = placaVehiculo;

    IF vehiculoID IS NOT NULL THEN
        -- Calcular el tiempo transcurrido en horas
        SET tiempoEstacionado = TIMESTAMPDIFF(HOUR, horaEntrada, NOW());

        -- Obtener la tarifa por hora
        SELECT valor_por_hora INTO costo FROM Tarifas;

        -- Calcular el costo total
        SET costo = tiempoEstacionado * costo;

        -- Liberar el puesto ocupado por el vehículo
        UPDATE Puestos SET ocupado = FALSE WHERE id = vehiculoID;

        -- Eliminar el registro del vehículo
        DELETE FROM Vehiculos WHERE id = vehiculoID;

        SELECT CONCAT('El vehículo con placa ', placaVehiculo, ' ha salido. Costo total: ', costo, ' pesos.') AS mensaje;
    ELSE
        SELECT 'El vehículo no se encuentra en el parqueadero.' AS mensaje;
    END IF;
END //

DELIMITER ;







DELIMITER //
CREATE PROCEDURE VerificarOcupacionPuestos()
BEGIN
    SELECT COUNT(*) AS puestos_ocupados FROM Puestos WHERE ocupado = TRUE;
END //
DELIMITER ;

CALL RegistrarEntradaVehiculo('ASD123');
SHOW PROCEDURE STATUS;

SHOW CREATE PROCEDURE VerificarOcupacionPuestos;

SELECT * FROM puestos;
SELECT * FROM tarifas;
SELECT * FROM vehiculos;