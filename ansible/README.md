Ansible implementation
======================

This folder contains the same kind of setup as the project's root, implemented using Ansible.

Steps to set up one of the playbooks:

1. Install Ansible on your machine: [http://docs.ansible.com/ansible/intro_installation.html#installing-the-control-machine]

2. Make sure you can ssh into your own machine as root, temporarily for Ansible to run
commands that require installing packages.

3. Run:

```bash
$ ansibe-playbook -i localhost [options] <playbook.yml>
```

where the different available options are:

    --extra-vars Double-quoted list of variables. Variables used in the
                 different playbooks are:

                 devel.yml:
                     git_email
                     git_name


Full examples:

```bash
$ ansible-playbook -i localhost \
  --extra-vars "git_email='<your_email>' git_name='<your name>'" \
  devel.yml
```
