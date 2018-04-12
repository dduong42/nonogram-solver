NAME = nonogram
OBJ = nonogram.o

all: $(NAME) test_set_current_count

$(NAME): $(OBJ)
	gcc $< -o $@

$(OBJ): nonogram.s variables.inc set_current_count.inc
	nasm -f macho64 $< -o $@

test_set_current_count: test_set_current_count.o
	gcc $< -o $@

test_set_current_count.o: test_set_current_count.s variables.inc set_current_count.inc
	nasm -f macho64 $< -o $@
