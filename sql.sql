CREATE TABLE IF NOT EXISTS `player_playtime` (
    `identifier` varchar(50) NOT NULL,
    `name` varchar(255) NOT NULL,
    `discord_id` varchar(50) DEFAULT NULL,
    `minutes` int(11) NOT NULL DEFAULT 0,
    `last_seen` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
