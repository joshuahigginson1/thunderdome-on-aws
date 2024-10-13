[//]: # (Implicit Links Within Project)

[1]: https://thunderdome.dev/subscriptions/pricing   "Thunderdome Application Hosting"
[2]: https://github.com/StevenWeathers/thunderdome-planning-poker   "Thunderdome Source Code"
[3]: https://github.com/users/joshuahigginson1/projects/6/views/1   "TOA Kanban Board"
[4]: https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/CreatingHostedZone.html "Creating a Public Hosted Zone"
[5]: https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/domain-register.html "Registering a New Domain in AWS"

# Thunderdome on AWS ECS

⚡️ 🌩️ ⛈️ 🌩️ ⚡️

**Battle out your agile ceremonies in the *THUNDERDOME* *...DOME* *...dome* on AWS ECS.**

_Deployment created by Joshua Higginson_

![GitHub](https://img.shields.io/github/license/joshuahigginson1/thunderdome-on-ecs?style=flat-square)

## Contents

- [Thunderdome on AWS ECS](#thunderdome-on-aws-ecs)
  - [Contents](#contents)
  - [Project Brief](#project-brief)
    - [Resources](#resources)
    - [Requirements](#requirements)
  - [Quickstart](#quickstart)
  - [Project Architecture](#project-architecture)
    - [CI Pipeline](#ci-pipeline)
  - [Project Review](#project-review)
    - [Known Issues and Future Optimisations](#known-issues-and-future-optimisations)
  - [Authors](#authors)

## Project Brief

To me, Thunderdome is one of the most effective tools for managing Backlog Refinement sessions. When I first discovered it in early 2024, I knew that it would hold it's own against PlanningPokerOnline.

As my team have grown, 'points in the Google Meets chat' just don't cut it for already strained refinement sessions.

I've spend the weekend creating a deployment of Thunderdome, which balances AWS Costs with scalability, whilst ensuring that all data is held within our own Cloud estate.

If you are interested in a 'no fuss' Thunderdome, give the original creators some love [here.][1]

If you want a low-hassle, autoscaling deployment of Thunderdome hosted on your own infrastructure, read on. 

### Resources

- View the main Thunderdome project page [here.][2]
- View the Kanban board for Thunderdome on AWS (ToA) [here.][3]

### Requirements

To deploy this application, you will need:

- A rough understanding of Terraform and AWS ECS. I've done my best to document code as I go along. You'll quickly come to see that my terraform is rather opinionated - Rather than parameterise everything under the sun, I would rather have as much written in raw code as possible. If you are looking for a setting that you can't find, add an issue and I'll get back as soon as I can.

- An AWS Account.

- A [Route 53 Public Hosted Zone][4] (Write a ticket, and I'll add Private Zone integration.) and a corresponding Domain Name, [registered in AWS][5].

> ⚠️ **Warning**<br>
If you don't have a Domain Name registered in AWS, or if you're using Private ACM, you'll be paying through the teeth for a certificate with this deployment. You have been warned!

- Terraform CLI, and AWS CLI v2.


## Quickstart

1. Ensure you've got the pre-requisites in place. Keep the Hosted Zone ID for your Public Hosted Zone to hand.

2. Authenticate to your AWS CLI on the terminal.

3. Clone this repository down. Review the terraform code. In particular, you'll want to edit the default tags in the root `providers.tf` file, and configure a remote backend to your liking.

4. `terraform init` to initialise the repository.

5. `terraform plan` for a dry-run inside of your environment. Follow the prompts on screen to add:

- Your Hosted Zone ID.
- The initial Thunderdome Administrator email address. This should ideally be your own email address.

6. `terraform apply` and a cup of coffee. It will take circa 20 minutes to deploy from baseline.

7. After 20 minutes, terraform should spit out an output titled `server_fqdn`. Visit this over a HTTPS connection and project plan to your heart's content. ❤️


## Project Architecture

*TO WRITE*: Diagram.

*TO WRITE*: Costs associated.


### CI Pipeline

I've not currently written a CI Pipeline for this project. *Shocker* but I'm rather against GitHub workflows, due to their lack of visibility into the underlying source code.

I've got a number of other side projects which will take priority over writing a CI Pipeline for TOA, including:

- Feasable Cost Konfiguration Secure NAT (Save 90% on your NAT costs, whilst keeping the underlying EC2 instancesship shape and secure.)
- GitHub Actions template, with no added preservatives.
- Baofinity VoD Scheduling and Streaming.


## Project Review

I've been told I'm biased towards AWS Fargate and AWS ECS. It's a fair assumption. I think it strikes a balance between the cost savings and scalability of AWS Lambda, with a touch more control than AWS App Runner.

Overall, it's not perfect - you can't currently scale fully to 0 on either the Database or UI, though you can come a lot closer than a Virtual Machine and old-school RDS.

But the advantages:

- Built-in reduncancy with RDS Serverless v2 cluster - your data is backed up in 6 different places, and you're likely not going to need more than 8 ACUs - moreso you'll be looking at tailoring this deployment for scaling horizontally for global accessibility.

- Patching is a breeze and I'm not made of time.

- HA is simple too, with automatic pod recovery built into ECS Fargate itself.

- This deployment has logging and observability burned into it - Visit AWS CloudWatch and AWS XRay.

- Three bloody variables to deploy. Can't ask for more than that.


### Known Issues and Future Optimisations

Most of the known issues have been laid out in the [GitHub Project Kanban Board][3]. With time, I'll whittle these down, in order of rouch importance here.

- No autoscaling (yet).

- Backup and Restore not documented (yet).

- Database to App connection isn't over HTTPS. (Needs custom container build.)
- Telemetry to App connection isn't over HTTPS. (Needs custom container build.)
- No container-level health check (Needs custom container build.)

- AWS NAT Gateways cost a bomb to keep running 24/7. Working on this as my next personal coding project.

- No Prom Metrics.

- No support for OIDC providers other than Google. Currently, there's a hanging AWS Secret in Secrets Manager, awaiting this application-level feature.

- Terraform Module isn't currently published to the TF Registry.


## Authors

**Josh Higginson** - _AWS Platforms Technical Lead at Naimuri._

**Steven Weathers and Contributors** - Underlying Source Code for the Thunderdome Planning Poker application.