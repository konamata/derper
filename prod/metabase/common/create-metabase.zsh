#!/usr/bin/env zsh

# Parse command line arguments
while getopts ":n:" opt; do
    case $opt in
        n) newname="$OPTARG"
        ;;
        i) ip="$OPTARG"
        ;;
        d) db="$OPTARG"
        ;;
        \?) echo "Invalid option: -$OPTARG" >&2
        ;;
    esac
done

# Check if the flag is provided
if [ -z "$newname" ]; then
    echo "Please provide a name for the -n flag." >&2
    exit 1
fi

if [ -z "$ip" ]; then
    echo "Please provide a ip address for the -i flag." >&2
    exit 1
fi

if [ -z "$db" ]; then
    echo "Please provide a database name for the -d flag." >&2
    exit 1
fi

echo "Creating new Metabase helm config: $newname"

cd ..
cp -r xooi-metabase-cargologi xooi-metabase-filenders
cd xooi-metabase-filenders
find . -type f -print0 | xargs -0 sed -i '' "s/xooi-metabase-cargologi/xooi-metabase-$newname/g"
find . -type f -print0 | xargs -0 sed -i '' "s/cargologi.report.xooi.com/$newname.report.xooi.com/g"
find . -type f -print0 | xargs -0 sed -i '' "s/CargologiCRM/$db/g"
find . -type f -print0 | xargs -0 sed -i '' "s/172.20.77.230/$ip/g"

echo "Creating new Metabase instance with name: $newname"

# S3 variables
S3_BUCKET="k8s-helm-chart"
FOLDER_PATH="prod/xooi-metabase/xooi-metabase-${newname}"
S3_FOLDER="s3://${S3_BUCKET}/${FOLDER_PATH}"

# Create new S3 folder
aws s3api put-object --bucket $S3_BUCKET --key "${FOLDER_PATH}/"

# Initialize Helm S3 repo
helm s3 init $S3_FOLDER

# Add Helm repo to local
helm repo add "xooi-metabase-${newname}" $S3_FOLDER

# Install Metabase Helm chart
helm-upgrade -e prod -n xooi-metabase-${newname} -p metabase

# DNS variables
PUBLIC_HOSTED_ZONE_ID="Z088448543GY75QV6FX6"
VPN_HOSTED_ZONE_ID="Z07448942OJ10QC53D75C" 
ALB_DNS_NAME="dualstack.xooi-metabase-prod-886175142.eu-west-1.elb.amazonaws.com."
ALB_HOSTED_ZONE_ID="Z32O12XQLNTSW2"

# Add existing domain to private VPN PROD route53 record set
# Replace "existing-domain.com" with your domain
aws route53 change-resource-record-sets --hosted-zone-id $VPN_HOSTED_ZONE_ID --change-batch '{
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "'"$newname.report.xooi.com"'",
        "Type": "A",
        "AliasTarget": {
          "DNSName": "'"$ALB_DNS_NAME"'",
          "EvaluateTargetHealth": true,
          "HostedZoneId": "'"$ALB_HOSTED_ZONE_ID"'"
        }
      }
    }
  ]
}'

# Add existing domain to public route53 record set
# Replace "existing-domain.com" with your domain
aws route53 change-resource-record-sets --hosted-zone-id $PUBLIC_HOSTED_ZONE_ID --change-batch '{
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "'"$newname.report.xooi.com"'",
        "Type": "A",
        "AliasTarget": {
          "DNSName": "'"$ALB_DNS_NAME"'",
          "EvaluateTargetHealth": true,
          "HostedZoneId": "'"$ALB_HOSTED_ZONE_ID"'"
        }
      }
    }
  ]
}'