# jd
Repo containing tools unning jupyter notebooks on a slurm cluster

## [Optional] Python management with pyenv and poetry
I prefer to manage my Python installation through [pyenv](https://github.com/pyenv/pyenv) and project dependencies through [Poetry](https://python-poetry.org/). Such a set up disentangles myself from system versions of Python and distribution related issues (Anaconda, etc.).

If you do not want python 3.8.6, modify the steps below as well as the `Dockerfile` accordingly.

```bash
# pyenv
curl https://pyenv.run | bash

# the installer should automatically add these lines to your bashrc or zshrc, restart your shell as needed
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# install python through pyenv
pyenv install 3.8.6
pyenv global 3.8.6 # will make all directories use python 3.8.6
pyenv local 3.8.6 # will make the local directory always use python 3.8.6

# poetry
curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python

# a lot of python installation come with pip 18 whereas some dependencies need pip 20
poetry run pip install --upgrade pip
```

## Setup `requirements.txt`
In this repo, I added a few basic dependnecies via poetry (pytorch, tensorflow, opencv, pandas, seaborn, matplotlib, jupyter, and jupyterlab) which are cleanly defined in `pyproject.toml`. However, each of these dependencies pull in many more dependencies which poetry helps manage. I exported *all* the dependencies of the python environment into `requirements.txt` using poetry and you can see things like numpy and pillow (that the above packages depend on) were automatically pulled in and managed by poetry. Poetry will do all the version handling as necessary to make sure the contents of `pyproject.toml` are satisfied.

If you are happy with these predefined dependencies, continue to the next step. Otherwise, create your own `requirements.txt` through whatever workflow you are most comfortable with.

## Docker image setup
This will build an image with the contents of the current directory. You can change the docker account and name of this image as desired.

```bash
docker build -t dxyang/jupyter_docker:0.1 .
docker push dxyang/jupyter_docker:0.1
```

From the cluster environment, pull this docker container using singularity.
```bash
cd /data/vision/fisher/expres2/dxyang/singularity
singularity pull docker://dxyang/jupyter_docker:0.1
```

## Running on the clusters
You don't necessarily need to clone this repo onto the cluster environment, but you will need `singularity_run_container.sh` and `slurm_run_container.sh` scripts. You should modify the path within `singularity_run_container.sh` to point towards wherever you just downloaded the container.

```bash
cd /data/vision/fisher/code/dxyang
git clone https://github.com/dxyang/jd.git
cd jd
./slurm_run_container.sh
```

You can modify `singularity_run_container.sh` such that singularity binds the NVIDIA CUDA drivers we have in our container to work with the CUDA drivers on the host machine. If you do not do this, pytorch and tensorflow will run their CPU only versions and you will not have access to the GPUs (i.e., `nvidia-smi` will fail). You can also modify `slurm_run_container.sh` to have a different time out length (default is 24 hours), specify a specific host that you want to launch onto, or define other requirements for the scheduler.

The first time you run this on a specific host, you will also need to configure your jupyter notebook settings. Since the machines and ports will be exposed to the internet, you should add a password and a cert/key file (so your password isn't sent unencrypted on the internet). Instructions below are taken from [here](https://jupyter-notebook.readthedocs.io/en/stable/public_server.html).

```bash
# generates the file ~/.jupyter/jupyter_notebook_config.py
jupyter notebook --generate-config

# generates a hashed password to a JSON file that you should copy/paste into the above config
jupyter notebook password

# create a self signed certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ~/.jupyter/mykey.key -out ~/.jupyter/mycert.pem
```

Modify `jupyter_notebook_config.py` as follows:
```python
c.NotebookApp.certfile = u'/absolute/path/to/your/certificate/mycert.pem'
c.NotebookApp.keyfile = u'/absolute/path/to/your/certificate/mykey.key'
c.NotebookApp.ip = '*'
c.NotebookApp.password = u'sha1:bcd259ccf...<your hashed password here>'
c.NotebookApp.open_browser = False
```

To simplify this across multiple machines, I save a copy of these configuration files on NFS and copy and paste them onto every new machine that I slurm onto.
```bash
cp -r ~/.jupyter /data/vision/fisher/expres2/dxyang/dot_jupyter
```

Finally, you can run either `jupyter notebook` or `jupyter lab` and access the server from any browser. For example, `https://bean3.csail.mit.edu:8888`. You may run into issues where your browser complains the certificate isn't signed and that the site is not secure.