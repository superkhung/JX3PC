#include <windows.h>
#include <stdio.h>
#include <direct.h>
#include "detours.h"

#define SIZE 6
//#define savelua
#define codeinject
#define codehijack

typedef UINT(__cdecl *PLUALOADBUFFER)(int, char*, int, char*);
UINT __cdecl h_luaL_loadbuffer(int, char*, int, char*);
PLUALOADBUFFER o_luaL_loadbuffer = NULL;

int CreateFolder(char * nPath)
{
	char tPath[255];
	if (nPath[0]=='/'||nPath[0]=='\\')
	{
		nPath++;
	}
	for (size_t i = 1; i < strlen(nPath); i++)
	{
		if (nPath[i] == '/')nPath[i] = '\\';
		if (nPath[i] == '\\')
		{
			memcpy(tPath, nPath, i );
			tPath[i] = 0;
			_mkdir(tPath);
		}
	}
	return 1;
}

INT APIENTRY DllMain(HMODULE hDLL, DWORD Reason, LPVOID Reserved)
{
    switch(Reason)
    {
    case DLL_PROCESS_ATTACH:
		{
			while (!o_luaL_loadbuffer)
			{
				o_luaL_loadbuffer = (PLUALOADBUFFER) GetProcAddress(GetModuleHandle("engine_lua5.dll"), "luaL_loadbuffer");
			}
			DetourTransactionBegin();
            DetourUpdateThread(GetCurrentThread());
			DetourAttach(&(PVOID&) o_luaL_loadbuffer, h_luaL_loadbuffer);
            DetourTransactionCommit();
			break;
		}
    case DLL_PROCESS_DETACH:
    case DLL_THREAD_ATTACH:
    case DLL_THREAD_DETACH:
        break;
    }
    return TRUE;
}

UINT __cdecl h_luaL_loadbuffer(int lState, char *lBuffer, int lSize, char *lFileName)
{
#ifdef savelua
	FILE *fp;
	char tmp[256];
	sprintf_s(tmp, sizeof(tmp), "outlua\\%s", lFileName);
	CreateFolder(tmp);
	fopen_s(&fp, tmp, "wb");
	fwrite(lBuffer, 1, lSize, fp);
	fclose(fp);
#endif
	char *filterName;
	
	if (strstr(lFileName, "interface") != NULL || strstr(lFileName, "Interface") != NULL )
	{
		return o_luaL_loadbuffer(lState, lBuffer, lSize, lFileName);
	}
	if (lFileName[0] == '@')
	{
		filterName = lFileName + 1;
		if (filterName[0] == '\\')
			filterName = filterName + 1;
	}

	if (filterName[0] == '\\')
		filterName = filterName + 1;
	//OutputDebugString(filterName);
	FILE *fp;
	if (fopen_s(&fp, filterName, "r"))
	{
		//OutputDebugString("Cant open file.");
		return o_luaL_loadbuffer(lState, lBuffer, lSize, lFileName);
	}
	else
	{
		OutputDebugString("Injected");
		OutputDebugString(filterName);
		fseek(fp, 0, SEEK_END);
		int fileSize = ftell(fp);
		rewind(fp);

		char *newbuff = (char*) malloc(fileSize + 1);
		memset(newbuff, 0, fileSize + 1);
		fread(newbuff, 1, fileSize, fp);
		fclose(fp);
		return o_luaL_loadbuffer(lState, newbuff, strlen(newbuff), lFileName);
	}
	return o_luaL_loadbuffer(lState, lBuffer, lSize, lFileName);
}

