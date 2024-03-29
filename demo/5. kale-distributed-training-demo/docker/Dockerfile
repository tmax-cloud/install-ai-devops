#  Copyright 2020 The Kale Authors
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

# Use tensorflow-1.14.0 as a base image, allowing the user to
# speficy if they want GPU support, by setting IMAGE_TYPE to "gpu".
ARG IMAGE_TYPE="cpu"
FROM gcr.io/kubeflow-images-public/tensorflow-2.1.0-notebook-${IMAGE_TYPE}:1.0.0

USER root

# Install basic dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates bash-completion tar less \
        python-pip python-setuptools build-essential python-dev \
        python3-pip python3-wheel && \
    rm -rf /var/lib/apt/lists/*

ENV SHELL /bin/bash
COPY bashrc /etc/bash.bashrc
RUN echo "set background=dark" >> /etc/vim/vimrc.local

# Install latest KFP SDK
RUN pip3 freeze
RUN pip3 install --upgrade pip && \
    # XXX: Install enum34==1.1.8 because other versions lead to errors during
    #  KFP installation
    pip3 install --upgrade "enum34==1.1.8" && \
    pip3 install --upgrade "jupyterlab>=2.0.0,<3.0.0"

# Install Kale from KALE_BRANCH (defaults to "master")
# ARG KALE_BRANCH="master"
WORKDIR /
RUN git clone https://github.com/tmax-cloud/kale-tekton-standalone.git

WORKDIR /kale-tekton-standalone/backend
RUN pip3 install --upgrade .
RUN pip3 install "kfp-tekton==1.0.0"
RUN pip3 install "tekton-pipeline==0.1.3"
# kfserving version upgrade
RUN pip3 install --upgrade "kfserving==0.5.1"
RUN pip3 install --upgrade "kubernetes"

WORKDIR /kale-tekton-standalone/labextension
RUN jlpm install && \
    jlpm run build && \
    jupyter labextension install .

RUN jupyter lab build --dev-build=False --minimize=False

RUN chown jovyan -R /home/jovyan

RUN echo "jovyan ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/jovyan
WORKDIR /home/jovyan
USER jovyan

CMD ["sh", "-c", \
     "jupyter lab --notebook-dir=/home/jovyan --ip=0.0.0.0 --no-browser \
      --allow-root --port=8888 --LabApp.token='' --LabApp.password='' \
      --LabApp.allow_origin='*' --LabApp.base_url=${NB_PREFIX}"]
