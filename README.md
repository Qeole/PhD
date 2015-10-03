<!-- vim: set spelllang=en,fr: -->
# Ph. D. thesis

Thèse de doctorat − Il s'agit de mon manuscrit de thèse, rédigé en français.
Si vous êtes intéressés par le contenu, par les figures ou bien par le code LaTeX utilisés, vous pouvez (presque) tout réutiliser (certaines figures ne sont pas de moi, merci de consulter la section **Licence** ci-dessous).
La soutenance de la thèse a eu lieu le 17 juillet 2015.
Le dossier [`slides`](https://github.com/Qeole/Enlight/tree/master/slides) contient les diapositives utilisées pour l'occasion.

_This is my Ph. D. thesis manuscript. Written in French.
If you're interested in contents, in figures or in LaTeX code, you may reuse (nearly) any part of it (some figures were not originally drawn by myself, please refer to the **License** section below).
The thesis defense took place on July 17th, 2015.
The slides associated to the talk are in the [`slides`](https://github.com/Qeole/Enlight/tree/master/slides) directory._

## Compilation / _Compiling_

XeLaTeX requis. Biber requis. De mémoire, il est possible qu'il y ait des soucis de compilation avec les versions de Biber inférieures à 1.9.

_XeLaTeX required. Biber required. There may be issues for Biber versions lower than 1.9._

Instructions (UNIX):
```bash
$ git clone https://github.com/Qeole/PhD.git QeolePhD
$ cd QeolePhD/src

$ xelatex master.tex

$ biber   master.bcf
$ makeindex -s style.ist   master.idx
$ makeindex -s nomencl.ist master.nlo -o master.nls

$ xelatex master.tex
$ xelatex master.tex
$ xelatex master.tex
```

J'ai utilisé l'outil d'automatisation Waf pour la compilation (d'où les fichiers `wscript` et `waf-1.7.16/waflib/Tools/tex.py`), lui même appelé depuis le fichier `recomp` à chaque enregistrement d'un fichier source.
Vous pouvez ignorer ces trois fichiers ; vous pouvez aussi vous en inspirer pour automatiser la compilation de vos propres fichiers LaTeX (installation de Waf requise ; attention, ces fichiers ne sont plus à jour avec l'actuelle version stable de Waf).
La compilation des slides est plus simple, elle ne devrait nécessiter que deux appels à `xelatex` sur le fichier source.

_I used the waf building tool to automate this task (hence the `wscript`, `waf-1.7.16/waflib/Tools/tex.py` files), automatically called on save via the `recomp` files.
You are probably not willing to automate compilation of my thesis, so you can safely ignore those files (you might get inspiration from them to automate other LaTeX builds, though; but this requires Waf to be installed. Note that those files are no more up-to-date with Waf current version).
Compiling the slides should be easier: running `xelatex` twice on the source file should do the trick._

## Licence / _License_

### French
Figures 4.15 à 4.23 : [Paolo BALLARINI][2] © 2011<br />
Figures 7.4 à 7.7 : [Mathieu SASSOLAS][3] © 2014

Ces illustrations sont soumises au droit d'auteur de leur créateur respectif.

Le fichier `laclthesis.cls` est basé sur la classe LaTeX standard `book.cls`, et est placé sous la _[LaTeX Project Public License (version 1.3c)][1]._

Le reste de cet ouvrage ainsi que ses sources sont mis à disposition selon les termes de la [licence universelle Creative Commons Zéro 1.0](https://creativecommons.org/publicdomain/zero/1.0/deed.fr) (transfert dans le domaine public).

### English
_Figures 4.14 to 4.22: [Paolo BALLARINI][2] © 2011<br />
Figures 7.4 to 7.7: [Mathieu SASSOLAS][3] © 2014_

_Those illustrations are subject to the copyright of their respective author._

_File `laclthesis.cls` was derived from the standard LaTeX class `book.cls` and is released under the [LaTeX Project Public License (version 1.3c)][1]._

_The remainder of this document and its sources are licenced under a [Creative Commons Zero 1.0 Universal License](https://creativecommons.org/publicdomain/zero/1.0) (Public Domain Dedication)._

[1]: http://www.latex-project.org/lppl.txt
[2]: https://sites.google.com/site/pballarini
[3]: https://www.lacl.fr/~msassolas
