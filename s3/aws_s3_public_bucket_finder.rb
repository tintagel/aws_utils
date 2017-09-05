#!/usr/bin/env ruby

require 'aws-sdk'
require 'JSON'
require 'pry'


# Use EC2 to get a list of regions
ec2 = Aws::EC2::Client.new
ec2_describe_regions_resp = ec2.describe_regions
regions = ec2_describe_regions_resp.regions.map(&:region_name)

regions.each { |region|

  # do nothing - we don't need region iteration for s3

  }

s3 = Aws::S3::Client.new
s3_list_buckets_resp = s3.list_buckets
buckets = s3_list_buckets_resp.buckets.map{ |b| b.name }

puts
puts "Found the following S3 Buckets: \n#{buckets}"
puts

buckets.each { |bucket|

  # s3 is a little crazy, we have to find the region for each bucket to successfully make the API call
  location_constraint = s3.get_bucket_location(bucket: bucket).location_constraint
  # adding to the crazy, if the location is an empty string, then it is us-east-1
  location_constraint = "us-east-1" if location_constraint == ""
  s3_with_location_constraint = Aws::S3::Client.new(region: location_constraint)
  grants = s3_with_location_constraint.get_bucket_acl(bucket: bucket).grants
  pub_bucket = grants.any?{ |g| g.grantee.include?("http://acs.amazonaws.com/groups/global/AllUsers")}
  puts "#{bucket} is a Public S3 Bucket" if pub_bucket

  }

puts
