project = "todo-test"

app "todo-test" {

  config {
    internal = {
      team-name = "panther"
      app-name = "todo-test"
    }

    env = {
      "PGHOST" = "${config.internal.app-name}-postgresql.${config.internal.team-name}.svc.cluster.local"
      DATABASE_PASSWORD = dynamic("kubernetes", {
        namespace = "${config.internal.team-name}"
        name = "${config.internal.app-name}-postgresql.${config.internal.team-name}.credentials"
        key = "password"
        secret = true
      })
    }

    workspace "dev" {
      config = {
        replicas = 1
      }
    }

    workspace "prod" {
      config = {
        replicas = 1
      }
    }
  }

  labels = {
    "service" = "${config.internal.app-name}",
    "env" = [workspace.name]
    "owner" = "${config.internal.team-name}"
  }

  build {
    use "docker" {}
    registry {
      use "docker" {
        # Replace with your docker image name (i.e. registry.hub.docker.com/library/go-k8s)
        image = "syntassodev/${config.internal.app-name}"
        tag = [workspace.name]
        local = true
      }
    }
  }

  deploy {
    use "kubernetes" {
      probe_path = "/"
      service_port = 8080
      replicas = ${config.replicas}
    }
  }

  release {
    use "kubernetes" {}
  }
}
