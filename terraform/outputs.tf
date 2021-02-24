output "improved-initiative" {
  value       = module.create_cloudfront.improved-initiative
  description = "The hostname for improved-initiative"
}
output "dungeon-revealer" {
  value       = module.create_cloudfront.dungeon-revealer
  description = "The hostname for dungeon-revealer"
}
output "paragon" {
  value       = module.create_cloudfront.paragon
  description = "The hostname for paragon"
}
output "bastion" {
  value       = module.create_ec2.bastion
  description = "The hostname for bastion"
}
