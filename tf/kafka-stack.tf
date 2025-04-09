resource "kubernetes_config_map" "kafka_config" {
  metadata {
    name      = "kafka-config"
    namespace = data.kubernetes_namespace.default.metadata[0].name
  }

  data = {
    KAFKA_NODE_ID                                  = "1"
    KAFKA_PROCESS_ROLES                            = "broker,controller"
    KAFKA_LISTENERS                                = "PLAINTEXT://0.0.0.0:9092,CONTROLLER://localhost:9093"
    KAFKA_ADVERTISED_LISTENERS                     = "PLAINTEXT://broker:9092"
    KAFKA_CONTROLLER_LISTENER_NAMES                = "CONTROLLER"
    KAFKA_LISTENER_SECURITY_PROTOCOL_MAP           = "CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT"
    KAFKA_CONTROLLER_QUORUM_VOTERS                 = "1@localhost:9093"
    KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR         = "1"
    KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR = "1"
    KAFKA_TRANSACTION_STATE_LOG_MIN_ISR            = "1"
    KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS         = "0"
    KAFKA_NUM_PARTITIONS                           = "3"
  }
}

resource "kubernetes_deployment" "broker" {
  metadata {
    name      = "kafka-broker"
    namespace = data.kubernetes_namespace.default.metadata[0].name
    labels = {
      app = "kafka-broker"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "kafka-broker"
      }
    }
    template {
      metadata {
        labels = {
          app = "kafka-broker"
        }
      }
      spec {
        container {
          name  = "broker"
          image = "apache/kafka:latest"
          port {
            container_port = 9092
          }
          env_from {
            config_map_ref {
              name = kubernetes_config_map.kafka_config.metadata[0].name
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "broker_service" {
  metadata {
    name      = "broker"
    namespace = data.kubernetes_namespace.default.metadata[0].name
  }
  spec {
    selector = {
      app = "kafka-broker"
    }
    port {
      port        = 9092
      target_port = 9092
    }
  }
}
