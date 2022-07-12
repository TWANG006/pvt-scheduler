#include "pch.h"
#include "Calculator.h"

TEST(PVT, Calculator)
{
	Matrix4d C{
		{-1.94992590217139, 0.293111560737720, 0.000188102947941970, 0.00100000000000000},
		{-374.613372696568, 123.610647361385, -13.4834156533495, 0.488848464417675},
		{-2.30659436349973, 1.20950253943883, -0.190793720071104, 0.0129642049007408},
		{23.1925081347043, -18.4357887498925, 4.79933270655633, -0.405776544113590},
	};

	VectorXd t02t1{
		{0, 0.02, 0.04, 0.06, 0.08, 0.1},
	};

	Calculator calc;

	auto ps = calc(t02t1, C.row(0), Calculator::P);
	std::cout << ps << std::endl;

	auto vs = calc(t02t1, C.row(0), Calculator::V);
	std::cout << vs << std::endl;

	auto as = calc(t02t1, C.row(0), Calculator::A);
	std::cout << as << std::endl;

	calc(ps, vs, as, t02t1, C.row(0));
	std::cout << ps.transpose() << std::endl;
	std::cout << vs.transpose() << std::endl;
	std::cout << as.transpose() << std::endl;
}