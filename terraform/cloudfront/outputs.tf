output "improved-initiative" {
  value       = aws_route53_record.improved-initiative.fqdn
  description = "The hostname for improved-initiative"
}
output "dungeon-revealer" {
  value       = aws_route53_record.dungeon-revealer.fqdn
  description = "The hostname for dungeon-revealer"
}
output "paragon" {
  value       = aws_route53_record.paragon.fqdn
  description = "The hostname for paragon"
}
