FROM centos:7

MAINTAINER sgcclh

# Upgrade and add third-party repository.
RUN yum update -y && \
      yum install -y epel-release

# Install the requires yum package and python.
RUN yum install -y \
      kernel-headers gcc python python-pip python-devel \
      libffi-devel openssl-devel git ipmitool\
      && \
      yum clean all

# Upgrade the pip to lastest.
RUN pip install -U pip
COPY requirements.txt /home
# Setup the ansible.
RUN pip install ansible
RUN pip install -r /home/requirements.txt
RUN pip install docker-py==1.10.6
# for disable localhost warning message.
RUN mkdir /etc/ansible && \
      /bin/echo -e "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts

# Setup with Ansible.
ADD https://raw.githubusercontent.com/chusiang/ansible-jupyter.dockerfile/master/setup_jupyter.yml /home
RUN ansible-playbook -vvvv /home/setup_jupyter.yml

# Copy a ipython notebook example to image.
ADD https://raw.githubusercontent.com/chusiang/ansible-jupyter.dockerfile/master/ipynb/ansible_on_jupyter.ipynb /home/
ADD https://raw.githubusercontent.com/chusiang/ansible-jupyter.dockerfile/master/ipynb/ansible_on_jupyter_centos.ipynb /home/

# Run service of Jupyter.
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT [ "docker-entrypoint.sh" ]
EXPOSE 8888

CMD [ "jupyter", "--version" ]
