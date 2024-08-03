FROM ubuntu:20.04

RUN apt update && \
    apt install -y software-properties-common curl git python3.11 python3.11-distutils && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt update && \
    apt install -y python3.11-venv

RUN curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py && \
    python3.11 /tmp/get-pip.py && \
    rm /tmp/get-pip.py

COPY . /opt/kubespray
WORKDIR /opt/kubespray

RUN pip3.11 install -r /opt/kubespray/requirements.txt

CMD ["bash"]
