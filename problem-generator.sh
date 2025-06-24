#!/bin/bash

# Problem Generator Script for K3s Web App Demo
# This script will generate various types of problems that can be observed in Grafana

echo "🚨 Starting Problem Generator for K3s Web App Demo"
echo "This will create observable issues in our monitoring dashboard..."

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BACKEND_URL="http://localhost:8080"
PROBLEMATIC_URL="http://localhost:8081"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $1"
}

print_error() {
    echo -e "${RED}[$(date '+%H:%M:%S')] ERROR:${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[$(date '+%H:%M:%S')] WARNING:${NC} $1"
}

print_success() {
    echo -e "${GREEN}[$(date '+%H:%M:%S')] SUCCESS:${NC} $1"
}

# Function to check if service is available
check_service() {
    local url=$1
    local name=$2
    
    if curl -s -f "$url" > /dev/null 2>&1; then
        print_success "$name is accessible at $url"
        return 0
    else
        print_error "$name is not accessible at $url"
        return 1
    fi
}

# Function to generate HTTP errors
generate_errors() {
    print_warning "🔥 Generating HTTP errors..."
    
    for i in {1..10}; do
        curl -s "$PROBLEMATIC_URL/api/error" > /dev/null 2>&1
        echo -n "."
        sleep 0.5
    done
    echo ""
    print_success "Generated 10 HTTP error requests"
}

# Function to generate slow responses
generate_slow_responses() {
    print_warning "🐌 Generating slow responses..."
    
    for i in {1..5}; do
        timeout 10s curl -s "$PROBLEMATIC_URL/" > /dev/null 2>&1 &
        echo -n "."
        sleep 1
    done
    wait
    echo ""
    print_success "Generated 5 slow response requests"
}

# Function to generate timeout errors
generate_timeouts() {
    print_warning "⏱️ Generating timeout errors..."
    
    for i in {1..5}; do
        curl -s --max-time 2 "$PROBLEMATIC_URL/api/timeout" > /dev/null 2>&1
        echo -n "."
        sleep 0.5
    done
    echo ""
    print_success "Generated 5 timeout requests"
}

# Function to stress test health checks
stress_health_checks() {
    print_warning "❤️ Stress testing health checks..."
    
    for i in {1..20}; do
        curl -s "$PROBLEMATIC_URL/health" > /dev/null 2>&1 &
        curl -s "$PROBLEMATIC_URL/ready" > /dev/null 2>&1 &
        echo -n "."
        sleep 0.2
    done
    wait
    echo ""
    print_success "Completed health check stress test"
}

# Function to generate load spikes
generate_load_spike() {
    print_warning "📈 Generating load spike..."
    
    # Start multiple concurrent requests
    for i in {1..20}; do
        (
            for j in {1..5}; do
                curl -s "$PROBLEMATIC_URL/" > /dev/null 2>&1
                curl -s "$PROBLEMATIC_URL/api/error" > /dev/null 2>&1
                sleep 0.1
            done
        ) &
        echo -n "."
    done
    wait
    echo ""
    print_success "Load spike completed"
}

# Function to trigger memory issues (by calling the problematic pods)
trigger_memory_issues() {
    print_warning "💾 Triggering memory stress..."
    
    # The low memory limits should cause issues
    for i in {1..3}; do
        curl -s "$PROBLEMATIC_URL/api/memory" > /dev/null 2>&1 &
        echo -n "."
        sleep 2
    done
    wait
    echo ""
    print_success "Memory stress requests sent"
}

# Function to create mixed traffic patterns
create_mixed_traffic() {
    print_warning "🌊 Creating mixed traffic patterns..."
    
    # Mix of successful and failing requests
    for i in {1..30}; do
        case $((i % 4)) in
            0) curl -s "$PROBLEMATIC_URL/" > /dev/null 2>&1 ;;
            1) curl -s "$PROBLEMATIC_URL/api/error" > /dev/null 2>&1 ;;
            2) curl -s "$PROBLEMATIC_URL/health" > /dev/null 2>&1 ;;
            3) curl -s "$PROBLEMATIC_URL/api/timeout" > /dev/null 2>&1 ;;
        esac
        echo -n "."
        sleep 0.3
    done
    echo ""
    print_success "Mixed traffic pattern completed"
}

# Function to monitor pod status
monitor_pods() {
    print_status "📊 Current pod status:"
    kubectl get pods -n webapp -l app=backend-api-problematic -o wide
    echo ""
    
    print_status "📈 Resource usage:"
    kubectl top pods -n webapp -l app=backend-api-problematic 2>/dev/null || echo "Metrics not available yet"
    echo ""
}

# Function to show Grafana dashboard info
show_grafana_info() {
    echo ""
    echo "🎯 Grafana Dashboard Information:"
    echo "=================================="
    echo "• Grafana URL: http://localhost:3000"
    echo "• Username: admin"
    echo "• Password: admin123"
    echo "• Dashboard: Web Application Dashboard"
    echo ""
    echo "🔍 What to watch for:"
    echo "• Pod restart counts increasing"
    echo "• Memory usage approaching limits (64Mi)"
    echo "• HTTP error rates spiking"
    echo "• Response time increases"
    echo "• Health check failures"
    echo "• CPU throttling events"
    echo ""
}

# Function to show MCP commands
show_mcp_commands() {
    echo "🤖 MCP Server Commands to Try:"
    echo "==============================="
    echo "In Slack, you can now use these commands to investigate:"
    echo ""
    echo "Kubernetes MCP:"
    echo "• kubectl get pods -n webapp"
    echo "• kubectl describe pod <pod-name> -n webapp"
    echo "• kubectl logs <pod-name> -n webapp"
    echo "• kubectl top pods -n webapp"
    echo ""
    echo "Grafana MCP:"
    echo "• search_dashboards query:'Web Application'"
    echo "• query_prometheus expr:'messages_total' datasourceUid:'prometheus'"
    echo "• list_alert_rules"
    echo "• get_dashboard_by_uid uid:'12f74260-6a7c-477f-9e0b-21d009493ad9'"
    echo ""
}

# Main execution
main() {
    echo "🚀 K3s Web App Problem Generator"
    echo "================================"
    echo ""
    
    # Check if services are available
    print_status "Checking service availability..."
    if ! check_service "$PROBLEMATIC_URL" "Problematic Backend"; then
        print_error "Please ensure port-forward is running: kubectl port-forward -n webapp service/backend-problematic-service 8080:80"
        exit 1
    fi
    
    echo ""
    print_status "Starting problem generation sequence..."
    echo ""
    
    # Show initial pod status
    monitor_pods
    
    # Generate different types of problems
    generate_errors
    sleep 2
    
    generate_slow_responses
    sleep 2
    
    generate_timeouts
    sleep 2
    
    stress_health_checks
    sleep 3
    
    trigger_memory_issues
    sleep 3
    
    generate_load_spike
    sleep 3
    
    create_mixed_traffic
    sleep 2
    
    # Show final pod status
    print_status "Final pod status after problem generation:"
    monitor_pods
    
    # Show information about monitoring
    show_grafana_info
    show_mcp_commands
    
    print_success "Problem generation completed! Check your Grafana dashboard for the results."
    echo ""
    echo "💡 Tip: Run this script multiple times to create ongoing issues for demonstration."
    echo "💡 Use 'kubectl get events -n webapp --sort-by=.metadata.creationTimestamp' to see recent events."
}

# Handle script arguments
case "${1:-}" in
    "errors")
        generate_errors
        ;;
    "slow")
        generate_slow_responses
        ;;
    "timeouts")
        generate_timeouts
        ;;
    "health")
        stress_health_checks
        ;;
    "memory")
        trigger_memory_issues
        ;;
    "load")
        generate_load_spike
        ;;
    "mixed")
        create_mixed_traffic
        ;;
    "monitor")
        monitor_pods
        ;;
    "info")
        show_grafana_info
        show_mcp_commands
        ;;
    *)
        main
        ;;
esac
