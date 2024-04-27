FROM hashicorp/terraform:latest

WORKDIR /ansibleTask

COPY main.tf .

VOLUME [ "/terraform" ]

ENV AWS_ACCESS_KEY_ID=$ANSIBLE_AWS_ACCESS_KEY_ID \
    AWS_SECRET_ACCESS_KEY=$ANSIBLE_AWS_SECRET_ACCESS_KEY

CMD ["init"]

