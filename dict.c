#include "global.h"

long int dict_size;
FILE *f1;

int open_dict(void)
{

    char s[80];

    dict_size = 0;
    if ((f1 = fopen("baffle.dic", "r")) == NULL)
	return -1;

    while (!feof(f1)) {
	if (fgets(s, 75, f1) == NULL)
	    break;
	dict_size++;
    }

    return dict_size;
}

/* binary search */
int check_word(char *a)
{

    char b[80];
    char *t;

    long int lo = 0;
    long int hi = dict_size - 1;
    long int guess;

    if (f1 == NULL)
	return -1;

    while (lo <= hi) {
	guess = (lo + hi) / 2;

/*		printf("lo %i hi %i guess %i\n",lo,hi,guess); */

	if ((fseek(f1, 31 * guess, SEEK_SET)) != -1) {
	    if (fgets(b, 32, f1) != NULL) {
		if ((t = strchr(b, '.')) != NULL) {
		    t[0] = '\0';
		}
	    }
	}

	if (strcmp(a, b) < 0)
	    hi = guess - 1;
	else if (strcmp(a, b) > 0)
	    lo = guess + 1;
	else
	    return guess;	/* found */
    }

    return -1;			/* not found */

}

int close_dict(void)
{

    fclose(f1);

}
