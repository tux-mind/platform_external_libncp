/*
    nwdsgetstat.c - NWDSGetNDSStatistics() API demo
    Copyright (C) 2000  Petr Vandrovec

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA


    Revision history:

	1.00  2000, February 2			Petr Vandrovec <vandrove@vc.cvut.cz>
		Initial version, copied from nwdsgethost demo.

*/

#ifndef N_PLAT_LINUX
#include <nwcalls.h>
#include <nwnet.h>
#include <nwclxcon.h>

#include <stdlib.h>
#include <ctype.h>
#include <stdio.h>
#include <string.h>

#include "getopt.h"

#define _(X) X

typedef unsigned int u_int32_t;
typedef unsigned long NWObjectID;
typedef u_int32_t Time_T;
#else
#include <ncp/nwcalls.h>
#include <ncp/nwnet.h>

#include <unistd.h>
#include <stdlib.h>
#include <ctype.h>
#include <wchar.h>
#include <string.h>

#include "private/libintl.h"
#define _(X) gettext(X)
#endif

static char *progname;

static void
usage(void)
{
	fprintf(stderr, _("usage: %s [options]\n"), progname);
}

static void
help(void)
{
	printf(_("\n"
	         "usage: %s [options]\n"), progname);
	printf(_("\n"
	       "-h              Print this help text\n"
	       "-v value        Context DCK_FLAGS value (default 0)\n"
	       "-o object_name  Name of object (default [Root])\n"
	       "-c context_name Name of current context (default OrgUnit.Org.Country)\n"
	       "-C confidence   DCK_CONFIDENCE value (default 0)\n"
	       "-S server       Server to start with (default CDROM)\n"
	       "\n"));
}

#ifndef N_PLAT_LINUX
char* strnwerror(int err) {
	static char errc[200];

	sprintf(errc, "error %u / %d / 0x%X", err, err, err);
	return errc;
}
#endif

int main(int argc, char *argv[]) {
	NWDSCCODE dserr;
	NWDSContextHandle ctx;
	NWCONN_HANDLE conn;
	const char* objectname = "[Root]";
	const char* context = "OrgUnit.Org.Country";
	const char* server = "CDROM";
	int opt;
	u_int32_t ctxflag = 0;
	u_int32_t confidence = 0;
	NDSStatsInfo_T info;

#ifdef N_PLAT_LINUX
	setlocale(LC_ALL, "");
	bindtextdomain(NCPFS_PACKAGE, LOCALEDIR);
	textdomain(NCPFS_PACKAGE);
#endif

	progname = argv[0];

	NWCallsInit(NULL, NULL);
#ifdef N_PLAT_LINUX
	NWDSInitRequester();
#endif

	dserr = NWDSCreateContextHandle(&ctx);
	if (dserr) {
		fprintf(stderr, "NWDSCretateContextHandle failed with %s\n", strnwerror(dserr));
		return 123;
	}
	while ((opt = getopt(argc, argv, "h?o:c:v:S:C:")) != EOF)
	{
		switch (opt)
		{
		case 'C':
			confidence = strtoul(optarg, NULL, 0);
			break;
		case 'o':
			objectname = optarg;
			break;
		case 'c':
			context = optarg;
			break;
		case 'v':
			ctxflag = strtoul(optarg, NULL, 0);
			break;
		case 'h':
		case '?':
			help();
			goto finished;
		case 'S':
			server = optarg;
			break;
		default:
			usage();
			goto finished;
		}
	}

	ctxflag |= DCV_XLATE_STRINGS;
	
	dserr = NWDSSetContext(ctx, DCK_FLAGS, &ctxflag);
	if (dserr) {
		fprintf(stderr, "NWDSSetContext(DCK_FLAGS) failed: %s\n",
			strnwerror(dserr));
		return 123;
	}
	dserr = NWDSSetContext(ctx, DCK_NAME_CONTEXT, context);
	if (dserr) {
		fprintf(stderr, "NWDSSetContext(DCK_NAME_CONTEXT) failed: %s\n",
			strnwerror(dserr));
		return 122;
	}
	dserr = NWDSSetContext(ctx, DCK_CONFIDENCE, &confidence);
	if (dserr) {
		fprintf(stderr, "NWDSSetContext(DCK_CONFIDENCE) failed: %s\n",
			strnwerror(dserr));
		return 122;
	}
#ifdef N_PLAT_LINUX
	{
		static const u_int32_t add[] = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
		dserr = NWDSSetTransport(ctx, 16, add);
		if (dserr) {
			fprintf(stderr, "NWDSSetTransport failed: %s\n",
				strnwerror(dserr));
			return 124;
		}
	}
#endif
#ifdef N_PLAT_LINUX
	if (server[0] == '/') {
		dserr = ncp_open_mount(server, &conn);
		if (dserr) {
			fprintf(stderr, "ncp_open_mount failed with %s\n",
				strnwerror(dserr));
			return 111;
		}
	} else {
		struct ncp_conn_spec connsp;
		long err;
		
		memset(&connsp, 0, sizeof(connsp));
		strcpy(connsp.server, server);
		conn = ncp_open(&connsp, &err);
		if (!conn) {
			fprintf(stderr, "ncp_open failed with %s\n",
				strnwerror(err));
			return 111;
		}
	}
	dserr = NWDSAddConnection(ctx, conn);
#endif
	if (dserr) {
		fprintf(stderr, "Cannot bind connection to context: %s\n",
			strnwerror(dserr));
	}
	dserr = NWDSGetNDSStatistics(ctx, objectname, sizeof(info), &info);
	if (dserr) {
		fprintf(stderr, "NWDSGetNDSStatistics failed with %s\n", 
			strnwerror(dserr));
	} else {
		printf("Stats version:        0x%08X\n", info.statsVersion);
		printf("No such entry:      %12u\n", info.noSuchEntry);
		printf("Local entry:        %12u\n", info.localEntry);
		printf("Type referral:      %12u\n", info.typeReferral);
		printf("Alias referral:     %12u\n", info.aliasReferral);
		printf("Request count:      %12u\n", info.requestCount);
		printf("Request Data Size:  %12u\n", info.requestDataSize);
		printf("Reply Data Size:    %12u\n", info.replyDataSize);
		printf("Reset time:         %12u\n", info.resetTime);
		printf("Transport referral: %12u\n", info.transportReferral);
		printf("Up referral:        %12u\n", info.upReferral);
		printf("Down referral:      %12u\n", info.downReferral);
	}
#ifdef N_PLAT_LINUX	
	NWCCCloseConn(conn);
#endif
	dserr = NWDSFreeContext(ctx);
	if (dserr) {
		fprintf(stderr, "NWDSFreeContext failed with %s\n", strnwerror(dserr));
		return 121;
	}
finished:
	return 0;
}
