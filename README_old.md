# Terraform module to collect postgres logs and put to cloudwatch

This repo is forked and splitted branch from https://github.com/SumoLogic/sumologic-content/tree/master/Amazon_Web_Services/RDS/Log-Collection

I implemented with terraform hcl codes to deploy a full solution with lambda function and schedule event to collect postgres logs regularly

I only test with postgresql, but it should work with other RDS databases, need your feedback, if you have chance to test. 

So why we need this lambda function.

# RDS Log Ingestion Script

RDS collects different logs depending on the database engine. They include different ones such as error, slow query, general, audit, and trace logs depending on the engine. These are for the most part the standard vendor logs these database engines typically have outside of RDS as well, so prebuilt Sumo content should work typically.

To collect RDS logs, you'll first need to determine which database engine is being used with RDS. There are currently 6 database engines that can be used for RDS:

* Aurora
* PostgreSQL
* MySQL
* MariaDB
* Oracle
* Microsoft SQL Server

Aurora MySQL, MySQL, and MariaDB logs can be configured to send their logs to CloudWatch Logs. Follow this AWS blog post on how to configure it: [Monitor Amazon Aurora MySQL, Amazon RDS for MySQL and MariaDB logs with Amazon CloudWatch](https://aws.amazon.com/blogs/database/monitor-amazon-rds-for-mysql-and-mariadb-logs-with-amazon-cloudwatch/).

Once those logs are forwarded to CloudWatch Logs, then the standard Sumo Lambda function will work to pull those logs into Sumo Logic.

For all other database engines, the logs are not made readily available at this time. These engines will require the AWS API to access those logs and pull them into Sumo Logic. A script is currently being developed to pull these logs into Sumo Logic, but the general flow is:

# Notes

* The script currently passes over .XEL and .TRC log files for Microsoft SQL Server. These are binary data files that cannot be read in plaintext.
