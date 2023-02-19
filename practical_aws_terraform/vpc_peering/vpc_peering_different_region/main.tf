#The following arguments are supported:
#peer_owner_id - (Optional) The AWS account ID of the owner of the peer VPC. Defaults to the account ID the AWS provider is currently connected to.
#peer_vpc_id - (Required) The ID of the VPC with which you are creating the VPC Peering Connection.
#vpc_id - (Required) The ID of the requester VPC.
#auto_accept - (Optional) Accept the peering (both VPCs need to be in the same AWS account and region).
#peer_region - (Optional) The region of the accepter VPC of the VPC Peering Connection. auto_accept must be false, and use the aws_vpc_peering_connection_accepter to manage the accepter side.

provider "aws" {
  region     = "ap-south-1"
}
provider "aws" {
  alias = "peer"
  region     = "us-east-1"
}

data "aws_caller_identity" "current" {}

#Requester's side of the connection.
resource "aws_vpc_peering_connection" "peer" {
  #peer_owner_id = var.account_id
  peer_owner_id = data.aws_caller_identity.current.account_id
  peer_vpc_id   = var.peer_vpc_id
  vpc_id        = var.requester_vpc_id
  peer_region   = aws.peer
  auto_accept   = false
  tags = {
    Side = "Requester"
  }
}

# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "peer" {
  provider                  = aws.peer
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  auto_accept               = true

  tags = {
    Side = "Accepter"
  }
}

#Note:-
#After creating the vpc peering connection this need update in the private  route table routes(both).