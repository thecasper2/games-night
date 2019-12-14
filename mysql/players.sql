DROP TABLE IF EXISTS event_players;
DROP TABLE IF EXISTS event;
DROP TABLE IF EXISTS player;

CREATE TABLE player (
    player_id INT NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (player_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO player (first_name, last_name) VALUES 
('Alex', 'Dolphin'),
('Tom', 'Ayre');

CREATE TABLE event (
    event_id INT NOT NULL AUTO_INCREMENT,
    creation_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    event_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (event_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO event (event_name) VALUES 
("test_event");

CREATE TABLE event_players (
   event_id INT NOT NULL,
   player_id INT NOT NULL,
   FOREIGN KEY (event_id)  REFERENCES event (event_id)    ON DELETE CASCADE,
   FOREIGN KEY (player_id) REFERENCES player (player_id) ON DELETE CASCADE,
   PRIMARY KEY (event_id, player_id)
);

INSERT INTO event_players (event_id, player_id) VALUES 
(1, 1),
(1, 2);

