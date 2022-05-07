.. _FriCAS Installation:

FriCAS Installation
===================

Default installation
--------------------

FriCAS_ comes with an
`Installation Guide <https://fricas.github.io/download.html>`_
of how to compile/install it from the
`official FriCAS release <https://github.com/fricas/fricas/releases>`_.
Unfortunately, this binary distribution does not work nicely together
with jFriCAS_  (which is the Jupyter_ interface of FriCAS_).
Although **QEta** would work perfectly with that distribution, we
recommend another way to install FriCAS_.


Recommended installation
------------------------

Use the following steps to get a running FriCAS_ 1.3.7 together
with a Jupyter_ notebook interface. It will install FriCAS_ in your
HOME directory (no root access is required) ``$HOM/fricas``.


Download and unpack
`fricas-1.3.7-hunchentoot-bionic.tar.bzip2 <http://hemmecke.org/fricas/dist/1.3.7/fricas-1.3.7-hunchentoot-bionic.tar.bzip2>`_.
*Note that the* ``md5sum`` *command just checks the integrity of the tarball.*
::

   FDIR=$HOME/fricas
   mkdir -p $FDIR
   cd $FDIR
   wget http://hemmecke.org/fricas/dist/1.3.7/fricas-1.3.7-hunchentoot-bionic.tar.bzip2
   echo "970806b96de599016af71699c5567336 fricas-1.3.7-hunchentoot-bionic.tar.bzip2" | md5sum -c
   tar xjf fricas-1.3.7-hunchentoot-bionic.tar.bzip2

Adapt the ``fricas`` and ``efricas`` scripts to point to the right paths.
::

   F=$FDIR
   L=$F/usr/local
   sed -i "s|^exec_prefix=|FRICAS_PREFIX=\"$L\"\nexport FRICAS_PREFIX\nexec_prefix=|" $L/bin/fricas
   sed -i "s|^FRICASCMD='/usr/local|FRICAS_PREFIX=\"$L\"\nexport FRICAS_PREFIX\nexec_prefix=\"\${FRICAS_PREFIX:-/usr/local}\"\nFRICAS=\"\${exec_prefix}\"'|;s|^export FRICASCMD|export FRICAS\nFRICASCMD=\"\$FRICAS\"\nexport FRICASCMD|;s|quote \"/usr/local|quote \"$L|" $L/bin/efricas

If you use the default setting of ``FDIR`` from above, the relevant
lines in your ``$L/bin/fricas`` file should look like this.
::

   FRICAS_PREFIX="$HOME/fricas/usr/local"
   export FRICAS_PREFIX
   exec_prefix="${FRICAS_PREFIX:-/usr/local}"

And in the ``efricas`` script like this.
::

   FRICAS_PREFIX="$HOME/fricas/usr/local"
   export FRICAS_PREFIX
   exec_prefix="${FRICAS_PREFIX:-/usr/local}"
   FRICAS="${exec_prefix}"'/lib/fricas/target/x86_64-linux-gnu/bin/fricas'
   export FRICAS
   FRICASCMD="$FRICAS"
   export FRICASCMD

Start FriCAS with one of the following commands.
::

   $FDIR/usr/local/bin/fricas
   $FDIR/usr/local/bin/efricas

Of course, you must have Emacs installed for the ``efricas``
script to work correctly.

You might have to install
::

   sudo apt install xfonts-75dpi xfonts-100dpi

and restart the X server (log out and log in again) in case the font
in HyperDoc does not look pretty.

That is, however, not necessary, if you do not intend to use HyperDoc
a lot and rather look at the FriCAS_ homepage in order to find
relavant information.

Set the PATH in ``$HOME/.bashrc``.

Edit the file ``$HOME/.bashrc`` (or whatever your shell initialization
resource is) and put in somthing like the following in order to make
all fricas scripts available.
::

   FDIR=$HOME/fricas
   export PATH=$FDIR/usr/local/bin:$PATH

**Issues with libssl1.0.0.**

If you see
::

   Error opening shared object "libssl.so.1.0.0":
   libssl.so.1.0.0: cannot open shared object file: No such file or directory.

and you have (on a newer linux distro), for example
libssl1.1, available, then issue the following command.
::

   sudo ln -s /usr/lib/x86_64-linux-gnu/libssl.so.1.1 /usr/lib/x86_64-linux-gnu/libssl.so.1.0.0

On Ubuntu 22.04 it would be
::

   sudo ln -s /usr/lib/x86_64-linux-gnu/libssl.so.3 /usr/lib/x86_64-linux-gnu/libssl.so.1.0.0

If you have no sudo right do the following.
::

   ln -s /usr/lib/x86_64-linux-gnu/libssl.so.3 $L/lib/libssl.so.1.0.0
   sed -i "s|^export FRICAS\$|export FRICAS\nLD_LIBRARY_PATH=\"\$LD_LIBRARY_PATH:$L/lib\"\nexport LD_LIBRARY_PATH|" $L/bin/fricas
   sed -i "s|^export FRICAS\$|export FRICAS\nLD_LIBRARY_PATH=\"\$LD_LIBRARY_PATH:$L/lib\"\nexport LD_LIBRARY_PATH|" $L/bin/efricas

That is your ``fricas`` and ``efricas`` scripts should have the
following inside.
::

   LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$HOME/fricas/usr/local/lib"
   export LD_LIBRARY_PATH

If you cannot solve this problem, because you do not have root access
on your machine or cannot install libssl, then remove the ``$FDIR``
directory, replace the line
::

   wget http://hemmecke.org/fricas/dist/1.3.7/fricas-1.3.7-hunchentoot-bionic.tar.bzip2

from above by
::

   wget https://github.com/fricas/fricas/releases/download/1.3.7/fricas-1.3.7.amd64.tar.bz2

and repeat the steps from above. That would give you the default
installation of FriCAS_.
In that case, however, jFriCAS cannot made to work and you can stop
here with the installation of FriCAS_.



jFriCAS installation
--------------------

Of course, jFriCAS_ needs Jupyter_ in a reasonably recent version (at
least 4).

Install prerequisites if not yet available (needs root access, but it
may already be installed on your system).
::

   sudo apt install python3-pip python3-venv

Prepare directories and download jfricas.
::

   FDIR=$HOME/fricas
   mkdir -p $FDIR/venv
   cd $FDIR
   git clone https://github.com/hemmecke/jfricas

Install prerequisites, Jupyter and jfricas.
::

   python3 -m venv $FDIR/venv/jfricas
   source $FDIR/venv/jfricas/bin/activate
   pip3 install wheel jupyter
   cd $FDIR/jfricas
   pip3 install .
   jupyter kernelspec list

The output of the last command should show something similar to the
following. ::

   Available kernels:
     jfricas     /home/hemmecke/fricas/venv/jfricas/share/jupyter/kernels/jfricas
     python3     /home/hemmecke/fricas/venv/jfricas/share/jupyter/kernels/python3

Create the script ``jfricas``.
::

   cat > $FDIR/usr/local/bin/jfricas <<EOF
   source $FDIR/venv/jfricas/bin/activate
   jupyter notebook \$1
   EOF
   chmod +x $FDIR/usr/local/bin/jfricas

Start a new terminal or set the ``PATH`` on the commandline like above
and start ``jfricas`` from any directory.
Note that inside jupyter the place from where you start
``jfricas`` is the place where your notebooks will be stored.

If you want to enjoy nice looking output, then type the following
inside a notebook cell.
::

   )set output algebra off
   setFormat!(FormatMathJax)$JFriCASSupport

You can go back to standard 2D ASCII output as follows.
::

   )set output formatted off
   )set output algebra on



Install JupyText
----------------

Ordinary Jupyter notebooks use a special format in order to store
their content. They have the file extension ``.ipynb``. It is an
incredible feature to be able to load and store notebooks as ordinary
FriCAS ``.input`` files. You can even synchronize between the
``.ipynb`` and ``.input`` formats.

There are two types of cells in Jupyter Markdown documentation
cells and execution cells. With the help of JupyText, Markdown
cells will appear inside an ``.input`` file as FriCAS_
comments and execution cells appear without the ``"-- "``
comment prefix.
::

   source $FDIR/venv/jfricas/bin/activate
   pip3 install jupytext


If ``$HOME/.jupyter/jupyter_notebook_config.py`` does not yet exist,
generate it.
*Note that this is outside the* ``$FDIR`` *directory.*
::

   jupyter notebook --generate-config

Make Jupytext available.
::

   sed -i 's|^# *c.NotebookApp.contents_manager_class =.*|c.NotebookApp.contents_manager_class = "jupytext.TextFileContentsManager"|;s|^# *c.NotebookApp.use_redirect_file = .*|c.NotebookApp.use_redirect_file = False|' $HOME/.jupyter/jupyter_notebook_config.py

Enable the spad language and set the respective parameters.
::

   cd $HOME
   J=$(find $FDIR/venv -type d | grep '/site-packages/jupytext$')

Edit the file ``$J/languages.py`` and change appropriately.
::

   #+BEGIN_ASCII
   # Jupyter magic commands that are also languages
   _JUPYTER_LANGUAGES = ['spad', "R", ...]

   # Supported file extensions (and languages)
   # Please add more languages here (and add a few tests) - see CONTRIBUTING.md
   _SCRIPT_EXTENSIONS = {
      ".py": {"language": "python", "comment": "#"},
       '.input': {'language': 'spad', 'comment': '--'},
       '.input-test': {'language': 'spad', 'comment': '--'},
       ...
   }



Put the following input into the file ``$FDIR/foo.input``.
::

   -- # FriCAS demo notebook

   )set output algebra off
   setFormat!(FormatMathJax)$JFriCASSupport

   -- Here we compute $\frac{d^2}{dx^2} sin(x^3)$.

   D(sin(x^3),x,2)

   -- We compute the indefinite integral $\int \sin x \cdot e^x dx$.

   integrate(exp(x)*sin(x), x)


Then start via ``jfricas``, load ``foo.input`` and enjoy.
::

   cd $FDIR
   jfricas


You can also download or clone the demo notebooks from
https://github.com/fricas/fricas-notebooks/ and compare them with what
you see at
`FriCAS Demos and Tutorials <https://fricas.github.io/fricas-notebooks/index.html>`_.


.. _FriCAS: https://fricas.github.io
.. _jFriCAS: https://jfricas.readthedocs.io
.. _Jupyter: https://jupyter.org
.. _JupyText: https://jupytext.readthedocs.io
