DROP TABLE IF EXISTS event_players;
DROP TABLE IF EXISTS event;
DROP TABLE IF EXISTS player;
DROP TABLE IF EXISTS fifa_results;

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
    FOREIGN KEY (event_id)  REFERENCES event (event_id) ON DELETE CASCADE,
    FOREIGN KEY (player_id) REFERENCES player (player_id) ON DELETE CASCADE,
    PRIMARY KEY (event_id, player_id)
);

INSERT INTO event_players (event_id, player_id) VALUES 
(1, 1),
(1, 2);

CREATE TABLE fifa_results (
    match_id INT NOT NULL AUTO_INCREMENT,
    event_id INT NOT NULL,
    home_player_id INT NOT NULL,
    away_player_id INT NOT NULL,
    home_goals INT NOT NULL,
    away_goals INT NOT NULL,
    FOREIGN KEY (event_id)  REFERENCES event (event_id) ON DELETE CASCADE,
    FOREIGN KEY (home_player_id) REFERENCES player (player_id) ON DELETE CASCADE,
    FOREIGN KEY (away_player_id) REFERENCES player (player_id) ON DELETE CASCADE,
    PRIMARY KEY (match_id, event_id)
);

INSERT INTO fifa_results (event_id, home_player_id, away_player_id, home_goals, away_goals) VALUES
(1, 1, 1, 0, 0),
(1, 1, 2, 0, 0),
(1, 1, 2, 0, 0),
(1, 2, 2, 0, 0),
(1, 2, 1, 0, 0);