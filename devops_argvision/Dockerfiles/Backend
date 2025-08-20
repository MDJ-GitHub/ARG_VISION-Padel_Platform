FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1
	
WORKDIR /app

RUN apt-get update && apt-get install -y \
    libjpeg-dev \
    zlib1g-dev \
    libpq-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip && pip install \
    django \
    djangorestframework \
    djangorestframework-simplejwt \
    python-decouple \
    django-phonenumber-field \
    phonenumbers \
    Pillow \
    drf-spectacular \
    channels \
    channels-redis \
    daphne

COPY . .

EXPOSE 8000

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
