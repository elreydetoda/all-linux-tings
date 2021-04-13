FROM elrey741/python3-pipenv:latest
LABEL maintainer="Alex (elrey741) <dockerfile-social-contact@elrey741.33mail.com>"

COPY ./app /app
WORKDIR /app
RUN pipenv install --deploy --system
USER nobody
ENTRYPOINT [ "uvicorn", "main:app", "--host", "0.0.0.0" ]
