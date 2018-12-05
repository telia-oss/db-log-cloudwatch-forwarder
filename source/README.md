# rds logs to cloudwatch

### Steps

* download state file from s3 bucket.
* create log group (default is **rds_logs**) if not exist
* Create log stream (example: postgresqldev/error/postgresql.log.2018-10-18-22) if not exist
* INITIAL_DAYS_TO_INGEST is used to set the history logs to go through at first run
* check the state in state file and make sure only read new logs
* push the latest logs to cloudwatch
* adjust sequence token when push the logs to cloudwatch
* pick up time in rds logs, and save as cloudwatch log time for each log
* write state (**JSON**) to state file and upload to s3

```
{
  "lastReadDate": 1539922165072,
  "readState": {
    "error/postgresql.log.2018-10-19-03": "4:4038",
    "error/postgresql.log.2018-10-19-04": "5:672"
  }
}
```

### System environment variables are required:

* BUCKET_NAME
* DB_INSTANCE_IDENTIFIERS
* (optional) INITIAL_DAYS_TO_INGEST
* (optional) LOG_GROUP
