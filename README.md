# EC2 Welcome App

## Overview

This project demonstrates a simple AWS EC2 deployment using a `user-data` bootstrap script.

When the instance starts for the first time, it automatically:

* installs Apache HTTP Server (`httpd`)
* enables and starts the service
* creates a custom welcome page

The goal is to show a minimal but production-like example of infrastructure bootstrap automation.

---

## Architecture

AWS EC2 instance
→ executes `user-data` at first boot
→ installs and starts Apache (`httpd`)
→ serves a static HTML welcome page

---

## Repository Structure

```text
ec2-welcome-app/
├── README.md
├── userdata/
│   └── userdata_httpd.bash
└── scripts/
    └── create_ec2_example.bash
```

---

## How It Works

The `user-data` script is passed during EC2 creation.

At first boot, the instance automatically:

1. updates system packages
2. installs Apache
3. starts and enables the web server
4. writes a custom `index.html` page

---

## Cloud Scope

This is a demonstration project focused on:

* EC2 provisioning basics
* Linux service bootstrap
* reproducible setup through scripting

It is intentionally simple.

---

## Data Sources

This project does not use external datasets.

---

## Next Improvements

Possible future extensions:

* parameterized EC2 creation script
* Nginx alternative
* HTTPS setup
* deployment through Terraform or CloudFormation

---

## Author

Maurizio Morgano
