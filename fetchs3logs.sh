BUCKET=
LOG_TYPE=
LOG_FILE_PREFIX=
DESTINATION_PATH=./$BUCKET/
files=$(aws s3 ls s3://$BUCKET/$LOG_TYPE/$LOG_FILE_PREFIX | awk '{print $4}')
for f in ${files}; do aws s3 cp s3://$BUCKET/$LOG_TYPE/${f} $DESTINATION_PATH; done;
gunzip $DESTINATION_PATH*.gz
