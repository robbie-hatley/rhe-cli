class X
{

};

class Y : private X
{

};

class Z : public Y
{
  public:
    Z(X&) {}
};

int main()
{
   return 0;
}
