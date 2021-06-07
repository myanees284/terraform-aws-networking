#repeated lengthy expressions used in the code are stored in locals. And accessed as local.<variable name>
locals {
  #data source to return no of AZs available in current region
  az_names           = data.aws_availability_zones.available.names
  public_subnet_ids  = aws_subnet.public.*.id
  private_subnet_ids = aws_subnet.private.*.id
}