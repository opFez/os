#include <stddef.h>
#include "types.h"

#define WHITE_TEXT 0x0f

void kprint(char *);
u32 strlen(char *);

void
kmain()
{
	char msg[] = "hello!\0";
	kprint(msg);
	

	while (1) {}
}

/* TODO:
 *  - doesn't support newline ('\n')
 *  - doesn't support long strings??
 */
void
kprint(char *msg)
{
	char *vmem = (char *)0xb8000;
	u32 offset = 0;

	while (*msg != '\0') {
		vmem[offset++] = *msg++;
		vmem[offset++] = WHITE_TEXT;
	}
}

u32
strlen(char *str)
{
	u32 ret = 0;
	while (*str++ != '\0')
		ret++;
	return ret;
}
