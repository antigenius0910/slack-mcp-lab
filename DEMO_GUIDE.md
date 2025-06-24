# 🚨 K3s Web App Monitoring Demo Guide

## Overview
This demonstration showcases a complete monitoring and troubleshooting environment using:
- **K3s Kubernetes cluster** with a problematic web application
- **Grafana monitoring stack** (Grafana + Prometheus + Loki)
- **MCP (Model Context Protocol) servers** for AI-powered investigation
- **Slack integration** for conversational troubleshooting

## 🎯 What's Been Set Up

### 1. Monitoring Infrastructure
- ✅ **Grafana Stack** deployed via Helm chart
- ✅ **Prometheus** collecting metrics from all pods
- ✅ **Loki** aggregating logs
- ✅ **Custom Grafana dashboard** for web application monitoring
- ✅ **Alert rules** configured for common issues

### 2. Web Application
- ✅ **Original backend/frontend** (healthy baseline)
- ✅ **Problematic backend** with intentional issues:
  - Low memory limits (64Mi) to trigger OOM kills
  - CPU throttling (100m limit)
  - Random HTTP errors (20% failure rate)
  - Slow responses (30% of requests)
  - Health check failures
  - Custom metrics generation

### 3. MCP Server Integration
- ✅ **Kubernetes MCP Server** for cluster operations
- ✅ **Grafana MCP Server** for monitoring queries
- ✅ **Filesystem MCP Server** for file operations
- ✅ **Slack MCP Client** with Anthropic AI integration

## 🔍 Access Points

### Grafana Dashboard
- **URL**: http://localhost:3000
- **Username**: admin
- **Password**: admin123
- **Dashboard**: "Web Application Dashboard"

### Web Applications
- **Original Frontend**: http://localhost:8080
- **Problematic Backend**: http://localhost:8081
- **Backend Metrics**: http://localhost:3001/metrics

### Prometheus
- **URL**: http://localhost:9090

## 🚨 Problem Scenarios Created

### 1. HTTP Errors
- **What**: Random 500/502/503/504 errors
- **Frequency**: 20% of requests
- **Observable in**: Error rate metrics, HTTP status code graphs

### 2. Performance Issues
- **What**: Slow response times (1-5 second delays)
- **Frequency**: 30% of requests
- **Observable in**: Response time percentiles, latency graphs

### 3. Resource Constraints
- **What**: Low memory/CPU limits causing throttling
- **Limits**: 64Mi memory, 100m CPU
- **Observable in**: Resource usage graphs, throttling events

### 4. Health Check Failures
- **What**: Intermittent liveness/readiness probe failures
- **Observable in**: Pod restart counts, health check metrics

### 5. Load Spikes
- **What**: Concurrent request bursts
- **Observable in**: Request rate spikes, resource usage peaks

## 🤖 MCP Commands for Investigation

### Kubernetes Operations
```
kubectl get pods -n webapp
kubectl describe pod <pod-name> -n webapp
kubectl logs <pod-name> -n webapp
kubectl top pods -n webapp
kubectl get events -n webapp --sort-by=.metadata.creationTimestamp
```

### Grafana Queries
```
search_dashboards query:"Web Application"
query_prometheus expr:"messages_total" datasourceUid:"prometheus"
query_prometheus expr:"rate(http_requests_total[5m])" datasourceUid:"prometheus"
list_alert_rules
get_dashboard_by_uid uid:"12f74260-6a7c-477f-9e0b-21d009493ad9"
```

### Advanced Monitoring
```
query_loki_logs datasourceUid:"loki" logql:"{namespace=\"webapp\"}"
list_prometheus_metric_names datasourceUid:"prometheus"
query_prometheus expr:"container_memory_usage_bytes{namespace=\"webapp\"}" datasourceUid:"prometheus"
```

## 🎮 Demo Scenarios

### Scenario 1: Real-time Problem Detection
1. **Run problem generator**: `./problem-generator.sh`
2. **Watch Grafana dashboard** for metrics spikes
3. **Use MCP commands** to investigate root cause
4. **Correlate metrics** with pod events and logs

### Scenario 2: Memory Pressure Investigation
1. **Trigger memory stress**: `./problem-generator.sh memory`
2. **Query memory metrics**: `query_prometheus expr:"container_memory_usage_bytes{namespace=\"webapp\"}" datasourceUid:"prometheus"`
3. **Check for OOM events**: `kubectl get events -n webapp | grep OOM`
4. **Analyze pod restarts**: `kubectl get pods -n webapp -w`

### Scenario 3: Error Rate Analysis
1. **Generate errors**: `./problem-generator.sh errors`
2. **Check error rates**: `query_prometheus expr:"rate(http_requests_total{status=~\"5..\"}[5m])" datasourceUid:"prometheus"`
3. **Investigate logs**: `query_loki_logs datasourceUid:"loki" logql:"{namespace=\"webapp\"} |= \"error\""`
4. **Correlate with application health**: `kubectl describe pod <pod-name> -n webapp`

### Scenario 4: Performance Troubleshooting
1. **Create load spike**: `./problem-generator.sh load`
2. **Monitor response times**: Check Grafana dashboard percentile graphs
3. **Analyze resource usage**: `kubectl top pods -n webapp`
4. **Check for throttling**: Look for CPU throttling events in metrics

## 🔧 Problem Generator Usage

### Full Demo Sequence
```bash
./problem-generator.sh
```

### Individual Problem Types
```bash
./problem-generator.sh errors      # HTTP errors
./problem-generator.sh slow        # Slow responses
./problem-generator.sh timeouts    # Timeout errors
./problem-generator.sh health      # Health check stress
./problem-generator.sh memory      # Memory stress
./problem-generator.sh load        # Load spike
./problem-generator.sh mixed       # Mixed traffic
./problem-generator.sh monitor     # Check pod status
./problem-generator.sh info        # Show info
```

## 📊 Key Metrics to Watch

### Application Metrics
- `http_requests_total` - Request counts by status code
- `http_request_duration_seconds` - Response time percentiles
- `messages_total` - Custom application metric
- `error_rate` - Application error percentage

### Infrastructure Metrics
- `container_memory_usage_bytes` - Memory consumption
- `container_cpu_usage_seconds_total` - CPU usage
- `kube_pod_container_status_restarts_total` - Pod restart counts
- `kube_pod_status_phase` - Pod health status

### System Metrics
- `node_memory_MemAvailable_bytes` - Available memory
- `node_cpu_seconds_total` - Node CPU usage
- `container_fs_usage_bytes` - Filesystem usage

## 🚀 Advanced Demonstrations

### 1. Incident Response Workflow
1. **Problem occurs** (run problem generator)
2. **Alert fires** (check Grafana alerts)
3. **Investigation begins** (use MCP commands in Slack)
4. **Root cause identified** (correlate metrics and logs)
5. **Resolution applied** (scale pods, adjust limits)
6. **Recovery verified** (monitor metrics return to normal)

### 2. Capacity Planning
1. **Baseline measurement** (normal traffic patterns)
2. **Load testing** (gradual traffic increase)
3. **Resource monitoring** (CPU/memory utilization)
4. **Bottleneck identification** (where limits are hit first)
5. **Scaling decisions** (horizontal vs vertical scaling)

### 3. SLI/SLO Monitoring
1. **Define SLIs** (error rate < 1%, latency p99 < 500ms)
2. **Monitor SLOs** (track compliance over time)
3. **Alert on SLO violations** (when SLIs exceed thresholds)
4. **Error budget tracking** (remaining error budget)

## 🎯 Learning Objectives

After this demo, you should understand:
- How to set up comprehensive monitoring for Kubernetes applications
- How to use Grafana dashboards for observability
- How to correlate metrics, logs, and events for troubleshooting
- How to use AI-powered tools (MCP) for investigation
- How to identify and resolve common application issues
- How to implement proactive monitoring and alerting

## 🔄 Cleanup

To clean up the demo environment:
```bash
# Remove problematic backend
kubectl delete -f backend-with-problems.yaml

# Remove monitoring stack (optional)
helm uninstall grafana-stack -n monitoring

# Remove namespace (optional)
kubectl delete namespace webapp monitoring
```

## 📝 Notes

- The problematic backend is intentionally configured with issues
- Memory limits are set very low (64Mi) to trigger problems quickly
- All metrics are simulated but represent realistic scenarios
- The MCP integration allows for conversational troubleshooting
- This setup demonstrates modern observability practices

---

**Happy Monitoring!** 🎉

For questions or issues, check the logs and use the MCP commands to investigate!
