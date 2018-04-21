// RUN: %check_clang_tidy %s misc-add-virtual %t


// CHECK-MESSAGES: [[@LINE+1]]:1: warning: implicit destructor can be slowed down by adding virtual [misc-add-virtual]
class Foo {
  virtual void virt();
  // CHECK-FIXES:  virtual void nonVirtual();
  // CHECK-MESSAGES: [[@LINE+1]]:3: warning: function can be slowed down by adding virtual [misc-add-virtual]
  void nonVirtual();
  // CHECK-FIXES: public: virtual ~Foo() = default;
};

// CHECK-MESSAGES: [[@LINE+1]]:1: warning: implicit destructor can be slowed down by adding virtual [misc-add-virtual]
class Derived : Foo {
  void virt();

  // CHECK-FIXES: virtual int nonVirtual();
  // CHECK-MESSAGES: [[@LINE+1]]:3: warning: function can be slowed down by adding virtual [misc-add-virtual]
  int nonVirtual();


  static int staticFun();

  Derived() = default;
  Derived(const Derived&);
  Derived(Derived&&) = delete;
  // CHECK-FIXES: public: virtual ~Derived() = default;
};

int Derived::nonVirtual() { return 0; }

class Other {

  template <typename T>
  void temp();

  virtual ~Other();
};

template <typename T>
class Templated {

  // CHECK-FIXES: virtual void foo();
  // CHECK-MESSAGES: [[@LINE+1]]:3: warning: function can be slowed down by adding virtual [misc-add-virtual]
  void foo();

  virtual ~Templated();
};

// CHECK-FIXES: template <typename T> void Templated<T>::foo() {}
template <typename T> void Templated<T>::foo() {}

// CHECK-MESSAGES: [[@LINE+1]]:1: warning: implicit destructor can be slowed down by adding virtual [misc-add-virtual]
struct Trivial {
  int a, b;
  // CHECK-MESSAGES: [[@LINE+1]]:3: note: Can't add the virtual here.
  int getA();
  // CHECK-FIXES-NOT: ~Trivial()
};

void use_trivial() {
  Trivial t = Trivial{1, 2};
}