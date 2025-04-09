from kafka import KafkaConsumer
from kafka.errors import NoBrokersAvailable


def check_connection(bootstrap_servers="localhost:9092"):
    try:
        consumer = KafkaConsumer(bootstrap_servers=bootstrap_servers)
        topics = consumer.topics()
        print(f"Connected to Kafka!")
        consumer.close()
    except NoBrokersAvailable:
        print("No Kafka brokers available.")

check_connection()
