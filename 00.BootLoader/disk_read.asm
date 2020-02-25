TOTALSECTORCOUNT:   dw  1024    ; 부트로더를 제외한 MINT64 OS이미지의 크기
                                ; 최대 1152 섹터(0x90000byte)까지 가능
SECTORNUMBER:       db  0x02    ; OS 이미지가 시작하는 섹터 번호를 저장하는 영역
HEADNUMBER:         db  0x00    ; OS 이미지가 시작하는 헤드 번호를 저장하는 영역
TRACKNUMBER:        db  0x00    ; OS 이미지가 시작하는 트랙 번호를 저장하는 영역

    ;디스크의 내용을 메모리로 복사할 어드레스(ES:BX)를 0x1000으로 설정
    mov si, 0x1000      ; OS 이미지를 복사할 어드레스(0x10000)를 세그먼트 레지스터 값으로 변환
    mov es, si          ; ES 세그먼트에 값 설정
    mov bx, 0x0000      ; BX 레지스터에 0x0000을 설정하여 복사할 어드레스를 0x1000:0000(0x10000)으로 최종 설정

    mov di, word [ TOTALSECTORCOUNT ]   ; 복사할 OS 이미지의 섹터 수를 DI 레지스터에 설정

READDATA:               ; 디스크를 읽는 코드의 시작
    ; 모든 섹터를 다 읽었는지 확인
    cmp di, 0           ; 복사할 OS의 이미지의 섹터 수를 0과 비교
    je READEND          ; 복사할 섹터 수가 0이라면 다 복사했으므로 READEND로 이동
    sub di, 0x01        ; 복사할 섹터 수를 1 감소

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; BIOS Read Function 호출
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov ah, 0x02                    ; BIOS 서비스 번호 2(Read Sector)
    mov al, 0x1                     ; 읽을 섹터 수는 1
    mov ch, byte [ TRACKNUMBER ]    ; 읽을 트랙 번호 설정
    mov cl, byte [ SECTORNUMBER ]   ; 읽을 섹터 번호 설정
    mov dh, byte [ HEADNUMBER ]     ; 읽을 헤드 번호 설정
    mov dl, 0x00                    ; 읽을 드라이브 번호(0=Floppy) 설정
    int 0x13                        ; 인터럽트 서비스 수행
    jc HANDLEDISKERROR              ; 에러가 발생했다면 HANDLEDISKERROR로 이동

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; 복사할 어드레스와 트랙, 헤드 섹터 어드레스 계산
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    add si, 0x0020      ; 512(0x200)바이트 만큼 읽었으므로 이를 세그먼트 레지스터 값으로 변환
    mov es, si          ; ES 세그먼트 레지스터에 더해서 어드레스를 한 섹터만큼 증가

    ; 한 섹터를 읽었으므로 섹터 번호를 증가시키고 마지막 섹터(18)까지 읽었는지 판단
    ; 마지막 섹터가 아니면 섹터 읽기로 이동해서 다시 섹터 읽기 수행
    mov al, byte [ SECTORNUMBER ]   ; 섹터 번호를 AL레지스터에 설정
    add al, 0x01                    ; 섹터 번호를 1 증가
    mov byte [ SECTORNUMBER ], al   ; 증가시킨 섹터 번호를 SECTORNUMBER에 다시 설정
    cmp al, 19                      ; 증가시킨 섹터 번호를 19와 비교
    jl READDATA                     ; 섹터 번호가 19미만이라면 READDATA로 이동
    
    ; 마지막 섹터까지 읽었으면(섹터 번호가 19이면) 헤드를 토글(0->1, 1->0)하고, 섹터 번호를 1로 설정
    xor byte [ HEADNUMBER ], 0x01   ; 헤드 번호를 0x01과 XOR하여 토글(0->1, 1->0)
    mov byte [ SECTORNUMBER ], 0x01 ; 섹터 번호를 다시 1 로 설정
    
    ; 만약 헤드가 1->0으로 바뀌었으면 양쪽 헤드를 모두 읽은것이므로 아래로 이동하여 트랙 번호를 1 증가
    cmp byte [ HEADNUMBER ], 0x00   ; 헤드 번호를 0x00과 비교
    jne READDATA                    ; 헤드 번호가 0이 아니면 READDATA로 이동
    
    ; 트랙을 1 증가시킨 후, 다시 섹터 읽기로 이동
    add byte [ TRACKNUMBER ] , 0x01 ; 트랙 번호를 1 증가
    jmp READDATA                    ; READDATA로 이동

    ; 스택을 0x0000:0000~0x0000:FFFF 영역에서 64KB 크기로 생성
    mov ax, 0x0000  ; 스택 세그먼트의 시작 어드레스(0x0000)를 세그먼트 레지스터 값으로 변환
    mov SS, ax      ; SS 세그먼트 레지스터에 설정
    mov sp, 0xFFFE  ; SP 레지스터의 어드레스를 0xFFFE로 설정
    mov bp, 0xFFFE  ; BP 레지스터의 어드레스를 0xFFFE로 설정

    ; 어셈블리어의 함수 호출 코드
    push word [ pcString ]
    push word [ iY ]
    push word [ iX ]
    call PRINTMESSAGE
    add sp, 6

READEND:

HANDLEDISKERROR:    ; 에러를 처리하는 코드
    ; 생략