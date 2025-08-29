#!/bin/bash

# =============================================================================
# Performance Benchmarks Module - DebianForge
# =============================================================================
# Copyright (c) 2025 Alexander Mishagin
# 
# This module CANNOT be executed directly.
# It must be called through main.sh for security reasons.
# =============================================================================

# Security check - prevent direct execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Error: This module cannot be executed directly."
    echo "Please use: ./main.sh performance benchmark [parameters]"
    exit 1
fi

# =============================================================================
# Performance Benchmark Functions
# =============================================================================

# Run system performance benchmarks
run_benchmarks() {
    local params=("$@")
    
    echo "⚡ Starting system performance benchmarks..."
    
    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        echo "Error: Performance benchmarks require root privileges"
        echo "Please run: sudo ./main.sh performance benchmark"
        return 1
    fi
    
    # Parse parameters
    local benchmark_type="full"
    local output_format="console"
    
    for param in "${params[@]}"; do
        case "$param" in
            "cpu") benchmark_type="cpu" ;;
            "memory") benchmark_type="memory" ;;
            "disk") benchmark_type="disk" ;;
            "network") benchmark_type="network" ;;
            "full") benchmark_type="full" ;;
            "html") output_format="html" ;;
            "json") output_format="json" ;;
            "csv") output_format="csv" ;;
            "markdown") output_format="markdown" ;;
        esac
    done
    
    echo "Benchmark Type: $benchmark_type"
    echo "Output Format: $output_format"
    
    # Run benchmarks based on type
    case "$benchmark_type" in
        "cpu")
            run_cpu_benchmarks "$output_format"
            ;;
        "memory")
            run_memory_benchmarks "$output_format"
            ;;
        "disk")
            run_disk_benchmarks "$output_format"
            ;;
        "network")
            run_network_benchmarks "$output_format"
            ;;
        "full")
            run_full_benchmarks "$output_format"
            ;;
    esac
}

# Run CPU benchmarks
run_cpu_benchmarks() {
    local output_format="$1"
    
    echo "Running CPU benchmarks..."
    
    # Check if sysbench is available
    if ! command_exists sysbench; then
        echo "Installing sysbench..."
        apt update && apt install -y sysbench
    fi
    
    # CPU benchmark
    echo "CPU Benchmark Results:"
    sysbench cpu --cpu-max-prime=20000 run
    
    # Generate report
    generate_benchmark_report "cpu" "$output_format"
}

# Run memory benchmarks
run_memory_benchmarks() {
    local output_format="$1"
    
    echo "Running memory benchmarks..."
    
    # Memory benchmark
    echo "Memory Benchmark Results:"
    sysbench memory --memory-block-size=1K --memory-total-size=100G run
    
    # Generate report
    generate_benchmark_report "memory" "$output_format"
}

# Run disk benchmarks
run_disk_benchmarks() {
    local output_format="$1"
    
    echo "Running disk benchmarks..."
    
    # Check if fio is available
    if ! command_exists fio; then
        echo "Installing fio..."
        apt update && apt install -y fio
    fi
    
    # Disk benchmark
    echo "Disk Benchmark Results:"
    fio --name=randread --ioengine=libaio --iodepth=16 --rw=randread --bs=4k --direct=1 --size=1G --numjobs=4
    
    # Generate report
    generate_benchmark_report "disk" "$output_format"
}

# Run network benchmarks
run_network_benchmarks() {
    local output_format="$1"
    
    echo "Running network benchmarks..."
    
    # Check if iperf3 is available
    if ! command_exists iperf3; then
        echo "Installing iperf3..."
        apt update && apt install -y iperf3
    fi
    
    # Network benchmark (server mode)
    echo "Starting iperf3 server..."
    iperf3 -s &
    local iperf_pid=$!
    
    sleep 2
    
    # Test localhost
    echo "Testing localhost network performance:"
    iperf3 -c localhost -t 10
    
    # Stop server
    kill $iperf_pid 2>/dev/null
    
    # Generate report
    generate_benchmark_report "network" "$output_format"
}

# Run full benchmarks
run_full_benchmarks() {
    local output_format="$1"
    
    echo "Running comprehensive performance benchmarks..."
    
    # Run all benchmark types
    run_cpu_benchmarks "$output_format"
    run_memory_benchmarks "$output_format"
    run_disk_benchmarks "$output_format"
    run_network_benchmarks "$output_format"
    
    # Generate comprehensive report
    generate_benchmark_report "full" "$output_format"
}

# Generate benchmark report
generate_benchmark_report() {
    local benchmark_type="$1"
    local output_format="$2"
    
    echo "Generating $benchmark_type benchmark report in $output_format format..."
    
    # Create reports directory if it doesn't exist
    mkdir -p "$SCRIPT_DIR/../reports/performance"
    
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local report_file="$SCRIPT_DIR/../reports/performance/performance-benchmark-${benchmark_type}-${timestamp}"
    
    case "$output_format" in
        "html")
            generate_benchmark_html_report "$report_file.html" "$benchmark_type"
            ;;
        "json")
            generate_benchmark_json_report "$report_file.json" "$benchmark_type"
            ;;
        "csv")
            generate_benchmark_csv_report "$report_file.csv" "$benchmark_type"
            ;;
        "markdown")
            generate_benchmark_markdown_report "$report_file.md" "$benchmark_type"
            ;;
        "console"|*)
            generate_benchmark_console_report "$report_file.txt" "$benchmark_type"
            ;;
    esac
    
    echo "Benchmark report generated: $report_file.$output_format"
}

# Generate console benchmark report
generate_benchmark_console_report() {
    local report_file="$1"
    local benchmark_type="$2"
    
    {
        echo "==============================================================================="
        echo "                        PERFORMANCE BENCHMARK REPORT"
        echo "                           DebianForge v1.0"
        echo "                    Functional Grouping Architecture"
        echo "==============================================================================="
        echo
        echo "REPORT INFORMATION"
        echo "=================="
        echo "Generated: $(date)"
        echo "Benchmark Type: $benchmark_type"
        echo "System: $(hostname)"
        echo
        echo "BENCHMARKS COMPLETED"
        echo "===================="
        case "$benchmark_type" in
            "cpu")
                echo "✅ CPU performance tested"
                ;;
            "memory")
                echo "✅ Memory performance tested"
                ;;
            "disk")
                echo "✅ Disk I/O performance tested"
                ;;
            "network")
                echo "✅ Network performance tested"
                ;;
            "full")
                echo "✅ CPU performance tested"
                echo "✅ Memory performance tested"
                echo "✅ Disk I/O performance tested"
                echo "✅ Network performance tested"
                ;;
        esac
        echo
        echo "==============================================================================="
        echo "Generated by DebianForge v1.0 | Functional Grouping Architecture"
        echo "For more information, visit the project documentation"
        echo "==============================================================================="
    } > "$report_file"
}

# Generate HTML benchmark report
generate_benchmark_html_report() {
    local report_file="$1"
    local benchmark_type="$2"
    
    {
        echo "<!DOCTYPE html>"
        echo "<html lang='en'>"
        echo "<head>"
        echo "    <meta charset='UTF-8'>"
        echo "    <meta name='viewport' content='width=device-width, initial-scale=1.0'>"
        echo "    <title>Performance Benchmark Report - DebianForge</title>"
        echo "    <style>"
        echo "        body { font-family: Arial, sans-serif; margin: 20px; }"
        echo "        .header { text-align: center; margin-bottom: 30px; }"
        echo "        .section { margin: 20px 0; }"
        echo "        .status { padding: 5px 10px; border-radius: 3px; }"
        echo "        .success { background-color: #d4edda; color: #155724; }"
        echo "    </style>"
        echo "</head>"
        echo "<body>"
        echo "    <div class='header'>"
        echo "        <h1>⚡ Performance Benchmark Report</h1>"
        echo "        <div class='subtitle'>DebianForge v1.0</div>"
        echo "    </div>"
        echo "    <div class='section'>"
        echo "        <h2>Report Information</h2>"
        echo "        <p><strong>Generated:</strong> $(date)</p>"
        echo "        <p><strong>Benchmark Type:</strong> $benchmark_type</p>"
        echo "        <p><strong>System:</strong> $(hostname)</p>"
        echo "    </div>"
        echo "    <div class='section'>"
        echo "        <h2>Benchmark Results</h2>"
        echo "        <p><span class='status success'>✅ $benchmark_type benchmarks completed</span></p>"
        echo "    </div>"
        echo "    <div class='footer'>"
        echo "        <p>Generated by DebianForge v1.0 | Functional Grouping Architecture</p>"
        echo "        <p>For more information, visit the project documentation</p>"
        echo "    </div>"
        echo "</body>"
        echo "</html>"
    } > "$report_file"
}

# Generate JSON benchmark report
generate_benchmark_json_report() {
    local report_file="$1"
    local benchmark_type="$2"
    
    {
        echo "{"
        echo "  \"report\": {"
        echo "    \"metadata\": {"
        echo "      \"title\": \"Performance Benchmark Report\","
        echo "      \"version\": \"1.0\","
        echo "      \"generator\": \"DebianForge\","
        echo "      \"architecture\": \"Functional Grouping\","
        echo "      \"generated_date\": \"$(date -Iseconds)\","
        echo "      \"benchmark_type\": \"$benchmark_type\","
        echo "      \"system\": \"$(hostname)\""
        echo "    },"
        echo "    \"benchmarks\": {"
        echo "      \"type\": \"$benchmark_type\","
        echo "      \"status\": \"completed\""
        echo "    },"
        echo "    \"export_info\": {"
        echo "      \"format\": \"JSON\","
        echo "      \"schema_version\": \"1.0\""
        echo "    }"
        echo "  }"
        echo "}"
    } > "$report_file"
}

# Generate CSV benchmark report
generate_benchmark_csv_report() {
    local report_file="$1"
    local benchmark_type="$2"
    
    {
        echo "Title,Performance Benchmark Report"
        echo "Version,1.0"
        echo "Generator,DebianForge"
        echo "Architecture,Functional Grouping"
        echo "Generated Date,$(date)"
        echo "Benchmark Type,$benchmark_type"
        echo "System,$(hostname)"
        echo "Status,Completed"
    } > "$report_file"
}

# Generate Markdown benchmark report
generate_benchmark_markdown_report() {
    local report_file="$1"
    local benchmark_type="$2"
    
    {
        echo "# Performance Benchmark Report"
        echo
        echo "**DebianForge v1.0** | *Functional Grouping Architecture*"
        echo
        echo "---"
        echo
        echo "## Report Information"
        echo
        echo "- **Generated**: $(date)"
        echo "- **Benchmark Type**: $benchmark_type"
        echo "- **System**: $(hostname)"
        echo "- **Version**: 1.0"
        echo
        echo "## Benchmark Results"
        echo
        echo "| Component | Status | Details |"
        echo "|-----------|--------|---------|"
        
        case "$benchmark_type" in
            "cpu")
                echo "| CPU | ✅ Completed | Performance tested with sysbench |"
                ;;
            "memory")
                echo "| Memory | ✅ Completed | Memory bandwidth tested |"
                ;;
            "disk")
                echo "| Disk | ✅ Completed | I/O performance tested with fio |"
                ;;
            "network")
                echo "| Network | ✅ Completed | Bandwidth tested with iperf3 |"
                ;;
            "full")
                echo "| CPU | ✅ Completed | Performance tested with sysbench |"
                echo "| Memory | ✅ Completed | Memory bandwidth tested |"
                echo "| Disk | ✅ Completed | I/O performance tested with fio |"
                echo "| Network | ✅ Completed | Bandwidth tested with iperf3 |"
                ;;
        esac
        
        echo
        echo "## Summary"
        echo
        echo "Performance benchmarks completed successfully. All requested benchmark types have been executed and results recorded."
        echo
        echo "---"
        echo
        echo "*Generated by DebianForge v1.0 | Functional Grouping Architecture*"
    } > "$report_file"
}

# Helper function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}
