#include <stdio.h>
#include <complex.h>
#include <math.h>

const int dbgW=0;
/// Implementation of the Lambert W function, which is a special function that is the inverse of the function f(w) = w * exp(w).
///
/// The Lambert W function is used in various mathematical and scientific applications, including solving equations involving exponential and logarithmic functions.
///
/// - Parameter z: The input value for the Lambert W function.
/// - Returns: The Lambert W function result.
double LambertW(const double z);
