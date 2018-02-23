
#include <stdio.h>
#include <stdlib.h>
#include<math.h>
  int OutputImage[512][512][3];
  int OutputImage2[512][512][3];
  int Image[786432]={0};
  int OUT[262144]={0};
  int OUT2[262144]={0};
  int tmp[512][512]={0};
int main()
{
  FILE *image_input;
  FILE *image_input2;
  FILE *image_output;
  FILE *bmp_out;
  FILE *data_input;
  FILE *color_out;
  int i, j, k;

  int header[54];
  const int row = 512;
  const int col = 512;
  //float kernel[9] ={-0.015625,-0.015625,-0.015625,-0.015625,0.125,-0.015625,-0.015625,-0.015625,-0.015625};//1/64
  float kernel[9] ={-1,-1,-1,-1,8,-1,-1,-1,-1};
   //int kernel[9]={-1,0,1,-2,0,2,-1,0,1};/*{-0.015625,-0.015625,-0.015625,-0.015625,0.125,-0.015625,-0.015625,-0.015625,-0.015625};*/
   int kernel2[9]={-1,-2,-1,0,0,0,1,2,1};
  if ((image_input = fopen("house.bmp","rb")) == NULL )
  {
    printf( "\n Can't open file %s","untitled8.bmp");
  }
  else
  {
    image_input2 = fopen("photo_man.bmp","rb");
    bmp_out = fopen("test2.bmp","wb");
    for(i=0;i<54;i++)
    {
      header[i] = fgetc(image_input);
      header[i]= fgetc(image_input2);
      fputc(header[i],bmp_out);
    }
    image_output = fopen("data_out.bin","wb");

    for(i=0; i<row; i++)
    {
      for (j=0; j<col; j++)
      {
        for (k=0; k<3; k++)
        {
            if(i==0 || i == row-1 || j == 0 || j == col-1)
            {
                OutputImage[i][j][k] = fgetc(image_input);
                OutputImage[i][j][k] = 0;
                OutputImage2[i][j][k] = fgetc(image_input2);
                OutputImage2[i][j][k] = 0;
            }

            else
            {
                OutputImage[i][j][k] = fgetc(image_input);
                OutputImage2[i][j][k] = fgetc(image_input2);
            }
        }

      }
    }
    for(i=0;i<row;i++)
    {
        for(j=0;j<col;j++)
        {
            fputc(OutputImage[i][j][0], image_output);
        }

    }

    for(i=0;i<row;i++)
    {
        for(j=0;j<col;j++)
        {
            fputc(OutputImage2[i][j][0], image_output);
        }
    }
    fclose(image_input);
    fclose(image_input2);
    fclose(image_output);

    data_input = fopen("data_out.bin","rb");
    for(i=0;i<512*512;i++){
        Image[i] = fgetc(data_input);
    }
    for(i=0;i<512*512;i++){
        Image[i] = fgetc(data_input);
    }

    //R
    for(i=0;i<512;i++){
        for(j=0;j<512;j++){
            if(i==0){
                if(j==0)
                    OUT[i*512+j] = Image[i*512+j]*kernel[4]+Image[i*512+j+1]*kernel[5]+Image[(i+1)*512+j]*kernel[7]+Image[(i+1)*512+j+1]*kernel[8];
                else if(j==511)
                    OUT[i*512+j] = Image[i*512+j-1]*kernel[3]+Image[i*512+j]*kernel[4]+Image[(i+1)*512+j-1]*kernel[6]+Image[(i+1)*512+j]*kernel[7];
                else
                    OUT[i*512+j] = Image[i*512+j-1]*kernel[3]+Image[i*512+j]*kernel[4]+Image[i*512+j+1]*kernel[5]+Image[(i+1)*512+j-1]*kernel[6]+Image[(i+1)*512+j]*kernel[7]+Image[(i+1)*512+j+1]*kernel[8];
            }
            else if(i==511){
                 if(j==0)
                    OUT[i*512+j] = Image[(i-1)*512+j]*kernel[1]+Image[(i-1)*512+j+1]*kernel[2]+Image[i*512+j]*kernel[4]+Image[i*512+j+1]*kernel[5];
                else if(j==511)
                    OUT[i*512+j] = Image[(i-1)*512+j-1]*kernel[0]+Image[(i-1)*512+j]*kernel[1]+Image[i*512+j-1]*kernel[3]+Image[i*512+j]*kernel[4];
                else
                    OUT[i*512+j] = Image[(i-1)*512+j-1]*kernel[0]+Image[(i-1)*512+j]*kernel[1]+Image[(i-1)*512+j+1]*kernel[2]+Image[i*512+j-1]*kernel[3]+Image[i*512+j]*kernel[4]+Image[i*512+j+1]*kernel[5];
            }
            else{
                if(j==0)
                    OUT[i*512+j] = Image[(i-1)*512+j]*kernel[1]+Image[(i-1)*512+j+1]*kernel[2]+Image[i*512+j]*kernel[4]+Image[i*512+j+1]*kernel[5]+Image[(i+1)*512+j]*kernel[7]+Image[(i+1)*512+j+1]*kernel[8];
                else if(j==511)
                    OUT[i*512+j] = Image[(i-1)*512+j-1]*kernel[0]+Image[(i-1)*512+j]*kernel[1]+Image[i*512+j-1]*kernel[3]+Image[i*512+j]*kernel[4]+Image[(i+1)*512+j-1]*kernel[6]+Image[(i+1)*512+j]*kernel[7];
                else
                    OUT[i*512+j] = Image[(i-1)*512+j-1]*kernel[0]+Image[(i-1)*512+j]*kernel[1]+Image[(i-1)*512+j+1]*kernel[2]+Image[i*512+j-1]*kernel[3]+Image[i*512+j]*kernel[4]+Image[i*512+j+1]*kernel[5]+Image[(i+1)*512+j-1]*kernel[6]+Image[(i+1)*512+j]*kernel[7]+Image[(i+1)*512+j+1]*kernel[8];
            }
        }
    }
     /*for(i=0;i<512;i++){
        for(j=0;j<512;j++){
            if(i==0){
                if(j==0)
                    OUT2[i*512+j] = Image[i*512+j]*kernel2[4]+Image[i*512+j+1]*kernel2[5]+Image[(i+1)*512+j]*kernel2[7]+Image[(i+1)*512+j+1]*kernel2[8];
                else if(j==511)
                    OUT2[i*512+j] = Image[i*512+j-1]*kernel2[3]+Image[i*512+j]*kernel2[4]+Image[(i+1)*512+j-1]*kernel2[6]+Image[(i+1)*512+j]*kernel2[7];
                else
                    OUT2[i*512+j] = Image[i*512+j-1]*kernel2[3]+Image[i*512+j]*kernel2[4]+Image[i*512+j+1]*kernel2[5]+Image[(i+1)*512+j-1]*kernel2[6]+Image[(i+1)*512+j]*kernel2[7]+Image[(i+1)*512+j+1]*kernel2[8];
            }
            else if(i==511){
                 if(j==0)
                    OUT2[i*512+j] = Image[(i-1)*512+j]*kernel2[1]+Image[(i-1)*512+j+1]*kernel2[2]+Image[i*512+j]*kernel2[4]+Image[i*512+j+1]*kernel2[5];
                else if(j==511)
                    OUT2[i*512+j] = Image[(i-1)*512+j-1]*kernel2[0]+Image[(i-1)*512+j]*kernel2[1]+Image[i*512+j-1]*kernel2[3]+Image[i*512+j]*kernel2[4];
                else
                    OUT2[i*512+j] = Image[(i-1)*512+j-1]*kernel2[0]+Image[(i-1)*512+j]*kernel2[1]+Image[(i-1)*512+j+1]*kernel2[2]+Image[i*512+j-1]*kernel2[3]+Image[i*512+j]*kernel2[4]+Image[i*512+j+1]*kernel2[5];
            }
            else{
                if(j==0)
                    OUT2[i*512+j] = Image[(i-1)*512+j]*kernel2[1]+Image[(i-1)*512+j+1]*kernel2[2]+Image[i*512+j]*kernel2[4]+Image[i*512+j+1]*kernel2[5]+Image[(i+1)*512+j]*kernel2[7]+Image[(i+1)*512+j+1]*kernel2[8];
                else if(j==511)
                    OUT2[i*512+j] = Image[(i-1)*512+j-1]*kernel2[0]+Image[(i-1)*512+j]*kernel2[1]+Image[i*512+j-1]*kernel2[3]+Image[i*512+j]*kernel2[4]+Image[(i+1)*512+j-1]*kernel2[6]+Image[(i+1)*512+j]*kernel2[7];
                else
                    OUT2[i*512+j] = Image[(i-1)*512+j-1]*kernel2[0]+Image[(i-1)*512+j]*kernel2[1]+Image[(i-1)*512+j+1]*kernel2[2]+Image[i*512+j-1]*kernel2[3]+Image[i*512+j]*kernel2[4]+Image[i*512+j+1]*kernel2[5]+Image[(i+1)*512+j-1]*kernel2[6]+Image[(i+1)*512+j]*kernel2[7]+Image[(i+1)*512+j+1]*kernel2[8];
            }
        }
    }*/
   /* color_out = fopen("color_out.txt","w");
    fwrite(OUT,sizeof(int),sizeof(OUT),color_out);*/
    for(i=0;i<262144 ;i++){
        /*int s = sqrt(OUT[i]*OUT[i]+OUT2[i]*OUT2[i]);
        fputc(s,bmp_out);
        fputc(s,bmp_out);
        fputc(s,bmp_out);*/
        if(OUT[i]<0){
            fputc(0,bmp_out);
            fputc(0,bmp_out);
            fputc(0,bmp_out);
        }
       else if(OUT[i]>255){
            fputc(255,bmp_out);
            fputc(255,bmp_out);
            fputc(255,bmp_out);
        }
        else{
            fputc(OUT[i],bmp_out);
            fputc(OUT[i],bmp_out);
            fputc(OUT[i],bmp_out);
        }
    }
   // printf("%d\n",OUT[0]);
    fclose(bmp_out);

  }
}
