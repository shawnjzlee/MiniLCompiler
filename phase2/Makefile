CC=g++
CFLAGS=
BFLAGS=-v -d --file-prefix=y
FFLAGS=
Y_SRC=mini_l.y
LEX_SRC=mini_l.lex
C_SRC=y.tab.c lex.yy.c
OBJECTS= 
EXECUTABLE=mini_l
BUILD_DIR=./bin

all: parse lex $(EXECUTABLE)

$(EXECUTABLE): move
	cd $(BUILD_DIR); \
	$(CC) $(C_SRC) -lfl -o $(EXECUTABLE)

parse:
	bison $(BFLAGS) $(Y_SRC)
	
lex:
	flex $(LEX_SRC)

move:
	mkdir -p $(BUILD_DIR)
	mv $(C_SRC) $(BUILD_DIR)/
	cp y.tab.h $(BUILD_DIR)/

check:
	(cat fibonacci.min | $(BUILD_DIR)/$(EXECUTABLE)) > fibonacci.test
	diff fibonacci.test fibonacci.parse
	

clean:
	rm -rf $(BUILD_DIR)
	rm fibonacci.test
