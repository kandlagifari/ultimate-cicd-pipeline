## Installing Jenkins on Ubuntu


```bash
#!/bin/bash

# Install OpenJDK 17 JRE Headless
sudo apt install openjdk-17-jre-headless -y

# Download Jenkins GPG key
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

# Add Jenkins repository to package manager sources
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update package manager repositories
sudo apt-get update

# Install Jenkins
sudo apt-get install jenkins -y
```

Save this script in a file, for example, `install_jenkins.sh`, and make it executable using:

```bash
chmod +x install_jenkins.sh
```

Then, you can run the script using:

```bash
./install_jenkins.sh
```

This script will automate the installation process of OpenJDK 17 JRE Headless and Jenkins.


## Install docker for future use

```bash
#!/bin/bash

# Update package manager repositories
sudo apt-get update

# Install necessary dependencies
sudo apt-get install -y ca-certificates curl

# Create directory for Docker GPG key
sudo install -m 0755 -d /etc/apt/keyrings

# Download Docker's GPG key
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc

# Ensure proper permissions for the key
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository to Apt sources
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package manager repositories
sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 
```

Save this script in a file, for example, `install_docker.sh`, and make it executable using:

```bash
chmod +x install_docker.sh
```

Then, you can run the script using:

```bash
./install_docker.sh
```

Give current user permission to use docker

```bash
sudo usermod -aG docker $USER  # Replace with your system's username, e.g., 'ssm-user'
newgrp docker
```


## Installing Trivy on Ubuntu

```bash
#!/bin/bash
sudo apt-get install wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy
```

Save this script in a file, for example, `install_trivy.sh`, and make it executable using:

```bash
chmod +x install_trivy.sh
```

Then, you can run the script using:

```bash
./install_trivy.sh
```


## Setup SonarQube Server for SonarQube Analysis Stage on Jenkins
Need to Install Trivy --> run `install_trivy.sh` script


## Setup SonarQube Server for SonarQube Analysis Stage on Jenkins
1. Go to Manage Jenkins
2. On the `SonarQube server`, we need to Add SonarQube

Name: sonar \
Server URL: http://<SonarQube-Public-IP>:9000 \
Server authentication token: Create and use SonarQube token credential called `sonar-token`


## Setup SonarQube Server for Quality Gate Stage on Jenkins
1. On the SonarQube, go to Administration
2. Go to Configuration, click on Webhooks
3. Create Webhook

Name: jenkins \
URL: http://<Jenkins-Public-IP>:8080/sonarqube-webhook/ \
Secret: <null>


## Setup SonarQube Server for Publish To Nexus Stage on Jenkins
1. Edit pom.xml on the `board-game` github repository

```bash
	<distributionManagement>
    <repository>
      <id>maven-releases</id>
      <url>http://<Nexus-Public-IP>:8081/repository/maven-releases/</url>
    </repository>
    <snapshotRepository>
      <id>maven-snapshots</id>
      <url>http://<Nexus-Public-IP>:8081/repository/maven-snapshots/</url>
    </snapshotRepository>
  </distributionManagement>
```

2. Create Nexus Credential on Jenkins \
2a) Go to Manage Jenkins \
2b) Go to Managed files (This will be available after installing `Config File Provider` Jenkins plugins) \
2c) Add a new Config \
2d) Check on Global Maven settings.xml \
2e) ID: global-settings \
2f) Change this
    ```bash
    <server>
      <id>deploymentRepo</id>
      <username>repouser</username>
      <password>repopwd</password>
    </server>
    ```
    
    Into this
    ```bash
    <server>
      <id>maven-releases</id>
      <username>admin</username>
      <password>nexuspass</password>
    </server>

    <server>
      <id>maven-snapshots</id>
      <username>admin</username>
      <password>nexuspass</password>
    </server>
    ```
2g) Generate script --> withMaven: Provide Maven environment \
    Maven: maven3 \
    JDK: jdk17 \
    Global Maven Settings Config: MyGlobalSettings


## Setup SonarQube Server for Docker Stage on Jenkins
1. Use `withDockerRegistry: Sets up Docker registry endpoint`
Docker registry URL: <null> --> need to input, if using private registry \
Registry credentials: Create username and password \
Docker installation: docker --> based on tool name

