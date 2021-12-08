output "all_users" {
  // values() returns the values of the resource
  // here, global_users is made as an array of resource
  // using values() returns the values of all the resources
  // the [*] splat means getting all values, and for each of them, get the arn
  value = values(aws_iam_user.global_users)[*].arn
}