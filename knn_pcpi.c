#include "firmware.h"
#define K						5
#define MAX_INT                 2147483647
#define DATA_LENGTH             3073
#define NUM_CLASS				10
#define NUM_TEST_IMAGE			50
#define NUM_TRAIN_IMAGE			950
#define IMAGE_OFFSET 			0x00010000
void sobel_pcpi(void)
{
	int test = 0;
  int i;
  int j;
  int color[512][512];
  int start, stop;
  
  while(test < 2){
	  print_str("test_image: ");
	  print_dec(test);
	  print_str("\n");
	  start = tick();
	    for(i = 0;i < 512;i++){
			for( j = 0;j<512;j++){
				color[i][j]=hard_sobel_pcpi(test,i*512+j); 
		}
	}
	  stop = tick();
	  print_str("Elapsed: ");
	  print_dec(start - stop);
	  print_str("\n");
	  test++;
  }

 
  
}
