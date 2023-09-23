# Use slim python layer from docker hub
FROM python:3.11-slim-bookworm

# Select wordir
WORKDIR /app

# copy requirements
COPY ./requirements.txt requirements.txt

# install requirements
RUN pip install --no-cache-dir --upgrade -r requirements.txt

# copy whole project
COPY ./app/ .

# Run gunicorn server
CMD ["gunicorn", "--bind", "0.0.0.0:80", "server:app"]