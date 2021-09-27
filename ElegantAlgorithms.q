
// Fibonnaci:
// we use the over operator "/" which applies a function recursively n number of times (here 20). We start with the list 0 1 and apply
// recursively over the result to get the fibonacci sequence:
{x,sum -2#x}/[;0 1] 20

// if we want to evaluate each step separately, use "\" instead:
{x,sum -2#x}\[;0 1] 20



// Newton Raphson Algorithm:
// find the zeros of a particular function, let's say for example f(x) = 2 - x^2
// implemetation of Newton Raphson is particularly elegant with over "/" in q. We do not specify the number of iterations,
// and thus run until convergence:

{[xn] xn + (2-xn*xn)%(2*xn)}\[2]



// Quicksort:
// sort an array in n*log(n) time on average
x: 4 7 3 9 8 53 38 29 4 1 48 3 10;
q:{$[2>count distinct x;x;raze q each x where each not scan x < rand x]}
q[x]