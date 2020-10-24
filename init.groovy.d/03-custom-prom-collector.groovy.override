import jenkins.model.Jenkins
import io.prometheus.client.Collector;
import io.prometheus.client.GaugeMetricFamily
import io.prometheus.client.CollectorRegistry;
import io.prometheus.client.Collector.MetricFamilySamples;

class BuildsCountByJobCollector extends Collector {
    String metricName = "jenkins_builds_in_queue_by_job_count"
    String helpString = "Builds in queue count by job"
    String labelName = "jenkins_job"

    List<MetricFamilySamples> collect() {
        List<MetricFamilySamples> mfs = new ArrayList<MetricFamilySamples>();

        GaugeMetricFamily labeledGauge = new GaugeMetricFamily(metricName,
                                                               helpString,
                                                               [labelName]);

        Map buildsCount = [:]

        def q = Jenkins.instance.queue

        q.items.each {
            if (it.task.class == org.jenkinsci.plugins.workflow.multibranch.WorkflowMultiBranchProject.class) {
                return // skip multibranch project indexing, we don't need them
            }
            def taskRunId = it.task.runId
            def jobName = taskRunId.substring(0, taskRunId.lastIndexOf('#'))

            buildsCount[jobName] = buildsCount.get(jobName, 0) + 1
        }

        buildsCount.each {
            labeledGauge.addMetric([it.key], it.value);
        }

        mfs.add(labeledGauge);
        return mfs;
    }
}

CollectorRegistry.defaultRegistry.collectors().each {
    if (it.class == BuildsCountByJobCollector) {
        // WARNING! it will delete all your custom collectors!
        CollectorRegistry.defaultRegistry.unregister(it)
    }
}

BuildsCountByJobCollector col = new BuildsCountByJobCollector().register()
