import java.util.logging.FileHandler
import java.util.logging.SimpleFormatter
import java.util.logging.LogManager
import java.util.logging.Level
import jenkins.model.Jenkins

/* put logs from given Java package to a file */
def setup_custom_logging(String package_name) {
    def RunLogger = LogManager.getLogManager().getLogger(package_name)
    def logsDir = new File(Jenkins.instance.rootDir, "custom_logs")
    if(!logsDir.exists()) {
        logsDir.mkdirs()
    }
    FileHandler handler = new FileHandler(logsDir.absolutePath+"/${package_name}-%g.log",
                                          100 * 1024 * 1024, 10, true);

    handler.setFormatter(new SimpleFormatter());
    handler.setLevel(Level.FINE)
    RunLogger.addHandler(handler)
    println "--> custom log for ${package_name} was set"
}

def packages = [
    "com.dabsquared.gitlabjenkins",
    "org.csanchez.jenkins.plugins.kubernetes",
    "hudson.TcpSlaveAgentListener",
    "org.kohsuke.github",
    "org.jenkinsci.plugins.github_branch_source",
    "org.jenkinsci.plugins.github",
]

packages.each { pkg ->
    setup_custom_logging(pkg)
}
