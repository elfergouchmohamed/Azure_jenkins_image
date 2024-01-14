#!! For Build the image USE : "docker build -t my-jenkins-image ."!!
#!! For Run the container USE : "docker run -d -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home --name my-container-name my-jenkins-image"!!

# Define the base image
FROM jenkins/jenkins:2.426.2-jdk17

# Set the user label
LABEL authors="Mohamed"

# Change the default user in the image to root
USER root

# Expose port 8080 for the web UI and 50000 for the build agent
EXPOSE 8080

EXPOSE 50000

# Set volume for Jenkins home directory
VOLUME /var/jenkins_home

# Update the package list and install the "lsb-release" package
RUN apt-get update && \
    apt-get install -y lsb-release

# Add the Docker GPG key, configure the Docker repository, and install the Docker client
RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
  https://download.docker.com/linux/debian/gpg

RUN echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

RUN apt-get update && apt-get install -y docker-ce-cli

# Download and run the Azure CLI installation script
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash 

# Install dependencies for Azure CLI package installation
RUN apt-get update && \
    apt-get install ca-certificates curl apt-transport-https lsb-release gnupg

# Download and install the Microsoft signing key
RUN mkdir -p /etc/apt/keyrings && \
    curl -sLS https://packages.microsoft.com/keys/microsoft.asc | \
    gpg --dearmor | \
    tee /etc/apt/keyrings/microsoft.gpg > /dev/null && \
    chmod go+r /etc/apt/keyrings/microsoft.gpg

# Add the Azure CLI software repository
RUN AZ_DIST=$(lsb_release -cs) && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $AZ_DIST main" \
    | tee /etc/apt/sources.list.d/azure-cli.list

# Update the repository information and install the azure-cli package
RUN apt-get update && \
    apt-get install wget && \
    apt-get install -y azure-cli

# Download and install the HashiCorp signing key
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg    

# Add the HashiCorp software repository
RUN echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list

# Update the repository information and install the terraform package
RUN apt update && \
    apt install terraform

# Switch back to the Jenkins user
USER jenkins
