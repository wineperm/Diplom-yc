FROM ubuntu:16.04

MAINTAINER Ernestas Poskus <hierco@gmail.com>

# Install dependencies.
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
    python-software-properties \
    software-properties-common \
    rsyslog systemd systemd-cron sudo \
    iproute curl

# Install Python 3.6
RUN apt-get install -y python3.6 python3.6-dev python3.6-venv
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 1
RUN update-alternatives --install /usr/bin/pip3 pip3 /usr/bin/pip3.6 1

# Upgrade pip
RUN pip3 install --upgrade pip

# Install Ansible version 2.17.0
RUN pip3 install ansible==2.17.0 \
    && rm -Rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man

RUN apt-get clean
RUN sed -i 's/^\($ModLoad imklog\)/#\1/' /etc/rsyslog.conf

# Install/prepare Ansible
RUN mkdir -p /etc/ansible/roles
RUN mkdir -p /opt/ansible/roles
RUN rm -f /opt/ansible/hosts
RUN printf '[local]\nlocalhost ansible_connection=local\n' > /etc/ansible/hosts
