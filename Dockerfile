# Use the official Ubuntu 20.04 image as the base image
FROM ubuntu:20.04

# Update the package list and install necessary packages
RUN apt update -y && \
    apt install python3.12-venv -y && \
    python3 -m venv venv && \
    source venv/bin/activate && \
    apt install -y git python3.11 python3.11-distutils && \
    venv/bin/pip install --upgrade pip

# Set the working directory
WORKDIR /workspace

# Copy the current directory contents into the container at /workspace
COPY . /workspace

# Install Python dependencies
RUN source venv/bin/activate && \
    pip install -r requirements.txt

# Set the default command to run when the container starts
CMD ["bash"]
