-- У всіх таблицях створити поля UCR, DCR, ULC, DLC.
-- Написати тригери які будуть заповнювати дані поля наступним чином:
-- UCR – ім’я користувача, що створив даний запис;
-- DCR – дата та час створення даного запису;
-- ULC – ім’я користувача, що останнім змінив даний запис;
-- DLC – дата та час останньої модифікації даного запису.

use airport;

-- Додавання полів UCR, DCR, ULC, DLC до таблиці planes
ALTER TABLE planes
ADD COLUMN UCR VARCHAR(50),
ADD COLUMN DCR TIMESTAMP,
ADD COLUMN ULC VARCHAR(50),
ADD COLUMN DLC TIMESTAMP;

-- Тригер для заповнення полів UCR, DCR, ULC, DLC у таблиці planes
DELIMITER //
CREATE TRIGGER planes_audit_trigger
BEFORE INSERT ON planes
FOR EACH ROW
BEGIN
    SET NEW.UCR = USER();
    SET NEW.DCR = CURRENT_TIMESTAMP;
    SET NEW.ULC = USER();
    SET NEW.DLC = CURRENT_TIMESTAMP;
END //
DELIMITER ;


-- Додавання полів UCR, DCR, ULC, DLC до таблиці flights
ALTER TABLE flights
ADD COLUMN UCR VARCHAR(50),
ADD COLUMN DCR TIMESTAMP,
ADD COLUMN ULC VARCHAR(50),
ADD COLUMN DLC TIMESTAMP;

-- Тригер для заповнення полів UCR, DCR, ULC, DLC у таблиці flights
DELIMITER //
CREATE TRIGGER flights_audit_trigger
BEFORE INSERT ON flights
FOR EACH ROW
BEGIN
    SET NEW.UCR = USER();
    SET NEW.DCR = CURRENT_TIMESTAMP;
    SET NEW.ULC = USER();
    SET NEW.DLC = CURRENT_TIMESTAMP;
END //
DELIMITER ;


-- Додавання полів UCR, DCR, ULC, DLC до таблиці crew_members
ALTER TABLE crew_members
ADD COLUMN UCR VARCHAR(50),
ADD COLUMN DCR TIMESTAMP,
ADD COLUMN ULC VARCHAR(50),
ADD COLUMN DLC TIMESTAMP;

-- Тригер для заповнення полів UCR, DCR, ULC, DLC у таблиці crew_members
DELIMITER //
CREATE TRIGGER crew_members_audit_trigger
BEFORE INSERT ON crew_members
FOR EACH ROW
BEGIN
    SET NEW.UCR = USER();
    SET NEW.DCR = CURRENT_TIMESTAMP;
    SET NEW.ULC = USER();
    SET NEW.DLC = CURRENT_TIMESTAMP;
END //
DELIMITER ;


-- Додавання полів UCR, DCR, ULC, DLC до таблиці pilots
ALTER TABLE pilots
ADD COLUMN UCR VARCHAR(50),
ADD COLUMN DCR TIMESTAMP,
ADD COLUMN ULC VARCHAR(50),
ADD COLUMN DLC TIMESTAMP;

-- Тригер для заповнення полів UCR, DCR, ULC, DLC у таблиці pilots
DELIMITER //
CREATE TRIGGER pilots_audit_trigger
BEFORE INSERT ON pilots
FOR EACH ROW
BEGIN
    SET NEW.UCR = USER();
    SET NEW.DCR = CURRENT_TIMESTAMP;
    SET NEW.ULC = USER();
    SET NEW.DLC = CURRENT_TIMESTAMP;
END //
DELIMITER ;


-- Додавання полів UCR, DCR, ULC, DLC до таблиці flight_crew
ALTER TABLE flight_crew
ADD COLUMN UCR VARCHAR(50),
ADD COLUMN DCR TIMESTAMP,
ADD COLUMN ULC VARCHAR(50),
ADD COLUMN DLC TIMESTAMP;

-- Тригер для заповнення полів UCR, DCR, ULC, DLC у таблиці flight_crew
DELIMITER //
CREATE TRIGGER flight_crew_audit_trigger
BEFORE INSERT ON flight_crew
FOR EACH ROW
BEGIN
SET NEW.UCR = USER();
SET NEW.DCR = CURRENT_TIMESTAMP;
SET NEW.ULC = USER();
SET NEW.DLC = CURRENT_TIMESTAMP;
END //
DELIMITER ;

-- Створити сурогатний ключ для деякої таблиці,
-- та написати тригер для обов’язкового заповнення цього поля послідовними значеннями.

-- Створення сурогатного ключа для таблиці planes
ALTER TABLE planes
MODIFY COLUMN id INTEGER AUTO_INCREMENT;

-- Забезпечення унікальності сурогатного ключа
ALTER TABLE planes
ADD CONSTRAINT pk_planes PRIMARY KEY (id);

-- В кожного пілота повинна бути перерва між вильотами не менше трьох днів.

DELIMITER //
CREATE TRIGGER check_pilot_break
BEFORE INSERT ON flights
FOR EACH ROW
BEGIN
  DECLARE last_flight_date TIMESTAMP;
  SET last_flight_date = (
    SELECT MAX(landing_time)
    FROM flights
    WHERE plane_id = NEW.plane_id
      AND landing_time < NEW.departure_time
  );

  IF last_flight_date IS NOT NULL AND DATEDIFF(NEW.departure_time, last_flight_date) < 3 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'The pilot must have a break of at least three days between flights.';
  END IF;
END //
DELIMITER ;

-- Система повинна не дозволяти конфлікти з призначенням персоналу одночасно на кілька вильотів.
DELIMITER //
CREATE TRIGGER check_flight_crew_assignment
BEFORE INSERT ON flight_crew
FOR EACH ROW
BEGIN
  IF EXISTS (
    SELECT 1
    FROM flight_crew
    WHERE crew_member_id = NEW.crew_member_id
      AND flight_id <> NEW.flight_id
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'The crew member is already assigned to another flight.';
  END IF;
END //
DELIMITER ;

-- INSERT INTO flights (departure_point, destination_point, departure_time, landing_time, plane_id, sold_tickets_number)
 -- VALUES ('Kyiv', 'London', '2023-05-22 10:00:00', '2023-05-22 14:00:00', 1, 100);

INSERT INTO flights (departure_point, destination_point, departure_time, landing_time, plane_id, sold_tickets_number)
VALUES ('Paris', 'Berlin', '2023-05-24 12:00:00', '2023-05-24 15:00:00', 1, 80);

-- INSERT INTO flight_crew (flight_id, crew_member_id)
--  VALUES (1, 1);

INSERT INTO flight_crew (flight_id, crew_member_id)
VALUES (2, 1);

SELECT * FROM planes;