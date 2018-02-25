#include <string.h>
#include "bionic.h"

#include "printf.h"


#include "vibrate.h"

#define MOTOR_CTRL 0xa07001b0

#define MOTOR_CTRL_OFF 0x0422
#define MOTOR_CTRL_LOW 0x8000
#define MOTOR_CTRL_MED 0x8010
#define MOTOR_CTRL_HIGH 0x8020


int cmd_vibrate(int argc, char **argv) {
	uint16_t *p;
	uint32_t level;

	if (argc < 1) {
	  printf("Usage: vibrate [level 0-3]\n");
		return -1;
	}

	level = strtoul(argv[0], NULL, 0);
	p = (uint16_t *) MOTOR_CTRL;


	switch(level) {
	case 0:
	p[0] = MOTOR_CTRL_OFF;
	printf("Vibrate off \n");
	break;
	case 1:
	p[0] = MOTOR_CTRL_LOW;
	printf("Vibrate low \n");
	break;
	case 2:
	p[0] = MOTOR_CTRL_MED;
	printf("Vibrate med \n");
	break;
	case 3:
	p[0] = MOTOR_CTRL_HIGH;
	printf("Vibrate high \n");
	break;
	}


	printf("\n");
	return 0;

}
