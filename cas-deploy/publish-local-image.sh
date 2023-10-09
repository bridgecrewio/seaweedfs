#!/bin/bash

image_version="$SEAWEEDFS_VERSION"
profile="$AWS_PROFILE"
region="$AWS_REGION"
account_id="$AWS_ACCOUNT_ID"

source_image="chrislusf/seaweedfs:local"
repo_name="cas-external-image-seaweedfs"
target_image="$account_id.dkr.ecr.$region.amazonaws.com/$repo_name:$image_version"

cd ../docker && make build

docker tag $source_image $target_image

if aws ecr describe-repositories --region $region --profile $profile --repository-names $repo_name > /dev/null 2>&1; then
    echo "ECR repository '$repo_name' already exists."
else
aws ecr create-repository \
     --repository-name $repo_name \
     --region $region \
     --profile $profile > /dev/null 2>&1
fi

aws ecr get-login-password \
     --profile $profile --region $region | docker login \
     --username AWS \
     --password-stdin $account_id.dkr.ecr.$region.amazonaws.com

docker push $target_image

rm ../docker/weed
