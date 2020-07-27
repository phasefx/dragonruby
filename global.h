#ifndef __global_h__
#define __global_h__

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <GL/glut.h>

extern int main_w;
extern int root2_w;

extern short int box, color, coord, rect, font, ortho, axes, four4,
    connect_line, roman, threedee, bubble, invis;
extern float spacing;
extern GLfloat line_width;

extern int s_x, s_y;

extern GLfloat EyeEl;
extern GLfloat EyeAz;
extern GLfloat EyeDist;
extern GLfloat AzSpin;
extern GLfloat ElSpin;

extern int MY_CLICK;
extern int FROM_AGV;

extern char *word_list[256];
extern int word_count;

void my_display(void);
int pstrcmp(const void *, const void *);

extern float br, bg, bb, s1r, s1g, s1b, s2r, s2g, s2b, s3r, s3g, s3b,
    s4r, s4g, s4b, asr, asg, asb, psr, psg, psb;

typedef enum { NORMAL, INTRO, ROUND1, ROUND2, ROUND3 } StateType;
extern StateType state;

#endif
