#!/bin/bash

# CLOSED-DISPLAY MODE WATCHDOG
#
# AMPHETAMINE KEEPS A MAC LAPTOP AWAKE WITH THE LID CLOSED BY RUNNING
# `pmset -a disablesleep 1` THROUGH POWER PROTECT. ON APPLE SILICON THAT
# SETTING CAN GET CLEARED WHILE A SESSION IS STILL ACTIVE (AFTER A POWER
# SOURCE CHANGE, OR WHEN A SESSION IS REPLACED), AND AMPHETAMINE DOES NOT
# RE-APPLY IT. THE MAC THEN SLEEPS AS SOON AS THE LID CLOSES.
#
# THIS SCRIPT RUNS EVERY FEW SECONDS. IT TRACKS AMPHETAMINE'S POWER
# ASSERTION BY ID. ONCE IT HAS SEEN CLOSED-DISPLAY MODE ON FOR A SESSION,
# IT RE-APPLIES IT IF IT DROPS WHILE THAT SAME SESSION IS STILL ACTIVE.
# A SESSION THAT NEVER TURNED CLOSED-DISPLAY MODE ON IS LEFT ALONE, SO
# "ALLOW SYSTEM SLEEP WHEN DISPLAY IS CLOSED" IS STILL RESPECTED.
#
# IT ALSO REPLACES THE OLD CLOSED-DISPLAY MODE FAIL-SAFE: IF AMPHETAMINE QUITS
# OR CRASHES WITH CLOSED-DISPLAY MODE ON, SLEEP IS TURNED BACK ON.
#
# REQUIRES AMPHETAMINE POWER PROTECT, WHICH ALLOWS
# `sudo -n pmset -a disablesleep 0|1` WITHOUT A PASSWORD.

{

    stateDir="$HOME/Library/Application Support/Amphetamine Enhancer"
    stateFile="$stateDir/cdmWatchdog.state"
    logFile="$HOME/Library/Logs/amphetamine-enhancer-cdmWatchdog.log"
    mkdir -p "$stateDir" "$(dirname "$logFile")"

    log() { echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >> "$logFile"; }

    # AMPHETAMINE'S CURRENT ASSERTION ID, EMPTY IF NO SESSION IS ACTIVE
    assertionId() {
        pmset -g assertions | awk '/\(Amphetamine\)/ && /named: "Amphetamine/ { gsub(/[\[\]]/, "", $3); print $3; exit }'
    }

    sleepDisabled() {
        pmset -g | awk '/SleepDisabled/ { print $2 }'
    }

    # STATE: <ASSERTION ID> <CDM SEEN FOR THIS SESSION 0|1> <WATCHDOG LAST SET DISABLESLEEP 0|1>
    trackedId=""; cdmSeen=0; ownsSetting=0
    [ -f "$stateFile" ] && read -r trackedId cdmSeen ownsSetting < "$stateFile"

    currentId=$(assertionId)
    disabled=$(sleepDisabled)

    # NO ACTIVE SESSION. IF THE LAST SESSION HAD CLOSED-DISPLAY MODE ON (OR THE
    # WATCHDOG SET IT) AND SLEEP IS STILL DISABLED, AMPHETAMINE QUIT OR CRASHED
    # WITHOUT CLEANING UP. HAND SLEEP BACK SO THE MAC DOES NOT STAY AWAKE FOREVER.
    # SLEEP DISABLED WITHOUT A TRACKED SESSION WAS SET BY HAND, SO LEAVE IT ALONE.
    if [ -z "$currentId" ]; then
        if { [ "$cdmSeen" = 1 ] || [ "$ownsSetting" = 1 ]; } && [ "$disabled" = 1 ]; then
            sudo -n /usr/bin/pmset -a disablesleep 0 && log "session ended, restored lid-close sleep"
        fi
        rm -f "$stateFile"
        exit 0
    fi

    # NEW SESSION: START TRACKING IT FRESH
    if [ "$currentId" != "$trackedId" ]; then
        trackedId="$currentId"; cdmSeen=0; ownsSetting=0
    fi

    if [ "$disabled" = 1 ]; then
        # AMPHETAMINE (OR THE WATCHDOG) HAS CLOSED-DISPLAY MODE ON FOR THIS SESSION
        cdmSeen=1
    elif [ "$cdmSeen" = 1 ]; then
        # CLOSED-DISPLAY MODE DROPPED MID-SESSION. WAIT A MOMENT SO A SESSION
        # THAT IS ENDING NORMALLY HAS TIME TO RELEASE ITS ASSERTION FIRST.
        sleep 3
        if [ "$(assertionId)" = "$currentId" ] && [ "$(sleepDisabled)" = 0 ]; then
            if sudo -n /usr/bin/pmset -a disablesleep 1; then
                ownsSetting=1
                log "closed-display mode dropped during session $currentId, re-applied"
            else
                log "closed-display mode dropped, but sudo pmset failed (is Power Protect installed?)"
            fi
        fi
    fi

    echo "$trackedId $cdmSeen $ownsSetting" > "$stateFile"

} &> /dev/null
