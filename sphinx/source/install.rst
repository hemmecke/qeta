.. _QEta Installation:

QEta installation
=================

Requirement FriCAS
------------------

**QEta** is built on FriCAS_. If you do not yet have it follow the
instructions at :ref:`FriCAS Installation` for an installation in a
Linux environment.

Installation steps for the QEta package
---------------------------------------

Clone the git repository and compile the sources.
::

   FDIR=$HOME/fricas
   mkdir -p $FDIR
   cd $FDIR
   git clone https://github.com/hemmecke/qeta.git
   cd $FDIR/qeta
   make compile-spad


(optional) Adapt some directories
---------------------------------

Adapt directories in the test files (extension ``.input-test``) so
that they match your setting.

This is only needed if you intend to work with these test/demo files
and if you have installed QEta into a different directory than
::

   $HOME/fricas/qeta

These test/demo files belong to the QEta testsuite, but might be
interesting to look into if you want to learn how to call some
command.

::

   # Change QETADIR to the absolute QEta installation path.
   QETADIR=$HOME/fricas/qeta
   OLD=fricas/input/jfricas-test-support
   NEW=$QETADIR/input/jfricas-test-support
   cd $QETADIR
   sed -i "s|^)read $OLD.*|)read $NEW.input )quiet|" worksheet/*.input test/*.input-test
   sed -i "s|^)cd fricas/qeta/tmp|)cd $QETADIR/tmp|" worksheet/*.input input/*.input


Look, for
example, into `RogersRamanujanContinuedFraction.input-test
<https://github.com/hemmecke/qeta/blob/master/test/RogersRamanujanContinuedFraction.input-test>`_
where we show that for the Rogers-Ramanujan continued fraction

.. math::

   \begin{gather*}
   R(q)
   =
   q^{\frac15}
   \dfrac{1}{1+\dfrac{q}{1+\dfrac{q^2}{1+\dfrac{q^3}{1+\ddots}}}}
   =
   q^{\frac15}
   \frac{(q,q^4;q^5)_\infty}{(q^2,q^3;q^5)_\infty}
   =
   \frac{\eta_{5,1}(\tau)}{\eta_{5,2}(\tau)}
   \end{gather*}

we have the identity

.. math::

   \begin{align*}
   U_5\!\left(\frac{R(q)^5}{R(q^5)}\right)
   &=
   U_5\!\left(\frac{R(q^5)}{R(q)^5}\right)
   \end{align*}

where :math:`U_5` is the operator that acts as follows:

.. math::

   \begin{gather*}
   U_5\left(\sum_{n=k}^\infty a(n)q^n\right)
   =
   \sum_{n=\lceil k/5 \rceil}^\infty a(5n)q^n
   \end{gather*}


Install 4ti2_
-------------

**QEta** builds on 4ti2_ in order to solve integer linear problems.

::

   sudo apt install 4ti2


(optional) Install SageMath_
----------------------------

**QEta** uses a command (run from the terminal)
::


  make LEVELS='6 9' er

to compute relations among eta quotients of certain levels.
**QEta** employs the Gröbner engine (slimgb) of the Singular_ computer
algebra system through its SageMath_ interface, since this seems to be
more efficient than the built-in FriCAS_ Gröbner engine.

Inside a FriCAS_ session **QEta** does not (yet) reach out to call
function from SageMath_, i.e. installation of SageMath_ is not
strictly needed and may just consume diskspace on your computer.
The following command may take 20 min to complete.
::

   apt install sagemath

.. _4ti2: https://4ti2.github.io
.. _SageMath: https://sagemath.org
.. _Singular: https://www.singular.uni-kl.de/
.. _FriCAS: https://fricas.github.io
.. _RISC: https://risc.jku.at
