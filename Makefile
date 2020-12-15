CC=clang
CFLAGS=-g -Werror -pedantic

.PHONY: default
default: fake6502.o fake2a03.o

fake6502.o: fake6502.c
	$(CC) -c $(CFLAGS) fake6502.c -o $@
fake2a03.o: fake6502.c
	$(CC) -DNES_CPU -c $(CFLAGS) fake6502.c -o $@

.PHONY: clean
clean:
	rm *.o
	