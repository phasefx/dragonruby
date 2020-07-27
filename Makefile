CC = gcc
#CC = checkergcc
DEBUG = -g
FLAGS = 
GL = -framework GLUT -framework OpenGL -framework Cocoa
OTHER = 

all: baffle.o dict.o menu.o agviewer.o
	$(CC) $(DEBUG) $(GL) $(OTHER) -o baffle baffle.o dict.o menu.o agviewer.o
agviewer.o: agviewer.c agviewer.h global.h
	$(CC) $(DEBUG) -c agviewer.c
baffle.o: baffle.c global.h agviewer.h menu.h dict.h
	$(CC) $(DEBUG) -c baffle.c
dict.o: dict.c global.h
	$(CC) $(DEBUG) -c dict.c
menu.o: menu.c global.h menu.h
	$(CC) $(DEBUG) -c menu.c
clean:
	rm *.o baffle

