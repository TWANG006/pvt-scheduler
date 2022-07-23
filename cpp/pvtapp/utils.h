#ifndef UTILS_H
#define UTILS_H

#include "pvtengine.h"

inline int_t ELT2D(int_t width, int_t x, int_t y) {
	return (y * width + x);
}

#endif // !UTILS_H
