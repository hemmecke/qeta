# QEta 1.0.0

The QEta Project is connected two articles.

It implements the `samba` algorithm from

[Ralf Hemmecke: "Dancing Samba with Ramanujan Partition Congruences",
Journal of Symbolic Computation, 84:14–24,
2018.](http://www.risc.jku.at/publications/download/risc_5338/DancingSambaRamanujan.pdf) [doi:10.1016/j.jsc.2017.02.001](https://doi.org/10.1016/j.jsc.2017.02.001)

and implements the algorithm to compute all polynomial relations among
eta functions of level N as described in

[Ralf Hemmecke and Silviu Radu: Construction of all Polynomial Relations
  among Dedekind Eta Functions of Level N](http://www.risc.jku.at/publications/download/risc_5561/etarelations.pdf)

### Prerequisites

In order to use this package you need [FriCAS] 1.3.2. In fact, the
package has been created on top of the
[master-hemmecke](https://github.com/hemmecke/fricas/commits/master-hemmecke)
branch of a clone of the FriCAS repository.

We assume that [SBCL] is installed in version 1.3.21 or higher.

```
cd SOMEDIR
ROOTDIR=`pwd`
PREFIX=$ROOTDIR/install
git clone -b master-hemmecke https://github.com/hemmecke/fricas.git
mkdir build
cd build
$ROOTDIR/fricas/configure  --prefix=$PREFIX \
  --with-lisp="sbcl --dynamic-space-size 4096"
make
make install
PATH=$ROOTDIR/install/bin:$PATH
export PATH
```
and put

```
PATH=SOMEDIR/install/bin:$PATH
export PATH

```
into your `.bashrc` in order to call `fricas` from anywhere on the
bash prompt.

The QEta package contains code to compute eta relations completely
done in FriCAS, but for efficiency reasons, some computations are done
by external programs.

For example, by default, `QEtaQuotientMonoidExponentVectors4ti2` is
used by `make eqmev` and requires [4ti2].

The Gröbner basis computation during `make er` is done by calling
`slimgb` from [Singular]. However, we do not call [Singular] directly,
but rather through a [SageMath] interface.

## Installing

Once [FriCAS] is available, the installation of the QEta package is as
easy as cloning a repository.

```
git clone https://github.com/hemmecke/qeta.git
cd qeta
make compile-spad
```

## Getting Started

Produce the documentation (overview and source code comments) into
`tmp/pdfall.pdf`.

```
make pdf
make pdf
make pdfall
```

There are two ways to work with the package

1. Call the functionality via `make` from the command line.
1. Use the QEta package inside a [FriCAS] session.

### Compute eta relations on the command line.

Compute eta relations of levels 4, 6, 8, and 9 into
`etafiles/Hemmecke/etaRelations*.input`.

```
make LEVELS='4 6 8 9 10' -j4 er
```

### Compute eta relations in a FriCAS session

```
make compile-spad
cd tmp
fricas
# now inside a fricas session
)read qetalibs
)read etamacros
er 6
```

## Authors

* **Ralf Hemmecke**

## License

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.




[4ti2]:http://www.4ti2.de
[FriCAS]:https://fricas.github.io
[SageMath]:http://sagemath.org
[Singular]:https://www.singular.uni-kl.de/
[SBCL]:http:sbcl.org
