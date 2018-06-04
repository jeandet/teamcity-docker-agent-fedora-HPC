FROM fedora:26
#Derived from official TeamCity image
LABEL modified "Alexis Jeandet <alexis.jeandet@member.fsf.org>"

RUN dnf clean all
RUN dnf update -y
RUN dnf install -y java-1.8.0-openjdk mercurial git tar gzip unzip xorg-x11-server-Xvfb cmake meson

VOLUME /data/teamcity_agent/conf
ENV CONFIG_FILE=/data/teamcity_agent/conf/buildAgent.properties \
    TEAMCITY_AGENT_DIST=/opt/buildagent

RUN mkdir $TEAMCITY_AGENT_DIST

ADD https://teamcity.jetbrains.com/update/buildAgent.zip $TEAMCITY_AGENT_DIST/
RUN unzip $TEAMCITY_AGENT_DIST/buildAgent.zip -d $TEAMCITY_AGENT_DIST/

LABEL dockerImage.teamcity.version="latest" \
      dockerImage.teamcity.buildNumber="latest"

COPY run-agent.sh /run-agent.sh
COPY run-services.sh /run-services.sh

RUN useradd -m buildagent && \
    chmod +x /run-agent.sh /run-services.sh && \
    rm $TEAMCITY_AGENT_DIST/buildAgent.zip && \
    sync


RUN dnf install -y findutils
RUN dnf install -y cppcheck luabind-devel tcl-devel tk-devel lua-devel  ncurses-devel lcov
RUN dnf install -y git ninja-build ncurses-devel cups-devel zlib-static zlib-devel itstool libpcap-devel SDL2-devel wget redhat-rpm-config  gettext unzip doxygen
RUN dnf install -y gcc-objc++ flex flex-devel bison-devel bison gcc-objc libasan valgrind libaec-devel
RUN dnf install -y vala hg mesa-vulkan-devel vulkan-devel
RUN dnf install -y libwmf-devel qt5*-devel qt*-devel wxGTK-devel wxGTK3-devel
RUN dnf install -y llvm llvm-devel llvm3.9-devel llvm-static clang-devel llvm-static clang-analyzer libasan libubsan
RUN dnf install -y boost-*-devel
RUN dnf install -y openmpi mpich-devel environment-modules openmpi-devel hdf5-devel
RUN dnf install -y graphviz texlive-*
RUN dnf install -y gitstats
RUN dnf install -y python3-scipy python3-numpy
RUN dnf install -y python2-devel python2-scipy python2-numpy
RUN dnf install -y python3-sphinx python3-sphinx_rtd_theme python3-breathe python3-docutils
RUN dnf install -y python2-sphinx python2-sphinx_rtd_theme python2-breathe python2-docutils



# SonarQube
RUN wget https://sonarcloud.io/static/cpp/build-wrapper-linux-x86.zip
RUN wget http://repo1.maven.org/maven2/org/codehaus/sonar/runner/sonar-runner-dist/2.4/sonar-runner-dist-2.4.zip
RUN unzip build-wrapper-linux-x86.zip -d /opt/
RUN unzip sonar-runner-dist-2.4.zip -d /opt/
RUN ln -s /opt/build-wrapper-linux-x86/build-wrapper-linux-x86-64 /usr/bin/build-wrapper-linux
RUN ln -s /opt/sonar-runner-2.4/bin/sonar-runner /usr/bin/sonar-runner

RUN rm build-wrapper-linux-x86.zip sonar-runner-dist-2.4.zip

# CLAZY
RUN git clone https://github.com/KDE/clazy.git /root/clazy
RUN cd /root/clazy && mkdir build && cd build && cmake ../ && make -j 4 && make install


RUN mkdir -p /opt/intel/licenses/
RUN wget http://jetons.polytechnique.fr/licences/intel/license.lic -O /opt/intel/licenses/license.lic
RUN wget http://jetons.polytechnique.fr/licences/intel/server.lic -O /opt/intel/licenses/server.lic

# ICC 2018
RUN wget http://pc-instru.lpp.polytechnique.fr/setups/parallel_studio_xe_2018_update1_composer_edition.tgz
RUN tar -xf parallel_studio_xe_2018_update1_composer_edition.tgz
COPY silent-icc2018.cfg /silent-icc2018.cfg
RUN parallel_studio_xe_2018_update1_composer_edition/install.sh -s silent-icc2018.cfg
RUN rm -rf parallel_studio_xe_2018_update1_composer_edition*

# ICC 2017
RUN wget http://pc-instru.lpp.polytechnique.fr/setups/parallel_studio_xe_2017_update4_composer_edition.tgz
RUN tar -xf parallel_studio_xe_2017_update4_composer_edition.tgz
COPY silent-icc2017.cfg /silent-icc2017.cfg
RUN parallel_studio_xe_2017_update4_composer_edition/install.sh -s silent-icc2017.cfg
RUN rm -rf parallel_studio_xe_2017_update4_composer_edition*


RUN mkdir pgilinux-2018-184-x86-64 && cd pgilinux-2018-184-x86-64
RUN wget http://pc-instru.lpp.polytechnique.fr/setups/pgilinux-2018-184-x86-64.tar.gz
RUN tar -xf pgilinux-2018-184-x86-64.tar.gz
ENV PGI_SILENT "true"
ENV PGI_ACCEPT_EULA "accept"
ENV PGI_INSTALL_DIR "/opt/pgi"
ENV PGI_INSTALL_TYPE "single"
ENV PGI_INSTALL_MPI "true"
RUN ./install
RUN cd /
RUN rm -rf /pgilinux-2018-184-x86-64*


RUN echo "system.has_qt5=true" >> /opt/buildagent/conf/buildAgent.dist.properties && \
    echo "system.has_icc=true" >> /opt/buildagent/conf/buildAgent.dist.properties && \
    echo "system.icc_version=2017;2018" >> /opt/buildagent/conf/buildAgent.dist.properties && \
    echo "system.has_pgi=true" >> /opt/buildagent/conf/buildAgent.dist.properties && \
    echo "system.pgi_version=2018" >> /opt/buildagent/conf/buildAgent.dist.properties && \
    echo "system.has_gcov=true" >> /opt/buildagent/conf/buildAgent.dist.properties && \
    echo "system.has_clang=true" >> /opt/buildagent/conf/buildAgent.dist.properties && \
    echo "system.has_clazy=true" >> /opt/buildagent/conf/buildAgent.dist.properties && \
    echo "system.has_cppcheck=true" >> /opt/buildagent/conf/buildAgent.dist.properties && \
    echo "system.has_clang_analyzer=true" >> /opt/buildagent/conf/buildAgent.dist.properties && \
    echo "system.has_lcov=true" >> /opt/buildagent/conf/buildAgent.dist.properties && \
    echo "system.has_gitstats=true" >> /opt/buildagent/conf/buildAgent.dist.properties && \
    echo "system.has_graphviz=true" >> /opt/buildagent/conf/buildAgent.dist.properties && \
    echo "system.has_sonarqube=true" >> /opt/buildagent/conf/buildAgent.dist.properties && \
    echo "system.has_openmpi=true" >> /opt/buildagent/conf/buildAgent.dist.properties  && \
    echo "system.agent_name=fedora-HPC" >> /opt/buildagent/conf/buildAgent.dist.properties  && \
    echo "system.agent_repo=https://github.com/jeandet/teamcity-docker-agent-fedora-HPC" >> /opt/buildagent/conf/buildAgent.dist.properties

CMD ["/run-services.sh"]

EXPOSE 9090
