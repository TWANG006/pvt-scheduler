// pvtengine.cpp : Defines the exported functions for the DLL.
//

#include "pch.h"
#include "framework.h"
#include "pvtengine.h"


// This is an example of an exported variable
PVTENGINE_API int npvtengine = 0;

// This is an example of an exported function.
PVTENGINE_API int fnpvtengine(void)
{
	std::cout << "Hello world from PVT engine." << std::endl;
	return 0;
}

// This is the constructor of a class that has been exported.
Cpvtengine::Cpvtengine()
{
	return;
}
