/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
 * secure.cpp
 * home security program
 * written Sunday August 12 2001 by Robbie Hatley
 * Notes, 2001-08-12:
 * Defines security zones as objects. Zones are numbered, organized, and
 * managed via an array of 50 pointers to Zone, with an array of 50 alarms
 * in each zone.
 * The Zone pointer array is defined globally and all values set to 0.
 * Then when an individual zone is created, the smallest-numbered available
 * pointer is pointed toward that zone, giving it a number and a handle.
 * When zones are destroyed, their numbers are freed to be re-used later.
 * I considered doing this as a linked list, but then I hit on this array-
 * of-pointers idea and liked it a lot better. Objects in linked lists are
 * not random-access, nor are they serialized; but a pointer array gives
 * both random access and numbering.
 * Notes, 2001-08-12: I've learned a lot about base-class pointers from this
 * program.  I've found that calling derived-class functions through a
 * base-class pointer doesn't work unless the base class has a virtual
 * function of the same name.  I've also learned that in base/derived class
 * pairs using over-ridden virtual functions, the base class needs a virtual
 * destructor if you are going to delete instances of the derived class
 * through base class pointers; else only the base-class portion of the
 * derived class is deleted.
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include <cstdlib>
#include <cstdio>
#include <cstring>
#include <cmath>
#include <iostream>
#include <string>
#include <cctype>
#include <ctime>
#include <new>

using namespace std;

enum AlarmType {burglar, fire};
enum ArmState {disarm, arm};
enum AlarmState {off, on};
enum ZoneType {inzone, outzone};

class Alarm {
  public:
    Alarm() {cout << "in Alarm constructor.\n";}
    ~Alarm() {cout << "in Alarm destructor.\n";}
    void arm(ArmState s){armstate=s;}
    void set(AlarmState s){alarmstate=s;}
  private:
    AlarmType alarmtype;
    volatile ArmState armstate;
    volatile AlarmState alarmstate;
};

class Zone {
  public:
    Zone() {cout << "in Zone constructor\n";}
    virtual ~Zone() {cout << "in Zone destructor\n";}
    void setid(int id) {zoneid=id;}
    void getid(void) {cout << "zone " << zoneid << "\n";}
    void settype(ZoneType t) {zonetype=t;}
    void gettype(void) {
      if (zonetype==inzone) cout << "zone type = inzone (indoors)\n";
      else if (zonetype==outzone) cout << "zone type = outzone (outdoors)\n";
      else cout << "zone type = unknown";
    }
    virtual void checkstatus()=0;
    virtual void countermeasures()=0;
    void callcops(void) {cout << "Calling cops!\n";}
    Alarm *alarm[50];
  private:
    ZoneType zonetype;
    int zoneid;
};

class InZone : public Zone {
  public:
    InZone(int id) {
      cout << "in InZone constructor\n";
      setid(id);       // set unique zone id
      settype(inzone); // set zonetype to inzone (indoors zone)
    }
    ~InZone() {cout << "in InZone destructor\n";}
    void checkstatus(){;}
    void countermeasures(void) {
      getid();
      gettype();
      cout << "Indoor intrusion detected!\n";
      release_nerve_gas();
      callcops();
    }
    void release_nerve_gas() {
      cout << "Releasing nerve gas: FOOF!\n";
    }
  private:
    Alarm entry_alarm;
};

class OutZone : public Zone {
  public:
    OutZone(int id) {
      cout << "in OutZone constructor.\n";
      setid(id);          // set unique zone id
      settype(outzone);   // set zone type to outzone (outdoors zone)
    }
    ~OutZone() {cout << "in OutZone destructor\n";}
    void checkstatus() {;}
    void countermeasures(void) {
      getid();
      gettype();
      cout << "Outdoor intrusion detected!\n";
      release_viscious_dogs();
      callcops();
    }
    void release_viscious_dogs() {
      cout << "Releasing viscious dogs: BOW-WOW!\n";
    }
  private:
    Alarm perimeter_alarm;
};

Zone *zone[500];

int main(int argc, char *argv[]) {
  ios::sync_with_stdio();
  zone[1]=new InZone (1);
  zone[1]->countermeasures();
  delete zone[1];
  zone[1]=new OutZone (1);
  zone[1]->countermeasures();
  delete zone[1];
  return 0;
}

