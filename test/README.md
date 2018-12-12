# Run AWS Lambda function on local machine

## Python version

This lambda function is written by python 3, because it used some new features after v3.3

## Usage

* install [python-lambda-local](https://github.com/HDE/python-lambda-local)

```
pip install python-lambda-local
```

* create event test data

```
{
  "region": "eu-west-1"
}
```

* test locally

```
export DB_INSTANCE_IDENTIFIERS="instance-1"
export INITIAL_DAYS_TO_INGEST=1
export BUCKET_NAME="db-logs-state-stage"
python-lambda-local -l lib/ -f lambda_handler -t 300 ../source/main.py event.json
```
* notes

you need to create the s3 bucket and pass the BUCKET_NAME to the environment variable of the lambda.