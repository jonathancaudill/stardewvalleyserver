# Stardew Valley Multiplayer Docker Compose

This project aims to autostart a Stardew Valley Multiplayer Server as easy as possible.

## Quick Start

Choose your platform:
- **x86 Linux (Steam/GOG):** See [Steam](#steam) or [GOG](#gog) sections
- **ARM64 (Raspberry Pi 5):** See [ARM Setup](#arm-raspberry-pi-5--arm64-linux) section

**For ARM64 users:** This setup uses [ValleyCore](https://github.com/a9ix/ValleyCore) to run Stardew Valley natively on ARM64 with full SMAPI modding support - no emulation required!

## Table of Contents

- [Quick Start](#quick-start)
- [Setup Options](#setup)
  - [Steam](#steam)
  - [GOG](#gog)
  - [ARM (Raspberry Pi 5)](#arm-raspberry-pi-5--arm64-linux)
- [Configuration](#configuration)
- [Game Setup](#game-setup)
- [Accessing the Server](#accessing-the-server)
- [Mods](#mods)
- [Troubleshooting](#troubleshooting)

## Notes

- Previous versions provided game files to create the server with the Docker container. To respect ConcernedApe's work and follow
intellectual property law, this will no longer be the case. Users will now be required to use their own copy of the game.
- Although I'm trying to put out updates, I don't have the time for testing thoroughly, so if you find issues, please put 
in an issue request and I will try to help.
- Thanks printfuck for the base code.

<a href="https://www.buymeacoffee.com/huntercavazos" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="41" width="174"></a>


## Setup

### Steam

This image will download the game from Steam server using [steamcmd](https://developer.valvesoftware.com/wiki/SteamCMD) if you own the game. For that, it requires your Steam login.

The credential variables are required only during building, not during game runtime.

```
## Set these variables only during the first build or during updates
export STEAM_USER=<steamUsername>
export STEAM_PASS=<steamPassword>
export STEAM_GUARD=<lastesSteamGuardCode> # If you account is not protected, don't set

docker compose -f docker-compose-steam.yml up
```

#### Steam Guard

If your account is protected by Steam Guard, the build is a little time sensitive. You must open your app and
export the current Steam Guard to `STEAM_GUARD` environment variable code right before building.

**Note: the code lasts a little longer than shown but not much.**

After starting build, pay attention to your app. Even with the code, it will request for authorization which must be granted.

If the build fails or when you want to update with `docker compose -f docker-compose-steam.yml build --no-cache`, you should set the newer `STEAM_GUARD` again.

```
## Remove env variables after build
unset STEAM_USER STEAM_PASS STEAM_GUARD
```
### GOG

To my knowledge there is no way to automate this. To use game files from GOG, you will need to download the Linux installer. 
Sign in, go to Games, find Stardew, change the system to Linux, and download the game installer. The file will look something 
like `stardew_valley_x.x.x.xxx.sh`. Unzip this file (using Git Bash if you are on Windows), and copy the files within the 
`data/noarch/` directory to `docker/game_data/`. Start the container using `docker compose -f docker-compose-gog.yml up`. To 
rebuild the container after updating the files, use `docker compose -f docker-compose-gog.yml build --no-cache`.

### ARM (Raspberry Pi 5 / ARM64 Linux)

This setup is designed for ARM64 systems like the Raspberry Pi 5. It uses **[ValleyCore](https://github.com/a9ix/ValleyCore)** to run Stardew Valley **natively** on ARM64 hardware with full SMAPI modding support - no emulation required!

#### How It Works

ValleyCore enables native ARM64 execution by:
1. Using the standard Linux x86 game files (same as GOG/Steam Linux version)
2. Patching the game DLL to work with ARM64 .NET runtime
3. Replacing the x86-64 runtime with ARM64 .NET runtime
4. Running the game natively without any emulation overhead

**Performance Benefits:** Native ARM64 execution provides significantly better performance than emulation:
- **Startup:** ~40s (native) vs ~2m 30s (emulated)
- **Save loading:** ~30s (native) vs ~1m 30s (emulated)  
- **In-game:** ~60 fps (native) vs ~40 fps (emulated)

#### Prerequisites

- Raspberry Pi 5 (or any ARM64 Linux system)
- Docker and Docker Compose installed
- Linux x86/x86-64 Stardew Valley game files (from Steam or GOG)
- At least 4GB RAM recommended

#### Step 1: Obtain Linux Game Files

You need the standard Linux x86/x86-64 version of Stardew Valley:

**From Steam:**
1. Use SteamCMD on any system (x86 or ARM) to download the Linux version
2. The game files will be in your Steam library directory
3. Look for files like `StardewValley` (executable), `Stardew Valley.dll`, `Content/` folder, etc.

**From GOG:**
1. Download the Linux installer from GOG
2. Extract the installer: `unzip stardew_valley_x.x.x.xxx.sh`
3. Game files are in `data/noarch/` directory

**Important:** You need the Linux version, not macOS or Windows. The macOS binary won't work on Linux.

#### Step 2: Prepare Game Files

You have two options for storing game files:

**Option A: Store in Git Repo (Recommended for Portainer)**
```bash
# Create the directory structure
mkdir -p docker/game_data/game

# Copy your game files
cp -r /path/to/steam/stardew/files/* docker/game_data/game/
# OR for GOG:
cp -r /path/to/gog/data/noarch/* docker/game_data/game/

# Verify the executable exists
ls docker/game_data/game/StardewValley
# or
ls docker/game_data/game/Stardew\ Valley
```

**Option B: Store Outside Repo (For CasaOS/Portainer)**
If you're using Portainer or want to keep game files separate:
1. Place game files at: `/DATA/AppData/stardew-multiplayer-docker/docker/game_data/game/`
2. The container will automatically copy them at startup if not found in the repo

#### Step 3: Setup via Command Line

1. **Clone or download this repository:**
   ```bash
   git clone <your-repo-url>
   cd stardew-multiplayer-docker
   ```

2. **Build and start the container:**
   ```bash
   # Build and start in background
   docker compose -f docker-compose-arm.yml up --build -d
   
   # Or watch logs in foreground
   docker compose -f docker-compose-arm.yml up --build
   ```

3. **Monitor the build:**
   - First build will download the Debian base image (~200-500MB, one-time)
   - ValleyCore will be downloaded automatically
   - ARM64 .NET SDK will be installed
   - Build typically takes 5-15 minutes depending on your connection

4. **Check container status:**
   ```bash
   docker compose -f docker-compose-arm.yml ps
   docker compose -f docker-compose-arm.yml logs -f
   ```

#### Step 4: Setup via Portainer

1. **Upload repository to Git:**
   - Push this repo to GitHub, GitLab, or your preferred git hosting
   - Make sure game files are included if using Option A above

2. **In Portainer:**
   - Go to **Stacks** → **Add stack**
   - Name: `stardew-valley-arm`
   - Build method: **Repository**
   - Fill in:
     - **Repository URL:** Your git repo URL
     - **Compose path:** `docker-compose-arm.yml`
     - **Reference:** `main` (or your branch name)
   - Click **Deploy the stack**

3. **If using Option B (game files outside repo):**
   - Make sure files are at `/DATA/AppData/stardew-multiplayer-docker/docker/game_data/game/`
   - The container will copy them automatically at startup

4. **Monitor deployment:**
   - Go to **Stacks** → your stack name
   - Click **Logs** to watch the build progress
   - Check **Containers** to see status

#### Step 5: First-Time Setup

Once the container is running:

1. **Access the game:**
   - **VNC:** Connect to `localhost:5902` (or your Pi's IP) with password `insecure`
   - **Web Interface:** Open `http://localhost:5801` (or your Pi's IP) in browser, password `insecure`

2. **Automatic setup happens:**
   - ValleyCore patch is applied automatically on first run
   - SMAPI is installed automatically if game files are detected
   - Mods are configured based on environment variables

3. **Create or load your first game:**
   - The game should start automatically
   - Create a new farm or load an existing save
   - Press **F9** (default) to enable Always On Server mode

4. **Verify everything works:**
   - Check that SMAPI loaded (you'll see SMAPI messages in console)
   - Verify mods are working
   - Test multiplayer connection

#### Directory Structure

Your repository should look like this:
```
stardew-multiplayer-docker/
├── docker/
│   ├── game_data/          # Game files go here (Option A)
│   │   └── game/
│   │       ├── StardewValley (or "Stardew Valley")
│   │       ├── Stardew Valley.dll
│   │       ├── Content/
│   │       └── ...
│   ├── Dockerfile-arm
│   ├── docker-entrypoint-arm.sh
│   ├── mods/
│   └── scripts/
├── docker-compose-arm.yml
├── configs/
│   └── autoload.json
└── valley_saves/           # Created automatically
```

#### Configuration

All mod configuration is done via environment variables in `docker-compose-arm.yml`. See the [Configuration](#configuration) section below for all available options.

Key settings for ARM:
- VNC password: Change `VNC_PASSWORD` for security
- Display size: Adjust `DISPLAY_HEIGHT` and `DISPLAY_WIDTH` if needed
- Mod enable/disable: Set `ENABLE_*_MOD` variables to `true` or `false`

#### Troubleshooting

**Build fails with "exec format error":**
- The base image might not support ARM64. Check that `platform: linux/arm64` is set in docker-compose file
- Try: `docker compose -f docker-compose-arm.yml build --no-cache --platform linux/arm64`

**Game files not found:**
- Verify game files exist: `ls docker/game_data/game/StardewValley`
- Check container logs: `docker compose -f docker-compose-arm.yml logs`
- If using Option B, verify path: `/DATA/AppData/stardew-multiplayer-docker/docker/game_data/game/`

**ValleyCore patch fails:**
- Check logs for specific error messages
- Verify game files are complete (not corrupted)
- Try manually running patch: `docker compose -f docker-compose-arm.yml exec valley bash /data/Stardew/game/patch.sh`

**SMAPI installation fails:**
- Check that game binary exists and is executable
- Verify .NET SDK installed: `docker compose -f docker-compose-arm.yml exec valley dotnet --version`
- Check SMAPI logs in container

**Game won't start:**
- Check container logs: `docker compose -f docker-compose-arm.yml logs -f`
- Access VNC and check for error messages
- Verify SDL2 and OpenAL are installed: `docker compose -f docker-compose-arm.yml exec valley dpkg -l | grep -E "sdl2|openal"`

**Performance issues:**
- Ensure you're using native ARM64 (not emulated)
- Check CPU usage: `docker stats`
- Consider limiting CPU in compose file (see commented `deploy.resources` section)

**Portainer-specific issues:**
- If relative paths don't work, check that Portainer is using the Repository method (not Web editor)
- Verify git repo is accessible
- Check Portainer logs for build errors

#### Quick Reference Commands

```bash
# Start container
docker compose -f docker-compose-arm.yml up -d

# Stop container
docker compose -f docker-compose-arm.yml down

# View logs
docker compose -f docker-compose-arm.yml logs -f

# Rebuild after changes
docker compose -f docker-compose-arm.yml up --build -d

# Execute commands in container
docker compose -f docker-compose-arm.yml exec valley bash

# Check container status
docker compose -f docker-compose-arm.yml ps

# View resource usage
docker stats stardew
```

#### Technical Details

- **Base Image:** `jlesage/baseimage-gui:debian-11` (ARM64 variant)
- **ValleyCore Version:** v1.6.15b (with SMAPI support)
- **.NET SDK:** 5.0.408 ARM64
- **SMAPI Version:** 4.1.10
- **Dependencies:** SDL2, OpenAL, Mono, .NET SDK
- **Architecture:** ARM64 (aarch64) only

#### Notes

- **Native Performance:** No emulation overhead - runs natively on ARM64
- **Game Files:** Uses standard Linux x86 binaries (patched at runtime)
- **Mods:** Full SMAPI modding support works natively
- **Updates:** To update game files, replace them and restart the container
- **Saves:** Game saves are stored in `valley_saves/` directory (persisted via volume)

### Configuration

Edit the docker-compose.yml with your desired configuration settings. Setting values are quite descriptive as to what
they set.

```
environment:
      # VNC
      - VNC_PASSWORD=insecure
      - DISPLAY_HEIGHT=900
      - DISPLAY_WIDTH=1200
      
      # Always On Server mod
      ## Removing this will probably defeat the point of ever using this?
      - ENABLE_ALWAYSONSERVER_MOD=${ENABLE_ALWAYSONSERVER_MOD-true}
      - ALWAYS_ON_SERVER_HOTKEY=${ALWAYS_ON_SERVER_HOTKEY-F9}
      - ALWAYS_ON_SERVER_PROFIT_MARGIN=${ALWAYS_ON_SERVER_PROFIT_MARGIN-100}
      - ALWAYS_ON_SERVER_UPGRADE_HOUSE=${ALWAYS_ON_SERVER_UPGRADE_HOUSE-0}
      - ALWAYS_ON_SERVER_PET_NAME=${ALWAYS_ON_SERVER_PET_NAME-Rufus}
      - ALWAYS_ON_SERVER_FARM_CAVE_CHOICE_MUSHROOMS=${ALWAYS_ON_SERVER_FARM_CAVE_CHOICE_MUSHROOMS-true}
      - ALWAYS_ON_SERVER_COMMUNITY_CENTER_RUN=${ALWAYS_ON_SERVER_COMMUNITY_CENTER_RUN-true}
      - ALWAYS_ON_SERVER_TIME_OF_DAY_TO_SLEEP=${ALWAYS_ON_SERVER_TIME_OF_DAY_TO_SLEEP-2200}
      - ALWAYS_ON_SERVER_LOCK_PLAYER_CHESTS=${ALWAYS_ON_SERVER_LOCK_PLAYER_CHESTS-false}
      - ALWAYS_ON_SERVER_CLIENTS_CAN_PAUSE=${ALWAYS_ON_SERVER_CLIENTS_CAN_PAUSE-true}
      - ALWAYS_ON_SERVER_COPY_INVITE_CODE_TO_CLIPBOARD=${ALWAYS_ON_SERVER_COPY_INVITE_CODE_TO_CLIPBOARD-false}

      - ALWAYS_ON_SERVER_FESTIVALS_ON=${ALWAYS_ON_SERVER_FESTIVALS_ON-true}
      - ALWAYS_ON_SERVER_EGG_HUNT_COUNT_DOWN=${ALWAYS_ON_SERVER_EGG_HUNT_COUNT_DOWN-600}
      - ALWAYS_ON_SERVER_FLOWER_DANCE_COUNT_DOWN=${ALWAYS_ON_SERVER_FLOWER_DANCE_COUNT_DOWN-600}
      - ALWAYS_ON_SERVER_LUAU_SOUP_COUNT_DOWN=${ALWAYS_ON_SERVER_LUAU_SOUP_COUNT_DOWN-600}
      - ALWAYS_ON_SERVER_JELLY_DANCE_COUNT_DOWN=${ALWAYS_ON_SERVER_JELLY_DANCE_COUNT_DOWN-600}
      - ALWAYS_ON_SERVER_GRANGE_DISPLAY_COUNT_DOWN=${ALWAYS_ON_SERVER_GRANGE_DISPLAY_COUNT_DOWN-600}
      - ALWAYS_ON_SERVER_ICE_FISHING_COUNT_DOWN=${ALWAYS_ON_SERVER_ICE_FISHING_COUNT_DOWN-600}

      - ALWAYS_ON_SERVER_END_OF_DAY_TIMEOUT=${ALWAYS_ON_SERVER_END_OF_DAY_TIMEOUT-300}
      - ALWAYS_ON_SERVER_FAIR_TIMEOUT=${ALWAYS_ON_SERVER_FAIR_TIMEOUT-1200}
      - ALWAYS_ON_SERVER_SPIRITS_EVE_TIMEOUT=${ALWAYS_ON_SERVER_SPIRITS_EVE_TIMEOUT-900}
      - ALWAYS_ON_SERVER_WINTER_STAR_TIMEOUT=${ALWAYS_ON_SERVER_WINTER_STAR_TIMEOUT-900}

      - ALWAYS_ON_SERVER_EGG_FESTIVAL_TIMEOUT=${ALWAYS_ON_SERVER_EGG_FESTIVAL_TIMEOUT-120}
      - ALWAYS_ON_SERVER_FLOWER_DANCE_TIMEOUT=${ALWAYS_ON_SERVER_FLOWER_DANCE_TIMEOUT-120}
      - ALWAYS_ON_SERVER_LUAU_TIMEOUT=${ALWAYS_ON_SERVER_LUAU_TIMEOUT-120}
      - ALWAYS_ON_SERVER_DANCE_OF_JELLIES_TIMEOUT=${ALWAYS_ON_SERVER_DANCE_OF_JELLIES_TIMEOUT-120}
      - ALWAYS_ON_SERVER_FESTIVAL_OF_ICE_TIMEOUT=${ALWAYS_ON_SERVER_FESTIVAL_OF_ICE_TIMEOUT-120 }

      # Auto Load Game mod
      ## Removing this will mean you need to VNC in to manually start the game each boot
      - ENABLE_AUTOLOADGAME_MOD=${ENABLE_AUTOLOADGAME-null}
      - AUTO_LOAD_GAME_LAST_FILE_LOADED=${AUTO_LOAD_GAME_LAST_FILE_LOADED-null}
      - AUTO_LOAD_GAME_FORGET_LAST_FILE_ON_TITLE=${AUTO_LOAD_GAME_FORGET_LAST_FILE_ON_TITLE-true}
      - AUTO_LOAD_GAME_LOAD_INTO_MULTIPLAYER=${AUTO_LOAD_GAME_LOAD_INTO_MULTIPLAYER-true}
      
      # Unlimited Players Mod
      - ENABLE_UNLIMITEDPLAYERS_MOD=${ENABLE_UNLIMITEDPLAYERS-true}
      - UNLIMITED_PLAYERS_PLAYER_LIMIT=${UNLIMITED_PLAYERS_PLAYER_LIMIT-8}

      # Chat Commands mod
      - ENABLE_CHATCOMMANDS_MOD=${ENABLE_CHATCOMMANDS_MOD-false}

      # Console Commands mod
      - ENABLE_CONSOLECOMMANDS_MOD=${ENABLE_CONSOLECOMMANDS_MOD-false}

      # Time Speed mod
      - ENABLE_TIMESPEED_MOD=${ENABLE_TIMESPEED_MOD-false}

      ## Days are only 20 hours long
      ##   7.0 = 14 mins per in game day (default)
      ##  10.0 = 20 mins
      ##  15.0 = 30 mins
      ##  20.0 = 40 mins
      ##  30.0 = 1 hour
      ## 120.0 = 4 hours
      ## 300.0 = 10 hours
      ## 600.0 = 20 hours (realtime)

      - TIME_SPEED_DEFAULT_TICK_LENGTH=${TIME_SPEED_DEFAULT_TICK_LENGTH-7.0}
      - TIME_SPEED_TICK_LENGTH_BY_LOCATION_INDOORS=${TIME_SPEED_TICK_LENGTH_BY_LOCATION_INDOORS-7.0}
      - TIME_SPEED_TICK_LENGTH_BY_LOCATION_OUTDOORS=${TIME_SPEED_TICK_LENGTH_BY_LOCATION_OUTDOORS-7.0}
      - TIME_SPEED_TICK_LENGTH_BY_LOCATION_MINE=${TIME_SPEED_TICK_LENGTH_BY_LOCATION_MINE-7.0}

      - TIME_SPEED_ENABLE_ON_FESTIVAL_DAYS=${TIME_SPEED_ENABLE_ON_FESTIVAL_DAYS-false}
      - TIME_SPEED_FREEZE_TIME_AT=${TIME_SPEED_FREEZE_TIME_AT-null}
      - TIME_SPEED_LOCATION_NOTIFY=${TIME_SPEED_LOCATION_NOTIFY-false}

      - TIME_SPEED_KEYS_FREEZE_TIME=${TIME_SPEED_KEYS_FREEZE_TIME-N}
      - TIME_SPEED_KEYS_INCREASE_TICK_INTERVAL=${TIME_SPEED_KEYS_INCREASE_TICK_INTERVAL-OemPeriod}
      - TIME_SPEED_KEYS_DECREASE_TICK_INTERVAL=${TIME_SPEED_KEYS_DECREASE_TICK_INTERVAL-OemComma}
      - TIME_SPEED_KEYS_RELOAD_CONFIG=${TIME_SPEED_KEYS_RELOAD_CONFIG-B}

      # Crops Anytime Anywhere mod
      - ENABLE_CROPSANYTIMEANYWHERE_MOD=${ENABLE_CROPSANYTIMEANYWHERE_MOD-false}

      - CROPS_ANYTIME_ANYWHERE_ENABLE_IN_SEASONS_SPRING=${CROPS_ANYTIME_ANYWHERE_ENABLE_IN_SEASONS_SPRING-true}
      - CROPS_ANYTIME_ANYWHERE_ENABLE_IN_SEASONS_SUMMER=${CROPS_ANYTIME_ANYWHERE_ENABLE_IN_SEASONS_SUMMER-true}
      - CROPS_ANYTIME_ANYWHERE_ENABLE_IN_SEASONS_FALL=${CROPS_ANYTIME_ANYWHERE_ENABLE_IN_SEASONS_FALL-true}
      - CROPS_ANYTIME_ANYWHERE_ENABLE_IN_SEASONS_WINTER=${CROPS_ANYTIME_ANYWHERE_ENABLE_IN_SEASONS_WINTER-true}

      - CROPS_ANYTIME_ANYWHERE_FARM_ANY_LOCATION=${CROPS_ANYTIME_ANYWHERE_FARM_ANY_LOCATION-true}

      - CROPS_ANYTIME_ANYWHERE_FORCE_TILLABLE_DIRT=${CROPS_ANYTIME_ANYWHERE_FORCE_TILLABLE_DIRT-true}
      - CROPS_ANYTIME_ANYWHERE_FORCE_TILLABLE_GRASS=${CROPS_ANYTIME_ANYWHERE_FORCE_TILLABLE_GRASS-true}
      - CROPS_ANYTIME_ANYWHERE_FORCE_TILLABLE_STONE=${CROPS_ANYTIME_ANYWHERE_FORCE_TILLABLE_STONE-false}
      - CROPS_ANYTIME_ANYWHERE_FORCE_TILLABLE_OTHER=${CROPS_ANYTIME_ANYWHERE_FORCE_TILLABLE_OTHER-false}

      # Friends Forever mod
      - ENABLE_FRIENDSFOREVER_MOD=${ENABLE_FRIENDSFOREVER_MOD-false}

      - FRIENDS_FOREVER_AFFECT_SPOUSE=${FRIENDS_FOREVER_AFFECT_SPOUSE-false}
      - FRIENDS_FOREVER_AFFECT_DATES=${FRIENDS_FOREVER_AFFECT_DATES-true}
      - FRIENDS_FOREVER_AFFECT_EVERYONE_ELSE=${FRIENDS_FOREVER_AFFECT_EVERYONE_ELSE-true}
      - FRIENDS_FOREVER_AFFECT_ANIMALS=${FRIENDS_FOREVER_AFFECT_ANIMALS-true}

      # No Fence Decay mod
      - ENABLE_NOFENCEDECAY_MOD=${ENABLE_NOFENCEDECAY_MOD-false}

      # Non-destructive NPCs mod
      - ENABLE_NONDESTRUCTIVENPCS_MOD=${ENABLE_NONDESTRUCTIVENPCS_MOD-false}
```

## Game Setup

Initially, you have to create or load a game once via VNC or web interface. After that, the Autoload Mod jumps into the
previously loaded game save everytime you restart or rebuild the container. The AutoLoad Mod config file is by default
mounted as a volume, since it keeps the state of the ongoing game save, but you can also copy your existing game save to
the `Saves` volume and define the game save's name in the environment variables. Once started, press the Always On
Hotkey (default F9) to enter server mode.

### VNC

Use a VNC client like `TightVNC` on Windows or plain `vncviewer` on any Linux distribution to connect to the server. You
can modify the VNC Port and IP address and Password in the `docker-compose.yml` file like this:

Localhost:

```
   # Server is only reachable on localhost on port 5902...
   ports:
     - 127.0.0.1:5902:5900
   # ... with the password "insecure"
   environment:
     - VNCPASS=insecure
```

### Web Interface

On port 5800 (mapped to 5801 by default) inside the container is a web interface. This is a bit easier and more
accessible than just the VNC interface. Although you will be asked for the vnc password, I wouldn't recommend exposing
the port to the outside world.

![img](https://store.eris.cc/uploads/859865e1ab5b23fb223923d9a7e4806b.PNG)

## Accessing the server

- Direct IP: You will need to set a up direct IP access over the internet "Join LAN Game" by opening (or forwarding)
  port 24642. Feel free to change this mapping in the compose file. People can then "Join LAN Game" via your external IP.

(Taken from mod description. See [Always On Server](https://www.nexusmods.com/stardewvalley/mods/2677?tab=description)
for more info.)

## Mods

- [Always On Server](https://www.nexusmods.com/stardewvalley/mods/2677) (Default: Required)
- [Auto Load Game](https://www.nexusmods.com/stardewvalley/mods/2509) (Default: On)
- [Crops Anytime Anywhere](https://www.nexusmods.com/stardewvalley/mods/3000) (Default: Off)
- [Friends Forever](https://www.nexusmods.com/stardewvalley/mods/1738) (Default: Off)
- [No Fence Decay](https://www.nexusmods.com/stardewvalley/mods/1180) (Default: Off)
- [Non Destructive NPCs](https://www.nexusmods.com/stardewvalley/mods/5176) (Default: Off)
- [Remote Control](https://github.com/Novex/stardew-remote-control) (Default: On)
- [TimeSpeed](https://www.nexusmods.com/stardewvalley/mods/169) (Default: Off)
- [Unlimited Players](https://www.nexusmods.com/stardewvalley/mods/2213) (Default: On)

## Troubleshooting

### General Issues

**Waiting for Day to End:**
- Check VNC just to make sure the host hasn't gotten stuck on a prompt.

**Error Messages in Console:**
- Usually you should be able to ignore any message there. If the game doesn't start or any errors appear, you should look
for messages like "cannot open display", which would most likely indicate permission errors.

**VNC Connection Issues:**
- Access the game via VNC to initially load or start a pre-generated game save. You can control the server from there or
edit the config.json files in the configs folder.
- Default VNC password is `insecure` - change it in docker-compose file for security
- Port 5902 for VNC, port 5801 for web interface

**Container Won't Start:**
- Check Docker logs: `docker compose -f docker-compose-*.yml logs`
- Verify all required files are in place
- Check disk space: `df -h`
- Verify Docker has enough resources allocated

**Game Crashes or Freezes:**
- Check container logs for errors
- Verify game files are not corrupted
- Check available memory: `docker stats`
- Try reducing display resolution in compose file

### ARM-Specific Issues

See the [ARM Setup](#arm-raspberry-pi-5--arm64-linux) section for detailed ARM troubleshooting, including:
- Build failures with "exec format error"
- ValleyCore patch issues
- SMAPI installation problems
- Performance optimization

### Getting Help

If you encounter issues not covered here:
1. Check the container logs: `docker compose -f docker-compose-*.yml logs -f`
2. Check SMAPI error logs (via VNC or in container)
3. Search existing GitHub issues
4. Create a new issue with:
   - Your platform (x86/ARM)
   - Docker compose file used
   - Relevant log excerpts
   - Steps to reproduce
