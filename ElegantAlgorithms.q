
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