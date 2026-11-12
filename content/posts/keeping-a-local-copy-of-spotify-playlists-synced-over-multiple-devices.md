+++
title = "Keeping a Local Copy of Spotify Playlists Synced Over Multiple Devices"
date = "2024-02-11"
tags = ["music", "spotify", "youtube-dl", "spotdl", "piracy"]
+++
I am a student from a developing country. My pocket money is pretty much nonexistent, so I cannot pay for Spotify. However, music is important to my productivity, and there are times when I go to places without an internet connection, so I need to keep local copies of songs for these reasons. Spotify restricts offline listening to premium subscribers, so my only option was to rely on their free API to apply a couple of workarounds.

I then found [spotdl](https://github.com/spotDL/spotify-downloader). It relies on their free API to get the song list of a Spotify playlist, then uses [youtube-dl](https://github.com/ytdl-org/youtube-dl) to query the songs on YouTube, subsequently downloading them. Spotdl supports multi-threading; that is, it can download multiple tracks simultaneously. It also skips the songs that you already have in the selected folder.

The next trouble was syncing the files to my other devices without manual labor. I found [Syncthing](https://syncthing.net/) useful for this. The process was really simple. If the devices are connected to the same Wi-Fi network, you don't really have to do much to get going. But if not, you have some setup to do yourself that I won't be explaining here.

If you use Windows 10, then you should install [Scoop](http://scoop.sh) to manage your packages. If you use Linux, then your default package managers themselves will do an adequate job. MacOS users are on their own, because I don't have the environment to test the steps I'd be mentioning.

# Prerequisites

Let us first set up all the prerequisites.

## Windows 10
```bash
scoop bucket add main
scoop bucket add extras
scoop bucket add versions

scoop install main/ffmpeg
scoop install main/python
scoop install main/syncthing
scoop install main/czkawka
scoop install versions/spotdl-beta
```

## Linux
I will only provide the steps for Ubuntu 22.04; other distribution users are asked to do internet searches and install the required packages. I don't use Ubuntu myself, but it is the most popular choice, so I am choosing it.
```bash
sudo mkdir -p /etc/apt/keyrings
sudo curl -L -o /etc/apt/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list

sudo add-apt-repository ppa:xtradeb/apps

sudo apt update

sudo apt install ffmpeg python3-pip syncthing czkawka

pip3 install spotdl
```

# Setup
`czkawka` will be used to discover and delete duplicate songs.

## Syncthing
You'd want to pick a folder to keep your songs in. I recommend `~/Music/Spotify`. Open a terminal window and start syncthing using the  `syncthing` command. Your default browser will be opened with a locally hosted instance of Syncthing. Add the folder you picked; make sure you give it an appropriate folder ID (like `spotify-sync`). Add your device by clicking on "Add remote device.". If you want to add an Android device, you can download their Android client from major app stores (Google Play, F-Droid).

I will give special attention to adding an Android device:
- install and open the "Syncthing" app on your phone;
- tap the '+' button;
- scan the QR code that you can find from Actions > Show ID button of the Syncthing web instance;
- wait some time, and then you should be prompted with a request to add the device on the web instance;
- edit the picked folder and register the device in the "Sharing" section;
- you will be notified on your Android to accept the request.
- open the Android app and tap on the new folder entry;
- link the folder to a local folder.

That should be it.

Edit the folder update interval in the web instance to your liking. Personally, I prefer ten minutes (600s).

To test, CWD to your picked folder, then execute `spotdl download [playlist_link]`. It will start downloading the songs there. Simultaneously, Syncthing will sync the files on other remote devices as instructed.

Duplicate songs are not kept in check. Continue reading to set that up. I prefer keeping the oldest copy, so my method would be `AEO`.

# Automating Things
For ease of use, I wrote a simple Python script to manage the Spotify folder:
```python
"""
Basic Spotify synchronization manager.

Author(s): eeriemyxi (GitHub)
License: GPL 3.0
"""

import pathlib, subprocess, sys, logging, argparse

SCRIPT_PATH = pathlib.Path(__file__).parent


logging.basicConfig(
    level=logging.INFO,
    filename=SCRIPT_PATH / "spotify-sync.log",
    format="%(asctime)s: %(message)s",
)
logger = logging.getLogger(__name__)
parser = argparse.ArgumentParser(description="Basic Spotify synchronization manager.")
parser.add_argument(
    "--duplicate-removal-method",
    help="Delete duplicates after syncing. NONE by default. Uses czkawka. "
    "See `czkawka dup --help`",
    default="NONE",
    dest="removal_method",
)
args = parser.parse_args()
args.removal_method = args.removal_method.upper()

logger.info("Script started with arguments: %s.", repr(sys.argv))

with open(SCRIPT_PATH / "playlists-to-sync.txt") as file:
    for line_c, line in enumerate(file.readlines(), 1):
        line = line.strip()

        if line[0] == "#":
            sys.stderr.write(f"Skipping line #{line_c}.\n")
            logger.warning(f"Skipping line #{line_c}.")
            continue

        links, folder_name = line.split(";", 1)
        links = links.split()
        logger.info(f"Downloading to folder {folder_name} from links: {links}.")

        playlist_path = SCRIPT_PATH / folder_name
        playlist_path.mkdir(parents=True, exist_ok=True)

        sync_file = playlist_path / "spotify-sync.spotdl"

        if sync_file.exists():
            subprocess.run(
                ["spotdl", "sync", sync_file.name], cwd=playlist_path, shell=True
            )
        else:
            subprocess.run(
                ["spotdl", "sync", " ".join(links), "--save-file", sync_file.name],
                cwd=playlist_path,
                shell=True,
            )

        logger.info(f"Done synching playlists to folder {folder_name}.")

if args.removal_method != "NONE":
    logger.info(
        "Deleting duplicates with method '%s' in '%s'.",
        args.removal_method,
        SCRIPT_PATH,
    )
    out = subprocess.run(
        [
            "czkawka",
            "dup",
            "-D",
            args.removal_method,
            "--directories",
            str(SCRIPT_PATH),
        ],
        shell=True,
        capture_output=True,
    )
    logger.info(
        "Deletion complete with return code %s; stdout: %s; stderr: %s",
        out.returncode,
        out.stdout,
        out.stderr,
    )
```
Save it in the picked folder as `spotify-sync.py`. This file can be downloaded from [here](https://files.catbox.moe/zogqu6.py).

The script will read a file `playlists-to-sync.txt` where each line is like this: `link-here.com optional-links.com just-like-this.com;folder name here`. You can ignore a line by adding a `#` to the start of the line. Here is a sample file:
```bash
https://open.spotify.com/playlist/4O[redacted]84;Liked Songs
# https://open.spotify.com/playlist/37[redacted]8a;Orchestra
```
The playlists will be synched to the folders named `Liked Songs` and `Orchestra` in the sample. However the second line is skipped due to the `#` character in the file. You can sync multiple playlists in one folder by splitting each link with a space (' '). You can set `Liked Songs/Sub Directory Name` as the folder to create empty folder `Liked Songs` and inside there then the files will be synced in `Sub Directory Name`.

If the folders registered in `playlists-to-sync.txt` have songs only available locally, they are deleted unless you add those tracks to the playlists the folders are supposed to backup.

See `python3 spotify-sync.py --help` for more information (on duplicating files, it is disabled by default).

# Scheduling
You can utilize Task Scheduler on Windows 10, and for Linux, Ubuntu comes with Systemd. There are also other tools that can help with the task. I leave the searching to you. I will, however, [link one guide](https://www.learnlinux.tv/automate-your-tasks-with-systemd-timers-a-step-by-step-guide/) on systemd timers. Something more universal and simpler (i.e., less abstracted) could be [cron jobs](https://www.howtogeek.com/devops/what-is-a-cron-job-and-how-do-you-use-them/).

I will only guide you through the steps I took on Windows 10. Download [Syncthing.xml](https://files.catbox.moe/5yi9mk.xml) and [Spotify Sync.xml](https://files.catbox.moe/x9qgo9.xml). Import them on Task Scheduler, then edit the Actions section of both tasks to fit your environment. `Runner.bat`, used for `Spotify Sync.xml`, is provided and explained next.

That file first changes the working directory to the picked folder, then runs `python spotify-sync.py --duplicate-removal-method AEO`. `Pythonw.exe` is avoided because there are some effortfully unresolved, obscure bugs associated with it, so I migrated to a batch script.
```bash
cd C:\Users\myxi\Music\Spotify
python spotify-sync.py --duplicate-removal-method aeo
```
