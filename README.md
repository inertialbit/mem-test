## Memory issues diff'ing keys in 2 buckets & downloading

A rake task creates 2 connections to S3 with fog. The first connection is the destination and the second is the source. If a file from source doesn't exist in destination then it is downloaded. Destination bucket is in us-west-2 and source is in us-west-1.

Listing files alone eventually consumed ~600MB but memory use held steady - actual number listed not available but it was > 2000 items.

Listing 1649 files and downloading the last 165 of them consumed all available memory ~1400MB and resulted in a 'Cannot allocate memory' error when the script shelled out to `free -m` call - ~13MB of memory was available at the time, as reported by free -m in a separate terminal session.

The script was tested on a m1.small ec2 instance from Amazon.

## Setup

Set the following environment variables:

    export DEST_BUCKET='destination-bucket'
    export DEST_REGION='us-west-2'
    export SRC_BUCKET='source-bucket'
    export SRC_REGION='us-west-1'
    export AUTH_KEY='your-key-id'
    export AUTH_SECRET='your-secret-key'