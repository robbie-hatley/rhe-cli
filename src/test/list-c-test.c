// list-c-test.c
#include <stdio.h>
#include <stdlib.h>

typedef struct Node_tag Node;
struct Node_tag
{
   Node   * next;
   Node   * prev;
   double * data;
};

int main (void)
{
   double a = 28958.563;
   double b = 14937.165;
   double c = 31872.307;
   Node node1;
   Node node2;
   Node node3;
   node1.prev = NULL;
   node1.next = &node2;
   node1.data = &a;
   node2.prev = &node1;
   node2.next = &node3;
   node2.data = &b;
   node3.prev = &node2;
   node3.next = NULL;
   node3.data = &c;
   printf("node1 data = %f\n", *node1.data);
   printf("node2 data = %f\n", *node1.next->data);
   printf("node3 data = %f\n", *node1.next->next->data);
   return 0;
}