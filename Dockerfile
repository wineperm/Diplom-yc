# Используем официальный образ Ubuntu 24.04 в качестве базового образа
FROM ubuntu:24.04

# Обновляем список пакетов и устанавливаем необходимые пакеты
RUN apt update -y && \
    apt install -y python3.12 python3.12-venv bash && \
    ln -s /usr/bin/python3.12 /usr/bin/python3

# Устанавливаем рабочую директорию
WORKDIR /workspace

# Копируем содержимое текущей директории в контейнер в /workspace
COPY . /workspace

# Создаем виртуальное окружение Python
RUN python3 -m venv venv

# Устанавливаем Python зависимости
RUN /bin/bash -c "source venv/bin/activate && pip install -r requirements.txt"

# Устанавливаем команду по умолчанию для запуска контейнера
CMD ["bash"]
