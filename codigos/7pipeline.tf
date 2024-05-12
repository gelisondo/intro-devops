
#Este es el "codepipeline" el orquestador, encargado de unir el codecommit con el codebuild para ejecutar el pipeline completo
resource "aws_codepipeline" "cicd_pipeline" {
  #Importante el name
  name     = "terraform-cicd"
  #Agregamos el role que nececitamos
  role_arn = aws_iam_role.assume_codepipeline_role.arn

  artifact_store {
    type     = "S3"
    #Agregamos el bucket, que es donde almacenara los archivos de terraform 
    location = aws_s3_bucket.codepipeline_artifacts.id
  }

##Escribirá los 3 estados


  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      #Indicamos que utilizara "CodeCommit" para indicar donde obtendra el código de Terraform que queremos desplegar
      provider         = "CodeCommit"
      version          = "1"
      ##Esto genera un output, que debe ser tomado por los suigentes STAGE, para continuar el pipeline
      output_artifacts = ["code"]
      configuration = {
        #Indicamos que repositorio queremso agregar
        RepositoryName       = "repositorio-de-cicd"
        #Indicamos que Rama bamos a utilizar, por lo general esto ya cambio a la rama "main" por defecto
        BranchName           = "master"
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }
##El paso anterior genera una carpeta que se la pasaremos a los guientes pasos

  stage {
    name = "Plan"
    action {
      name            = "Build"
      category        = "Build"
      provider        = "CodeBuild"
      version         = "1"
      owner           = "AWS"
      #Introducimos como input la salida del stage anterior
      input_artifacts = ["code"]
      configuration = {
        ProjectName = "cicd-plan"
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Build"
      provider        = "CodeBuild"
      version         = "1"
      owner           = "AWS"
      input_artifacts = ["code"]
      configuration = {
        ProjectName = "cicd-apply"
      }
    }
  }

}































  #    stage {
  #        name = "Source"
  #        action{
  #            name = "Source"
  #            category = "Source"
  #            owner = "AWS"
  #            provider = "CodeStarSourceConnection"
  #            version = "1"
  #            output_artifacts = ["code"]
  #            configuration = {
  #                FullRepositoryId = "culturadevops/"
  #                BranchName   = "master"
  #                ConnectionArn =aws_codestarconnections_connection.example.arn
  #                OutputArtifactFormat = "CODE_ZIP"
  #            }
  #        }
  #    }
