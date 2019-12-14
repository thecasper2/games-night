DROP TABLE IF EXISTS event_players;
DROP TABLE IF EXISTS event;
DROP TABLE IF EXISTS player;
DROP TABLE IF EXISTS fifa_results;
DROP TABLE IF EXISTS rps_results;
DROP TABLE IF EXISTS headers_and_volleys_results;
DROP TABLE IF EXISTS ticket_to_ride_results;
DROP TABLE IF EXISTS catan_results;
DROP TABLE IF EXISTS ctr_results;

CREATE TABLE player (
    player_id INT NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (player_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE event (
    event_id INT NOT NULL AUTO_INCREMENT,
    creation_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    event_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (event_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE event_players (
    event_id INT NOT NULL,
    player_id INT NOT NULL,
    FOREIGN KEY (event_id)  REFERENCES event (event_id) ON DELETE CASCADE,
    FOREIGN KEY (player_id) REFERENCES player (player_id) ON DELETE CASCADE,
    PRIMARY KEY (event_id, player_id)
);

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

CREATE TABLE rps_results (
    match_id INT NOT NULL,
    event_id INT NOT NULL,
    home_player_id INT NOT NULL,
    away_player_id INT NOT NULL,
    home_wins INT NOT NULL,
    away_wins INT NOT NULL,
    FOREIGN KEY (event_id)  REFERENCES event (event_id) ON DELETE CASCADE,
    FOREIGN KEY (home_player_id) REFERENCES player (player_id) ON DELETE CASCADE,
    FOREIGN KEY (away_player_id) REFERENCES player (player_id) ON DELETE CASCADE,
    PRIMARY KEY (match_id, event_id, home_player_id, away_player_id)
);

CREATE TABLE headers_and_volleys_results (
    match_id INT NOT NULL,
    event_id INT NOT NULL,
    player_id INT NOT NULL,
    position INT NOT NULL,
    FOREIGN KEY (event_id)  REFERENCES event (event_id) ON DELETE CASCADE,
    FOREIGN KEY (player_id) REFERENCES player (player_id) ON DELETE CASCADE,
    PRIMARY KEY (match_id, event_id, player_id)
);

CREATE TABLE ticket_to_ride_results (
    match_id INT NOT NULL,
    event_id INT NOT NULL,
    player_id INT NOT NULL,
    position INT NOT NULL,
    FOREIGN KEY (event_id)  REFERENCES event (event_id) ON DELETE CASCADE,
    FOREIGN KEY (player_id) REFERENCES player (player_id) ON DELETE CASCADE,
    PRIMARY KEY (match_id, event_id, player_id)
);

CREATE TABLE catan_results (
    match_id INT NOT NULL,
    event_id INT NOT NULL,
    player_id INT NOT NULL,
    position INT NOT NULL,
    victory_points INT NOT NULL,
    FOREIGN KEY (event_id)  REFERENCES event (event_id) ON DELETE CASCADE,
    FOREIGN KEY (player_id) REFERENCES player (player_id) ON DELETE CASCADE,
    PRIMARY KEY (match_id, event_id, player_id)
);

CREATE TABLE ctr_results (
    match_id INT NOT NULL,
    event_id INT NOT NULL,
    player_id INT NOT NULL,
    position INT NOT NULL,
    FOREIGN KEY (event_id)  REFERENCES event (event_id) ON DELETE CASCADE,
    FOREIGN KEY (player_id) REFERENCES player (player_id) ON DELETE CASCADE,
    PRIMARY KEY (match_id, event_id, player_id)
);