# games-night

* [ Overview ](#overview)
* [ Requirements ](#requirements)
* [ Supported Games ](#games)
* [ How-to ](#how_to)
	* [ Setup ](#setup)

<a name="overview"></a>
## Overview :scroll:

This repository is ideal if you are:

- Hosting a games night
- Want to keep scores
- Want a handy way to visualise those scores

This repo will:
- Deploy an app server, where you can see your latest scores and update them
- Deploy a MySQL database to manage the results in the background

<a name="requirements"></a>
## Requirements :floppy_disk:

It is required to have Docker installed and configured such that the user can run docker-compose.

<a name="games"></a>
## Supported Games :game_die:

The following games are currently supported:

- FIFA
- Rock Paper Scissors
- Headers and Volleys
- Ticket to Ride
- Catan
- Crash Team Racing

<a name="how_to"></a>
## How-to

<a name="setup"></a>
### Setup :wrench:

To deploy the necessary services, simply navigate to the directory via command line and execute:

`docker-compose up -d`

You can then access the following apps at the given addresses:

- Game night summary: http://localhost:5001/apps/games/
- Score updater: http://localhost:5001/apps/update/