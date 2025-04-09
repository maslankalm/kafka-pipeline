# maslankalm/kafka-producer-consumer:1.0.1

FROM python:3.13-alpine
WORKDIR /app
COPY src/ /app/
RUN pip install --no-cache-dir -r requirements.txt
CMD ["sh"]
