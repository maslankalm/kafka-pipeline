# Real-Time Transaction Tagging Pipeline

## How to Start the Pipeline

You can start the pipeline using one of the following methods:

- **Docker Compose**
  ```bash
  docker-compose up
  ```

- **Kubernetes (kubectl)**
  ```bash
  kubectl apply -f .  # inside the `k8s` directory
  ```

- **Terraform**
  ```bash
  terraform apply  # inside the `tf` directory
  ```

---

## Notes

- **Startup Wait Logic**:  
  Both the Producer and Consumer apps include simple checks to wait for the Kafka broker if it's not available yet.

- **Producer Behavior**:  
  - Creates an initial batch of `TXS` dummy transactions.
  - Then generates 1 transaction every `INTERVAL` seconds.


- **Message Processing Placeholder**:  
  When a transaction is processed:
  - A field `value_tag` is added:  
    - `"HIGH"` if the transaction `amount > 1000`,  
    - `"LOW"` otherwise.
  - `date` and `time` fields are extracted from the UNIX `timestamp`.

- **Deployment Interoperability**:  
  The stacks are interchangeable. For example:
  - You can deploy the Kafka broker with Kubernetes and the Producer with Terraform.
  - Or the other way around.

- **Unified Image**:  
  Both Producer and Consumer use the same Docker image for simplicity.  
  Their behavior is controlled via overridden commands per container.

- **Prebuilt Images**:  
  Kubernetes and Terraform configurations use a pre-built public Docker image, allowing you to deploy to Kubernetes without building anything locally.

  **Image**: [`maslankalm/kafka-producer-consumer:1.0.1`](https://hub.docker.com/r/maslankalm/kafka-producer-consumer)  
  **Architectures Supported**: `amd64` and `arm64` (multi-platform image)

- **Data Storage**:  
  The consumer saves transactions in `/app/txs.csv` inside its container.

---

## Configuration Variables

| Variable        | Description                              | Used By    | Example             |
|-----------------|------------------------------------------|------------|---------------------|
| `KAFKA_BROKER`  | Kafka broker address                     | All        | `broker:9092`       |
| `KAFKA_TOPIC`   | Kafka topic name                         | All        | `kafka-pipeline`    |
| `TXS`           | Initial batch size of transactions       | Producer   | `100`               |
| `INTERVAL`      | Interval between transaction generations | Producer   | `10` (seconds)      |

---
