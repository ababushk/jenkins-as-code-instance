FROM jenkins/jenkins:2.235.5-jdk11

USER root

# Install plugins
# force versions from plugins.txt
ENV PLUGINS_FORCE_UPGRADE=true
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

# Install groovy startup hooks
COPY init.groovy.d/*.groovy.override /usr/share/jenkins/ref/init.groovy.d/

# configuration as code settings
ENV CASC_JENKINS_CONFIG=/var/jenkins_home/casc
COPY casc /usr/share/jenkins/ref/casc

# Prevent setup wizard
RUN echo $JENKINS_VERSION | tee \
    $jenkins_home/jenkins.install.UpgradeWizard.state \
    $jenkins_home/jenkins.install.InstallUtil.lastExecVersion

VOLUME $JENKINS_HOME/builds
VOLUME $JENKINS_HOME/custom_logs

# Setting JAVA_OPTS
# 1. Increase heap size. Jenkins can work with default heap size, but we debug an issue with very long scheduling time (with available kubernetes agents) when number of builds in queue is very high (>700)
# 2. increate timeout for pipeline 'sh' step to cause exception when machine hangs. Useful for slow machines (e.g. raspberry)
# 3. disable security for pipeline scripts. Dangerous, but script approval is no longer required
# 4. Java's native proxy settings (mostly for Pipeline: GitHub plugin)
# 5. timezone (doesn't affect 'build periodically' triggers, it should be specified explicitly in time specification there)
# 6. Disable security policies for static content (css, js, html, png files included in tests reports)
# 7. Switch default encoding to UTF-8 (should fix zip step on files with cyrillic symbols
# 8. Switch default Display URL to Classic view instead of BlueOcean
# 9. JVM memory settings. We've faced this https://bugs.openjdk.java.net/browse/JDK-8024669 and tried to set
#    the base address for the heap somewhere above first 32GB. It didn't work, so we've disabled CompressedOops
#    completely
# 10. JVM garbage collection logging settings
# 11. Prevent timeout when using kubernetes in declarative pipelines with two containers in a pod
# 12. Separate builds from jobs configurations
ENV JAVA_OPTS='\
        -Djenkins.install.runSetupWizard=false \
        -Dorg.jenkinsci.plugins.durabletask.BourneShellScript.LAUNCH_DIAGNOSTICS=true \
        -Dorg.jenkinsci.plugins.durabletask.BourneShellScript.HEARTBEAT_CHECK_INTERVAL=84000 \
        -Dpermissive-script-security.enabled=no_security \
        -Dorg.apache.commons.jelly.tags.fmt.timeZone=Europe/Moscow \
        -Dhudson.model.DirectoryBrowserSupport.CSP= \
        -Dfile.encoding=UTF-8 \
        -Djenkins.displayurl.provider=org.jenkinsci.plugins.displayurlapi.ClassicDisplayURLProvider \
        -Xlog:gc*,gc+ref=debug,gc+heap=debug,gc+age=trace:file=/var/jenkins_home/gc-%p-%t.log:tags,uptime,time,level:filecount=10,filesize=500m \
        -XX:-UseCompressedOops \
        -Djenkins.model.Jenkins.buildsDir=${JENKINS_HOME}/builds/${ITEM_FULL_NAME}'

USER jenkins
# parent's ENTRYPOINT should be used
