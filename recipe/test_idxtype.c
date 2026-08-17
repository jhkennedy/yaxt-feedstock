/* Verify that the installed Xt_int has the width promised by this build's
 * idxtype variant (build string), since autoconf silently ignores an
 * unknown --with-idxtype instead of failing. */
#include <yaxt.h>

int
main(void)
{
  return sizeof(Xt_int) == sizeof(XT_EXPECTED_TYPE) ? 0 : 1;
}
