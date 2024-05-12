
#crea un bucket S3, para desplegar los artefactos FrontEnd
resource "aws_s3_bucket" "frontend_artifacts" {
  bucket = var.S3FrontEnd
  acl    = "public-read"
  policy = data.aws_iam_policy_document.website_policy.json
  #Aqui donde se cargaran los archivos de Agular y se serviran al publico(iternet)
  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

#Agregamos permisos y el recurso S3 para que culquiera los pueda ver.
data "aws_iam_policy_document" "website_policy" {
  statement {
    actions = [
      "s3:GetObject"
    ]
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
    resources = [
      "arn:aws:s3:::${var.S3FrontEnd}/*"
    ]
  }
}

#crea un doebuild
resource "aws_codebuild_project" "tf-frontend1" {
  name         = "cicd-build-${var.name_frontend}"
  description  = "pipeline for aplicacion frontend"
  service_role = var.codebuild_role

  artifacts {
    type = "CODEPIPELINE"
  }

  #En este caso utilizamos una imagen(linux) propia de AWS para hacer compilaciones
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      type  = "PLAINTEXT"
      name  = "S3_BUCKET_URL"
      value = aws_s3_bucket.frontend_artifacts.id
    }
  }

  #Agregamos un buildspec.
  #Este integra otro archiov que indica que pasos realizar pora compilar el proyecto
  #En nuestros caso llama al archivo buildspect.yml que contiene los pasos para preparar el entorno para angular
  source {
    type      = "CODEPIPELINE" #BITBUCKETaws
    buildspec = file("2-frontend/buildspec.yml")
  }
}
resource "aws_codepipeline" "frontend1_pipeline" {
  #Definición del nombre
  name     = "cicd-${var.name_frontend}"
  #Definición del Rol - con su ARN
  role_arn = var.codepipeline_role

  #Indicaos a que vamos usar el bucket ya creado "platzi-mis-despliegues-automaticos-con-terraform"
  artifact_store {
    type     = "S3"
    location = var.s3_terraform_pipeline
  }

#Configuramos el origen del Código de nuestro proeyecto Angular
#Como esta almacenado en BitBucket, se define la conexión al servicio 
#Se configura el repositorio y su rama para extraer el código
  stage {
    name = "Source"
    action {
      name     = "Source"
      category = "Source"
      owner    = "AWS"
      #Definición del proveedor, apunta a su coneccón 
      provider = "CodeStarSourceConnection"
      version  = "1"
      output_artifacts = [
        "SourceArtifact",
      ]
      #Repositorio del equipo de desarrollo
      configuration = {
        FullRepositoryId     = "culturadevops/angular2.git"
        BranchName           = "master"
        #Arn de la conexión
        ConnectionArn        = var.codestar_connector_credentials
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Plan"
    action {
      name     = "Build"
      category = "Build"
      provider = "CodeBuild"
      version  = "1"
      owner    = "AWS"
      input_artifacts = [
        "SourceArtifact",
      ]

      output_artifacts = [
        "BuildArtifact",
      ]
      configuration = {
        ProjectName = "cicd-build-${var.name_frontend}"
      }
    }
  }
  stage {
    name = "Deploy"

    action {
      category = "Deploy"
      configuration = {
        "BucketName" = aws_s3_bucket.frontend_artifacts.id
        "Extract"    = "true"
      }
      input_artifacts = [
        "BuildArtifact",
      ]
      name             = "Deploy"
      output_artifacts = []
      owner            = "AWS"
      provider         = "S3"
      run_order        = 1
      version          = "1"
    }
  }


}
