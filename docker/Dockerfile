FROM python:3.8.6-slim-buster

RUN mkdir /app
RUN groupadd -r appuser && useradd -r -s /bin/false -g appuser appuser
WORKDIR /app

COPY . /app
RUN chown -R appuser:appuser /app

RUN addgroup appuser tty \
    && ln -sf /dev/stdout /var/log/app.log


ENV PATH="/app/.local/bin:$PATH"

RUN pip3 install -r requirements.txt

EXPOSE 5000

USER appuser

ENTRYPOINT ["gunicorn", "--config", "gunicorn_config.py", "app.wsgi:app"]