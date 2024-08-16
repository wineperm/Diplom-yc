# Дипломный практикум в Yandex.Cloud

- [Цели:](#цели)
- [Этапы выполнения:](#этапы-выполнения)
  - [Создание облачной инфраструктуры](#создание-облачной-инфраструктуры)
  - [Создание Kubernetes кластера](#создание-kubernetes-кластера)
  - [Создание тестового приложения](#создание-тестового-приложения)
  - [Подготовка cистемы мониторинга и деплой приложения](#подготовка-cистемы-мониторинга-и-деплой-приложения)
  - [Установка и настройка CI/CD](#установка-и-настройка-cicd)
- [Что необходимо для сдачи задания?](#что-необходимо-для-сдачи-задания)
- [Как правильно задавать вопросы дипломному руководителю?](#как-правильно-задавать-вопросы-дипломному-руководителю)

**Перед началом работы над дипломным заданием изучите [Инструкция по экономии облачных ресурсов](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD).**

---

## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

---

## Этапы выполнения:

### Создание облачной инфраструктуры

Для начала необходимо подготовить облачную инфраструктуру в ЯО при помощи [Terraform](https://www.terraform.io/).

Особенности выполнения:

- Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
  Для облачного k8s используйте региональный мастер(неотказоустойчивый). Для self-hosted k8s минимизируйте ресурсы ВМ и долю ЦПУ. В обоих вариантах используйте прерываемые ВМ для worker nodes.

Предварительная подготовка к установке и запуску Kubernetes кластера.

1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
2. Подготовьте [backend](https://www.terraform.io/docs/language/settings/backends/index.html) для Terraform:  
   а. Рекомендуемый вариант: S3 bucket в созданном ЯО аккаунте(создание бакета через TF)
   б. Альтернативный вариант: [Terraform Cloud](https://app.terraform.io/)
3. Создайте VPC с подсетями в разных зонах доступности.
4. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
5. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://www.terraform.io/docs/language/settings/backends/index.html) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

Ожидаемые результаты:

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий.
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

---

Общая концепция работы кода:

При нажатии кнопки "run workflow" для [Terraform Apply.yml](https://github.com/wineperm/Diplom-yc/blob/main/.github/workflows/Terraform%20Apply.yml) или при коммите в GitHub Actions со словом "apply" на основе Terraform происходит создание инфраструктуры с заданным количеством и характеристиками виртуальных машин k8s-master-_ и k8s-worker-_. Машины распределяются по разным зонам доступности в зависимости от их количества. Далее на основе отдельной виртуальной машины Runner происходит установка и настройка кластера Kubernetes на основе пакета kubespray, установка пакета kube-prometheus и установка приложения со статической картинкой. Настройки можно менять в файле конфигурации приложения APP. После этого Runner выключается.

При внесении изменений в приложении APP и коммите происходит сборка нового Docker-образа с последующим сохранением в репозитории DockerHub с фиксацией в теге хеш коммита. [Build and Push Docker Image.yaml](https://github.com/wineperm/Diplom-yc/blob/main/.github/workflows/Build%20and%20Push%20Docker%20Image.yaml)

При внесении изменений в приложении APP и коммите с тегом вида v1.0.0 происходит сборка нового Docker-образа с последующим сохранением в репозитории DockerHub с фиксацией в теге версии и установка с помощью создаваемой виртуальной машины Runner этой версии приложения в ранее созданный кластер Kubernetes. После этого Runner выключается. [Build, Push, and Deploy Docker Image.yaml](https://github.com/wineperm/Diplom-yc/blob/main/.github/workflows/Build%2C%20Push%2C%20and%20Deploy%20Docker%20Image.yaml)

При нажатии кнопки "run workflow" для [Terraform Destroy.yml](https://github.com/wineperm/Diplom-yc/blob/main/.github/workflows/Terraform%20Destroy.yml) или при коммите со словом "destroy" происходит полное удаление всех ресурсов, созданных ранее на Yandex Cloud в рамках этого проекта.

- [Terraform Apply.yml](https://github.com/wineperm/Diplom-yc/blob/main/.github/workflows/Terraform%20Apply.yml)
- [Build and Push Docker Image.yaml](https://github.com/wineperm/Diplom-yc/blob/main/.github/workflows/Build%20and%20Push%20Docker%20Image.yaml)
- [Build, Push, and Deploy Docker Image.yaml](https://github.com/wineperm/Diplom-yc/blob/main/.github/workflows/Build%2C%20Push%2C%20and%20Deploy%20Docker%20Image.yaml)
- [Terraform Destroy.yml](https://github.com/wineperm/Diplom-yc/blob/main/.github/workflows/Terraform%20Destroy.yml)

---

## Ответ

Инфраструктура создана с помощью Terraform, backend сделан в Terraform Cloud. Оркестрацию поднятия инфраструктуры с кнопки осуществляет GitHub Actions или при отправке коммита "apply", используя workflows. Машины распределяются в зависимости от заданного количества по разным зонам доступности.

- [main.tf](https://github.com/wineperm/Diplom-yc/blob/main/main.tf)
- [runner.tf](https://github.com/wineperm/Diplom-yc/blob/main/runner.tf)
- [vpc.tf](https://github.com/wineperm/Diplom-yc/blob/main/vpc.tf)
- [providers.tf](https://github.com/wineperm/Diplom-yc/blob/main/providers.tf)
- [variables.tf](https://github.com/wineperm/Diplom-yc/blob/main/variables.tf)
- [outputs.tf](https://github.com/wineperm/Diplom-yc/blob/main/outputs.tf)
- [backend.tf](https://github.com/wineperm/Diplom-yc/blob/main/backend.tf)

![Alt text](https://github.com/user-attachments/assets/db759888-bcb3-4171-9b16-e9abe82fea37)
![Alt text](https://github.com/user-attachments/assets/33a7de73-7fa2-4984-9a1f-640b273d2e89)
![Alt text](https://github.com/user-attachments/assets/22e07020-1149-4552-9286-b6701748599a)

---

### Создание Kubernetes кластера

На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфраструктуры. Требуется обеспечить доступ к ресурсам из Интернета.

Это можно сделать двумя способами:

1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.  
   а. При помощи Terraform подготовить как минимум 3 виртуальных машины Compute Cloud для создания Kubernetes-кластера. Тип виртуальной машины следует выбрать самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.  
   б. Подготовить [ansible](https://www.ansible.com/) конфигурации, можно воспользоваться, например [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)  
   в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.
2. Альтернативный вариант: воспользуйтесь сервисом [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)  
   а. С помощью terraform resource для [kubernetes](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) создать **региональный** мастер kubernetes с размещением нод в разных 3 подсетях  
   б. С помощью terraform resource для [kubernetes node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)

Ожидаемый результат:

1. Работоспособный Kubernetes кластер.
2. В файле `~/.kube/config` находятся данные для доступа к кластеру.
3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.

## Ответ

Выбран способ установки кластера K8s с помощью Kubespray. Генерируется динамический hosts.yaml файл с помощью шаблона и скрипта. Количество машин и их конфигурацию можно выбрать в файлах настройки Terraform [main.tf](https://github.com/wineperm/Diplom-yc/blob/main/main.tf). Для установки в кластер Kubespray используется отдельная машина [runner.tf](https://github.com/wineperm/Diplom-yc/blob/main/runner.tf), которая после выполнения поставленных задач выключается. 

- [Kubespray](https://github.com/wineperm/kubespray)
- [generate_hosts.py](https://github.com/wineperm/Diplom-yc/blob/main/generate_hosts.py)

![Alt text](https://github.com/user-attachments/assets/9822da65-f02a-40eb-b777-5890aa21b91d)

![Alt text](https://github.com/user-attachments/assets/35eb69ea-2dc1-4780-9799-4b3f2c3d77a0)

---

### Создание тестового приложения

Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.

Способ подготовки:

1. Рекомендуемый вариант:  
   а. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.  
   б. Подготовьте Dockerfile для создания образа приложения.
2. Альтернативный вариант:  
   а. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.

Ожидаемый результат:

1. Git репозиторий с тестовым приложением и Dockerfile.
2. Регистри с собранным docker image. В качестве регистри может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform.

## Ответ

- [APP](https://github.com/wineperm/Diplom-yc/tree/main/APP) приложение с картинкой.

- APP
  - html
    - [KLS_netology_12.07.2004.jpeg](https://github.com/wineperm/Diplom-yc/blob/main/APP/html/KLS_netology_12.07.2004.jpeg)
    - [index.html](https://github.com/wineperm/Diplom-yc/blob/main/APP/html/index.html)
  - [Dockerfile](https://github.com/wineperm/Diplom-yc/blob/main/APP/Dockerfile)
  - README.md
  - app.yaml
  - [nginx.conf](https://github.com/wineperm/Diplom-yc/blob/main/APP/nginx.conf)

- [DockerHub](https://hub.docker.com/repository/docker/wineperm/my-nginx-app/general) репозиторий DockerHub с приложением.

![Alt text](https://github.com/user-attachments/assets/ecb6ed66-1317-453c-946e-b9466edc0564)

---

### Подготовка cистемы мониторинга и деплой приложения

Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.  
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.

Цель:

1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортер](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
2. Задеплоить тестовое приложение, например, [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.

Способ выполнения:

1. Воспользоваться пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), который уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter). Альтернативный вариант - использовать набор helm чартов от [bitnami](https://github.com/bitnami/charts/tree/main/bitnami).

2. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте и настройте в кластере [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры. Альтернативный вариант 3 задания: вместо Terraform Cloud или atlantis настройте на автоматический запуск и применение конфигурации terraform из вашего git-репозитория в выбранной вами CI-CD системе при любом комите в main ветку. Предоставьте скриншоты работы пайплайна из CI/CD системы.

Ожидаемый результат:

1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.
2. Http доступ к web интерфейсу grafana.
3. Дашборды в grafana отображающие состояние Kubernetes кластера.
4. Http доступ к тестовому приложению.

---

## Ответ

Установка мониторинга в кластер выбрана пакетом [kube-prometheus](https://github.com/wineperm/kube-prometheus). Пакет устанавливается в кластер с помощью GitHub Actions, используя workflows при создании и настройке инфраструктуры в облаке Yandex Cloud. Также происходит установка приложения с помощью GitHub Actions, используя workflows; образ берется с [DockerHub](https://hub.docker.com/repository/docker/wineperm/my-nginx-app/general). Доступ по http для сервиса Grafana и приложения есть.

- [kube-prometheus](https://github.com/wineperm/kube-prometheus)
 
![Alt text](https://github.com/user-attachments/assets/678e80f0-3ac1-4484-9f3c-c8ede68b8d43)
![Alt text](https://github.com/user-attachments/assets/4962a9e4-09e5-46b2-98c9-a0a8ba1842b5)


### Установка и настройка CI/CD

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:

1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
2. Автоматический деплой нового docker образа.

Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/), [GitLab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/) или GitHub Actions.

Ожидаемый результат:

1. Интерфейс ci/cd сервиса доступен по http.
2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.
3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистри, а также деплой соответствующего Docker образа в кластер Kubernetes.

## Ответ

При любом изменении в директории приложения [APP](https://github.com/wineperm/Diplom-yc/tree/main/APP) и коммите происходит сборка нового образа с фиксацией в теге хеша коммита и отправка его в репозиторий [Dockerhub](https://hub.docker.com/repository/docker/wineperm/my-nginx-app/general). При любом изменении в директории приложения [APP](https://github.com/wineperm/Diplom-yc/tree/main/APP) и коммите с тегом вида v1.0.0 происходит сборка с фиксацией тега, отправка в репозиторий [Dockerhub](https://hub.docker.com/repository/docker/wineperm/my-nginx-app/general) и установка новой версии в кластер k8s.

- [Build and Push Docker Image.yaml](https://github.com/wineperm/Diplom-yc/blob/main/.github/workflows/Build%20and%20Push%20Docker%20Image.yaml)
- [Build, Push, and Deploy Docker Image.yaml](https://github.com/wineperm/Diplom-yc/blob/main/.github/workflows/Build%2C%20Push%2C%20and%20Deploy%20Docker%20Image.yaml)

![Alt text](https://github.com/user-attachments/assets/afde4683-262e-46d7-ad34-778a63264192)
![Alt text](https://github.com/user-attachments/assets/a65b3546-60c1-4dc6-a637-f903ae635446)
![Alt text](https://github.com/user-attachments/assets/7d6bd1b0-88e1-4b39-949d-417c2d754fa0)

Тут должно быть подтверждение в виде скриншотов, что работает сборка по тегу вида v1.0.0, но закончились минуты на github, карты не принимает, локальный раннер не качает пакеты без vpn, санкции, а с ним не соединяется с удаленными хостами. Обнуление минут в сентябре.

было до тега
![Alt text]z5-3
стало после тега
![Alt text]z5-4

---

## Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.
2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud или вашего CI-CD-terraform pipeline.
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.
5. Репозиторий с конфигурацией Kubernetes кластера.
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.
7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)

## Итог проделанной работы:

Общая работа данного кода заключается в автоматизации процесса развертывания инфраструктуры и приложений с использованием Terraform и GitHub Actions. Код включает несколько рабочих процессов (workflows), которые выполняют различные задачи, такие как применение Terraform-конфигураций, сборка и развертывание Docker-образов, а также управление Kubernetes-кластером.

### Основные компоненты и их функции:

1. **Terraform Apply Workflow**:

   - **Триггеры**: Запускается при нажатии кнопки (workflow_dispatch) или при пуше в ветку `main`.
   - **Условия**: Выполняется только если сообщение коммита содержит слово `apply`.
   - **Шаги**:
     - Проверка кода.
     - Установка Terraform.
     - Настройка SSH-ключей.
     - Настройка Terraform CLI.
     - Инициализация Terraform.
     - Применение Terraform-конфигурации.
     - Генерация выходных данных Terraform.
     - Ожидание доступности SSH на мастер-узлах и runner-узле.
     - Копирование SSH-ключей и файлов на runner-узел.
     - Выполнение задач на runner-узле (например, установка Kubespray и развертывание Kubernetes-кластера).
     - Выполнение команд на мастер-узле (например, настройка kubeconfig).
     - Клонирование и применение Kube-Prometheus манифестов на мастер-узле.
     - Копирование и развертывание Docker-образа на мастер-узле.
     - Удаление runner-узла после успешного выполнения.
     - Удаление всей инфраструктуры в случае ошибки.

2. **Terraform Destroy Workflow**:

   - **Триггеры**: Запускается при нажатии кнопки (workflow_dispatch) или при пуше в ветку `main`.
   - **Условия**: Выполняется только если сообщение коммита содержит слово `destroy`.
   - **Шаги**:
     - Проверка кода.
     - Установка Terraform.
     - Настройка SSH-ключей.
     - Настройка Terraform CLI.
     - Инициализация Terraform.
     - Удаление Terraform-инфраструктуры.

3. **Build and Push Docker Image Workflow**:

   - **Триггеры**: Запускается при нажатии кнопки (workflow_dispatch) или при пуше в любую ветку (кроме создания тега).
   - **Шаги**:
     - Проверка кода.
     - Установка Docker Buildx.
     - Вход в Docker Hub.
     - Сборка и пуш Docker-образа с тегом, соответствующим хешу коммита.

4. **Build, Push, and Deploy Docker Image Workflow**:
   - **Триггеры**: Запускается при нажатии кнопки (workflow_dispatch) или при создании тега.
   - **Шаги**:
     - Проверка кода.
     - Установка Docker Buildx.
     - Вход в Docker Hub.
     - Сборка и пуш Docker-образа с тегом, соответствующим версии тега.
     - Сборка и пуш Docker-образа с тегом `latest`.
     - Установка kubectl.
     - Применение Terraform-конфигурации для создания runner-узла.
     - Генерация выходных данных Terraform.
     - Ожидание доступности SSH на мастер-узле.
     - Копирование SSH-ключей и файлов на runner-узел.
     - Копирование и развертывание Docker-образа на мастер-узле.
     - Удаление runner-узла после успешного выполнения.
     - Удаление runner-узла в случае ошибки.

### Terraform Configuration:

- **Провайдеры**: Используются провайдеры Yandex Cloud, local и null.
- **Ресурсы**:
  - Создание VPC и подсетей.
  - Создание мастер-узлов и воркер-узлов для Kubernetes-кластера.
  - Создание runner-узла для выполнения задач.
- **Переменные**:
  - Идентификаторы облака и папки Yandex Cloud.
  - SSH-ключи для доступа к инстансам.
  - Пути к файлам ключей.
- **Выходные данные**:
  - IP-адреса мастер-узлов, воркер-узлов и runner-узла.

### Dockerfile и Kubernetes Manifests:

- **Dockerfile**: Создает Docker-образ на основе официального образа Nginx, копирует конфигурационный файл и статические файлы, открывает порт 80 и запускает Nginx.
- **Kubernetes Manifests**:
  - Создание Namespace для приложения.
  - Создание Deployment для развертывания приложения с репликами.
  - Создание Service типа NodePort для доступа к приложению.

### HTML-файл:

- Содержит HTML-код для отображения страницы с текстом и изображением.

### Общая концепция:

- **Автоматизация**: Все процессы автоматизированы с использованием GitHub Actions.
- **Инфраструктура как код (IaC)**: Terraform используется для управления инфраструктурой.
- **Контейнеризация**: Docker используется для создания и развертывания приложений.
- **Оркестрация**: Kubernetes используется для управления контейнерами и их распределением по узлам.

Этот код обеспечивает полный цикл разработки и развертывания приложений, начиная от создания инфраструктуры и заканчивая развертыванием приложений в Kubernetes-кластере.
