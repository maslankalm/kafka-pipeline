resource "kubernetes_config_map" "producer_consumer_config" {
  metadata {
    name      = "producer-consumer-config"
    namespace = data.kubernetes_namespace.default.metadata[0].name
  }

  data = {
    KAFKA_NODE_ID = "1"
    KAFKA_BROKER  = "broker:9092"
    KAFKA_TOPIC   = "kafka-pipeline"
    TXS           = "100"
    INTERVAL      = "10"
  }
}

resource "kubernetes_deployment" "producer" {
  metadata {
    name      = "kafka-producer"
    namespace = data.kubernetes_namespace.default.metadata[0].name
    labels = {
      app = "kafka-producer"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "kafka-producer"
      }
    }
    template {
      metadata {
        labels = {
          app = "kafka-producer"
        }
      }
      spec {
        container {
          name  = "producer"
          image = "maslankalm/kafka-producer-consumer:1.0.1"
          command = [
            "python",
            "/app/producer.py"
          ]
          env_from {
            config_map_ref {
              name = kubernetes_config_map.producer_consumer_config.metadata[0].name
            }
          }
          env {
            name  = "PYTHONUNBUFFERED"
            value = "1"
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "consumer" {
  metadata {
    name      = "kafka-consumer"
    namespace = data.kubernetes_namespace.default.metadata[0].name
    labels = {
      app = "kafka-consumer"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "kafka-consumer"
      }
    }
    template {
      metadata {
        labels = {
          app = "kafka-consumer"
        }
      }
      spec {
        container {
          name  = "consumer"
          image = "maslankalm/kafka-producer-consumer:1.0.1"
          command = [
            "python",
            "/app/consumer.py"
          ]
          env_from {
            config_map_ref {
              name = kubernetes_config_map.producer_consumer_config.metadata[0].name
            }
          }
          env {
            name  = "PYTHONUNBUFFERED"
            value = "1"
          }
        }
      }
    }
  }
}
