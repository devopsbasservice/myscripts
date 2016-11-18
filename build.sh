#!/bin/bash
# The temp directory where jjb files will be cloned and build will happen
build_dir="/home/ubuntu/temp_builds"
cd $build_dir

# For debugging
echo "Getiing parameters"
echo $1
echo $2
echo $3
echo $4
echo $5

# Full Commit ID
fullcommitid="$3"
echo "This is the Current Full commitid " $fullcommitid
commit_id="$(echo $fullcommitid  | cut -c -7)"
echo "New Commit ID" $commit_id
fullprevcmmitid="$2"
echo "This is the Prev Full commitid " $fullprevcmmitid
prev_id="$(echo $fullprevcmmitid  | cut -c -7)"
echo "Previous Commit ID" $prev_id

# Creating the directory
mkdir $5_$commit_id && cd $5_$commit_id
repo="$5"

# Full BRANCHID
fullbranch="$1"
echo "This is the Fullbranch name" $fullbranch
branch="$(echo $fullbranch | cut -c 12-)"
echo "This is the short branch" $branch
wget https://raw.githubusercontent.com/$4/$branch/Dockerfile
wget https://raw.githubusercontent.com/$4/$branch/job.yaml
wget https://raw.githubusercontent.com/$4/$branch/jenkins.plugins.logstash.LogstashInstallation.xml

# change repo to push into dockerhub
username="devopsbasservice/"
a="$username$repo"
image_id="$a:$commit_id"
echo "New Image ID"  $image_id
echo "Previous commit" $prev_id
prev_img_id="$a:$prev_id"
echo "Previous Image ID" $prev_img_id

# Append the commit_id to the job.yaml
sed -i 's,<appndid>,'"$commit_id"',g' job.yaml
sed -i 's,<ID>,'"$commit_id"',g' job.yaml
sed -i 's,<IP>,'"$SCALR_INTERNAL_IP"',g' job.yaml

# get basejenkinsimage from job.yaml
# Author: Venkatesh
w="$(tac job.yaml| grep -m 1 '.')"
echo "This is the base image" $w
set -- "$w"
IFS=":"; declare -a Array=($*)
final="${Array[1]}"
final="${final#"${final%%[![:space:]]*}"}"
final="${final%"${final##*[![:space:]]}"}"
sed -i 's,<NAME>,'"$final"',' Dockerfile
IFS=""

# Push images
# Author: Kishore Ramanan
cd "$build_dir/$5_$commit_id"
echo "Performing build"
echo "New Image ID"  $image_id
echo "Previous Image ID" $prev_img_id
echo "New Commit ID" $commit_id
docker build -t $image_id .
docker push $image_id

# Change marthon JSON
# Author: Venkatesh / Kishore
ext=".json"
file="$commit_id$ext"
echo $pwd
sed -e 's,<image>,'"$image_id"',;s,<tagid>,'"$commit_id"',' /home/ubuntu/goscripts/marathon.json >> $file

# Cleanup the old docker build
docker rmi -f $prev_img_id

# POST data to marathon
curl -X POST $SCALR_EXTERNAL_IP:8080/v2/apps -d @$file -H "Content-type: application/json"

