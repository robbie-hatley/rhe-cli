class Singleton
{
  public:
    virtual ~Singleton();
    static Singleton* GetInstance() 
    {
      if( m_instance == NULL )
      m_instance = new Singleton;
      return m_instance;
    }
  private:
    static Singleton* m_instance;             // Instance pointer is private.
    Singleton(){};                            // Default constructor is private.
    Singleton(Singleton const&){};            // Copy constructor is private.
    Singleton& operator=(Singleton const&){}; // Assignment operator is private.
    
}
