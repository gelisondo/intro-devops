#Le decimos a Terraform que deve guardar el archivo .tfstate dentro del bucket S3
#Devemos crear este bucket previamente - Crear en AWS el bucket 1w2g-devops-terraform

terraform{
    backend "s3" {
        bucket = "platzi-mi-repo-para-terraform"
        encrypt = true
        key = "terraform.tfstate"
        region = "us-east-1"
    }
}

provider "aws" {
    region = "us-east-1"
    #Es posible ingresar los secretos en este archivo
    #Lo mejor es pasarselo como parametro y guardarlo en un lugar seguro
    #Para que este paso se realize con exito se necesita crear un Access Key, en la seccion "User - Security Credential" en AWS

    #access_key = "AKIAYFQTFKR6I4IUOGSY"
    #secret_key = "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"
}
#export AWS_ACCESS_KEY_ID=AKIAYFQTFKR6I4IUOGSY ; 
#export AWS_SECRET_ACCESS_KEY=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