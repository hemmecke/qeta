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

The **QEta** package started at the end of 2015 with an implementation
of the AB algorithm from the article `An algorithmic approach to
Ramanujan-Kolberg identities
<https://www.sciencedirect.com/science/article/pii/S0747717114000868>`_
by Silviu Radu and the *Samba* algorithm from the article `Dancing
Samba with Ramanujan Partition Congruences
<https://doi.org/10.1016/j.jsc.2017.02.001>`_ by Ralf Hemmecke.

In addition it implements the algorithm from the article
`Construction of all Polynomial Relations among Dedekind Eta Functions
of Level N <https://doi.org/10.1016/j.jsc.2018.10.001>`_
by Hemmecke and Radu to compute all polynomial relations of Dedekind
eta-functions of a certain level (`related website
<https://www.risc.jku.at/people/hemmecke/qeta/eta>`_).
The computations for the article
`Construction of Modular Function Bases for Γ₀(121) related to
p(11n+6) <https://doi.org/10.1080/10652469.2020.1806261>`_
by Hemmecke, Paule, and Radu were done
with the **QEta** package. See also the related `website
<https://www.risc.jku.at/people/hemmecke/papers/integralbasis/>`_.

In 2021 the extensions to Radu's algorithm for generalized
eta-quotients described in the the article `Finding Modular Functions
for Ramanujan-Type Identities
<https://doi.org/10.1007/s00026-019-00457-4>`_ by Chen, Du, and Zhao
have also been included in **QEta**.

The underlying theory of the programs is described in the above
articles which are also available as RISC_ reports
`15-14 <http://www.risc.jku.at/publications/download/risc_5069/zzz3.pdf>`_,
`16-06 <http://www.risc.jku.at/publications/download/risc_5338/DancingSambaRamanujan.pdf>`_,
`18-03 <http://www.risc.jku.at/publications/download/risc_5561/etarelations.pdf>`_.
`19-10 <https://www.risc.jku.at/publications/download/risc_6343/19-10.pdf>`_.

The **QEta** package requires FriCAS_ 1.3.7.

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
