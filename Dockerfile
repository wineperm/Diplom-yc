# Use the official Ubuntu 20.04 image as the base image
FROM ubuntu:20.04

# Update the package list and install necessary packages
RUN apt-get update && \
    apt-get install -y git python3 python3-pip && \
    pip3 install jmespath==1.0.1 jsonschema==4.23.0 netaddr==1.3.0 ruamel.yaml && \
    apt-get install -y software-properties-common && \
    add-apt-repository --yes --update ppa:ansible/ansible && \
    apt-get install -y ansible

# Set the working directory
WORKDIR /workspace

# Copy the current directory contents into the container at /workspace
COPY . /workspace

# Set the default command to run when the container starts
CMD ["bash"]
