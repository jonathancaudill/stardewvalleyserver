#!/bin/bash
export HOME=/config

# Copy game files from absolute path on host if they exist and game directory is empty
# This allows game files to be stored outside the git repo
if [ ! -f "/data/Stardew/game/StardewValley" ] && [ ! -f "/data/Stardew/game/Stardew Valley" ]; then
    if [ -d "/DATA/AppData/stardew-multiplayer-docker/docker/game_data/game" ] && [ "$(ls -A /DATA/AppData/stardew-multiplayer-docker/docker/game_data/game 2>/dev/null)" ]; then
        echo "Copying game files from /DATA/AppData/stardew-multiplayer-docker/docker/game_data/game"
        cp -r /DATA/AppData/stardew-multiplayer-docker/docker/game_data/game/* /data/Stardew/game/ 2>/dev/null || true
        chmod +x /data/Stardew/game/StardewValley /data/Stardew/game/Stardew\ Valley 2>/dev/null || true
    fi
fi

# Detect game binary name (could be "StardewValley" or "Stardew Valley")
GAME_BINARY=""
if [ -f "/data/Stardew/game/StardewValley" ]; then
    GAME_BINARY="/data/Stardew/game/StardewValley"
elif [ -f "/data/Stardew/game/Stardew Valley" ]; then
    GAME_BINARY="/data/Stardew/game/Stardew Valley"
fi

# Apply ValleyCore patch for native ARM64 support
# This patches the game DLL to work with ARM64 .NET runtime
if [ -n "$GAME_BINARY" ] && [ -f "/opt/valleycore/patch.sh" ]; then
    echo "Applying ValleyCore patch for native ARM64 support..."
    # Copy ValleyCore files to game directory if not already there
    if [ ! -f "/data/Stardew/game/patch.sh" ]; then
        cp -r /opt/valleycore/* /data/Stardew/game/ 2>/dev/null || true
    fi
    # Run the patch script
    cd /data/Stardew/game
    bash /data/Stardew/game/patch.sh || echo "Patch already applied or failed (this is OK if already patched)"
fi

# Install SMAPI if game binary exists and SMAPI is not already installed
# SMAPI installer should work natively with ARM64 .NET
if [ -n "$GAME_BINARY" ] && [ ! -f "/data/Stardew/game/StardewModdingAPI" ]; then
    echo "Installing SMAPI..."
    SMAPI_INSTALLER=$(find /data/nexus -name 'SMAPI*.*Installer' -type f -path "*/SMAPI * installer/internal/linux/*" | head -n 1)
    if [ -n "$SMAPI_INSTALLER" ]; then
        # Run SMAPI installer natively (should work with ARM64 .NET)
        /bin/bash -c "SMAPI_NO_TERMINAL=true SMAPI_USE_CURRENT_SHELL=true echo -e '2\n\n' | \"$SMAPI_INSTALLER\" --install --game-path '/data/Stardew/game'" || echo "SMAPI installation failed or already installed"
    fi
fi

# Make game binary executable if it exists
if [ -n "$GAME_BINARY" ]; then
    chmod +x "$GAME_BINARY"
fi

# Configure mods
for modPath in /data/Stardew/game/Mods/*/
do
  mod=$(basename "$modPath")

  # Normalize mod name to uppercase and only characters, eg. "Always On Server" => ENABLE_ALWAYSONSERVER_MOD
  var="ENABLE_$(echo "${mod^^}" | tr -cd '[A-Z]')_MOD"

  # Remove the mod if it's not enabled
  if [ "${!var}" != "true" ]; then
    echo "Removing ${modPath} (${var}=${!var})"
    rm -rf "$modPath"
    continue
  fi

  if [ -f "${modPath}/config.json.template" ]; then
    echo "Configuring ${modPath}config.json"

    # Seed the config.json only if one isn't manually mounted in (or is empty)
    if [ "$(cat "${modPath}config.json" 2> /dev/null)" == "" ]; then
      envsubst < "${modPath}config.json.template" > "${modPath}config.json"
    fi
  fi
done

# Run extra steps for certain mods
/opt/configure-remotecontrol-mod.sh

/opt/tail-smapi-log.sh &

# Ready to start!

export XAUTHORITY=~/.Xauthority

# Modify the Stardew Valley launcher script if it exists
if [ -f "/data/Stardew/game/Stardew Valley" ]; then
    sed -i 's/env TERM=xterm $LAUNCHER "$@"/env SHELL=\/bin\/bash TERM=xterm xterm  -e "\/bin\/bash -c $LAUNCHER \"$@\""/' /data/Stardew/game/Stardew\ Valley
fi

# Determine how to start the game
# Run natively on ARM64 using ValleyCore patch
# If SMAPI is installed, use ValleyCore's SMAPI wrapper if available, otherwise use SMAPI directly
if [ -f "/data/Stardew/game/StardewModdingAPI" ]; then
    echo "Starting Stardew Valley with SMAPI (native ARM64)..."
    cd /data/Stardew/game
    # Use ValleyCore's SMAPI wrapper if available, otherwise run SMAPI directly
    if [ -f "/data/Stardew/game/smapi-wrapper.sh" ]; then
        bash /data/Stardew/game/smapi-wrapper.sh
    else
        ./StardewModdingAPI
    fi
elif [ -n "$GAME_BINARY" ]; then
    echo "Starting Stardew Valley natively on ARM64 (no SMAPI)..."
    cd /data/Stardew/game
    "$GAME_BINARY"
else
    echo "ERROR: Game binary not found at /data/Stardew/game/StardewValley or /data/Stardew/game/Stardew Valley"
    echo "Please ensure the Linux game files are mounted at ./docker/game_data/game/"
    exit 1
fi

sleep 233333333333333

