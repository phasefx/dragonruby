#include "global.h"
#include "menu.h"

const char last[] = "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";

int erase_m;
int theme_m;

void erase_menu(int);

void make_theme_menu(void);
void theme_menu(int);

void empty_menu(int id)
{
}

void time_menu(int id)
{

}

void size_menu(int id)
{
    if (id == 1)
	four4 = -1;
    else if (id == 2)
	four4 = 1;
}

void round_menu(int id)
{

}

void word_menu(int id)
{

}

void color_menu2(int id)
{
    switch (id) {
    case 1:
	br = 1.0;
	bg = 0.0;
	bb = 0.0;
	break;
    case 2:
	br = 0.0;
	bg = 1.0;
	bb = 0.0;
	break;
    case 3:
	br = 0.0;
	bg = 0.0;
	bb = 1.0;
	break;
    case 4:
	br = 0.0;
	bg = 1.0;
	bb = 1.0;
	break;
    case 5:
	br = 1.0;
	bg = 0.0;
	bb = 1.0;
	break;
    case 6:
	br = 1.0;
	bg = 1.0;
	bb = 0.0;
	break;
    case 7:
	br = 1.0;
	bg = 1.0;
	bb = 1.0;
	break;
    case 8:
	br = 0.0;
	bg = 0.0;
	bb = 0.0;
	break;
    }
}

void red_menu(int id)
{
    switch (id) {
    case 0:
	br = 0;
	break;
    case 1:
	br = .1;
	break;
    case 2:
	br = .2;
	break;
    case 3:
	br = .3;
	break;
    case 4:
	br = .4;
	break;
    case 5:
	br = .5;
	break;
    case 6:
	br = .6;
	break;
    case 7:
	br = .7;
	break;
    case 8:
	br = .8;
	break;
    case 9:
	br = .9;
	break;
    case 10:
	br = 1;
	break;
    }
}

void green_menu(int id)
{
    switch (id) {
    case 0:
	bg = 0;
	break;
    case 1:
	bg = .1;
	break;
    case 2:
	bg = .2;
	break;
    case 3:
	bg = .3;
	break;
    case 4:
	bg = .4;
	break;
    case 5:
	bg = .5;
	break;
    case 6:
	bg = .6;
	break;
    case 7:
	bg = .7;
	break;
    case 8:
	bg = .8;
	break;
    case 9:
	bg = .9;
	break;
    case 10:
	bg = 1;
	break;
    }
}

void blue_menu(int id)
{
    switch (id) {
    case 0:
	bb = 0;
	break;
    case 1:
	bb = .1;
	break;
    case 2:
	bb = .2;
	break;
    case 3:
	bb = .3;
	break;
    case 4:
	bb = .4;
	break;
    case 5:
	bb = .5;
	break;
    case 6:
	bb = .6;
	break;
    case 7:
	bb = .7;
	break;
    case 8:
	bb = .8;
	break;
    case 9:
	bb = .9;
	break;
    case 10:
	bb = 1;
	break;
    }
}

void color_menu2_s1(int id)
{
    switch (id) {
    case 1:
	s1r = 1.0;
	s1g = 0.0;
	s1b = 0.0;
	break;
    case 2:
	s1r = 0.0;
	s1g = 1.0;
	s1b = 0.0;
	break;
    case 3:
	s1r = 0.0;
	s1g = 0.0;
	s1b = 1.0;
	break;
    case 4:
	s1r = 0.0;
	s1g = 1.0;
	s1b = 1.0;
	break;
    case 5:
	s1r = 1.0;
	s1g = 0.0;
	s1b = 1.0;
	break;
    case 6:
	s1r = 1.0;
	s1g = 1.0;
	s1b = 0.0;
	break;
    case 7:
	s1r = 1.0;
	s1g = 1.0;
	s1b = 1.0;
	break;
    case 8:
	s1r = 0.0;
	s1g = 0.0;
	s1b = 0.0;
	break;
    }
}

void red_menu_s1(int id)
{
    switch (id) {
    case 0:
	s1r = 0;
	break;
    case 1:
	s1r = .1;
	break;
    case 2:
	s1r = .2;
	break;
    case 3:
	s1r = .3;
	break;
    case 4:
	s1r = .4;
	break;
    case 5:
	s1r = .5;
	break;
    case 6:
	s1r = .6;
	break;
    case 7:
	s1r = .7;
	break;
    case 8:
	s1r = .8;
	break;
    case 9:
	s1r = .9;
	break;
    case 10:
	s1r = 1;
	break;
    }
}

void green_menu_s1(int id)
{
    switch (id) {
    case 0:
	s1g = 0;
	break;
    case 1:
	s1g = .1;
	break;
    case 2:
	s1g = .2;
	break;
    case 3:
	s1g = .3;
	break;
    case 4:
	s1g = .4;
	break;
    case 5:
	s1g = .5;
	break;
    case 6:
	s1g = .6;
	break;
    case 7:
	s1g = .7;
	break;
    case 8:
	s1g = .8;
	break;
    case 9:
	s1g = .9;
	break;
    case 10:
	s1g = 1;
	break;
    }
}

void blue_menu_s1(int id)
{
    switch (id) {
    case 0:
	s1b = 0;
	break;
    case 1:
	s1b = .1;
	break;
    case 2:
	s1b = .2;
	break;
    case 3:
	s1b = .3;
	break;
    case 4:
	s1b = .4;
	break;
    case 5:
	s1b = .5;
	break;
    case 6:
	s1b = .6;
	break;
    case 7:
	s1b = .7;
	break;
    case 8:
	s1b = .8;
	break;
    case 9:
	s1b = .9;
	break;
    case 10:
	s1b = 1;
	break;
    }
}

void color_menu2_s2(int id)
{
    switch (id) {
    case 1:
	s2r = 1.0;
	s2g = 0.0;
	s2b = 0.0;
	break;
    case 2:
	s2r = 0.0;
	s2g = 1.0;
	s2b = 0.0;
	break;
    case 3:
	s2r = 0.0;
	s2g = 0.0;
	s2b = 1.0;
	break;
    case 4:
	s2r = 0.0;
	s2g = 1.0;
	s2b = 1.0;
	break;
    case 5:
	s2r = 1.0;
	s2g = 0.0;
	s2b = 1.0;
	break;
    case 6:
	s2r = 1.0;
	s2g = 1.0;
	s2b = 0.0;
	break;
    case 7:
	s2r = 1.0;
	s2g = 1.0;
	s2b = 1.0;
	break;
    case 8:
	s2r = 0.0;
	s2g = 0.0;
	s2b = 0.0;
	break;
    }
}

void red_menu_s2(int id)
{
    switch (id) {
    case 0:
	s2r = 0;
	break;
    case 1:
	s2r = .1;
	break;
    case 2:
	s2r = .2;
	break;
    case 3:
	s2r = .3;
	break;
    case 4:
	s2r = .4;
	break;
    case 5:
	s2r = .5;
	break;
    case 6:
	s2r = .6;
	break;
    case 7:
	s2r = .7;
	break;
    case 8:
	s2r = .8;
	break;
    case 9:
	s2r = .9;
	break;
    case 10:
	s2r = 1;
	break;
    }
}

void green_menu_s2(int id)
{
    switch (id) {
    case 0:
	s2g = 0;
	break;
    case 1:
	s2g = .1;
	break;
    case 2:
	s2g = .2;
	break;
    case 3:
	s2g = .3;
	break;
    case 4:
	s2g = .4;
	break;
    case 5:
	s2g = .5;
	break;
    case 6:
	s2g = .6;
	break;
    case 7:
	s2g = .7;
	break;
    case 8:
	s2g = .8;
	break;
    case 9:
	s2g = .9;
	break;
    case 10:
	s2g = 1;
	break;
    }
}

void blue_menu_s2(int id)
{
    switch (id) {
    case 0:
	s2b = 0;
	break;
    case 1:
	s2b = .1;
	break;
    case 2:
	s2b = .2;
	break;
    case 3:
	s2b = .3;
	break;
    case 4:
	s2b = .4;
	break;
    case 5:
	s2b = .5;
	break;
    case 6:
	s2b = .6;
	break;
    case 7:
	s2b = .7;
	break;
    case 8:
	s2b = .8;
	break;
    case 9:
	s2b = .9;
	break;
    case 10:
	s2b = 1;
	break;
    }
}

void color_menu2_s3(int id)
{
    switch (id) {
    case 1:
	s3r = 1.0;
	s3g = 0.0;
	s3b = 0.0;
	break;
    case 2:
	s3r = 0.0;
	s3g = 1.0;
	s3b = 0.0;
	break;
    case 3:
	s3r = 0.0;
	s3g = 0.0;
	s3b = 1.0;
	break;
    case 4:
	s3r = 0.0;
	s3g = 1.0;
	s3b = 1.0;
	break;
    case 5:
	s3r = 1.0;
	s3g = 0.0;
	s3b = 1.0;
	break;
    case 6:
	s3r = 1.0;
	s3g = 1.0;
	s3b = 0.0;
	break;
    case 7:
	s3r = 1.0;
	s3g = 1.0;
	s3b = 1.0;
	break;
    case 8:
	s3r = 0.0;
	s3g = 0.0;
	s3b = 0.0;
	break;
    }
}

void red_menu_s3(int id)
{
    switch (id) {
    case 0:
	s3r = 0;
	break;
    case 1:
	s3r = .1;
	break;
    case 2:
	s3r = .2;
	break;
    case 3:
	s3r = .3;
	break;
    case 4:
	s3r = .4;
	break;
    case 5:
	s3r = .5;
	break;
    case 6:
	s3r = .6;
	break;
    case 7:
	s3r = .7;
	break;
    case 8:
	s3r = .8;
	break;
    case 9:
	s3r = .9;
	break;
    case 10:
	s3r = 1;
	break;
    }
}

void green_menu_s3(int id)
{
    switch (id) {
    case 0:
	s3g = 0;
	break;
    case 1:
	s3g = .1;
	break;
    case 2:
	s3g = .2;
	break;
    case 3:
	s3g = .3;
	break;
    case 4:
	s3g = .4;
	break;
    case 5:
	s3g = .5;
	break;
    case 6:
	s3g = .6;
	break;
    case 7:
	s3g = .7;
	break;
    case 8:
	s3g = .8;
	break;
    case 9:
	s3g = .9;
	break;
    case 10:
	s3g = 1;
	break;
    }
}

void blue_menu_s3(int id)
{
    switch (id) {
    case 0:
	s3b = 0;
	break;
    case 1:
	s3b = .1;
	break;
    case 2:
	s3b = .2;
	break;
    case 3:
	s3b = .3;
	break;
    case 4:
	s3b = .4;
	break;
    case 5:
	s3b = .5;
	break;
    case 6:
	s3b = .6;
	break;
    case 7:
	s3b = .7;
	break;
    case 8:
	s3b = .8;
	break;
    case 9:
	s3b = .9;
	break;
    case 10:
	s3b = 1;
	break;
    }
}

void color_menu2_s4(int id)
{
    switch (id) {
    case 1:
	s4r = 1.0;
	s4g = 0.0;
	s4b = 0.0;
	break;
    case 2:
	s4r = 0.0;
	s4g = 1.0;
	s4b = 0.0;
	break;
    case 3:
	s4r = 0.0;
	s4g = 0.0;
	s4b = 1.0;
	break;
    case 4:
	s4r = 0.0;
	s4g = 1.0;
	s4b = 1.0;
	break;
    case 5:
	s4r = 1.0;
	s4g = 0.0;
	s4b = 1.0;
	break;
    case 6:
	s4r = 1.0;
	s4g = 1.0;
	s4b = 0.0;
	break;
    case 7:
	s4r = 1.0;
	s4g = 1.0;
	s4b = 1.0;
	break;
    case 8:
	s4r = 0.0;
	s4g = 0.0;
	s4b = 0.0;
	break;
    }
}

void red_menu_s4(int id)
{
    switch (id) {
    case 0:
	s4r = 0;
	break;
    case 1:
	s4r = .1;
	break;
    case 2:
	s4r = .2;
	break;
    case 3:
	s4r = .3;
	break;
    case 4:
	s4r = .4;
	break;
    case 5:
	s4r = .5;
	break;
    case 6:
	s4r = .6;
	break;
    case 7:
	s4r = .7;
	break;
    case 8:
	s4r = .8;
	break;
    case 9:
	s4r = .9;
	break;
    case 10:
	s4r = 1;
	break;
    }
}

void green_menu_s4(int id)
{
    switch (id) {
    case 0:
	s4g = 0;
	break;
    case 1:
	s4g = .1;
	break;
    case 2:
	s4g = .2;
	break;
    case 3:
	s4g = .3;
	break;
    case 4:
	s4g = .4;
	break;
    case 5:
	s4g = .5;
	break;
    case 6:
	s4g = .6;
	break;
    case 7:
	s4g = .7;
	break;
    case 8:
	s4g = .8;
	break;
    case 9:
	s4g = .9;
	break;
    case 10:
	s4g = 1;
	break;
    }
}

void blue_menu_s4(int id)
{
    switch (id) {
    case 0:
	s4b = 0;
	break;
    case 1:
	s4b = .1;
	break;
    case 2:
	s4b = .2;
	break;
    case 3:
	s4b = .3;
	break;
    case 4:
	s4b = .4;
	break;
    case 5:
	s4b = .5;
	break;
    case 6:
	s4b = .6;
	break;
    case 7:
	s4b = .7;
	break;
    case 8:
	s4b = .8;
	break;
    case 9:
	s4b = .9;
	break;
    case 10:
	s4b = 1;
	break;
    }
}

void color_menu2_as(int id)
{
    switch (id) {
    case 1:
	asr = 1.0;
	asg = 0.0;
	asb = 0.0;
	break;
    case 2:
	asr = 0.0;
	asg = 1.0;
	asb = 0.0;
	break;
    case 3:
	asr = 0.0;
	asg = 0.0;
	asb = 1.0;
	break;
    case 4:
	asr = 0.0;
	asg = 1.0;
	asb = 1.0;
	break;
    case 5:
	asr = 1.0;
	asg = 0.0;
	asb = 1.0;
	break;
    case 6:
	asr = 1.0;
	asg = 1.0;
	asb = 0.0;
	break;
    case 7:
	asr = 1.0;
	asg = 1.0;
	asb = 1.0;
	break;
    case 8:
	asr = 0.0;
	asg = 0.0;
	asb = 0.0;
	break;
    }
}

void red_menu_as(int id)
{
    switch (id) {
    case 0:
	asr = 0;
	break;
    case 1:
	asr = .1;
	break;
    case 2:
	asr = .2;
	break;
    case 3:
	asr = .3;
	break;
    case 4:
	asr = .4;
	break;
    case 5:
	asr = .5;
	break;
    case 6:
	asr = .6;
	break;
    case 7:
	asr = .7;
	break;
    case 8:
	asr = .8;
	break;
    case 9:
	asr = .9;
	break;
    case 10:
	asr = 1;
	break;
    }
}

void green_menu_as(int id)
{
    switch (id) {
    case 0:
	asg = 0;
	break;
    case 1:
	asg = .1;
	break;
    case 2:
	asg = .2;
	break;
    case 3:
	asg = .3;
	break;
    case 4:
	asg = .4;
	break;
    case 5:
	asg = .5;
	break;
    case 6:
	asg = .6;
	break;
    case 7:
	asg = .7;
	break;
    case 8:
	asg = .8;
	break;
    case 9:
	asg = .9;
	break;
    case 10:
	asg = 1;
	break;
    }
}

void blue_menu_as(int id)
{
    switch (id) {
    case 0:
	asb = 0;
	break;
    case 1:
	asb = .1;
	break;
    case 2:
	asb = .2;
	break;
    case 3:
	asb = .3;
	break;
    case 4:
	asb = .4;
	break;
    case 5:
	asb = .5;
	break;
    case 6:
	asb = .6;
	break;
    case 7:
	asb = .7;
	break;
    case 8:
	asb = .8;
	break;
    case 9:
	asb = .9;
	break;
    case 10:
	asb = 1;
	break;
    }
}

void color_menu2_ps(int id)
{
    switch (id) {
    case 1:
	psr = 1.0;
	psg = 0.0;
	psb = 0.0;
	break;
    case 2:
	psr = 0.0;
	psg = 1.0;
	psb = 0.0;
	break;
    case 3:
	psr = 0.0;
	psg = 0.0;
	psb = 1.0;
	break;
    case 4:
	psr = 0.0;
	psg = 1.0;
	psb = 1.0;
	break;
    case 5:
	psr = 1.0;
	psg = 0.0;
	psb = 1.0;
	break;
    case 6:
	psr = 1.0;
	psg = 1.0;
	psb = 0.0;
	break;
    case 7:
	psr = 1.0;
	psg = 1.0;
	psb = 1.0;
	break;
    case 8:
	psr = 0.0;
	psg = 0.0;
	psb = 0.0;
	break;
    }
}

void red_menu_ps(int id)
{
    switch (id) {
    case 0:
	psr = 0;
	break;
    case 1:
	psr = .1;
	break;
    case 2:
	psr = .2;
	break;
    case 3:
	psr = .3;
	break;
    case 4:
	psr = .4;
	break;
    case 5:
	psr = .5;
	break;
    case 6:
	psr = .6;
	break;
    case 7:
	psr = .7;
	break;
    case 8:
	psr = .8;
	break;
    case 9:
	psr = .9;
	break;
    case 10:
	psr = 1;
	break;
    }
}

void green_menu_ps(int id)
{
    switch (id) {
    case 0:
	psg = 0;
	break;
    case 1:
	psg = .1;
	break;
    case 2:
	psg = .2;
	break;
    case 3:
	psg = .3;
	break;
    case 4:
	psg = .4;
	break;
    case 5:
	psg = .5;
	break;
    case 6:
	psg = .6;
	break;
    case 7:
	psg = .7;
	break;
    case 8:
	psg = .8;
	break;
    case 9:
	psg = .9;
	break;
    case 10:
	psg = 1;
	break;
    }
}

void blue_menu_ps(int id)
{
    switch (id) {
    case 0:
	psb = 0;
	break;
    case 1:
	psb = .1;
	break;
    case 2:
	psb = .2;
	break;
    case 3:
	psb = .3;
	break;
    case 4:
	psb = .4;
	break;
    case 5:
	psb = .5;
	break;
    case 6:
	psb = .6;
	break;
    case 7:
	psb = .7;
	break;
    case 8:
	psb = .8;
	break;
    case 9:
	psb = .9;
	break;
    case 10:
	psb = 1;
	break;
    }
}


void font_menu(int id)
{
    int w, a, d;
    int win = glutGetWindow();

    font = id;
}

void file_menu(int id)
{
    int i = glutGetWindow();
    switch (id) {
    case 4:
	exit(0);
	break;
    }
    glutSetWindow(main_w);
    glutPostRedisplay();
    glutSetWindow(i);
}

void options_menu(int id)
{
    int i = glutGetWindow();
    switch (id) {
    case 11:
	printf("EyeEl %.04f  EyeAz %.04f  EyeDist %.04f \n", EyeEl, EyeAz,
	       EyeDist);
	printf("ElSpin %.04f  AzSpin %.04f \n", ElSpin, AzSpin);
	printf("Spacing %.04f  Line Width %.04f \n", spacing, line_width);
	break;
    case 12:
	printf("\12\10\n");
	break;
    }
    glutSetWindow(main_w);
    glutPostRedisplay();
    glutSetWindow(i);
}

void options_menu_visual(int id)
{
    int i = glutGetWindow();
    switch (id) {
    case 3:
	ortho = -1;
	break;
    case 4:
	ortho = 1;
	break;
    case 5:
	color = -color;
	break;
    case 6:
	spacing += 0.1;
	printf("spacing %.04f \n", spacing);
	break;
    case 7:
	spacing -= 0.1;
	printf("spacing %.04f \n", spacing);
	break;
    case 8:
	line_width += 1;
	glLineWidth(line_width);
	printf("line %.04f \n", line_width);
	break;
    case 9:
	line_width -= 1;
	glLineWidth(line_width);
	printf("line %.04f \n", line_width);
	break;
    case 10:
	box = -box;
	break;
    case 11:
	rect = -rect;
	break;
    case 12:
	coord = -coord;
	break;
    case 13:
	axes = -axes;
	break;
    case 14:
	connect_line = -connect_line;
	break;
    case 15:
	spacing = 2.5;
	line_width = 4;
	connect_line = 1;
	box = 1;
	color = 1;
	coord = -1;
	rect = -1;
	roman = 1;
	threedee = 1;
	font = -1;
	ortho = -1;
	EyeEl = 30.0, EyeAz = 0.0;
	EyeDist = 13.4;
	AzSpin = 0.5;
	ElSpin = 0.0;
	break;
    case 16:
	bubble = -bubble;
	break;
    case 17:
	invis = -invis;
	break;
    }
    glutSetWindow(main_w);
    glutPostRedisplay();
    glutSetWindow(i);
}

void help_menu(int id)
{

}

void make_file_menu(void)
{
    glutCreateMenu(file_menu);
    glutAddMenuEntry("New", 1);
    glutAddMenuEntry("Open", 2);
    glutAddMenuEntry("...", 0);
    glutAddMenuEntry("Save", 3);
    glutAddMenuEntry("...", 0);
    glutAddMenuEntry("Quit", 4);
    glutAttachMenu(GLUT_LEFT_BUTTON);
    glutAttachMenu(GLUT_MIDDLE_BUTTON);
    glutAttachMenu(GLUT_RIGHT_BUTTON);
}

void make_options_menu(void)
{

    int sub_menu;
    int sub_menu3;
    int sub_menu_t;
    int sub_menu_s;
    int sub_menu_r;
    int sub_menu_w;
    int sub_menu3_s1;
    int sub_menu3_s2;
    int sub_menu3_s3;
    int sub_menu3_s4;
    int sub_menu3_as;
    int sub_menu3_ps;

    int c_menu2;
    int cr_menu;
    int cg_menu;
    int cb_menu;
    int c_menu2_s1;
    int cr_menu_s1;
    int cg_menu_s1;
    int cb_menu_s1;
    int c_menu2_s2;
    int cr_menu_s2;
    int cg_menu_s2;
    int cb_menu_s2;
    int c_menu2_s3;
    int cr_menu_s3;
    int cg_menu_s3;
    int cb_menu_s3;
    int c_menu2_s4;
    int cr_menu_s4;
    int cg_menu_s4;
    int cb_menu_s4;
    int c_menu2_as;
    int cr_menu_as;
    int cg_menu_as;
    int cb_menu_as;
    int c_menu2_ps;
    int cr_menu_ps;
    int cg_menu_ps;
    int cb_menu_ps;

    int sub_menu2 = glutCreateMenu(font_menu);
    glutAddMenuEntry("Bitmap Times Roman", -1);
    glutAddMenuEntry("Bitmap Helvetica", -2);
    glutAddMenuEntry("Stroke Roman", -3);
    glutAddMenuEntry("Test Font", 0);

    c_menu2 = glutCreateMenu(color_menu2);
    glutAddMenuEntry("Red", 1);
    glutAddMenuEntry("Green", 2);
    glutAddMenuEntry("Blue", 3);
    glutAddMenuEntry("Cyan", 4);
    glutAddMenuEntry("Magenta", 5);
    glutAddMenuEntry("Yellow", 6);
    glutAddMenuEntry("White", 7);
    glutAddMenuEntry("Black", 8);

    cr_menu = glutCreateMenu(red_menu);
    glutAddMenuEntry("0.0", 0);
    glutAddMenuEntry("0.1", 1);
    glutAddMenuEntry("0.2", 2);
    glutAddMenuEntry("0.3", 3);
    glutAddMenuEntry("0.4", 4);
    glutAddMenuEntry("0.5", 5);
    glutAddMenuEntry("0.6", 6);
    glutAddMenuEntry("0.7", 7);
    glutAddMenuEntry("0.8", 8);
    glutAddMenuEntry("0.9", 9);
    glutAddMenuEntry("1.0", 10);

    cg_menu = glutCreateMenu(green_menu);
    glutAddMenuEntry("0.0", 0);
    glutAddMenuEntry("0.1", 1);
    glutAddMenuEntry("0.2", 2);
    glutAddMenuEntry("0.3", 3);
    glutAddMenuEntry("0.4", 4);
    glutAddMenuEntry("0.5", 5);
    glutAddMenuEntry("0.6", 6);
    glutAddMenuEntry("0.7", 7);
    glutAddMenuEntry("0.8", 8);
    glutAddMenuEntry("0.9", 9);
    glutAddMenuEntry("1.0", 10);

    cb_menu = glutCreateMenu(blue_menu);
    glutAddMenuEntry("0.0", 0);
    glutAddMenuEntry("0.1", 1);
    glutAddMenuEntry("0.2", 2);
    glutAddMenuEntry("0.3", 3);
    glutAddMenuEntry("0.4", 4);
    glutAddMenuEntry("0.5", 5);
    glutAddMenuEntry("0.6", 6);
    glutAddMenuEntry("0.7", 7);
    glutAddMenuEntry("0.8", 8);
    glutAddMenuEntry("0.9", 9);
    glutAddMenuEntry("1.0", 10);

    sub_menu3 = glutCreateMenu(empty_menu);
    glutAddSubMenu("Primary Colors", c_menu2);
    glutAddSubMenu("Red Component", cr_menu);
    glutAddSubMenu("Green Component", cg_menu);
    glutAddSubMenu("Blue Component", cb_menu);

    c_menu2_s1 = glutCreateMenu(color_menu2_s1);
    glutAddMenuEntry("Red", 1);
    glutAddMenuEntry("Green", 2);
    glutAddMenuEntry("Blue", 3);
    glutAddMenuEntry("Cyan", 4);
    glutAddMenuEntry("Magenta", 5);
    glutAddMenuEntry("Yellow", 6);
    glutAddMenuEntry("White", 7);
    glutAddMenuEntry("Black", 8);

    cr_menu_s1 = glutCreateMenu(red_menu_s1);
    glutAddMenuEntry("0.0", 0);
    glutAddMenuEntry("0.1", 1);
    glutAddMenuEntry("0.2", 2);
    glutAddMenuEntry("0.3", 3);
    glutAddMenuEntry("0.4", 4);
    glutAddMenuEntry("0.5", 5);
    glutAddMenuEntry("0.6", 6);
    glutAddMenuEntry("0.7", 7);
    glutAddMenuEntry("0.8", 8);
    glutAddMenuEntry("0.9", 9);
    glutAddMenuEntry("1.0", 10);

    cg_menu_s1 = glutCreateMenu(green_menu_s1);
    glutAddMenuEntry("0.0", 0);
    glutAddMenuEntry("0.1", 1);
    glutAddMenuEntry("0.2", 2);
    glutAddMenuEntry("0.3", 3);
    glutAddMenuEntry("0.4", 4);
    glutAddMenuEntry("0.5", 5);
    glutAddMenuEntry("0.6", 6);
    glutAddMenuEntry("0.7", 7);
    glutAddMenuEntry("0.8", 8);
    glutAddMenuEntry("0.9", 9);
    glutAddMenuEntry("1.0", 10);

    cb_menu_s1 = glutCreateMenu(blue_menu_s1);
    glutAddMenuEntry("0.0", 0);
    glutAddMenuEntry("0.1", 1);
    glutAddMenuEntry("0.2", 2);
    glutAddMenuEntry("0.3", 3);
    glutAddMenuEntry("0.4", 4);
    glutAddMenuEntry("0.5", 5);
    glutAddMenuEntry("0.6", 6);
    glutAddMenuEntry("0.7", 7);
    glutAddMenuEntry("0.8", 8);
    glutAddMenuEntry("0.9", 9);
    glutAddMenuEntry("1.0", 10);

    sub_menu3_s1 = glutCreateMenu(empty_menu);
    glutAddSubMenu("Primary Colors", c_menu2_s1);
    glutAddSubMenu("Red Component", cr_menu_s1);
    glutAddSubMenu("Green Component", cg_menu_s1);
    glutAddSubMenu("Blue Component", cb_menu_s1);

    c_menu2_s2 = glutCreateMenu(color_menu2_s2);
    glutAddMenuEntry("Red", 1);
    glutAddMenuEntry("Green", 2);
    glutAddMenuEntry("Blue", 3);
    glutAddMenuEntry("Cyan", 4);
    glutAddMenuEntry("Magenta", 5);
    glutAddMenuEntry("Yellow", 6);
    glutAddMenuEntry("White", 7);
    glutAddMenuEntry("Black", 8);

    cr_menu_s2 = glutCreateMenu(red_menu_s2);
    glutAddMenuEntry("0.0", 0);
    glutAddMenuEntry("0.1", 1);
    glutAddMenuEntry("0.2", 2);
    glutAddMenuEntry("0.3", 3);
    glutAddMenuEntry("0.4", 4);
    glutAddMenuEntry("0.5", 5);
    glutAddMenuEntry("0.6", 6);
    glutAddMenuEntry("0.7", 7);
    glutAddMenuEntry("0.8", 8);
    glutAddMenuEntry("0.9", 9);
    glutAddMenuEntry("1.0", 10);

    cg_menu_s2 = glutCreateMenu(green_menu_s2);
    glutAddMenuEntry("0.0", 0);
    glutAddMenuEntry("0.1", 1);
    glutAddMenuEntry("0.2", 2);
    glutAddMenuEntry("0.3", 3);
    glutAddMenuEntry("0.4", 4);
    glutAddMenuEntry("0.5", 5);
    glutAddMenuEntry("0.6", 6);
    glutAddMenuEntry("0.7", 7);
    glutAddMenuEntry("0.8", 8);
    glutAddMenuEntry("0.9", 9);
    glutAddMenuEntry("1.0", 10);

    cb_menu_s2 = glutCreateMenu(blue_menu_s2);
    glutAddMenuEntry("0.0", 0);
    glutAddMenuEntry("0.1", 1);
    glutAddMenuEntry("0.2", 2);
    glutAddMenuEntry("0.3", 3);
    glutAddMenuEntry("0.4", 4);
    glutAddMenuEntry("0.5", 5);
    glutAddMenuEntry("0.6", 6);
    glutAddMenuEntry("0.7", 7);
    glutAddMenuEntry("0.8", 8);
    glutAddMenuEntry("0.9", 9);
    glutAddMenuEntry("1.0", 10);

    sub_menu3_s2 = glutCreateMenu(empty_menu);
    glutAddSubMenu("Primary Colors", c_menu2_s2);
    glutAddSubMenu("Red Component", cr_menu_s2);
    glutAddSubMenu("Green Component", cg_menu_s2);
    glutAddSubMenu("Blue Component", cb_menu_s2);

    c_menu2_s3 = glutCreateMenu(color_menu2_s3);
    glutAddMenuEntry("Red", 1);
    glutAddMenuEntry("Green", 2);
    glutAddMenuEntry("Blue", 3);
    glutAddMenuEntry("Cyan", 4);
    glutAddMenuEntry("Magenta", 5);
    glutAddMenuEntry("Yellow", 6);
    glutAddMenuEntry("White", 7);
    glutAddMenuEntry("Black", 8);

    cr_menu_s3 = glutCreateMenu(red_menu_s3);
    glutAddMenuEntry("0.0", 0);
    glutAddMenuEntry("0.1", 1);
    glutAddMenuEntry("0.2", 2);
    glutAddMenuEntry("0.3", 3);
    glutAddMenuEntry("0.4", 4);
    glutAddMenuEntry("0.5", 5);
    glutAddMenuEntry("0.6", 6);
    glutAddMenuEntry("0.7", 7);
    glutAddMenuEntry("0.8", 8);
    glutAddMenuEntry("0.9", 9);
    glutAddMenuEntry("1.0", 10);

    cg_menu_s3 = glutCreateMenu(green_menu_s3);
    glutAddMenuEntry("0.0", 0);
    glutAddMenuEntry("0.1", 1);
    glutAddMenuEntry("0.2", 2);
    glutAddMenuEntry("0.3", 3);
    glutAddMenuEntry("0.4", 4);
    glutAddMenuEntry("0.5", 5);
    glutAddMenuEntry("0.6", 6);
    glutAddMenuEntry("0.7", 7);
    glutAddMenuEntry("0.8", 8);
    glutAddMenuEntry("0.9", 9);
    glutAddMenuEntry("1.0", 10);

    cb_menu_s3 = glutCreateMenu(blue_menu_s3);
    glutAddMenuEntry("0.0", 0);
    glutAddMenuEntry("0.1", 1);
    glutAddMenuEntry("0.2", 2);
    glutAddMenuEntry("0.3", 3);
    glutAddMenuEntry("0.4", 4);
    glutAddMenuEntry("0.5", 5);
    glutAddMenuEntry("0.6", 6);
    glutAddMenuEntry("0.7", 7);
    glutAddMenuEntry("0.8", 8);
    glutAddMenuEntry("0.9", 9);
    glutAddMenuEntry("1.0", 10);

    sub_menu3_s3 = glutCreateMenu(empty_menu);
    glutAddSubMenu("Primary Colors", c_menu2_s3);
    glutAddSubMenu("Red Component", cr_menu_s3);
    glutAddSubMenu("Green Component", cg_menu_s3);
    glutAddSubMenu("Blue Component", cb_menu_s3);

    c_menu2_s4 = glutCreateMenu(color_menu2_s4);
    glutAddMenuEntry("Red", 1);
    glutAddMenuEntry("Green", 2);
    glutAddMenuEntry("Blue", 3);
    glutAddMenuEntry("Cyan", 4);
    glutAddMenuEntry("Magenta", 5);
    glutAddMenuEntry("Yellow", 6);
    glutAddMenuEntry("White", 7);
    glutAddMenuEntry("Black", 8);

    cr_menu_s4 = glutCreateMenu(red_menu_s4);
    glutAddMenuEntry("0.0", 0);
    glutAddMenuEntry("0.1", 1);
    glutAddMenuEntry("0.2", 2);
    glutAddMenuEntry("0.3", 3);
    glutAddMenuEntry("0.4", 4);
    glutAddMenuEntry("0.5", 5);
    glutAddMenuEntry("0.6", 6);
    glutAddMenuEntry("0.7", 7);
    glutAddMenuEntry("0.8", 8);
    glutAddMenuEntry("0.9", 9);
    glutAddMenuEntry("1.0", 10);

    cg_menu_s4 = glutCreateMenu(green_menu_s4);
    glutAddMenuEntry("0.0", 0);
    glutAddMenuEntry("0.1", 1);
    glutAddMenuEntry("0.2", 2);
    glutAddMenuEntry("0.3", 3);
    glutAddMenuEntry("0.4", 4);
    glutAddMenuEntry("0.5", 5);
    glutAddMenuEntry("0.6", 6);
    glutAddMenuEntry("0.7", 7);
    glutAddMenuEntry("0.8", 8);
    glutAddMenuEntry("0.9", 9);
    glutAddMenuEntry("1.0", 10);

    cb_menu_s4 = glutCreateMenu(blue_menu_s4);
    glutAddMenuEntry("0.0", 0);
    glutAddMenuEntry("0.1", 1);
    glutAddMenuEntry("0.2", 2);
    glutAddMenuEntry("0.3", 3);
    glutAddMenuEntry("0.4", 4);
    glutAddMenuEntry("0.5", 5);
    glutAddMenuEntry("0.6", 6);
    glutAddMenuEntry("0.7", 7);
    glutAddMenuEntry("0.8", 8);
    glutAddMenuEntry("0.9", 9);
    glutAddMenuEntry("1.0", 10);

    sub_menu3_s4 = glutCreateMenu(empty_menu);
    glutAddSubMenu("Primary Colors", c_menu2_s4);
    glutAddSubMenu("Red Component", cr_menu_s4);
    glutAddSubMenu("Green Component", cg_menu_s4);
    glutAddSubMenu("Blue Component", cb_menu_s4);

    c_menu2_as = glutCreateMenu(color_menu2_as);
    glutAddMenuEntry("Red", 1);
    glutAddMenuEntry("Green", 2);
    glutAddMenuEntry("Blue", 3);
    glutAddMenuEntry("Cyan", 4);
    glutAddMenuEntry("Magenta", 5);
    glutAddMenuEntry("Yellow", 6);
    glutAddMenuEntry("White", 7);
    glutAddMenuEntry("Black", 8);

    cr_menu_as = glutCreateMenu(red_menu_as);
    glutAddMenuEntry("0.0", 0);
    glutAddMenuEntry("0.1", 1);
    glutAddMenuEntry("0.2", 2);
    glutAddMenuEntry("0.3", 3);
    glutAddMenuEntry("0.4", 4);
    glutAddMenuEntry("0.5", 5);
    glutAddMenuEntry("0.6", 6);
    glutAddMenuEntry("0.7", 7);
    glutAddMenuEntry("0.8", 8);
    glutAddMenuEntry("0.9", 9);
    glutAddMenuEntry("1.0", 10);

    cg_menu_as = glutCreateMenu(green_menu_as);
    glutAddMenuEntry("0.0", 0);
    glutAddMenuEntry("0.1", 1);
    glutAddMenuEntry("0.2", 2);
    glutAddMenuEntry("0.3", 3);
    glutAddMenuEntry("0.4", 4);
    glutAddMenuEntry("0.5", 5);
    glutAddMenuEntry("0.6", 6);
    glutAddMenuEntry("0.7", 7);
    glutAddMenuEntry("0.8", 8);
    glutAddMenuEntry("0.9", 9);
    glutAddMenuEntry("1.0", 10);

    cb_menu_as = glutCreateMenu(blue_menu_as);
    glutAddMenuEntry("0.0", 0);
    glutAddMenuEntry("0.1", 1);
    glutAddMenuEntry("0.2", 2);
    glutAddMenuEntry("0.3", 3);
    glutAddMenuEntry("0.4", 4);
    glutAddMenuEntry("0.5", 5);
    glutAddMenuEntry("0.6", 6);
    glutAddMenuEntry("0.7", 7);
    glutAddMenuEntry("0.8", 8);
    glutAddMenuEntry("0.9", 9);
    glutAddMenuEntry("1.0", 10);

    sub_menu3_as = glutCreateMenu(empty_menu);
    glutAddSubMenu("Primary Colors", c_menu2_as);
    glutAddSubMenu("Red Component", cr_menu_as);
    glutAddSubMenu("Green Component", cg_menu_as);
    glutAddSubMenu("Blue Component", cb_menu_as);

    c_menu2_ps = glutCreateMenu(color_menu2_ps);
    glutAddMenuEntry("Red", 1);
    glutAddMenuEntry("Green", 2);
    glutAddMenuEntry("Blue", 3);
    glutAddMenuEntry("Cyan", 4);
    glutAddMenuEntry("Magenta", 5);
    glutAddMenuEntry("Yellow", 6);
    glutAddMenuEntry("White", 7);
    glutAddMenuEntry("Black", 8);

    cr_menu_ps = glutCreateMenu(red_menu_ps);
    glutAddMenuEntry("0.0", 0);
    glutAddMenuEntry("0.1", 1);
    glutAddMenuEntry("0.2", 2);
    glutAddMenuEntry("0.3", 3);
    glutAddMenuEntry("0.4", 4);
    glutAddMenuEntry("0.5", 5);
    glutAddMenuEntry("0.6", 6);
    glutAddMenuEntry("0.7", 7);
    glutAddMenuEntry("0.8", 8);
    glutAddMenuEntry("0.9", 9);
    glutAddMenuEntry("1.0", 10);

    cg_menu_ps = glutCreateMenu(green_menu_ps);
    glutAddMenuEntry("0.0", 0);
    glutAddMenuEntry("0.1", 1);
    glutAddMenuEntry("0.2", 2);
    glutAddMenuEntry("0.3", 3);
    glutAddMenuEntry("0.4", 4);
    glutAddMenuEntry("0.5", 5);
    glutAddMenuEntry("0.6", 6);
    glutAddMenuEntry("0.7", 7);
    glutAddMenuEntry("0.8", 8);
    glutAddMenuEntry("0.9", 9);
    glutAddMenuEntry("1.0", 10);

    cb_menu_ps = glutCreateMenu(blue_menu_ps);
    glutAddMenuEntry("0.0", 0);
    glutAddMenuEntry("0.1", 1);
    glutAddMenuEntry("0.2", 2);
    glutAddMenuEntry("0.3", 3);
    glutAddMenuEntry("0.4", 4);
    glutAddMenuEntry("0.5", 5);
    glutAddMenuEntry("0.6", 6);
    glutAddMenuEntry("0.7", 7);
    glutAddMenuEntry("0.8", 8);
    glutAddMenuEntry("0.9", 9);
    glutAddMenuEntry("1.0", 10);

    sub_menu3_ps = glutCreateMenu(empty_menu);
    glutAddSubMenu("Primary Colors", c_menu2_ps);
    glutAddSubMenu("Red Component", cr_menu_ps);
    glutAddSubMenu("Green Component", cg_menu_ps);
    glutAddSubMenu("Blue Component", cb_menu_ps);

    make_theme_menu();

    sub_menu_t = glutCreateMenu(time_menu);
    glutAddMenuEntry("No Time Limit", 0);
    glutAddMenuEntry("1 Minute", 1);
    glutAddMenuEntry("2 Minutes", 2);
    glutAddMenuEntry("3 Minutes", 3);
    glutAddMenuEntry("4 Minutes", 4);
    glutAddMenuEntry("5 Minutes", 5);
    glutAddMenuEntry("10 Minutes", 10);

    sub_menu_s = glutCreateMenu(size_menu);
    glutAddMenuEntry("3 by 3 matrix", 1);
    glutAddMenuEntry("4 by 4 matrix", 2);

    sub_menu_r = glutCreateMenu(round_menu);
    glutAddMenuEntry("1 Round", 1);
    glutAddMenuEntry("3 Rounds", 3);
    glutAddMenuEntry("10 Rounds", 10);

    sub_menu_w = glutCreateMenu(word_menu);
    glutAddMenuEntry("Keep word list between rounds", 1);
    glutAddMenuEntry("Clear word list between rounds", 2);
    glutAddMenuEntry("...", 0);
    glutAddMenuEntry("Show word list", 3);
    glutAddMenuEntry("Hide word list", 4);

    sub_menu = glutCreateMenu(options_menu_visual);
    glutAddSubMenu("Theme", theme_m);
    glutAddMenuEntry("...", 0);
    glutAddSubMenu("Fonts", sub_menu2);
    glutAddSubMenu("Background Color", sub_menu3);
    glutAddSubMenu("Slice 1 Color", sub_menu3_s1);
    glutAddSubMenu("Slice 2 Color", sub_menu3_s2);
    glutAddSubMenu("Slice 3 Color", sub_menu3_s3);
    glutAddSubMenu("Slice 4 Color", sub_menu3_s4);
    glutAddSubMenu("Active Select Color", sub_menu3_as);
    glutAddSubMenu("Passive Select Color", sub_menu3_ps);
    glutAddMenuEntry("...", 0);
    glutAddMenuEntry("Perspective", 3);
    glutAddMenuEntry("Orthogonal", 4);
    glutAddMenuEntry("...", 0);
    glutAddMenuEntry("Increase Spacing", 6);
    glutAddMenuEntry("Decrease Spacing", 7);
    glutAddMenuEntry("...", 0);
    glutAddMenuEntry("Increase Line Thickness", 8);
    glutAddMenuEntry("Decrease Line Thickness", 9);
    glutAddMenuEntry("...", 0);
    glutAddMenuEntry("Toggle Color", 5);
    glutAddMenuEntry("Toggle Outline Box", 10);
    glutAddMenuEntry("Toggle Bubble Box", 16);
    glutAddMenuEntry("Toggle Hide UnSelectables", 17);
    glutAddMenuEntry("Toggle Selection Polygons", 11);
    glutAddMenuEntry("Toggle Coordinates", 12);
    glutAddMenuEntry("Toggle Axes", 13);
    glutAddMenuEntry("Toggle Letter Connecting Line", 14);
    glutAddMenuEntry("...", 0);
    glutAddMenuEntry("Defaults", 15);

    glutCreateMenu(options_menu);
    glutAddSubMenu("Visual", sub_menu);
    glutAddMenuEntry("Debug", 11);
    glutAddMenuEntry("...", 0);
    glutAddSubMenu("Size", sub_menu_s);
    glutAddSubMenu("Time Limit", sub_menu_t);
    glutAddSubMenu("Rounds", sub_menu_r);
    glutAddSubMenu("Word List", sub_menu_w);

    glutAttachMenu(GLUT_LEFT_BUTTON);
    glutAttachMenu(GLUT_MIDDLE_BUTTON);
    glutAttachMenu(GLUT_RIGHT_BUTTON);
}

void make_help_menu(void)
{
    glutCreateMenu(help_menu);
    glutAddMenuEntry("About 3D Baffle", 1);
    glutAddMenuEntry("Instructions", 2);
    glutAddMenuEntry("Known Bugs", 3);
    glutAttachMenu(GLUT_LEFT_BUTTON);
    glutAttachMenu(GLUT_MIDDLE_BUTTON);
    glutAttachMenu(GLUT_RIGHT_BUTTON);
}

void make_erase_menu(void)
{
    int i;
    erase_m = glutCreateMenu(erase_menu);
    for (i = 0; i < word_count; i++)
	glutAddMenuEntry(word_list[i], i);
    glutAttachMenu(GLUT_LEFT_BUTTON);
    glutAttachMenu(GLUT_MIDDLE_BUTTON);
    glutAttachMenu(GLUT_RIGHT_BUTTON);
}

void unmake_erase_menu(void)
{
    glutDestroyMenu(erase_m);
}

void erase_menu(int id)
{
    int w = glutGetWindow();
    if (id >= word_count)
	return;
    free(word_list[id]);
    word_list[id] = (char *) last;
    qsort(word_list, word_count, sizeof(word_list[0]), pstrcmp);
    word_count--;
    unmake_erase_menu();
    make_erase_menu();
    glutSetWindow(root2_w);
    glutPostRedisplay();
    glutSetWindow(w);
}

void theme_menu(int id)
{
    FILE *f;
    char s[512];
    int r, i, n;

    if ((f = fopen("baffle.thm", "r")) != NULL) {

	for (i = 0; i <= id; i++) {

	    r = fscanf(f,
		       "([ %s ] < %f %f %f > < %f %f %f > < %f %f %f > < %f %f %f > < %f %f %f > < %f %f %f > < %f %f %f > %i )\n",
		       s, &br, &bg, &bb, &s1r, &s1g, &s1b, &s2r, &s2g,
		       &s2b, &s3r, &s3g, &s3b, &s4r, &s4g, &s4b, &asr,
		       &asg, &asb, &psr, &psg, &psb, &n);

	}

	fclose(f);

    }
}

void make_theme_menu(void)
{
    FILE *f;
    float t;
    int n, r, i;
    char s[512];

    theme_m = glutCreateMenu(theme_menu);

    if ((f = fopen("baffle.thm", "r")) != NULL) {

	for (i = 0; !feof(f); i++) {

	    /* printf("for (i = %i...",i); */

	    r = fscanf(f,
		       "([ %s ] < %f %f %f > < %f %f %f > < %f %f %f > < %f %f %f > < %f %f %f > < %f %f %f > < %f %f %f > %i )\n",
		       s, &t, &t, &t, &t, &t, &t, &t, &t, &t, &t, &t, &t,
		       &t, &t, &t, &t, &t, &t, &t, &t, &t, &n);

	    /* printf(") r = %i \n",r); */

	    if ((r == EOF) || (r == 0)) {
		break;
	    } else
		glutAddMenuEntry(s, i);

	}

	fclose(f);

    }

    glutAttachMenu(GLUT_LEFT_BUTTON);
    glutAttachMenu(GLUT_MIDDLE_BUTTON);
    glutAttachMenu(GLUT_RIGHT_BUTTON);

    theme_menu(0);		/* apply default theme */

}
