import random, time, json, os
from kafka import KafkaConsumer, KafkaProducer
from kafka.admin import KafkaAdminClient, NewTopic
from kafka.errors import NoBrokersAvailable, TopicAlreadyExistsError

BROKER = os.getenv("KAFKA_BROKER", "localhost:9092")
TOPIC = os.getenv("KAFKA_TOPIC", "kafka-pipeline")
TXS = os.getenv("TXS", 50) # txs to generate


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


def create_topic(topic_name=TOPIC, bootstrap_servers=BROKER):
    try:
        admin_client = KafkaAdminClient(bootstrap_servers=bootstrap_servers)
        topic = NewTopic(
            name=topic_name,
            num_partitions=1,
            replication_factor=1
        )
        admin_client.create_topics(
            new_topics=[topic],
            validate_only=False
        )
        admin_client.close()
    except TopicAlreadyExistsError:
        print(f"Topic {topic_name} already exists.")


def send_to_kafka(message_content, topic_name=TOPIC, bootstrap_servers=BROKER):
    producer = KafkaProducer(bootstrap_servers=bootstrap_servers)
    producer.send(
        topic_name,
        value=json.dumps(message_content).encode('utf-8')
    )
    print(f"Message sent: {message_content}")
    producer.flush()
    producer.close()


def generate_dummy_eth_transaction():
    tx = {
        "wallet_id": "0x" + "".join(random.choices("0123456789abcdef", k=40)),
        "amount": random.uniform(1e-8, 10000),
        "timestamp": random.randint(1438269989, int(time.time()))
     }
    return tx


def run_producer():
    wait_for_kafka()
    create_topic()
    for _ in range(TXS):
        tx = generate_dummy_eth_transaction()
        send_to_kafka(tx)


run_producer()
