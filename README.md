<h1 align="center">Лабораторная работа №3</h1>

<h2 align="center">Постановка задачи</h2>
В данной лабораторной работе нам необходимо написать организовать CI/CD пайплайн, который после пуша в репозиторий собирал docker-образ и сохранял вывод в Репозиторий/Сервер/Локальную машину. 

---

<h2 align="center">Выполнение работы</h2>
Будем собирать образ, который будет выполнять развертку простого flask приложения, которое выводит "Hello, world!".
Секреты были реализованы при помощи GitHub secrets, а реализация workflow представлена ниже:

```
name: CI

env:
  TEST_TAG: ${{ secrets.DOCKERHUB_LOGIN }}/flask-server:test
  LATEST_TAG: ${{ secrets.DOCKERHUB_LOGIN }}/flask-server:latest

on:
  push:
    branches: [ "main" ]

  workflow_dispatch:

jobs:
  python_test:
    runs-on: ubuntu-latest

    steps:
      - name: CheckOut
        uses: actions/checkout@v3
      - name: Set up python
        uses: actions/setup-python@v4
        with:
          python-version: 3.11
      - name: Install Dependencies
        run: |
          ls
          python -m pip install --upgrade pip
          pip install -r requirements.txt
      - name: Run Tests
        run: |
          cd app
          make test

  docker_test:
    runs-on: ubuntu-latest
    needs: [python_test]
    steps: 
      - name: CheckOut
        uses: actions/checkout@v3
      - name: TestBuild
        uses: docker/setup-buildx-action@v3
      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_LOGIN }}
          password: ${{ secrets.DOCKERHUB_PASSWORD }}
      - name: Build and export to Docker
        uses: docker/build-push-action@v5
        with:
          context: .
          load: true
          tags: ${{ env.TEST_TAG }}
      - name: Test
        run: |
          docker run -d --rm ${{ env.TEST_TAG }}           
      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ env.LATEST_TAG }} 
```


Разберем этот файл. Он состоит из двух jobs: "python_test" и "docker_test". 



В первом job "python_test" выполняются следующие шаги:

1. Checkout - получение репозитория с кодом.

 2. Set up python - установка версии Python.
      
      
 3. Install Dependencies - установка зависимостей, указанных в файле requirements.txt.

 4. Run Tests - запуск тестов, выполняется команда make test в папке "app".



Во втором job "docker_test" выполняются следующие шаги:

1. Checkout - получение репозитория с кодом.

 2. TestBuild - настройка Docker Buildx.
      
      
 3. Login to Docker Hub - авторизация в Docker Hub с использованием учетных данных из секретов.

 4. Build and export to Docker - сборка и экспорт Docker-образа с тегом из переменной окружения "TEST_TAG".
      
 5. Test - запуск Docker-контейнера на базе собранного образа.
  
 6. Build and push - сборка и публикация Docker-образа с тегом из переменной окружения "LATEST_TAG".

---

<h2 align="center">Проверка</h2>
Переходим в Actions и видим, что добавился новый workflow "CI". Запускаем его и видим следующее:

<p align="center">
  <img src="https://github.com/NikiforovSaveliy/DEV-OPS-ITMO-lab-3/blob/main/images/CI_procces.png"/>
</p>

Как и предпологалось все запустилось без ошибок. Проверяем, что образ создался и пушнулся в Docker Hub:

<p align="center">
  <img src="https://github.com/NikiforovSaveliy/DEV-OPS-ITMO-lab-3/blob/main/images/example.jpg"/>
</p>

Ура, все сработало!

---

<h2 align="center">Вывод</h2>

С помощью github actions мы смогли настроить автоматическую сборку и выгрузку docker образа на docker hub.
