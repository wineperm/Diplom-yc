FROM ubuntu:20.04

# Обновляем пакеты и устанавливаем необходимые зависимости
RUN apt-get update -y && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update -y && \
    apt-get install -y git python3.11 python3.11-venv curl && \
    curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py && \
    python3.11 /tmp/get-pip.py && \
    rm /tmp/get-pip.py

# Копируем файлы из репозитория в контейнер
COPY . /opt/kubespray
WORKDIR /opt/kubespray

# Устанавливаем зависимости из requirements.txt
RUN pip3.11 install -r /opt/kubespray/requirements.txt

# Устанавливаем команду по умолчанию
CMD ["bash"]
