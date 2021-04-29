CC=gcc
CFLAGS=-g -Werror -pedantic
GCOV=-fprofile-arcs -ftest-coverage
OUTDIR=build/

.PHONY: default
default: $(OUTDIR)/fake6502.o $(OUTDIR)/fake2a03.o $(OUTDIR)/fake65c02.o $(OUTDIR)/fake6800.o

$(OUTDIR):
	mkdir -p $(OUTDIR)

$(OUTDIR)/fake6502.o: $(OUTDIR) fake6502.c
	$(CC) $(GCOV) -DDECIMALMODE -DNMOS6502 -c $(CFLAGS) fake6502.c -o $@
$(OUTDIR)/fake65c02.o: fake6502.c
	$(CC) -DDECIMALMODE -DCMOS6502 -c $(CFLAGS) fake6502.c -o $@
$(OUTDIR)/fake2a03.o: fake6502.c
	$(CC) -DNMOS6502 -c $(CFLAGS) fake6502.c -o $@

$(OUTDIR)/tests: fake6502.c tests.c $(OUTDIR)/fake6502.o
	gcc $(GCOV) $(CFLAGS) tests.c -c -o $(OUTDIR)/tests.o
	gcc -lgcov --coverage $(OUTDIR)/tests.o $(OUTDIR)/fake6502.o -o $(OUTDIR)/tests

.PHONY: test
test: $(OUTDIR)/tests
	valgrind -q ./$(OUTDIR)/tests

lcov: $(OUTDIR)
	lcov --zerocounters -d $(OUTDIR)/
	lcov --capture --initial -d $(OUTDIR)/ --output-file $(OUTDIR)/coverage.info
	make test
	lcov --capture -d $(OUTDIR)/ --output-file $(OUTDIR)/coverage.info
	mkdir -p $(OUTDIR)/coverage
	cd $(OUTDIR)/coverage && genhtml ../coverage.info
	sensible-browser $(OUTDIR)/coverage/index.html

cppcheck:
	cppcheck --enable=all fake6502.c tests.c

.PHONY: format
format:
	clang-format -style="{BasedOnStyle: llvm, IndentWidth: 4}" -i *.c

.PHONY: clean
clean:
	rm -rf build/
	
