#Nico Williams and Brandon Rullamas
#nijowill and brullama
#Assignment 2 - Lexical Analyzer using flex

MKFILE    = Makefile
#DEPSFILE  = ${MKFILE}.deps
NOINCLUDE = ci clean spotless
NEEDINCL  = ${filter ${NOINCLUDE}, ${MAKECMDGOALS}}
VALGRIND  = valgrind --leak-check=full --show-reachable=yes

#
# Definitions of list of files:
#
HSOURCES  = astree.h lyutils.h  auxlib.h  stringset.h 
CSOURCES  = astree.cpp lyutils.cpp auxlib.cpp stringset.cpp main.cpp
LSOURCES  = scanner.l
YSOURCES  = parser.y
ETCSRC    = README ${MKFILE}
CLGEN     = yylex.cpp
HYGEN     = yyparse.h
CYGEN     = yyparse.cpp
CGENS     = ${CYGEN} ${CLGEN}
ALLGENS   = ${HYGEN} ${CGENS}
EXECBIN   = oc
ALLCSRC   = ${CGENS} ${CSOURCES}
OBJECTS   = ${ALLCSRC:.cpp=.o}
LREPORT   = yylex.output
YREPORT   = yyparse.output
IREPORT   = ident.output
REPORTS   = ${LREPORT} ${YREPORT} ${IREPORT}
ALLSRC    = ${ETCSRC} ${YSOURCES} ${LSOURCES} ${HSOURCES} ${CSOURCES}
TESTINS   = ${wildcard test?.in}
LISTSRC   = ${ALLSRC} ${HYGEN}

#
# Definitions of the compiler and compilation options:
#
GCC       = g++ -g -O0 -Wall -Wextra -std=gnu++11
#MKDEPS    = g++ -MM -std=gnu++11

#
# The first target is always ``all'', and hence the default,
# and builds the executable images
#
all : ${EXECBIN}

#
# Build the executable image from the object files.
#
${EXECBIN} : ${OBJECTS}
	${GCC} -o${EXECBIN} ${OBJECTS}


#
# Build an object file form a C source file.
#
%.o : %.cpp
	${GCC} -c $<

#
# Build the scanner.
#
${CLGEN} : ${LSOURCES}
	flex --outfile=${CLGEN} ${LSOURCES} 2>${LREPORT}

#
# Build the parser.
#
${CYGEN} ${HYGEN} : ${YSOURCES}
	bison --defines=${HYGEN} --output=${CYGEN} ${YSOURCES}

#
# Check sources into an RCS subdirectory.
#
ci : ${ALLSRC} ${TESTINS}
	cid + ${ALLSRC} ${TESTINS} test?.inh

#
# Make a listing from all of the sources
#
lis : ${LISTSRC} tests
	mkpspdf List.source.ps ${LISTSRC}
	mkpspdf List.output.ps ${REPORTS} \
		${foreach test, ${TESTINS:.in=}, \
		${patsubst %, ${test}.%, in out err}}

#
# Clean and spotless remove generated files.
#
clean :
	- rm ${OBJECTS} ${ALLGENS} ${REPORTS} core
	- rm ${foreach test, ${TESTINS:.in=}, \
		${patsubst %, ${test}.%, out err}}

spotless : clean
	- rm ${EXECBIN} List.*.ps List.*.pdf

#
# Build the dependencies file using the C preprocessor
#
#deps : ${ALLCSRC}
#	@ echo "# ${DEPSFILE} created `date` by ${MAKE}" >${DEPSFILE}
#	${MKDEPS} ${ALLCSRC} >>${DEPSFILE}

#${DEPSFILE} :
#	@ touch ${DEPSFILE}
#	${MAKE} --no-print-directory deps

#
# Test
#

tests : ${EXECBIN}
	touch ${TESTINS}
	make --no-print-directory ${TESTINS:.in=.out}

%.out %.err : %.in ${EXECBIN}
	( ${VALGRIND} ${EXECBIN} -ly -@@ $< \
	;  echo EXIT STATUS $$? 1>&2 \
	) 1>$*.out 2>$*.err

#
# Everything
#
again :
	gmake --no-print-directory spotless ci all lis
	
ifeq "${NEEDINCL}" ""
#include ${DEPSFILE}
endif