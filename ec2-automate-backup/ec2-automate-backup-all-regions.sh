#!/bin/bash -
# Date: 2015-10-13
# Version 0.10
# License Type: GNU GENERAL PUBLIC LICENSE, Version 3
# Author:
# Dan Switzer / https://github.com/dswitzer

#get_EBS_List gets a list of available EBS instances depending upon the selection_method of EBS selection that is provided by user input
get_Region_List() {
  #creates a list of all the ec2 regions
  local ec2_region_list=$(aws ec2 describe-regions --output text --query 'Regions[*].RegionName')
  #takes the output of the previous command 
  local ec2_region_list_result=$(echo $?)
  if [[ $ec2_region_list_result -gt 0 ]]; then
    echo -e "An error occurred when running ec2-describe-regions. The error returned is below:\n$ec2_region_list_result" 1>&2 ; exit 70
  fi
  # get the region and replace all whitespace with single space
  echo "$ec2_region_list" | sed -r 's/\s+/ /g'
}

# get the regions
region_list=$(get_Region_List)

# copy the expected arguments, but remove the region
args=""
while getopts :s:c:r:v:t:k:pnhu opt; do
	case $opt in
		# skip the region
		r);;
		# copy all the other expected arguments
		*)
			args="$args -$opt"
			if [ -n "$OPTARG" ]; then
				args="$args \"$OPTARG\""
			fi
		;;
	esac
done


# call the backup script for each region and pass in the original arguments
for region_name in $region_list; do
	script="./ec2-automate-backup.sh $args -r $region_name"

	# run the script	
	eval ${script}
done
