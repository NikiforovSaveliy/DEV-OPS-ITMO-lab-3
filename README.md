<h1 align="center">Лабораторная работа №3</h1>

<h2 align="center">Постановка задачи</h2>
В данной лабораторной работе нам необходимо написать организовать CI/CD пайплайн, который после пуша в репозиторий собирал docker-образ и сохранял вывод в Репозиторий/Сервер/Локальную машину. 

---

<h2 align="center">Выполнение работы</h2>
Будем собирать образ, который будет выполнять развертку простого flask приложения, которое выводит "Hello, world!".
Секреты были реализованы при помощи GitHub secrets.
Реализация workflow представлена ниже:

```
# This is a basic workflow to help you get started with Actions

name: CI

env:
  TEST_TAG: ${{ secrets.DOCKERHUB_LOGIN }}/flask-server:test
  LATEST_TAG: ${{ secrets.DOCKERHUB_LOGIN }}/flask-server:latest

# Controls when the workflow will run
on:
  # Triggers the workflow on push or pull request events but only for the "main" branch
  push:
    branches: [ "main" ]

  # Allows you to run this workflow manually from the Actions tab
  workflow_dispatch:

# A workflow run is made up of one or more jobs that can run sequentially or in parallel
jobs:
  # This workflow contains a single job called "build"
  python_test:
    # The type of runner that the job will run on
    runs-on: ubuntu-latest

    # Steps represent a sequence of tasks that will be executed as part of the job
    steps:
      # Checks-out your repository under $GITHUB_WORKSPACE, so your job can access it
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
  


---

<h2 align="center">Вывод</h2>
