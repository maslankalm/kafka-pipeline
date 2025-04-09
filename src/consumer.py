import os, json, csv, time
from datetime import datetime, timezone
from kafka import KafkaConsumer
from kafka.errors import NoBrokersAvailable

BROKER = os.getenv("KAFKA_BROKER", "localhost:9092")
TOPIC = os.getenv("KAFKA_TOPIC", "kafka-pipeline")


def wait_for_kafka(bootstrap_servers=BROKER):
    while True:
        try:
            consumer = KafkaConsumer(bootstrap_servers=bootstrap_servers)
            consumer.topics()
            print(f"Connected to Kafka!")
            consumer.close()
            break
        except NoBrokersAvailable:
            print("No Kafka brokers available, retry in 10s.")
            time.sleep(10)


def get_from_kafka(topic_name=TOPIC, bootstrap_servers=BROKER):
    consumer = KafkaConsumer(
        topic_name,
        bootstrap_servers=bootstrap_servers,
        auto_offset_reset="earliest",
        enable_auto_commit=True
    )
    for message in consumer:
        message_content = json.loads(message.value.decode("utf-8"))
        processed_message = processing(message_content)
        store_in_csv(processed_message)
        print(f"New message: {processed_message}")


def processing(message_content, threshold=1000):
    message_content["value_tag"] = "HIGH" if message_content["amount"] > threshold else "LOW"
    date_time = datetime.fromtimestamp(message_content["timestamp"], tz=timezone.utc)
    message_content["date"], message_content["time"]= date_time.strftime('%Y-%m-%d %H:%M:%S').split(" ")
    return message_content


def store_in_csv(processed_message, csv_file="txs.csv"):
    file_exists = os.path.isfile(csv_file)

    with open(csv_file, mode="a", newline="") as file:
        fieldnames = ["wallet_id", "amount", "timestamp", "value_tag", "date", "time"]
        writer = csv.DictWriter(file, fieldnames=fieldnames)
        if not file_exists:
            writer.writeheader()
        writer.writerow(processed_message)


def run_consumer():
    wait_for_kafka()
    get_from_kafka()


run_consumer()
