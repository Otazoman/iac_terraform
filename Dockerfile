FROM ubuntu:focal
MAINTAINER devuser

SHELL ["/bin/bash", "-c"]
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NOWARNINGS yes

#VersionUP
RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get -y update
RUN apt-get -y dist-upgrade

#Japanese
RUN apt-get install -y language-pack-ja-base language-pack-ja locales
RUN locale-gen ja_JP.UTF-8
ENV LANG ja_JP.UTF-8
RUN DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y tzdata

#Dev Package Get
RUN apt-get -y install sudo git vim man curl wget unzip

#Node Install
RUN apt-get install -y nodejs npm
RUN npm install n -g
RUN n latest
RUN ln -sf /usr/local/bin/node /usr/bin/node
RUN apt-get -y purge nodejs npm

#Ruby Install
ARG ruby_ver
RUN apt-get install -y build-essential libssl-dev zlib1g-dev
RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv
RUN git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
RUN echo 'export PATH="~/.rbenv/bin:$PATH"' >> ~/.bashrc
RUN echo 'eval "$(rbenv init -)"' >> ~/.bashrc
ENV PATH $PATH:~/.rbenv/bin
ENV PATH $PATH:~/.rbenv/shims
RUN rbenv install $ruby_ver
RUN rbenv global $ruby_ver
ENV RUBYOPT -EUTF-8

#Python Install
ARG python_ver
ARG python_old_ver
RUN apt-get install -y build-essential libffi-dev libssl-dev zlib1g-dev liblzma-dev libbz2-dev libreadline-dev libsqlite3-dev
RUN git clone https://github.com/pyenv/pyenv.git ~/.pyenv
RUN git clone git://github.com/yyuu/pyenv-update.git ~/.pyenv/plugins/pyenv-update
RUN echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
RUN echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
RUN echo 'eval "$(pyenv init -)"' >> ~/.bashrc
ENV PATH $PATH:~/.pyenv/bin
ENV PATH $PATH:~/.pyenv/shims
#RUN pyenv global 3.9.2
RUN pyenv install $python_ver
RUN pyenv install $python_old_ver
RUN pyenv global $python_ver
RUN pyenv rehash
RUN pip install --upgrade pip

#AWS-CLI
RUN apt-get -y install jq
RUN pip install --upgrade awscli
RUN pip install --upgrade aws-sam-cli

#Azure-CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
ENV DEBIAN_FRONTEND=noninteractive

#Google CloudSDK Install
RUN apt-get -y install apt-transport-https ca-certificates gnupg
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
RUN apt-get update && apt-get -y install google-cloud-sdk
RUN apt-get -y install google-cloud-sdk-app-engine-python \
  google-cloud-sdk-bigtable-emulator \
  google-cloud-sdk-cbt google-cloud-sdk-cloud-build-local \
  google-cloud-sdk-datalab google-cloud-sdk-datastore-emulator kubectl \
  google-cloud-sdk-pubsub-emulator
RUN echo 'export CLOUDSDK_PYTHON=~/.pyenv/shims/python' >> ~/.bashrc

#Terraform
RUN git clone https://github.com/tfutils/tfenv.git ~/.tfenv
RUN echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bashrc
ENV PATH $PATH:~/.tfenv/bin
RUN tfenv install latest
RUN tfenv use latest

#WorkingDir make
RUN mkdir ~/terraform
