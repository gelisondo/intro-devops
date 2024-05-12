# intro-devops

Este proyecto tiene todo lo visto en el curso de introducción a devops

la carpeta "codigos" tiene todos los archivos terraforms para crear el primer pipeline que te ayudara a montar la infra, con el cual podrás usar la carpeta repositorio-de-cicd para crear tus siguientes pipeline

la carpeta reposiorio-de-cicd tiene todo lo necesario para crear los pipelines de frontend, serverless, base de datos y de backend ci tal cual se ve en el curso

la carpeta repositorio-de-aplicaciones tiene los repositorios de aplicación para los pipelines creados en en la práctica del curso

Puedes tomar cada uno de esas carpetas y crear un repo en alguna plataforma de git (github,bitbucket,gitlab,etc) y apuntar tus pipelines a ese repo para poder terminar la práctica o simplemente puedes apuntar el pipeline a otro repo sin ningún problema, los archivos están para que te guíes.

# Configuramos una Iaac con Terraform

Vamos a configurar un PipeLine con terraform para crear varios servicios en AWS, estos daran soporte a los seuigentes pipelene CI/CD para desplegar nuestros softwares.

- Creamos previamente un bucket S3 en AWS

Servicios:

- PipeLine de AWS
- CodeBuil - plan
- CodeBuil - apply
- Code Commit

Esto lo aplicaremos desde terraform, los mismos archivos están comentados para aclarar cada paso a aplicar:
- 0states.tf
- 1codecommit.tf
- 2iamcodebuild.tf
- 2iamcodepipeline.tf
- 3secret.tf


Despues que tengamos nuestro entorno configurado, lansaremos los suigentes comandos para desplegar la infra.

Inicializamos el directorio local, creando un entorno para terraform
```
$terraform init
```

Ejecutamos y aplicamos los cambios en el entorno/ambiente.
```
$terraform apply
```

En en la pagina de AWS debemos entrar a la sección del **CodeCommit** ir a **code** y en nuestro repositorio llamado **repositorio-de-cicd** vamos al apartado HTTPS(CRC), donde nos mostrara el comando para clonar nuestro repo y seguir el pipelie.

```
$git clone codecommit::us-east-1://repositorio-de-cicd
```

Cuando tengamos todo preparado en nuestra carpeta "repositorio-de-cicd", los subimos con un **git push** esto sera el 
detonante donde **codepipeline** seguira su curso.

```
$cd repositorio-de-cicd
repositorio-de-cicd$ git add .
repositorio-de-cicd$ git commit -m "primer push"
repositorio-de-cicd$ git push 
```

Cuanto termine de aprovisionar todos los elementeos, nos permitira conectarnos con BigBucket el nuevo servicio.
Si vamos a la sección en AWS de CodeBuild, en **setting - connections** veremos el servicio implementado, devemos copiarnos el **ARN** para pasarlos a nuestras variables(repositorio-de-cicd/variables.tfvars) esto se agregara a la linea:

- codestar-connector_credentials="Aca pega tu ARN"


# Crear un pipeline para aplicaciones Frontend

 Desplegaremos una aplicación FrontEnd sin necesidad de conexión con servidores BackEnd.

 Esto lo haremos directamente en el servicio S3, ya que el mismo esta capacitado para que corran estas tecnólogias si la necesitamos. Agregaremos que el sofware a desplegar esta escrito en Angular, no es necesario que sepamos programar en este lenguaje.

 Los servicios que utilizaremos son los siguientes:

 - CodePipeline - conecta y desplica codigo de y con (Bitbucket/codebuil/S3)
 - Bitbucket
 - Code Build (Build)
 - infraestructura Serverles


El proceso sera:

**BitBucket**  (Descarga de códiog) ==>  **Code Build Plan** (Npm run build)==> **Code Build apply** (upload file) ==> S3


Necesitamos ciertos datos para que nuestro pipeline funcione, 
Reusaremos los roles ya creados el CodePipeline y el CodeBuild, por ende necesitamos 
sus nombres para ingresarlos en el archivo de variables bajo:

- repositorio-de-cicd - variables.tfvars.

Vamos a los archiovos donde los creamos y copiamos sus nombres, para obtener en la consola de amason su ARN:

CodePipeline:
- 2iamcodepipeline.tf --> copiamos (name = "codepipeline_role")
- AWS -> Roles -> Buscamos por el nombre - Entramos a el objeto y copiamos su ARN
- variables.tfvars -> Agregamos este dato en la variables codepipeline_role="arn"

Codebuild:
- 2iamcodebuild.tf --> copiamos (name = "codebuild_role")
- AWS -> Roles -> Buscamos por el nombre - Entramos a el objeto y copiamos su ARN
- variables.tfvars -> Agregamos este dato en la variables codebuild_role="arn"

Mostramos un ejemplo del archivo de variables en repositorio-de-cicd - variables.tfvars:

```
codebuild_role= "arn:aws:iam::561607169148:role/codebuild_role"
codepipeline_role= "arn:aws:iam::561607169148:role/codepipeline_role"
```

Con estos arn, terraform los podra identificar y agregarlos a nuestro **pipeline**.

# Creamos y corremos nuestro pipeline para el FrontEnd

Los archivos de terraform que necesitaremos crear se alojaran debvajo de **repositorio-de-cicd** en una carpeta llamada **2-frontend**:

- 2frontedn-pipeline.tf
- buildspec.yml
- varr2frontend.tf

Comentamos los archivos anteriores, para indicar como despliega nuestro pipeline para este proyecto **FrontEnd**

Agregamos las suigentes variables adicionales en el archivo de variables "repositorio-de-cicd/variables.tfvars

```
S3FrontEnd="platzi-mi-frontend-automatico"
name_frontend= "frontend"
```

Con esto ya estamos listo para desplegar nuestra aplicación. Como en el ejemplo anterior se desplegara con un **git push**

```
$cd repositorio-de-cicd
repositorio-de-cicd$ git add .
repositorio-de-cicd$ git commit -m "add frontend project"
repositorio-de-cicd$ git push 
```