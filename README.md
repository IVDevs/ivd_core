# IVD_Core - GTA IV Roleplay Framework (Alpha)
IVD_Core is a work-in-progress roleplay framework for GTA IV, designed to bring structured roleplay mechanics to the game. While it's still in early alpha, we are actively developing it to create a complete and immersive RP experience.

This framework lays the foundation for roleplay servers, providing essential core functionalities, database integration, and future expansion capabilities.

# 🔧 Setting Up MySQL
Before running the server, you need to configure your MySQL database connection. To do this, update the credentials inside:

```
/server/main.lua
```
Modify the following line with your database details:

```
-- MYSQL LOGIN --
MySQL.Connect("IP", 33060, "DATABASE", "PASSWORD", "DATABASE")
```
Make sure to replace IP, DATABASE, and PASSWORD with your actual database information. This step is crucial for proper data storage and retrieval.

# 🚀 Future Development
We are actively working on expanding IVD_Core with:

* Character systems (player creation, inventory, etc.)
* Job systems (police, medic, criminal activities)
* Advanced UI elements for better user interaction
* Vehicle and property systems
* Full-fledged economy integration

As this is an alpha release, expect frequent updates and improvements as we move towards a complete RP framework.

# 🙌 Special Thanks
A huge thanks to LeChapellierFou for creating IVMenu, which has greatly helped us in developing this framework.

# ⚠️ Disclaimer
This is an experimental project in active development. Some features may be missing or incomplete. If you're interested in contributing or testing, feel free to join the project!

Stay tuned for more updates! 🚧🔨
