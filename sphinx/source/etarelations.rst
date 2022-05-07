.. _Ideal of Relations of eta Functions:

Ideal of Relations of eta Functions
===================================

On `this site
<https://risc.jku.at/people/hemmecke/qeta/eta/etarelations/index.html>`_
we list the polynomials of a (degrevlex) Gröbner basis of relations
among eta functions for various levels.

The relations are expressed as polynomials in variables :math:`E1,
E2`, etc. where for a divisor :math:`δ` of a given level :math:`N` the
variable :math:`Eδ` stands for the eta function :math:`η(δτ)`.

.. math::

   η(δτ) = \exp\left(\frac{πiτ}{12}\right) \prod_{n=1}^\infty (1 − q^{δn})

with :math:`q = q(τ) = \exp(2πiτ)`.

The relations listed by
`Somos <https://en.wikipedia.org/wiki/Michael_Somos>`_ can easily be
expressed in terms of the :math:`Eδ` variables (i.e. directly in terms of
eta functions). These (transformed) relations can be represented in
terms of the Gröbner bases from
`this site <https://risc.jku.at/people/hemmecke/qeta/eta/etarelations/index.html>`_.
We give a
`collection <https://risc.jku.at/people/hemmecke/qeta/eta/somos/index.html>`_
of such representations for various entries in the collection of Somos.

The relations have been computed by an implementation of the
algorithm samba from
`"Dancing Samba with Ramanujan Partition Congruences" <https://doi.org/10.1016/j.jsc.2017.02.001>`_
in the computer algebra system FriCAS_ and the
slimgb (Gröbner bases) algorithm from the system Singular_.

All files can be read directly by FriCAS_, in particular, reading the
``fricassomos*.input`` files evaluates the representation of relations
from Somos' list in terms of the Gröbner basis of relations and thus
yields a list of zeros.
See `EtaRelations8 <http://fricas-wiki.math.uni.wroc.pl/EtaRelations8>`_
for an example of evaluation in FriCAS_ and
`SandboxSomos2Eta <http://fricas-wiki.math.uni.wroc.pl/SandboxSomos2Eta>`_
for a FriCAS_ implementation to translate the notation of Somos into
our notation.

Details of how exactly the relations have been computed is
explained in the article
`"Construction of all Polynomial Relations among Dedekind Eta
Functions of Level N" <https://doi.org/10.1016/j.jsc.2018.10.001>`_
by `Hemmecke <http://www.risc.jku.at/people/hemmecke>`_ and
`Radu <https://risc.jku.at/m/cristian-silviu-radu/>`_
in the
`Journal of Symbolic Computation
<https://www.journals.elsevier.com/journal-of-symbolic-computation>`_.
The article is also available as RISC_ report
`18-03 <http://www.risc.jku.at/publications/download/risc_5561/etarelations.pdf>`_.


.. _Singular: https://www.singular.uni-kl.de/
.. _FriCAS: https://fricas.github.io
.. _RISC: https://risc.jku.at
