Uses infra blueprints from AWS to deploy web app on ECS
The infra consists of an ALB deployed in the public subnet and ECS cluster with Fargate launch type (target task of 3) in the private subnet across 2 AZs
