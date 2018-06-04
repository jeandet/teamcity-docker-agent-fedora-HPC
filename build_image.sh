docker build -t jeandet/teamcity-docker-agent-fedora-hpc .
docker run -d=true -e SERVER_URL=https://hephaistos.lpp.polytechnique.fr/teamcity --name=teamcity-docker-agent-fedora-hpc -it jeandet/teamcity-docker-agent-fedora-hpc &
sleep 300
docker stop teamcity-docker-agent-fedora-hpc
docker commit teamcity-docker-agent-fedora-hpc jeandet/teamcity-docker-agent-fedora-hpc
docker rm teamcity-docker-agent-fedora-hpc
