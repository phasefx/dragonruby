#define BAFFLE_VERSION "3D Baffle Version .03, by Jason Etheridge"

/* #define DO_PRINT */

#include "global.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "agviewer.h"
#include "menu.h"
#include "dict.h"

#ifndef M_PI
#define M_PI            3.14159265358979323846
#endif

#define FONT_WIDTH 1
#define FONT_HEIGHT 1

int W = 400;			/* window dimensions */
int H = 400;
int W2 = 400, H2 = 400;

int hi_w;			/* which window to hilite with mouseover */

int root_w;			/* root window handle */
int root2_w;			/* word list window */
int main_w;			/* main window handle */
int file_w, options_w, help_w, erase_w, submit_w, store_w, recall_w, hide_w, clear_w, word_w;	/* more window handles */
int use_my_own_idle = 0;	/* my_idle vs. agv's idle */

typedef enum { NOT_FOR_USE, AXES } DisplayLists;

void my_init(void);		/* initialize some stuff */
void my_idle(void);		/* things to do while idling (eg. no events) */
void visible(int);		/* visibility callback */
void root_display(void);	/* display callback */
void root2_display(void);	/* second window */
void root2_reshape(int, int);
/* void my_display(void); display callback, moved to global.h */
void other_display(void);	/* display callback */
void show_word_in_progress(void);	/* display callback */
void my_reshape(int, int);	/* reshape callback */
void other_passive(int, int);	/* passive mouse callback */
void my_passive(int, int);	/* passive mouse callback */
void my_submit_mouse(int, int, int, int);	/* mouse callback */
void my_clear_mouse(int, int, int, int);	/* mouse callback */
void my_hide_mouse(int, int, int, int);
void my_word_mouse(int, int, int, int);	/* mouse callback */
void my_recall_mouse(int, int, int, int);	/* mouse callback */
void my_store_mouse(int, int, int, int);	/* mouse callback */

short int box = 1, color = 1, coord = -1, rect = -1, font = -1,
    ortho = -1, axes = -1, four4 = -1, connect_line = 1,
    roman = 1, threedee = 1, word_good = -1, bubble = -1, invis = -1,
    invis0 = -1, invis1 = -1, invis2 = -1, invis3 = -1;

float br = 0.3, bg = 0.5, bb = 1.0;
float s1r = 1, s1g = 0, s1b = 0,
    s2r = 0, s2g = 1, s2b = 0,
    s3r = 0, s3g = 0, s3b = 1,
    s4r = 1, s4g = 0, s4b = 1,
    asr = 1, asg = 1, asb = 0, psr = 0, psg = 1, psb = 1;

void draw_cell(GLenum, int, int, int, int, float, float, float);
void draw_row(GLenum, int, int, float, float, float);
void draw_slice(GLenum, int, float, float, float);
void draw_matrix(GLenum);
void connect_the_dots(void);

/*  S is a temporary string.  S1 holds the word in progress
    lx, ly, lz hold the coordinates for each letter in S1 */

char S[512];
char S1[512];
char hilite = (char) 0;
int size = 0;
int lx[255], ly[255], lz[255];
char *word_list[256];
int word_count = 0;

char store_S1[512];
int store_size = 0;

int s_x = 0, s_y = 0;		/* cursor tracking */

int MY_CLICK = -1;		/* hilite vs. clicking */
int FROM_AGV = -1;		/* mouse fight */

float spacing = 2.5;
GLfloat line_width = 4.0;
int cube[4][4][4];
int cube2[4][4][4];
int cube3[4][4][4];
int store_cube2[4][4][4];
int store_cube3[4][4][4];

float fr = 0, fg = 0, fb = 1;	/* feedback colors */

StateType state = INTRO;

int main(int argc, char **argv)
{
    glutInit(&argc, argv);
    glutInitWindowSize(W, H);
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH |
			GLUT_MULTISAMPLE);
    root_w = glutCreateWindow(BAFFLE_VERSION);
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glutDisplayFunc(root_display);
    glutReshapeFunc(my_reshape);
    glutPassiveMotionFunc(other_passive);
    hi_w = main_w = glutCreateSubWindow(root_w, 0, 21, W, H - 63);
    glClearColor(br, bg, bb, 0.0);
    glutVisibilityFunc(visible);
    if (use_my_own_idle)
	glutIdleFunc(my_idle);
    agvInit(!use_my_own_idle);
    agvMakeAxesList(AXES);
    my_init();
    glutDisplayFunc(my_display);
    glutPassiveMotionFunc(my_passive);
    file_w = glutCreateSubWindow(root_w, 0, 0, 54, 19);
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glutDisplayFunc(other_display);
    glutPassiveMotionFunc(other_passive);
    make_file_menu();
    options_w = glutCreateSubWindow(root_w, 55, 0, 81, 19);
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glutDisplayFunc(other_display);
    glutPassiveMotionFunc(other_passive);
    make_options_menu();
    erase_w = glutCreateSubWindow(root_w, 137, 0, 63, 19);
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glutDisplayFunc(other_display);
    glutPassiveMotionFunc(other_passive);
    make_erase_menu();
    help_w = glutCreateSubWindow(root_w, 201, 0, 54, 19);
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glutDisplayFunc(other_display);
    glutPassiveMotionFunc(other_passive);
    make_help_menu();
    submit_w = glutCreateSubWindow(root_w, W - 72, H - 19, 72, 19);
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glutDisplayFunc(other_display);
    glutPassiveMotionFunc(other_passive);
    glutMouseFunc(my_submit_mouse);
    store_w = glutCreateSubWindow(root_w, W - 135, H - 19, 63, 19);
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glutDisplayFunc(other_display);
    glutPassiveMotionFunc(other_passive);
    glutMouseFunc(my_store_mouse);
    recall_w = glutCreateSubWindow(root_w, W - 207, H - 19, 72, 19);
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glutDisplayFunc(other_display);
    glutPassiveMotionFunc(other_passive);
    glutMouseFunc(my_recall_mouse);
    clear_w = glutCreateSubWindow(root_w, W - 270, H - 19, 63, 19);
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glutDisplayFunc(other_display);
    glutPassiveMotionFunc(other_passive);
    glutMouseFunc(my_clear_mouse);
    hide_w = glutCreateSubWindow(root_w, 0, H - 19, 54, 19);
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glutDisplayFunc(other_display);
    glutPassiveMotionFunc(other_passive);
    glutMouseFunc(my_hide_mouse);

    word_w = glutCreateSubWindow(root_w, 0, H - 42, W, 19);
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glutDisplayFunc(other_display);
    glutPassiveMotionFunc(other_passive);
    glutMouseFunc(my_word_mouse);
    root2_w = glutCreateWindow("List of Submitted Words");
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glutDisplayFunc(root2_display);
    glutReshapeFunc(root2_reshape);
    glutMainLoop();
    close_dict();
    return 0;
}

void output(int x, int y, char *string)
{
    int len, i;

    glRasterPos2f((GLfloat) x, (GLfloat) y);
    len = (int) strlen(string);
    for (i = 0; i < len; i++) {
	glutBitmapCharacter(GLUT_BITMAP_9_BY_15, (int) string[i]);
    }
}

/* compare strings via pointers */
int pstrcmp(const void *p1, const void *p2)
{
    return strcmp(*(char *const *) p1, *(char *const *) p2);
}

int is_word_in_list(char *s)
{

    int w;
    if (word_count == 0)
	return -1;
    for (w = 0; w < word_count; w++) {
	if (strcmp(s, word_list[w]) == 0)
	    return 1;
    }
    return -1;
}

void show_word_in_progress(void)
{
    int i;
    /*glPushMatrix(); */
    if (word_good == 1)
	glColor3f(0.0, 1.0, 0.0);
    else
	glColor3f(1.0, 0.0, 0.0);
    glRasterPos2f(0.0, 15.0);
    for (i = 0; i < size; i++) {
	glutBitmapCharacter(GLUT_BITMAP_9_BY_15, (int) S1[i]);
    }

    if (hilite > 0) {
	glColor3f(0.0, 1.0, 1.0);
/*
		glRasterPos2f(-xx+2*i*glutBitmapWidth(GLUT_BITMAP_TIMES_ROMAN_24,'W'),-yy+24);
*/
	glutBitmapCharacter(GLUT_BITMAP_9_BY_15, ' ');
	glutBitmapCharacter(GLUT_BITMAP_9_BY_15, '<');
	glutBitmapCharacter(GLUT_BITMAP_9_BY_15, '-');
	glutBitmapCharacter(GLUT_BITMAP_9_BY_15, ' ');
	glutBitmapCharacter(GLUT_BITMAP_9_BY_15, hilite);
    }
    glutPostRedisplay();
    /*glPopMatrix(); */
}

void display_words(void)
{
    int w, i, len = 0, lines = 0, ww = 0, hh = 0;
    if (word_count == 0)
	return;
    for (w = 0; w < word_count; w++)
	if ((int) strlen(word_list[w]) > len)
	    len = (int) strlen(word_list[w]);
    for (w = 0; w < word_count; w++) {
	if ((ww + 1) * 15 > H2) {
	    ww = 0;
	    hh++;
	}
	output(hh * (len + 5) * 9, 15 * (ww + 1), word_list[w]);
	ww++;
    }
}

void my_init(void)
{
    int x, y, z, w, a, d;
    GLfloat mat_ambuse[] = { 1.0, 1.0, 1.0, 1.0 };
    GLfloat mat_specular[] = { 1.0, 1.0, 1.0, 1.0 };
    GLfloat light0_position[] = { 0.6, 0.4, 0.3, 0.0 };

    glLightfv(GL_LIGHT0, GL_POSITION, light0_position);
/*   glEnable(GL_LIGHTING);
   glEnable(GL_LIGHT0); */
    glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, mat_ambuse);
    glMaterialfv(GL_FRONT, GL_SPECULAR, mat_specular);
    glMaterialf(GL_FRONT, GL_SHININESS, 25.0);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    glEnable(GL_NORMALIZE);
    glDepthFunc(GL_LESS);
    glEnable(GL_DEPTH_TEST);
    glShadeModel(GL_SMOOTH);
    glLineWidth(line_width);

    glAlphaFunc(GL_GEQUAL, 0.0625);
    glEnable(GL_ALPHA_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    glFlush();

    for (x = 0; x < 4; x++)
	for (y = 0; y < 4; y++)
	    for (z = 0; z < 4; z++) {
		cube3[x][y][z] = -1;
		cube2[x][y][z] = -1;
		cube[x][y][z] = 65 + rand() % 26;
	    }

    open_dict();

}

void my_idle(void)
{
    if (agvMoving)
	agvMove();
    glutPostRedisplay();
}

void visible(int v)
{
    if (v == GLUT_VISIBLE) {
	if (use_my_own_idle) {
	    glutIdleFunc(my_idle);
	    agvSetAllowIdle(0);
	} else {
	    glutIdleFunc(NULL);
	    agvSetAllowIdle(1);
	}
    } else {
	glutIdleFunc(NULL);
	agvSetAllowIdle(0);
    }
}

void processHits(GLint hits, GLuint buffer[])
{
    unsigned int i, j;
    GLuint ii, jj, kk, names, *ptr;

    int w = glutGetWindow();

    for (ii = 0; ii < 4; ii++)
	for (jj = 0; jj < 4; jj++)
	    for (kk = 0; kk < 4; kk++)
		cube3[ii][jj][kk] = -1;

    hilite = 0;

    glutSetWindow(word_w);
    glutPostRedisplay();
    glutSetWindow(w);
    glutPostRedisplay();

    if (hits == 0)
	return;

#ifdef DO_PRINT
    printf("hits = %d\n", hits);
#endif
    ptr = (GLuint *) buffer;
    for (i = 0; i < hits; i++) {	/*  for each hit  */
	names = *ptr;
#ifdef DO_PRINT
	printf(" number of names for this hit = %d\n", names);
#endif
	ptr++;
#ifdef DO_PRINT
	printf("  z1 is %g;", (float) *ptr / 0x7fffffff);
#endif
	ptr++;
#ifdef DO_PRINT
	printf(" z2 is %g\n", (float) *ptr / 0x7fffffff);
#endif
	ptr++;
#ifdef DO_PRINT
	printf("   names are ");
#endif
	for (j = 0; j < names; j++) {	/*  for each name */
#ifdef DO_PRINT
	    printf("%d ", *ptr);
#endif
	    if (j == 0)		/*  set row and column  */
		ii = *ptr;
	    else {
		if (j == 1)
		    jj = *ptr;
		else if (j == 2)
		    kk = *ptr;
	    }
	    ptr++;
	}
    }
    if (names != 3)
	return;
    if (four4 == 1) {
	if ((kk > 3) || (jj > 3) || (ii > 3))
	    return;
    } else {
	if ((kk > 2) || (jj > 2) || (ii > 2))
	    return;
    }

    if (MY_CLICK == -1) {

	cube3[kk][jj][ii] = 1;

	if (size > 0) {
	    if ((kk == lx[size - 1]) && (jj == ly[size - 1])
		&& (ii == lz[size - 1])) {
	    } else {
		if ((abs(kk - lx[size - 1]) < 2) &&
		    (abs(jj - ly[size - 1]) < 2) &&
		    (abs(ii - lz[size - 1]) < 2) &&
		    (cube2[kk][jj][ii] == -1)
		    ) {
		    hilite = cube[kk][jj][ii];
		}
	    }
	} else {
	    hilite = cube[kk][jj][ii];
	}
    } else {
	if (FROM_AGV == -1)
	    return;
	if (size > 0) {
	    if ((kk == lx[size - 1]) && (jj == ly[size - 1])
		&& (ii == lz[size - 1])) {
		if (cube2[kk][jj][ii] == 1) {
		    S1[--size] = '\0';
		    cube2[kk][jj][ii] = -1;
		}
	    } else {
		if ((abs(kk - lx[size - 1]) < 2) &&
		    (abs(jj - ly[size - 1]) < 2) &&
		    (abs(ii - lz[size - 1]) < 2) &&
		    (cube2[kk][jj][ii] == -1)
		    ) {
		    S1[size] = cube[kk][jj][ii];
		    S1[size + 1] = '\0';
		    lx[size] = kk;
		    ly[size] = jj;
		    lz[size] = ii;
		    size++;
		    cube2[kk][jj][ii] = 1;
		}
	    }
	} else {
	    S1[size] = cube[kk][jj][ii];
	    S1[size + 1] = '\0';
	    lx[size] = kk;
	    ly[size] = jj;
	    lz[size] = ii;
	    size++;
	    cube2[kk][jj][ii] = 1;
	}
    }
    if (size > 0) {
	if (check_word(S1) == -1)
	    word_good = -1;
	else
	    word_good = 1;
    }
}

void root_display(void)
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glutSwapBuffers();
    glFlush();
}

#define BUFSIZE 512

void my_display(void)
{
    static int pick = -1;

    GLuint selectBuf[BUFSIZE];
    GLint hits;
    GLint viewport[4];

    if (FROM_AGV == 1)
	pick = 1;

    if (pick == 1) {
	glGetIntegerv(GL_VIEWPORT, viewport);
	glSelectBuffer(BUFSIZE, selectBuf);
	glRenderMode(GL_SELECT);
    }

    glClearColor(br, bg, bb, 0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();

    if (pick == 1) {
	gluPickMatrix((GLdouble) s_x, (GLdouble) (viewport[3] - s_y),
		      2.0, 2.0, viewport);
    }

    gluPerspective(60.0, 1.0, 1.5, 2000.0);
    agvViewTransform();
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    if (pick == 1)
	draw_matrix(GL_SELECT);
    else
	draw_matrix(GL_RENDER);
    if (axes == 1)
	glCallList(AXES);
    if (connect_line == 1)
	connect_the_dots();
    if (pick != 1)
	glutSwapBuffers();
    glFinish();

    if (pick == 1) {
	hits = glRenderMode(GL_RENDER);
	processHits(hits, selectBuf);
	glutPostRedisplay();
	pick = -1;
    } else
	pick = 1;
}

void other_display(void)
{
    int i = glutGetWindow();
    if (i == hi_w)
	glClearColor(fr, fg, fb, 0);
    else {
	if ( (i == hide_w) && (invis == 1) ) glClearColor(1, 1, 1, 0);
	else glClearColor(0, 0, 0, 0);
    }
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluOrtho2D(0, 1, 19, 0);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    if ( (i == hide_w) && (invis == 1) ) glColor3f(0,0,0); else glColor3f(1, 1, 1);
    if (i == file_w)
	output(0, 15, "[File]");
    else if (i == options_w)
	output(0, 15, "[Options]");
    else if (i == erase_w)
	output(0, 15, "[Erase]");
    else if (i == help_w)
	output(0, 15, "[Help]");
    else if (i == submit_w)
	output(0, 15, "[SUBMIT]");
    else if (i == store_w)
	output(0, 15, "[STORE]");
    else if (i == recall_w)
	output(0, 15, "[RECALL]");
    else if (i == clear_w)
	output(0, 15, "[CLEAR]");
    else if (i == hide_w)
	output(0, 15, "[HIDE]");
    else if (i == word_w)
	show_word_in_progress();
    glutPostRedisplay();
    glutSwapBuffers();
    glFinish();
}

void root2_reshape(int w, int h)
{
    glViewport(0, 0, (GLsizei) w, (GLsizei) h);
    W2 = w;
    H2 = h;
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluOrtho2D(0, w, h, 0);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

void root2_display(void)
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluOrtho2D(0, W2, H2, 0);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    display_words();
    glutSwapBuffers();
}

void my_reshape(int w, int h)
{
    if ((w < 280) || (h < 60)) {
	if (w < 280)
	    w = 280;
	if (h < 60)
	    h = 60;
	glutReshapeWindow(w, h);
	glutPostRedisplay();
	return;
    }
    W = w;
    H = h;
    glViewport(0, 0, (GLsizei) w, (GLsizei) h);
    glutSetWindow(main_w);
    glutPositionWindow(0, 21);
    glutReshapeWindow(w, h - 63);
    glutPostRedisplay();
    glutSetWindow(file_w);
    glutPositionWindow(0, 0);
    glutReshapeWindow(54, 19);
    glutPostRedisplay();
    glutSetWindow(options_w);
    glutPositionWindow(55, 0);
    glutReshapeWindow(81, 19);
    glutPostRedisplay();
    glutSetWindow(erase_w);
    glutPositionWindow(137, 0);
    glutReshapeWindow(63, 19);
    glutSetWindow(help_w);
    glutPositionWindow(201, 0);
    glutReshapeWindow(54, 19);
    glutPostRedisplay();
    glutSetWindow(submit_w);
    glutPositionWindow(w - 72, h - 20);
    glutReshapeWindow(72, 19);
    glutPostRedisplay();
    glutSetWindow(store_w);
    glutPositionWindow(w - 135, h - 20);
    glutReshapeWindow(63, 19);
    glutPostRedisplay();
    glutSetWindow(recall_w);
    glutPositionWindow(w - 207, h - 20);
    glutReshapeWindow(72, 19);
    glutPostRedisplay();
    glutSetWindow(clear_w);
    glutPositionWindow(w - 270, h - 20);
    glutReshapeWindow(63, 19);
    glutPostRedisplay();
    glutSetWindow(hide_w);
    glutPositionWindow(0, h - 20);
    glutReshapeWindow(54,19);
    glutPostRedisplay();
    glutSetWindow(word_w);
    glutPositionWindow(0, h - 40);
    glutReshapeWindow(w, 19);
    glutPostRedisplay();
    glutSetWindow(root2_w);
    glutPostRedisplay();
    glutSetWindow(root_w);
    glutPostRedisplay();
}

void other_passive(int x, int y)
{
    static int j = 0;
    int i = glutGetWindow();
    hi_w = i;
    if (i != j) {
	glutSetWindow(file_w);
	glutPostRedisplay();
	glutSetWindow(options_w);
	glutPostRedisplay();
	glutSetWindow(erase_w);
	glutPostRedisplay();
	glutSetWindow(help_w);
	glutPostRedisplay();
	glutSetWindow(submit_w);
	glutPostRedisplay();
	glutSetWindow(store_w);
	glutPostRedisplay();
	glutSetWindow(recall_w);
	glutPostRedisplay();
	glutSetWindow(clear_w);
	glutPostRedisplay();
	glutSetWindow(hide_w);
	glutPostRedisplay();
	glutSetWindow(word_w);
	glutPostRedisplay();
	glutSetWindow(root2_w);
	glutPostRedisplay();
	j = i;
	glutSetWindow(i);
    }
    glutPostRedisplay();
}

void my_passive(int x, int y)
{
    s_x = x;
    s_y = y;
    other_passive(x, y);
}

void draw_cell(GLenum mode, int name, int x, int y, int z, float r,
	       float g, float b)
{
    int a = 1;
    int i;
    int do_bubble = 0;
    glPushMatrix();
    /* PolarLookFrom(0, -EyeEl, -EyeAz); */
    glRotatef(-EyeAz, 0, 1, 0);
    glRotatef(-EyeEl, 1, 0, 0);
    glRotatef(-EyeEl / 10.0, 0, 0, 1);
    if (mode == GL_SELECT)
	glPushName(name);
    if (cube2[x][y][z] == 1) {
	r = asr;
	g = asg;
	b = asb;
    }
    if (cube3[x][y][z] == 1) {
	r = psr;
	g = psg;
	b = psb;
    }
    if ( ((invis0 == 1) && (z == 0)) ||
	 ((invis1 == 1) && (z == 1)) ||
	 ((invis2 == 1) && (z == 2)) ||
	 ((invis3 == 1) && (z == 3)) ) {
	if (mode == GL_SELECT)
	    glPopName();
	glPopMatrix();
	return;
    }
    if (size > 0) {
	if ((abs(x - lx[size - 1]) < 2) &&
	    (abs(y - ly[size - 1]) < 2) && (abs(z - lz[size - 1]) < 2)) {
	    if (bubble == 1)
		do_bubble = 1;
	} else {
	    if (invis == 1) {
		if (mode == GL_SELECT)
		    glPopName();
		glPopMatrix();
		return;
	    }
	    if (r == 1)
		r = 0.4;
	    if (g == 1)
		g = 0.4;
	    if (b == 1)
		b = 0.4;
	}
    }
    glColor4f(r, g, b, 1);
    switch (font) {
    case -1:
	glRasterPos2f(0, 0);
	glutBitmapCharacter(GLUT_BITMAP_TIMES_ROMAN_24, cube[x][y][z]);
	break;
    case -2:
	glRasterPos2f(0, 0);
	glutBitmapCharacter(GLUT_BITMAP_HELVETICA_18, cube[x][y][z]);
	break;
    case -3:
	glRasterPos2f(0, 0);
	glPushMatrix();
	glScalef(0.01, 0.01, 1);
	glutStrokeCharacter(GLUT_STROKE_ROMAN, cube[x][y][z]);
	glPopMatrix();
	break;
    case 0:
	break;
    }
    if (coord == 1) {
	sprintf(S, "(%i,%i,%i)", x, y, z);
	output(0, 0, S);
    }
    if ((do_bubble == 1) || (mode == GL_SELECT) || (rect == 1)
	|| (cube3[x][y][z] == 1)) {
	if (do_bubble == 1)
	    glColor4f(0.5, 0.5, 0.5, 0.2);
	else
	    glColor4f(1, 1, 1, 0.2);
	glLineWidth(1);
	if (font == -3) {
	    glTranslatef(0.5, 0.5, 0.0);
	    glutSolidSphere(0.9, 16, 16);
	} else {
	    glTranslatef(0.25, 0.25, 0.0);
	    glutSolidSphere(0.6, 16, 16);
	}
	glLineWidth(line_width);
    }
    if (mode == GL_SELECT)
	glPopName();
    glPopMatrix();
}

void draw_row(GLenum mode, int y, int z, float r, float g, float b)
{
    if ((EyeAz < 360) && (EyeAz > 180)) {
	glPushMatrix();
	glTranslatef(-FONT_WIDTH * spacing, 0, 0);
	draw_cell(mode, 0, 0, y, z, r, g, b);
	glPopMatrix();
	glPushMatrix();
	draw_cell(mode, 1, 1, y, z, r, g, b);
	glPopMatrix();
	glPushMatrix();
	glTranslatef(FONT_WIDTH * spacing, 0, 0);
	draw_cell(mode, 2, 2, y, z, r, g, b);
	glPopMatrix();
	if (four4 == 1) {
	    glPushMatrix();
	    glTranslatef(FONT_WIDTH * 2 * spacing, 0, 0);
	    draw_cell(mode, 3, 3, y, z, r, g, b);
	    glPopMatrix();
	}
    } else {
	if (four4 == 1) {
	    glPushMatrix();
	    glTranslatef(FONT_WIDTH * 2 * spacing, 0, 0);
	    draw_cell(mode, 3, 3, y, z, r, g, b);
	    glPopMatrix();
	}
	glPushMatrix();
	glTranslatef(FONT_WIDTH * spacing, 0, 0);
	draw_cell(mode, 2, 2, y, z, r, g, b);
	glPopMatrix();
	glPushMatrix();
	draw_cell(mode, 1, 1, y, z, r, g, b);
	glPopMatrix();
	glPushMatrix();
	glTranslatef(-FONT_WIDTH * spacing, 0, 0);
	draw_cell(mode, 0, 0, y, z, r, g, b);
	glPopMatrix();
    }
}

void draw_slice(GLenum mode, int z, float r, float g, float b)
{
    if (EyeEl > 0) {
	glPushMatrix();
	glTranslatef(0, -FONT_HEIGHT * spacing, 0);
	if (mode == GL_SELECT)
	    glPushName(0);
	draw_row(mode, 0, z, r, g, b);
	if (mode == GL_SELECT)
	    glPopName();
	glPopMatrix();
	glPushMatrix();
	if (mode == GL_SELECT)
	    glPushName(1);
	draw_row(mode, 1, z, r, g, b);
	if (mode == GL_SELECT)
	    glPopName();
	glPopMatrix();
	glPushMatrix();
	glTranslatef(0, FONT_HEIGHT * spacing, 0);
	if (mode == GL_SELECT)
	    glPushName(2);
	draw_row(mode, 2, z, r, g, b);
	if (mode == GL_SELECT)
	    glPopName();
	glPopMatrix();
	if (four4 == 1) {
	    glPushMatrix();
	    glTranslatef(0, FONT_HEIGHT * 2 * spacing, 0);
	    if (mode == GL_SELECT)
		glPushName(3);
	    draw_row(mode, 3, z, r, g, b);
	    if (mode == GL_SELECT)
		glPopName();
	    glPopMatrix();
	}
    } else {
	if (four4 == 1) {
	    glPushMatrix();
	    glTranslatef(0, FONT_HEIGHT * 2 * spacing, 0);
	    if (mode == GL_SELECT)
		glPushName(3);
	    draw_row(mode, 3, z, r, g, b);
	    if (mode == GL_SELECT)
		glPopName();
	    glPopMatrix();
	}
	glPushMatrix();
	glTranslatef(0, FONT_HEIGHT * spacing, 0);
	if (mode == GL_SELECT)
	    glPushName(2);
	draw_row(mode, 2, z, r, g, b);
	if (mode == GL_SELECT)
	    glPopName();
	glPopMatrix();
	glPushMatrix();
	if (mode == GL_SELECT)
	    glPushName(1);
	draw_row(mode, 1, z, r, g, b);
	if (mode == GL_SELECT)
	    glPopName();
	glPopMatrix();
	glPushMatrix();
	glTranslatef(0, -FONT_HEIGHT * spacing, 0);
	if (mode == GL_SELECT)
	    glPushName(0);
	draw_row(mode, 0, z, r, g, b);
	if (mode == GL_SELECT)
	    glPopName();
	glPopMatrix();
    }
}

void draw_matrix(GLenum mode)
{
    int m;
    int x1, x2, y1, y2, z1, z2;

    glColor3f(1, 1, 1);

    glPushMatrix();

    if (four4 == 1) {
	glTranslatef(-FONT_WIDTH * spacing / 2,
		     -FONT_HEIGHT * spacing / 2,
		     -FONT_WIDTH * spacing / 2);
	m = 2;
    } else
	m = 1;
    if (box == 1) {
	glLineWidth(1);
	glEnable(GL_LINE_STIPPLE);
	glLineStipple(1, 0x0101);
	if (size > 0) {
	    x1 = lx[size - 1] - 1;
	    if (x1 < 0)
		x1 = 0;
	    x2 = lx[size - 1] + 1;
	    if (x2 == m + 2)
		x2--;
	    y1 = ly[size - 1] - 1;
	    if (y1 < 0)
		y1 = 0;
	    y2 = ly[size - 1] + 1;
	    if (y2 == m + 2)
		y2--;
	    z1 = lz[size - 1] - 1;
	    if (z1 < 0)
		z1 = 0;
	    z2 = lz[size - 1] + 1;
	    if (z2 == m + 2)
		z2--;
	    /* printf("%i %i , %i %i , %i %i \n",x1,x2,y1,y2,z1,z2); */
	    glBegin(GL_LINE_LOOP);
	    glVertex3f((x1 - 1) * spacing - FONT_WIDTH,
		       (y1 - 1) * spacing - FONT_HEIGHT,
		       (z1 - 1) * spacing - FONT_HEIGHT);
	    glVertex3f((x2 - 1) * spacing + FONT_WIDTH,
		       (y1 - 1) * spacing - FONT_HEIGHT,
		       (z1 - 1) * spacing - FONT_HEIGHT);
	    glVertex3f((x2 - 1) * spacing + FONT_WIDTH,
		       (y2 - 1) * spacing + FONT_HEIGHT,
		       (z1 - 1) * spacing - FONT_HEIGHT);
	    glVertex3f((x1 - 1) * spacing - FONT_WIDTH,
		       (y2 - 1) * spacing + FONT_HEIGHT,
		       (z1 - 1) * spacing - FONT_HEIGHT);
	    glEnd();
	    glBegin(GL_LINE_LOOP);
	    glVertex3f((x1 - 1) * spacing - FONT_WIDTH,
		       (y1 - 1) * spacing - FONT_HEIGHT,
		       (z2 - 1) * spacing + FONT_HEIGHT);
	    glVertex3f((x2 - 1) * spacing + FONT_WIDTH,
		       (y1 - 1) * spacing - FONT_HEIGHT,
		       (z2 - 1) * spacing + FONT_HEIGHT);
	    glVertex3f((x2 - 1) * spacing + FONT_WIDTH,
		       (y2 - 1) * spacing + FONT_HEIGHT,
		       (z2 - 1) * spacing + FONT_HEIGHT);
	    glVertex3f((x1 - 1) * spacing - FONT_WIDTH,
		       (y2 - 1) * spacing + FONT_HEIGHT,
		       (z2 - 1) * spacing + FONT_HEIGHT);
	    glEnd();
	    glBegin(GL_LINES);
	    glVertex3f((x1 - 1) * spacing - FONT_WIDTH,
		       (y1 - 1) * spacing - FONT_HEIGHT,
		       (z1 - 1) * spacing - FONT_HEIGHT);
	    glVertex3f((x1 - 1) * spacing - FONT_WIDTH,
		       (y1 - 1) * spacing - FONT_HEIGHT,
		       (z2 - 1) * spacing + FONT_HEIGHT);
	    glVertex3f((x2 - 1) * spacing + FONT_WIDTH,
		       (y1 - 1) * spacing - FONT_HEIGHT,
		       (z1 - 1) * spacing - FONT_HEIGHT);
	    glVertex3f((x2 - 1) * spacing + FONT_WIDTH,
		       (y1 - 1) * spacing - FONT_HEIGHT,
		       (z2 - 1) * spacing + FONT_HEIGHT);
	    glVertex3f((x2 - 1) * spacing + FONT_WIDTH,
		       (y2 - 1) * spacing + FONT_HEIGHT,
		       (z1 - 1) * spacing - FONT_HEIGHT);
	    glVertex3f((x2 - 1) * spacing + FONT_WIDTH,
		       (y2 - 1) * spacing + FONT_HEIGHT,
		       (z2 - 1) * spacing + FONT_HEIGHT);
	    glVertex3f((x1 - 1) * spacing - FONT_WIDTH,
		       (y2 - 1) * spacing + FONT_HEIGHT,
		       (z1 - 1) * spacing - FONT_HEIGHT);
	    glVertex3f((x1 - 1) * spacing - FONT_WIDTH,
		       (y2 - 1) * spacing + FONT_HEIGHT,
		       (z2 - 1) * spacing + FONT_HEIGHT);
	    glEnd();

	} else {
	    glBegin(GL_LINE_LOOP);
	    glVertex3f(-FONT_WIDTH * spacing - FONT_WIDTH,
		       -FONT_HEIGHT * spacing - FONT_HEIGHT,
		       -FONT_HEIGHT * spacing - FONT_HEIGHT);
	    glVertex3f(m * FONT_WIDTH * spacing + FONT_WIDTH,
		       -FONT_HEIGHT * spacing - FONT_HEIGHT,
		       -FONT_HEIGHT * spacing - FONT_HEIGHT);
	    glVertex3f(m * FONT_WIDTH * spacing + FONT_WIDTH,
		       m * FONT_HEIGHT * spacing + FONT_HEIGHT,
		       -FONT_HEIGHT * spacing - FONT_HEIGHT);
	    glVertex3f(-FONT_WIDTH * spacing - FONT_WIDTH,
		       m * FONT_HEIGHT * spacing + FONT_HEIGHT,
		       -FONT_HEIGHT * spacing - FONT_HEIGHT);
	    glEnd();
	    glBegin(GL_LINE_LOOP);
	    glVertex3f(-FONT_WIDTH * spacing - FONT_WIDTH,
		       -FONT_HEIGHT * spacing - FONT_HEIGHT,
		       m * FONT_HEIGHT * spacing + FONT_HEIGHT);
	    glVertex3f(m * FONT_WIDTH * spacing + FONT_WIDTH,
		       -FONT_HEIGHT * spacing - FONT_HEIGHT,
		       m * FONT_HEIGHT * spacing + FONT_HEIGHT);
	    glVertex3f(m * FONT_WIDTH * spacing + FONT_WIDTH,
		       m * FONT_HEIGHT * spacing + FONT_HEIGHT,
		       m * FONT_HEIGHT * spacing + FONT_HEIGHT);
	    glVertex3f(-FONT_WIDTH * spacing - FONT_WIDTH,
		       m * FONT_HEIGHT * spacing + FONT_HEIGHT,
		       m * FONT_HEIGHT * spacing + FONT_HEIGHT);
	    glEnd();
	    glBegin(GL_LINES);
	    glVertex3f(-FONT_WIDTH * spacing - FONT_WIDTH,
		       -FONT_HEIGHT * spacing - FONT_HEIGHT,
		       -FONT_HEIGHT * spacing - FONT_HEIGHT);
	    glVertex3f(-FONT_WIDTH * spacing - FONT_WIDTH,
		       -FONT_HEIGHT * spacing - FONT_HEIGHT,
		       m * FONT_HEIGHT * spacing + FONT_HEIGHT);
	    glVertex3f(m * FONT_WIDTH * spacing + FONT_WIDTH,
		       -FONT_HEIGHT * spacing - FONT_HEIGHT,
		       -FONT_HEIGHT * spacing - FONT_HEIGHT);
	    glVertex3f(m * FONT_WIDTH * spacing + FONT_WIDTH,
		       -FONT_HEIGHT * spacing - FONT_HEIGHT,
		       m * FONT_HEIGHT * spacing + FONT_HEIGHT);
	    glVertex3f(m * FONT_WIDTH * spacing + FONT_WIDTH,
		       m * FONT_HEIGHT * spacing + FONT_HEIGHT,
		       -FONT_HEIGHT * spacing - FONT_HEIGHT);
	    glVertex3f(m * FONT_WIDTH * spacing + FONT_WIDTH,
		       m * FONT_HEIGHT * spacing + FONT_HEIGHT,
		       m * FONT_HEIGHT * spacing + FONT_HEIGHT);
	    glVertex3f(-FONT_WIDTH * spacing - FONT_WIDTH,
		       m * FONT_HEIGHT * spacing + FONT_HEIGHT,
		       -FONT_HEIGHT * spacing - FONT_HEIGHT);
	    glVertex3f(-FONT_WIDTH * spacing - FONT_WIDTH,
		       m * FONT_HEIGHT * spacing + FONT_HEIGHT,
		       m * FONT_HEIGHT * spacing + FONT_HEIGHT);
	    glEnd();
	}
	glDisable(GL_LINE_STIPPLE);
	glLineWidth(line_width);
    }

    if ((EyeAz < 90) || (EyeAz > 270)) {
	glPushMatrix();
	glTranslatef(0, 0, -FONT_HEIGHT * spacing);
	if (mode == GL_SELECT) {
	    glInitNames();
	    glPushName(0);
	    glLoadName(0);
	}
	if (color == 1)
	    glColor3f(s1r, s1g, s1b);
	draw_slice(mode, 0, s1r, s1g, s1b);
	glColor3f(1, 1, 1);
	glPopMatrix();
	glPushMatrix();
	if (mode == GL_SELECT)
	    glLoadName(1);
	if (color == 1)
	    glColor3f(s2r, s2g, s2b);
	draw_slice(mode, 1, s2r, s2g, s2b);
	glColor3f(1, 1, 1);
	glPopMatrix();
	glPushMatrix();
	glTranslatef(0, 0, FONT_HEIGHT * spacing);
	if (mode == GL_SELECT)
	    glLoadName(2);
	if (color == 1)
	    glColor3f(s3r, s3g, s3b);
	draw_slice(mode, 2, s3r, s3g, s3b);
	glColor3f(1, 1, 1);
	glPopMatrix();
	if (four4 == 1) {
	    glPushMatrix();
	    glTranslatef(0, 0, FONT_HEIGHT * 2 * spacing);
	    if (mode == GL_SELECT)
		glLoadName(3);
	    if (color == 1)
		glColor3f(s4r, s4g, s4b);
	    draw_slice(mode, 3, s4r, s4g, s4b);
	    glColor3f(1, 1, 1);
	    glPopMatrix();
	}
    } else {
	if (mode == GL_SELECT) {
	    glInitNames();
	    glPushName(0);
	}
	if (four4 == 1) {
	    glPushMatrix();
	    glTranslatef(0, 0, FONT_HEIGHT * 2 * spacing);
	    if (mode == GL_SELECT)
		glLoadName(3);
	    if (color == 1)
		glColor3f(s4r, s4g, s4b);
	    draw_slice(mode, 3, s4r, s4g, s4b);
	    glColor3f(1, 1, 1);
	    glPopMatrix();
	}
	glPushMatrix();
	glTranslatef(0, 0, FONT_HEIGHT * spacing);
	if (mode == GL_SELECT)
	    glLoadName(2);
	if (color == 1)
	    glColor3f(s3r, s3g, s3b);
	draw_slice(mode, 2, s3r, s3g, s3b);
	glColor3f(1, 1, 1);
	glPopMatrix();
	glPushMatrix();
	if (mode == GL_SELECT)
	    glLoadName(1);
	if (color == 1)
	    glColor3f(s2r, s2g, s2b);
	draw_slice(mode, 1, s2r, s2g, s2b);
	glColor3f(1, 1, 1);
	glPopMatrix();
	glPushMatrix();
	glTranslatef(0, 0, -FONT_HEIGHT * spacing);
	if (color == 1)
	    glColor3f(s1r, s1g, s1b);
	if (mode == GL_SELECT)
	    glLoadName(0);
	draw_slice(mode, 0, s1r, s1g, s1b);
	glColor3f(1, 1, 1);
	glPopMatrix();
    }
    glPopMatrix();
}

void my_submit_mouse(int b, int s, int x, int y)
{
    int z;
    int w = glutGetWindow();
    glutSetWindow(main_w);
    glutPostRedisplay();
    glutSetWindow(w);
    glutPostRedisplay();
    if (s == GLUT_DOWN) {
	fr = 1;
	fg = 0;
	fb = 0;
	if ((size > 0) && (is_word_in_list(S1) == -1)) {
	    fr = 0;
	    fg = 1;
	    fb = 0;
	    if (check_word(S1) == -1)
		fr = 1;
	    word_list[word_count++] = strdup(S1);
	    for (x = 0; x < 4; x++)
		for (y = 0; y < 4; y++)
		    for (z = 0; z < 4; z++) {
			cube2[x][y][z] = -1;
			cube3[x][y][z] = -1;
		    }
	    S1[0] = '\0';
	    size = 0;
	    qsort(word_list, word_count, sizeof(word_list[0]), pstrcmp);
	    glutSetWindow(root2_w);
	    display_words();
	    glutPostRedisplay();
	    glutSetWindow(w);
	    unmake_erase_menu();
	    glutSetWindow(erase_w);
	    make_erase_menu();
	    glutSetWindow(w);
	}
    } else {
	fr = 0;
	fg = 0;
	fb = 1;
    }
}

void my_clear_mouse(int b, int s, int x, int y)
{
    int z;
    int w = glutGetWindow();
    glutSetWindow(main_w);
    glutPostRedisplay();
    glutSetWindow(w);
    glutPostRedisplay();
    if (s == GLUT_DOWN) {
	fr = 1;
	fg = 0;
	fb = 0;
	if (size < 1)
	    return;
	fr = 0;
	fg = 1;
	fb = 0;
	for (x = 0; x < 4; x++)
	    for (y = 0; y < 4; y++)
		for (z = 0; z < 4; z++) {
		    cube2[x][y][z] = -1;
		    cube3[x][y][z] = -1;
		}
	S1[0] = '\0';
	size = 0;
    } else {
	fr = 0;
	fg = 0;
	fb = 1;
    }
}

void my_word_mouse(int b, int s, int x, int y)
{
    int z;
    int w = glutGetWindow();
    glutSetWindow(main_w);
    glutPostRedisplay();
    glutSetWindow(w);
    glutPostRedisplay();
}

void my_hide_mouse(int b, int s, int x, int y)
{
    int z;
    int w = glutGetWindow();
    glutSetWindow(main_w);
    glutPostRedisplay();
    glutSetWindow(w);
    glutPostRedisplay();
    if (s == GLUT_DOWN) {
	invis = -invis;
	fr = 0;
	fg = 1;
	fb = 0;
    } else {
	fr = 0;
	fg = 0;
	fb = 1;
    }
}


void my_store_mouse(int b, int s, int x, int y)
{
    int z;
    int w = glutGetWindow();
    glutSetWindow(main_w);
    glutPostRedisplay();
    glutSetWindow(w);
    glutPostRedisplay();
    if (s == GLUT_DOWN) {
	fr = 1;
	fg = 0;
	fb = 0;
	if (size < 1)
	    return;
	fr = 0;
	fg = 1;
	fb = 0;
	for (x = 0; x < 4; x++)
	    for (y = 0; y < 4; y++)
		for (z = 0; z < 4; z++) {
		    store_cube2[x][y][z] = cube2[x][y][z];
		    store_cube3[x][y][z] = cube3[x][y][z];
		}
	/* printf("Storing ->"); */
	for (x = 0; x <= size; x++) {
	    store_S1[x] = S1[x];	/* printf("%c",S1[x]); */
	}
	/* printf("<-\n"); */
	store_size = size;
    } else {
	fr = 0;
	fg = 0;
	fb = 1;
    }
}

void my_recall_mouse(int b, int s, int x, int y)
{
    int z;
    int w = glutGetWindow();
    glutSetWindow(main_w);
    glutPostRedisplay();
    glutSetWindow(w);
    glutPostRedisplay();
    if (s == GLUT_DOWN) {
	fr = 1;
	fg = 0;
	fb = 0;
	if (store_size < 1)
	    return;
	fr = 0;
	fg = 1;
	fb = 0;
	for (x = 0; x < 4; x++)
	    for (y = 0; y < 4; y++)
		for (z = 0; z < 4; z++) {
		    cube2[x][y][z] = store_cube2[x][y][z];
		    cube3[x][y][z] = store_cube3[x][y][z];
		}
	for (x = 0; x <= size; x++)
	    S1[x] = store_S1[x];
	size = store_size;
/*
		printf("Restored ->%s<- \n",S1);
*/
    } else {
	fr = 0;
	fg = 0;
	fb = 1;
    }
}

void connect_the_dots(void)
{
    int i;
    if (size == 0)
	return;
    glPushMatrix();
    if (four4 == 1)
	glTranslatef(-FONT_WIDTH * spacing / 2,
		     -FONT_HEIGHT * spacing / 2,
		     -FONT_WIDTH * spacing / 2);
    glEnable(GL_LINE_STIPPLE);
    glColor4f(1, 1, 1, 1);
    glLineStipple(1, 0x00FF);
    glBegin(GL_LINE_STRIP);
    for (i = 0; i < size; i++) {
	glVertex3f((lx[i] - 1) * FONT_WIDTH * spacing,
		   (ly[i] - 1) * FONT_HEIGHT * spacing,
		   (lz[i] - 1) * FONT_HEIGHT * spacing);
    }
    glEnd();
    glDisable(GL_LINE_STIPPLE);
    glColor3f(1, 1, 1);
    glPopMatrix();
}
