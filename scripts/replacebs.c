// replacebs.c
// Replace Octave "" strings using '\\$' line continuation with string arrays

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[])
{
#define LINE_SIZE 256
  char line[LINE_SIZE];

  while(fgets(line, LINE_SIZE, stdin) != NULL)
	{
      // Find the start of a string
      char *sdq=strchr(line,'\"');
      if (sdq == NULL)
        {
          // Print the line
          printf("%s",line);
          continue;
        }

      // Find a line continuation
      char *sbs=strrchr(line,'\\');
      if ((sbs == NULL) || ((*(sbs+1) != '\n') && ((*(sbs+1) != '\r'))))
        {
          // Print the line
          printf("%s",line);
          continue;
        }

      // Print the first line of the continued string
      *sdq='\0';
      *sbs='\0';
      char *str=sdq+1;
      printf("%s[\"%s\", ...\n",line,str);
      
      // Read line continuations
      while (fgets(line, LINE_SIZE, stdin) != NULL)
        {
          char *sbs2=strrchr(line,'\\');
          if ((sbs2 == NULL) || ((*(sbs2+1) != '\n') && ((*(sbs2+1) != '\r'))))
            {
              // We have finished reading this continued string
              char *sdq2=strrchr(line,'\"');
              if (sdq2 == NULL)
                {
                  fprintf(stderr,"Expected a trailing \" (%s)!", line);
                  exit(-1);
                }
              *sdq2='\0';
              char *str2=sdq2+1;
              printf(" \"%s\"]%s",line,str2);
              break;
            }

          // Write this line of the continued string
          *sbs2='\0';
          printf(" \"%s\", ...\n",line);
        }
    }
}
