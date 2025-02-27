// cross-test.hpp
class CounterClass
{
	public:
		CounterClass(){c=0;}
		void increment(){++c;}
		int getcount(){return c;}
	private:
		int c;
};