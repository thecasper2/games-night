INSERT INTO player (first_name, last_name) VALUES
("Alex", "Dolphin"),
("Tom", "Ayre"),
("Steve", "Ayre"),
("Chris", "Horton");

INSERT INTO event (event_name) VALUES
("event_1"),
("event_2");

INSERT INTO event_players (event_id, player_id) VALUES
(1, 1),
(1, 2),
(1, 3),
(1, 4),
(2, 1),
(2, 2);

INSERT INTO fifa_results (event_id, home_player_id, away_player_id, home_goals, away_goals) VALUES 
(1, 1, 2, 3, 0),
(1, 1, 3, 3, 4),
(1, 1, 4, 2, 1),
(1, 2, 3, 0, 1),
(1, 2, 4, 6, 3),
(1, 3, 4, 1, 3),
(2, 1, 2, 2, 0);

INSERT INTO rps_results (event_id, home_player_id, away_player_id, home_wins, away_wins) VALUES 
(1, 1, 2, 3, 0),
(1, 1, 3, 3, 4),
(1, 1, 4, 2, 1),
(1, 2, 3, 0, 1),
(1, 2, 4, 6, 3),
(1, 3, 4, 1, 3),
(2, 1, 2, 2, 0);

INSERT INTO headers_and_volleys_results (match_id, event_id, player_id, position) VALUES 
(1, 1, 1, 4),
(1, 1, 2, 3),
(1, 1, 3, 2),
(1, 1, 4, 1),
(2, 1, 1, 2),
(2, 1, 2, 4),
(2, 1, 3, 1),
(2, 1, 4, 3);

INSERT INTO ticket_to_ride_results (match_id, event_id, player_id, position) VALUES 
(1, 1, 1, 3),
(1, 1, 2, 4),
(1, 1, 3, 1),
(1, 1, 4, 2),
(2, 1, 1, 2),
(2, 1, 2, 4),
(2, 1, 3, 1),
(2, 1, 4, 3);

INSERT INTO catan_results (match_id, event_id, player_id, victory_points) VALUES 
(1, 1, 1, 7),
(1, 1, 2, 9),
(1, 1, 3, 11),
(1, 1, 4, 6),
(2, 1, 1, 9),
(2, 1, 2, 5),
(2, 1, 3, 10),
(2, 1, 4, 2);

INSERT INTO ctr_results (match_id, event_id, player_id, position) VALUES 
(1, 1, 1, 3),
(1, 1, 2, 4),
(1, 1, 3, 1),
(1, 1, 4, 2),
(2, 1, 1, 2),
(2, 1, 2, 4),
(2, 1, 3, 1),
(2, 1, 4, 3);