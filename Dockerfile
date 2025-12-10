FROM cm2network/steamcmd:latest

RUN mkdir -p /home/steam/kf2
WORKDIR /home/steam
RUN /home/steam/steamcmd/steamcmd.sh +force_install_dir /home/steam/kf2 \
    +login anonymous \
    +app_update 232130 validate \
    +quit

WORKDIR /home/steam/kf2
CMD ["./Binaries/Win64/KFGameSteamServer.bin.x86_64", "kf-bioticslab"]