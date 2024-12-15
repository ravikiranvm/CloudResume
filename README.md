# [Cloud Resume](https://raviki.online)

## Overview

The Cloud Resume [raviki.online](https://raviki.online) showcases the use of AWS services to deploy a highly available, scalable, and monitored personal resume website. This project integrates multiple AWS services, Terraform for Infrastructure as Code (IaC), and a CI/CD pipeline to automate workflows. Advanced monitoring and alerting systems are implemented using tools like PagerDuty, Slack, and Jira to ensure operational efficiency.

## Features

- **Static Website Hosting:** A resume website hosted in an S3 bucket and distributed globally through CloudFront with Origin Access Control (OAC).
- **Custom Domain:** Route 53 manages domain name configurations, including MX records for domain email.
- **Visitor Tracking:** Tracks website visitors using a serverless backend with REST API Gateway, Lambda, and DynamoDB.
- **Infrastructure as Code:** Utilizes Terraform to provision and manage AWS resources.
- **CI/CD Pipeline:** GitHub Actions automates the deployment process for frontend updates.
- **Monitoring and Alerts:** Integrates CloudWatch, PagerDuty, Slack, and Jira for comprehensive monitoring and incident management.
- **CloudWatch Alarms:** Tracks metrics such as Lambda invocation errors and monthly AWS costs.

## Project Architecture

![alt text](<Architecture Diagram.png>)

## Project Structure

```plaintext
.
├── LICENSE
├── README.md
├── frontend
│   ├── index.html
│   ├── script.js
│   └── styles.css
└── terraform
    ├── main.tf
    ├── modules
    │   ├── back-end
    │   │   ├── api.tf
    │   │   ├── db.tf
    │   │   ├── lambda.tf
    │   │   ├── update_count.py
    │   │   └── update_count_function.zip
    │   ├── front-end
    │   │   ├── cf.tf
    │   │   ├── dns.tf
    │   │   ├── s3.tf
    │   │   └── variables.tf
    │   └── monitoring
    │       ├── main.tf
    │       └── variables.tf
    ├── providers.tf
```

### Explanation of Directories and Files

- **frontend/**: Contains the static website files.
  - `index.html`: Main HTML file for the website.
  - `script.js`: JavaScript file for interacting with API.
  - `styles.css`: CSS file for website styling.
- **terraform/**: Contains Terraform configuration files for provisioning AWS resources.
  - `main.tf`: Entry point for Terraform to orchestrate all modules.
  - `modules/`:
    - **back-end/**: Provisions REST API Gateway, DynamoDB, and Lambda for visitor tracking. The Lambda function updates and fetches visitor counts from the DynamoDB table.
    - **front-end/**: Provisions S3, CloudFront, SLL Certificate and Route 53 for website hosting and DNS management, including MX records for email.
    - **monitoring/**: Configures CloudWatch alarms for Lambda invocation errors and monthly AWS costs, integrating with PagerDuty, Slack, and Jira.
  - `providers.tf`: Configures AWS provider settings.


## Implementation Details

### 1. **Static Website Hosting**
- **Technology:** S3, CloudFront
- **Details:** The website is hosted in an S3 bucket and delivered globally using CloudFront with Origin Access Control (OAC).

### 2. **Visitor Tracking**
- **Technology:** REST API Gateway, Lambda, DynamoDB
- **Details:**
  - API Gateway triggers the Lambda function.
  - The Lambda function updates the visitor count in a DynamoDB table and fetches the count for display.

### 3. **Infrastructure as Code (IaC)**
- **Technology:** Terraform
- **Details:** All resources are managed as code, enabling version control and reproducibility.

### 4. **CI/CD Pipeline**
- **Technology:** GitHub Actions
- **Details:** Automates the deployment of frontend updates.

### 5. **Monitoring and Incident Management**
- **Technology:** CloudWatch, PagerDuty, Slack, Jira
- **Details:**
  - **CloudWatch:** Tracks performance metrics such as Lambda invocation errors and monthly AWS costs.
  - **PagerDuty:** Escalates critical alerts to the team.
  - **Slack:** Sends real-time notifications for alerts and updates.
  - **Jira:** Logs incidents and assigns tasks for resolution.

## Future Improvements

- Expand CI/CD to include other Terraform modules.
- Implement a resume download option.
- Add DNSSEC for enhanced domain security.

## License

This project is licensed under the [MIT License](LICENSE).
