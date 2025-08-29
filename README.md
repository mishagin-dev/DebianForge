# 🔧 DebianForge

[![Version](https://img.shields.io/badge/version-0.9.8_alpha-orange.svg)](https://github.com/mishagin-dev/DebianForge)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Status](https://img.shields.io/badge/status-active%20development-brightgreen.svg)](https://github.com/mishagin-dev/DebianForge)
[![Platform](https://img.shields.io/badge/platform-Debian%2013-orange.svg)](https://www.debian.org/)
[![Shell](https://img.shields.io/badge/shell-Bash%205.0+-lightgrey.svg)](https://www.gnu.org/software/bash/)
[![Architecture](https://img.shields.io/badge/architecture-modular-blue.svg)](https://github.com/mishagin-dev/DebianForge)

A comprehensive, all-in-one solution for Debian-based server optimization, security auditing, and system administration. Combines performance tuning, security hardening, and automated reporting in a single, intelligent toolkit.

> **🇷🇺 Русская версия**: [README_ru.md](README_ru.md)

## ✨ Features

- **System Performance Optimization**: CPU, Memory, Disk, Network tuning
- **Security Audit & Hardening**: Automated vulnerability assessment and security configuration
- **Real-time Monitoring**: System resource tracking and performance metrics
- **Comprehensive Reporting**: Multiple formats (HTML, JSON, CSV, Console)
- **Modular Architecture**: Easy to extend and customize
- **Automated Security**: Firewall, SSH, intrusion detection, and audit tools

## 🏗️ Architecture

The project uses a **Functional Grouping** architecture for better organization and maintainability:

```
DebianForge/
├── lib/                    # Core library functions
├── modules/                # Functional modules
│   ├── performance/        # Performance optimization
│   ├── security/           # Security tools and auditing
│   └── system/             # System administration
├── resources/              # Configuration files and resources
└── reports/                # Generated reports and templates
```

## 🚀 Quick Start

### Prerequisites

- **Debian 13** (tested and supported)
- Bash 5.0+
- Root or sudo privileges
- Git (for version control)

> **Note**: This project has been tested only on Debian 13. Compatibility with other Debian versions or Ubuntu distributions is not guaranteed.

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/mishagin-dev/DebianForge.git
   cd DebianForge
   ```

2. **Make executable**:
   ```bash
   chmod +x main.sh
   ```

3. **Run the main script**:
   ```bash
   sudo ./main.sh
   ```

### Basic Usage

```bash
# Start the interactive interface
sudo ./main.sh

# Run specific operations with parameters
sudo ./main.sh security audit full markdown
sudo ./main.sh performance benchmark cpu html
sudo ./main.sh system update
sudo ./main.sh report generate security

# Show help for specific modules
./main.sh security help
./main.sh performance help
./main.sh system help
./main.sh report help
```

> **⚠️ Security Note**: Individual module scripts cannot be executed directly. All functionality must be accessed through `main.sh` for security reasons.

## 📋 Module Overview

### Performance Module
- **Benchmarks**: System performance testing
- **Kernel Tuning**: Optimize kernel parameters
- **Memory Management**: Swap and RAM optimization
- **Network Optimization**: TCP/IP tuning and BBR

### Security Module
- **Security Audit**: Comprehensive system security assessment
- **Firewall Management**: UFW configuration and management
- **SSH Hardening**: Secure SSH server configuration
- **Intrusion Detection**: Fail2ban and RKHunter setup
- **Log Analysis**: Security event monitoring

### System Module
- **Package Management**: System updates and dependency management
- **Timezone Configuration**: System time and locale setup
- **Base Dependencies**: Essential system packages installation

## 🔒 Security Features

- **Automated Security Hardening**: Pre-configured security settings
- **Vulnerability Assessment**: Regular security scanning
- **Compliance Reporting**: Security audit reports in multiple formats
- **Network Security**: Firewall and service monitoring
- **Access Control**: SSH and user management

## 📊 Reporting

Generate comprehensive reports in multiple formats through the centralized interface:

```bash
# Generate security audit reports
sudo ./main.sh report generate security full markdown
sudo ./main.sh report generate security quick html
sudo ./main.sh report generate security full json

# Generate performance benchmark reports
sudo ./main.sh report generate performance cpu markdown
sudo ./main.sh report generate performance full html

# Export existing reports
sudo ./main.sh report export security html
sudo ./main.sh report export performance csv

# List available reports
sudo ./main.sh report list
```

**Supported Formats**:
- **HTML**: Interactive web reports with styling
- **JSON**: API integration and data processing
- **CSV**: Data analysis and spreadsheet import
- **Markdown**: Documentation and version control
- **Console**: Terminal output and logging

## 🛠️ Development

### Project Structure
- **Modular Design**: Each module is self-contained
- **Configuration Management**: Centralized settings
- **Error Handling**: Comprehensive error management
- **Logging**: Detailed operation logging

### Contributing
1. Fork the repository
2. Create a feature branch
3. Follow the coding standards
4. Submit a pull request

### Coding Standards
- **Bash Scripting**: Follow shell scripting best practices
- **Error Handling**: Proper error checking and reporting
- **Documentation**: Comprehensive inline documentation
- **Testing**: Include tests for new features

## 📚 Documentation

- **User Guide**: `working/docs/user-guide.md`
- **Developer Guide**: `working/docs/developer-guide.md`
- **API Reference**: `working/docs/api-reference.md`
- **Configuration**: `working/docs/configuration.md`

## 🔧 Configuration

### Main Configuration
```bash
# Edit main configuration
nano resources/config/settings.conf

# Package configurations
nano resources/config/packages/*.conf

# System limits
nano resources/limits.d/*.conf
```

Git hooks automatically manage `.gitignore` switching and multi-remote pushes.

## 📈 Performance Impact

- **Minimal Overhead**: Lightweight operation
- **Efficient Algorithms**: Optimized for server environments
- **Resource Monitoring**: Real-time performance tracking
- **Benchmarking**: Performance measurement tools

## 🤝 Support

- **Issues**: [GitHub Issues](https://github.com/mishagin-dev/DebianForge/issues)
- **Discussions**: [GitHub Discussions](https://github.com/mishagin-dev/DebianForge/discussions)
- **Wiki**: [Project Wiki](https://github.com/mishagin-dev/DebianForge/wiki)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Debian Project for the excellent base system
- Open source community for tools and inspiration
- Contributors and users for feedback and improvements

---

**Made with ❤️ for the Debian community**

*For Russian documentation, see [README_ru.md](README_ru.md)*
