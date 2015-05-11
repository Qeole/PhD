#! /usr/bin/env python
# encoding: utf-8

VERSION='0.1'
APPNAME='manuscrit'

top = '.'
out = 'build'

def configure(conf):
    conf.load('biber')
    #conf.find_program('biber', var='BIBER')
    #conf.env.BIBTEX = conf.env.BIBER
    #if not conf.env.LATEX and not conf.env.PDFLATEX and not conf.env.conf.LATEX:
        #conf.fatal('could not find any TeX compiler')

def build(bld):
    ## Set up rules to build any of the .dot files to png versions
    #for x in bld.path.ant_glob('*.dot'):
        #tg = bld(rule='${DOT} -Tpdf -o${TGT[0].get_bld().abspath()} ${SRC[0].abspath()}', source=x, target=x.change_ext('.pdf'))
    #bld.add_group()

    deps_str = 'src/laclthesis.cls '
    for i in bld.path.ant_glob('src/**/*'):
    #for i in bld.path.ant_glob('src/**'):
        deps_str += i.path_from(bld.path.search(top)) + " "

    bld(
        features = 'tex',
        type     = 'xelatex',
        source   = 'src/master.tex',
        outs     = 'pdf', # we want a postscript output too - 'ps pdf' works too
        prompt   = 1, # put 0 for the batchmode (conceals the debug output)
        deps     = deps_str # src/thesismanuscrit.cls' # use this to give dependencies directly
    )
    bld.env.MAKEINDEXFLAGS = ['-s', '../../src/style.ist']
    bld.env.MAKENOMENFLAGS = ['-s', '../../src/nomencl.ist']

    if bld.options.view:
        bld.add_post_fun(display)

def display(cmd):
    cmd.exec_command("okular \"{0}/src/master.pdf\"".format(out))


def options(opt):
    # custom command-line options
    opt.add_option('--view', action='store_true', default=False, help='view document')
