output "folder_id" {
  description = "The numeric folder ID (without the `folders/` prefix). Use this when APIs or variables expect a bare numeric ID."
  value       = google_folder.folder.folder_id
}

output "name" {
  description = "The fully qualified folder name in `folders/FOLDER_ID` format. Use this as the `parent` input to child `folder` or `project` modules, and when constructing org policy resource names."
  value       = google_folder.folder.name
}

output "display_name" {
  description = "The human-readable display name of the folder."
  value       = google_folder.folder.display_name
}
