**SWE 645 – Assignment 1**

**Name: Rudra Chauhan**

**Project Overview**

This project is divided into two parts:

1. **Part 1** involves creating a class homepage using AWS S3.
1. **Part 2** involves creating and deploying a student survey form on an AWS EC2 instance.

**Part 1: Class Homepage (AWS S3)**

- **Homepage URL**:[ http://rudra-swe645.s3-website-us-east-1.amazonaws.com/ ](http://rudra-swe645.s3-website-us-east-1.amazonaws.com/)
- This homepage contains a welcoming paragraph, an image, and is styled using Bootstrap.
- An error page (error.html) is provided for handling errors, and it will display if the main page is unavailable.

**Steps to Create and Configure AWS S3 Bucket for Static Website:**

1. **Create an S3 Bucket**:
   - Navigate to the S3 dashboard in AWS.
   - Click "Create Bucket" and choose a unique bucket name.
   - Set the bucket to "public" for website hosting purposes.
1. **Enable Static Website Hosting**:
   - After creating the bucket, go to the bucket settings.
   - Enable "Static website hosting" in the bucket properties.
   - Specify index.html as the default home page and error.html as the error page.
1. **Upload Files**:
   - Upload index.html, error.html, and any images or CSS files.
   - Ensure all files have public read access under the permissions settings.
1. **Add a Public Access Policy for S3 Bucket**:

   - Go to the "Permissions" tab of your S3 bucket.
   - Under "Bucket Policy", click "Edit" and add the following policy to allow public access:

     ```
       {
         "Version": "2012-10-17",
         "Statement": [
           {
             "Sid": "PublicReadGetObject",
             "Effect": "Allow",
             "Principal": "*",
             "Action": "s3:GetObject",
             "Resource": "arn:aws:s3:::rudra-swe645/*"
           }
         ]
       }
     ```

1. **Access the Website**:
   - The S3 bucket URL will serve the homepage.

**Part 2: Student Survey Form (AWS EC2)**

- **Survey Form URL**:[ http://ec2-54-145-103-103.compute-1.amazonaws.com ](http://ec2-54-145-103-103.compute-1.amazonaws.com/)
- The student survey form allows users to enter their personal details, preferences, and additional feedback.
- Form includes validation and input fields for name, address, survey date, campus preferences, and raffle numbers.

**Steps to Create and Configure AWS EC2 Instance:**

1. **Launch EC2 Instance**:
   - Navigate to the EC2 dashboard in AWS.
   - Launch a new instance, choosing an appropriate Amazon Machine Image (AMI) (e.g., Ubuntu).
   - Choose instance type (e.g., t2.micro) and configure the security group to allow HTTP traffic.
2. **Add User Data to Install and Start Apache:**

   - While configuring the EC2 instance, under the **Advanced settings** section, add the following user data script:

     ```
     #!/bin/bash
     yum -y install httpd
     systemctl enable httpd
     systemctl start httpd
     ```

   - This script automatically installs and starts the Apache HTTP server when the EC2 instance is launched.

3. **Deploy the Survey Form:**
   - SSH into the instance using the provided key pair (if needed).
   - Copy the HTML files for the student survey form to /var/www/html/.
4. **Test the Application**:
   - Ensure that the form is accessible via the public IP address or DNS of the EC2 instance.
   - Include the URL of the survey form on your class homepage.

**Submission Details**

- **Homepage URL**:[ http://rudra-swe645.s3-website-us-east-1.amazonaws.com/ ](http://rudra-swe645.s3-website-us-east-1.amazonaws.com/)
- **Survey Form URL**:[ http://ec2-54-145-103-103.compute-1.amazonaws.com ](http://ec2-54-145-103-103.compute-1.amazonaws.com/)
- **Error Page URL** :[ http://rudra-swe645.s3-website-us-east- 1.amazonaws.com/error.html ](http://rudra-swe645.s3-website-us-east-1.amazonaws.com/error.html)
