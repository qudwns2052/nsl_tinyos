#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "sfsource.h"

void send_packet(int fd, unsigned char byte[2][3])
{
  int i;
  unsigned char *packet;

  unsigned char header[9][3] = {"00","ff","ff","00","00","02","00","89"};

  packet = malloc(10);
  if (!packet)
    exit(2);

  for (i = 0; i < 8; i++)
    packet[i] = strtol(header[i], NULL, 16);
      
  for (i = 0; i < 2; i++)
      packet[i+8] = strtol(byte[i], NULL, 16);

  fprintf(stderr,"Sending ");
  for (i = 0; i < 10; i++)
    fprintf(stderr, " %02x", packet[i]);
  fprintf(stderr, "\n");

  write_sf_packet(fd, packet, 10);
}

int main(int argc, char **argv)
{
  int fd;

  if (argc < 3)
    {
      fprintf(stderr, "Usage: %s <host> <port>\n", argv[0]);
      exit(2);
    }
  fd = open_sf_source(argv[1], atoi(argv[2]));
  if (fd < 0)
    {
      fprintf(stderr, "Couldn't open serial forwarder at %s:%s\n",
	      argv[1], argv[2]);
      exit(1);
    }

  printf("id\tcommand\n");
//  printf("Timer stop\t00\n");
//  printf("Timer start\t01 time_interval\n");
//  printf("get parent\t02\n");
//  printf("get Rank\t03\n");
//  printf("\nquit\t\tq\n\n");


  unsigned char byte[2][3];
  while (1)
  {
      scanf("%s %s", byte[0], byte[1]);

      if(!strcmp(byte[0],"q"))
              break;

      send_packet(fd, byte);
  }
  close(fd);
}
