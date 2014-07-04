/*******************************************************************************
* Copyright 2011 by the Digital Aggregates Corporation, Colorado, USA
* Licensed under the terms in README.h
* Chip Overclock <coverclock@diag.com>
* http://www.diag.com/navigation/downloads/Biscuit
* Because sometimes BusyBox is built without printenv.
*******************************************************************************/

#include <stdio.h>

int main(int argc, char ** argv, char ** envp)
{
	for (; (envp != (char**)0) && (*envp != (char*)0); ++envp) {
		printf("%s\n", *envp);
	}
	return 0;
}
