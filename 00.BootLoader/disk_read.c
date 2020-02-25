//
// Created by yby-lab on 2020-02-24.
//

int main(int argc, char* argv[]) // argc, argv --> 실행파일 옵션 받기
{
	int iTotalSectorCount = 1024; // 인터럽트 256개 x 각 항목의 크기 4바이트
	int iSectorNumber = 2;
	int iHeadNumber = 0;
	int iTrackNumber = 0;
	// 물리 주소 초기화
	char* pcTargetAddress = (char* )0x10000;
	
	while (1) {
		// 전체 섹터 훑기
		if (iTotalSectorCount == 0)
		{
			break;
		}
		iTotalSectorCount = iTotalSectorCount - 1;
		
		// 하나의 섹터를 읽어들여 메모리에 어드레스복사, BIOSReadOneSector --> 섹터 읽기 기능 호출 함수
		if (BIOSReadOneSector(iSectorNumber, iHeadNumber, iTrackNumber, pcTargetAddress) == "ERROR")
		{
			HandleDiskError();
		}
		
		// 1 섹터는 512(0x200) 바이트이므로, 복사한 섹터 수만큼 어드레스 증가
		pcTargetAddress = pcTargetAddress + 0x200;
		
		// 섹터 -> 헤드 -> 트랙 순으로 번호 증가
		iSectorNumber = iSectorNumber + 1;
		if (iSectorNumber < 19)
		{
			continue;
		}
		
		iHeadNumber = iHeadNumber ^ 0x01; // iHeadNumber = ( iHeadNumber == 0x00 ) ? 0x01 : 0x00;
		iSectorNumber = 1;
		
		if (iHeadNumber != 0)
		{
			continue;
		}
		iTrackNumber = iTrackNumber + 1;
	}
	return 0;
}
	
	void HandleDiskError()
	{
		printf("Disk Error~!!");
		while(1);
	}




