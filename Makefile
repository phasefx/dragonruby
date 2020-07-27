CC = gcc
#CC = checkergcc
DEBUG = -g
FLAGS = -O3 -ansi -pedantic -fPIC -ffast-math -D_SVID_SOURCE -D_BAS_SOURCE -DSHM -DUSE_X86_ASM
GL = -I/usr/X11R6/include -I/usr/X11R6/include -L/usr/X11/lib -L/usr/X11R6/lib -L/usr/include/GL -lX11 -lXext -lXmu -lXt -lXi -lSM -lICE -lglut -lGLU -lGL -lm
OTHER = -lefence

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

