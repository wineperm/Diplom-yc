FROM ubuntu:24.04

# Install dependencies
RUN apt-get update -y && \
    apt-get install -y python3.12-venv git && \
    apt-get clean

# Create a virtual environment
RUN python3 -m venv /venv

# Activate the virtual environment and install requirements
RUN /venv/bin/pip install --upgrade pip

# Set up the environment
ENV PATH="/venv/bin:$PATH"

# Clone Kubespray repository
RUN git clone https://github.com/kubernetes-sigs/kubespray.git /kubespray

# Install Kubespray requirements
RUN pip install -r /kubespray/requirements.txt

# Copy the sample inventory to mycluster
RUN cp -rfp /kubespray/inventory/sample /kubespray/inventory/mycluster

# Copy the private SSH key into the container
COPY ~/.ssh/id_ed25519 /root/.ssh/id_ed25519
RUN chmod 600 /root/.ssh/id_ed25519

# Generate the dynamic hosts.yaml file
COPY generate_hosts.py /kubespray/generate_hosts.py
RUN python3 /kubespray/generate_hosts.py

# Run the Ansible playbook
CMD ["ansible-playbook", "-i", "/kubespray/inventory/mycluster/hosts.yaml", "/kubespray/cluster.yml", "-b", "-v"]
