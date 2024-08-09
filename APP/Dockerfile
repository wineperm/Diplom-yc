# Используем официальный образ Nginx
FROM nginx:latest

# Копируем конфигурационный файл Nginx и статические файлы в один слой
COPY nginx.conf /etc/nginx/nginx.conf
COPY html /usr/share/nginx/html

# Открываем порт 80
EXPOSE 80

# Запускаем Nginx
CMD ["nginx", "-g", "daemon off;"]
