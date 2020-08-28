|PACKAGE_NAME| |PACKAGE_VERSION|
================================

Abstract
--------

The **QEta** package is a collection of programs written in the
FriCAS_ computer algebra system that allow to compute with
`Dedekind eta-functions
<https://en.wikipedia.org/wiki/Dedekind_eta_function>`_
and related :math:`q`-series where :math:`q=e^{2\pi i \tau}`.

Furthermore, we provide a number of functions connected to the theory
of modular functions.


Overview
--------

The **QEta** package started with an implementation of the AB
algorithm from the article `An algorithmic approach to
Ramanujan-Kolberg identities
<https://www.sciencedirect.com/science/article/pii/S0747717114000868>`_
by Silviu Radu
and the *Samba* algorithm from the article `Dancing Samba with
Ramanujan Partition Congruences
<https://doi.org/10.1016/j.jsc.2017.02.001>`_ by Ralf Hemmecke in
addition it implements the algorithm from the article `Construction of
all Polynomial Relations among Dedekind Eta Functions of Level N
<https://doi.org/10.1016/j.jsc.2018.10.001>`_ by Hemmecke and Radu to
compute all polynomial relations of Dedekind eta-functions of a
certain level.

The underlying theory of the programs is described in the above
articles which are also available as RISC_ reports
`15-14 <http://www.risc.jku.at/publications/download/risc_5069/zzz3.pdf>`_,
`16-06 <http://www.risc.jku.at/publications/download/risc_5338/DancingSambaRamanujan.pdf>`_,
`18-03 <http://www.risc.jku.at/publications/download/risc_5338/DancingSambaRamanujan.pdf>`_.

Further material is in the |git repository|.

This package requires a version of FriCAS_ that is compiled from at
least SVN revision 2328, i.e. where Gröbner basis computations do no
longer require variable names.

TODO: MUST FIX

The scripts usually use::

  )set output linear on

which is coded in the file `1d.spad
<https://github.com/hemmecke/fricas/blob/master-hemmecke/src/algebra/1d.spad>`_
in the `master-hemmecke
<https://github.com/hemmecke/fricas/tree/master-hemmecke/src>`_ branch
of a `clone <https://github.com/hemmecke/fricas>`_ of the FriCAS_
`git repository <https://github.com/fricas/fricas/>`_. However, this
*linear* output form is not absolutely necessary.


Contents
--------

.. toctree::
   :maxdepth: 2

   api/index

Links
-----

* |home page|
* |git repository|
* Bug reports: |PACKAGE_BUGREPORT|

.. _FriCAS: https://fricas.github.io
.. _RISC: https://risc.jku.at
