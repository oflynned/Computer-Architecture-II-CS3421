//
// IA32codegen.cpp
//
// Copyright (C) 2012 - 2016 jones@scss.tcd.ie
//

#include "stdafx.h"         // pre-compiled headers
#include <iostream>         // cout
#include "conio.h"          // _getch
#include "t1.h"             //
#include "fib32.h"          //

using namespace std;        // cout

//
// fib: C++
//
int fib(int n)
{
    int fi, fj, t;

    if (n <= 1)
        return n;

    fi = 0;
    fj = 1;
    while (n > 1) {
        t = fj;
        fj = fi + fj;
        fi = t;
        n--;
    }
    return fj;
}

//
// fib: C/C++ and IA32 assembly language
//
int fib_IA32(int n)
{
    _asm {      mov eax, n          }   // mov n into eax
    _asm {      cmp eax, 1          }   // if (n <= 0)
    _asm {      jle L3              }   // return n
    _asm {      xor ecx, ecx        }   // fi = 0
    _asm {      mov edx, 1          }   // fj = 1
    _asm {L1:   cmp eax, 1          }   // while (n > 1)
    _asm {      jle L2              }   //
    _asm {      mov ebx, ecx        }   // ebx = fi
    _asm {      add ebx, edx        }   // ebx = fi + fj
    _asm {      mov ecx, edx        }   // fi = fj
    _asm {      mov edx, ebx        }   // fj = ebx
    _asm {      dec eax             }   // n--
    _asm {      jmp L1              }   //
    _asm {L2:   mov eax, edx        }   // eax = fj
    _asm {L3:                       }   //
}

//
// check
//
void check(char *s, int v, int val)
{
    cout << s << " = " << v;
    if (v == val) {
        cout << " OK";
    } else {
        cout << " ERROR: should be " << v;
    }
    cout << endl;
}

//
// _tmain
//
int _tmain(int argc, _TCHAR* argv[])
{
    //
    // tutorial 1
    //
    check("g", g, 256);
    check("p(1, 2)", p(1, 2), 11);
    check("q(2)", q(2), 1015);
    check("f(6)", f(6), 720);
    cout << endl;

    //
    // fib: C++
    //
    for (int i = -1; i < 20; i++)
        cout << fib(i) << " ";
    cout << endl;

    //
    // fib: mixed C++ and assmbly language
    //
    for (int i = -1; i < 20; i++)
        cout << fib_IA32(i) << " ";
    cout << endl;

    //
    // fib: IA32 assembly language  unoptimised (Debug!)
    //
    for (int i = -1; i < 20; i++)
        cout << fib_IA32a(i) << " ";
    cout << endl;

    //
    // fib: IA32 assembly language optimised (Release!)
    //
    for (int i = -1; i < 20; i++)
        cout << fib_IA32b(i) << " ";
    cout << endl;

    _getch();

    return 0;
}

// eof