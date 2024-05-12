##En este archivo creamos los objetos de **CodePipeline**

resource "aws_codebuild_project" "plan" {
  ##El name es importante por que se utilizara mas adelante
  name          = "cicd-plan"
  description   = "Plan stage for terraform"
  service_role  = aws_iam_role.assume_codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    #Utiliza una imagen de "Linux+terraform" para lanzar los comandos de Terrafor
    #Por esta razon necesitamos este servicio
    image                       = "hashicorp/terraform:0.14.3"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    registry_credential{
        #Adjudicamos las credenciales que utilizamos en el archivo de secretos
        credential = aws_secretsmanager_secret.dockerhubconnection.arn
        credential_provider = "SECRETS_MANAGER"
    }
 }

 #Crea un archivo que contine los camandos que vamos a ejecutar
 source {
     type   = "CODEPIPELINE"
     buildspec = file("buildspec/plan-buildspec.yml")
 }
}

#Sección similar al anterior donde cambia el name y el archivo indicado en "buildspec"
resource "aws_codebuild_project" "apply" {
  name          = "cicd-apply"
  description   = "Apply stage for terraform"
  service_role  = aws_iam_role.assume_codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform:0.14.3"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    registry_credential{
        credential = aws_secretsmanager_secret.dockerhubconnection.arn
        credential_provider = "SECRETS_MANAGER"
    }
 }
 source {
     type   = "CODEPIPELINE"
     buildspec = file("buildspec/apply-buildspec.yml")
 }
}

