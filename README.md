# ESX MH-Playtime

**MH-Playtime** is an ESX script that tracks how long each player has been active on the server.  
The script records playtime automatically and sends detailed statistics to a designated Discord channel using a Discord bot integration from `server.lua`.

---

## Features
- Tracks individual player playtime on the server  
- Sends playtime reports directly to a configured Discord channel  
- Easy integration with ESX framework  
- Lightweight and optimized for performance  
- Simple configuration for Discord bot and channel setup  

---

## Configuration
1. Set up your Discord bot and add it to your server.  
2. Define the Discord bot token and channel id in the `server.lua`.
4. Import .sql file into your database.
5. Adjust settings in `server.lua` to specify the target channel for playtime reports.  

---

## Usage
- The script will automatically track player activity when they join the server.  
- Playtime data is periodically calculated and transmitted to the configured Discord channel.  
- Ideal for monitoring staff activity, tracking player engagement, or rewarding active community members.  

---
