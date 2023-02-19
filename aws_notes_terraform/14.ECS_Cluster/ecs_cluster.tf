provider "aws" {
  region = "ap-south-1"
}

module "ecs_cluster" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = "my-ecs-cluster"

  vpc_id = "vpc-049df61146f12"

  subnets = ["subnet-049df61146f12a", "subnet-049df61146f12b", "subnet-049df61146f12c"]

  instance_type = "t2.micro"

  desired_capacity = 2

  max_size = 2

  key_name = "my-key-pair"
}
