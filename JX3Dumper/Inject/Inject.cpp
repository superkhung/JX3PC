#include <windows.h>
#include <stdio.h>

PROCESS_INFORMATION processInfo;

int Inject(HANDLE hProcess, char *fileName)
{
	HANDLE hThread;
	char   filePath [_MAX_PATH];
	void*  pLibRemote = 0;
	DWORD  hLibModule = 0;
	HMODULE hKernel32 = ::GetModuleHandle("Kernel32");

	if (::GetCurrentDirectoryA(_MAX_PATH, filePath) == 0)
		return false;
	
	::strcat_s(filePath, _MAX_PATH, fileName);

	pLibRemote = ::VirtualAllocEx( hProcess, NULL, sizeof(filePath), MEM_COMMIT, PAGE_READWRITE );
	if( pLibRemote == NULL )
		return false;
	
	::WriteProcessMemory(hProcess, pLibRemote, (void*)filePath,sizeof(filePath),NULL);

	hThread = ::CreateRemoteThread( hProcess, NULL, 0,	
					(LPTHREAD_START_ROUTINE) ::GetProcAddress(hKernel32,"LoadLibraryA"), 
					pLibRemote, 0, NULL );
	if( hThread == NULL )
		goto JUMP;

	::WaitForSingleObject( hThread, INFINITE );

	::GetExitCodeThread( hThread, &hLibModule );
	::CloseHandle( hThread );

JUMP:	
	::VirtualFreeEx( hProcess, pLibRemote, sizeof(filePath), MEM_RELEASE );
	if( hLibModule == NULL )
		return false;

	return 0;
}

int StartGame()
{
	STARTUPINFO startupInfo;
    ZeroMemory(&startupInfo, sizeof(STARTUPINFO));
	char *params = "jx3client.exe DOTNOTSTARTGAMEBYJX3CLIENT.EXE";
	
	BOOL cp = CreateProcess(NULL,params,NULL,NULL,TRUE,CREATE_SUSPENDED,NULL,NULL,&startupInfo, &processInfo); 

    if(cp)
    {
		printf("Game started, PID %d\n", processInfo.dwProcessId);
		Sleep(200);
		printf("Injecting dll ...\n");
		Inject(processInfo.hProcess, "\\JX3Hook.dll");
		Sleep(500);
		ResumeThread(processInfo.hThread);
		printf("Check JX3Root/output for extracted files\n");
		getchar();
		return 0;
	}
	return 0;
}

int main(int argc,char **argv)
{
	//SetCurrentDirectory("D:\Games\VoLamTruyenKyPhienBan3D\data");
	printf("JX3 NewPack content dumper - KhaNP\n");
	printf("Starting game client ...\n");
    StartGame();
    return 0;
}