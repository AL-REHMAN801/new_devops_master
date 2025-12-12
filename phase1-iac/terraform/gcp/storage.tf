# Cloud Storage Bucket
resource "google_storage_bucket" "main" {
  name          = "${var.bucket_name}-${var.environment}-${var.project_id}"
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }

  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

# Bucket IAM - Make bucket private
resource "google_storage_bucket_iam_binding" "main" {
  bucket = google_storage_bucket.main.name
  role   = "roles/storage.objectViewer"

  members = [
    "serviceAccount:${google_service_account.gke_nodes.email}",
  ]
}
