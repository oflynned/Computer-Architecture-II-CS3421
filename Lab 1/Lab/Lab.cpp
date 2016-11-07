//
// IA32codegen.cpp
//
// Copyright (C) 2012 - 2016 jones@scss.tcd.ie
//

#include "stdafx.h"        
#include <iostream>       
#include "conio.h"         
#include "t1.h"             
#include "fib32.h"          

using namespace std; 

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
void check(char *s, int i, int v, long val)
{
    cout << s  << "(" << i << ")" << " = " << v;
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
    //check("g", g, 256);
    //check("p(1, 2)", p(1, 2), 11);
    //check("q(2)", q(2), 1015);
    
	cout << endl;
	for (int i = 1; i < 11; i++) {
		check("f", i, f(i), f(i));
	}
    cout << endl;


    _getch();

    return 0;
}

// eof