#creamos los backet S3 para que los utilize terraform

resource "aws_s3_bucket" "codepipeline_artifacts" {
  bucket = "platzi-mis-despliegues-automaticos-con-terraform"
} 
resource "aws_s3_bucket" "terraformstate" {
  bucket = "platzi-terraform-state"
} 
