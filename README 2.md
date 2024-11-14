 terraform plan --var-file="./vars/dev.tfvars"

 aws ecs list-tasks --cluster esc_market_fargate_cluster

aws ecs describe-tasks \
    --cluster esc_market_fargate_cluster \
    --tasks 4bf75d813abf4c74a94acc630d113dbf
