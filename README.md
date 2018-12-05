# Postgres db cloudwatch forwarder

This repo is duplicated from ozbillwang's repo [https://github.com/ozbillwang/tf_module_rds_logs2cloudwatch]


# What changed:
 
 Lambda function support to forward multiple db logs to cloudwatch.
 log state bucket has to be precreated and pass the bucket name to the lambda.
 