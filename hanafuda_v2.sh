#!/bin/bash

# 환경 변수 설정
export WORK="/root/hanafuda-bot"
export NVM_DIR="$HOME/.nvm"

# 색상 정의
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # 색상 초기화

echo -e "${GREEN}hanafuda-bot을 설치합니다.${NC}"
echo -e "${GREEN}스크립트작성자: https://t.me/kjkresearch${NC}"
echo -e "${GREEN}출처: https://github.com/Widiskel/hanafuda-bot${NC}"

echo -e "${GREEN}설치 옵션을 선택하세요:${NC}"
echo -e "${YELLOW}1. hanafuda-bot 새로 설치${NC}"
echo -e "${YELLOW}2. 재실행하기${NC}"
read -p "선택: " choice

case $choice in
  1)
    echo -e "${GREEN}hanafuda-bot을 새로 설치합니다.${NC}"

    # 사전 필수 패키지 설치
    echo -e "${YELLOW}시스템 업데이트 및 필수 패키지 설치 중...${NC}"
    sudo apt update
    sudo apt install -y git

    echo -e "${YELLOW}작업 공간 준비 중...${NC}"
    if [ -d "$WORK" ]; then
        echo -e "${YELLOW}기존 작업 공간 삭제 중...${NC}"
        rm -rf "$WORK"
    fi

    # GitHub에서 코드 복사
    echo -e "${YELLOW}GitHub에서 코드 복사 중...${NC}"
    git clone https://github.com/Widiskel/hanafuda-bot
    cd "$WORK"

    # Node.js LTS 버전 설치 및 사용
    echo -e "${YELLOW}Node.js LTS 버전을 설치하고 설정 중...${NC}"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # nvm을 로드합니다
    nvm install --lts
    nvm use --lts
    npm install

    # 사용자로부터 설정 정보 입력받기
    echo -e "${YELLOW}기본 디파짓 금액은 1회당 0.00001ETH입니다.${NC}"
    read -p "자동 디파짓을 실행하시겠습니까? (true/false): " deposit_choice
    read -p "데일리 디파짓 횟수를 입력하세요 (숫자): " daily_deposit_count
    read -p "$네트워크를 선택하세요 (BASE/ARB): " network_choice

    # config.js 파일 생성
    {
        echo "export class Config {"
        echo "  static USEDEPOSIT = $deposit_choice; // TURN ON OR OFF DEPOSIT"
        echo "  static NETWORK = \"$network_choice\"; // ARB or BASE"
        echo "  static DEPOSITAMOUNT = 0.00001; // DEPOSIT AMOUNT"
        echo "  static DAILYDEPOSITCOUNT = $daily_deposit_count; // DEPOSIT COUNT DAILY"
        echo "  static GWEIPRICE = 0.15; // GWEI PRICE"
        echo "  static WAITFORBLOCKCONFIRMATION = true; // IF TRUE AFTER TX EXECUTED BOT WILL WAIT TX TO BE MINED FIRST, IF FALSE AFTER TX EXECUTED BOT WILL CONTINUE TO NEXT TX"
        echo "  static DISPLAY = \"BLESS\"; // TWIST or BLESS"
        echo "}"
    } > "$WORK/config/config.js"
    cp $WORK_DIR/config/config.js $WORK_DIR/app/accounts/config.js
    
    # 프록시파일 생성
    echo -e "${YELLOW}프록시 정보를 입력하세요. 입력형식: http://user:pass@ip:port${NC}"
    echo -e "${YELLOW}여러 개의 프록시는 줄바꿈으로 구분하세요.${NC}"
    echo -e "${YELLOW}입력을 마치려면 엔터를 두 번 누르세요.${NC}"

    {
        echo "export const proxyList = ["  # 파일 시작
        while IFS= read -r line; do
            [[ -z "$line" ]] && break
            # 입력된 프록시 정보를 그대로 사용
            echo "  \"$line\","
        done
        echo "];"  # 배열 끝
    } > "$WORK/config/proxy_list.js"
    
    # 사용자로부터 계정 정보 입력받기
    echo -e "${GREEN}사용자 정보를 입력받습니다.${NC}"
    echo -e "${YELLOW}리프레시 토큰을 얻기위해 다음을 따르세요.${NC}"
    echo -e "${YELLOW}1.https://hanafuda.hana.network/ 에 접속합니다.${NC}"
    echo -e "${YELLOW}2.F12를 누른 후 상단탭에서 애플리케이션을 클릭합니다.${NC}"
    echo -e "${YELLOW}3.좌측탭에서 세션 저장소를 클릭한 후 https://hanafuda를 클립합니다${NC}"
    echo -e "${YELLOW}4.가운데창에서 firebase:auth라는 것을 클릭하시고 sTsTokenManager를 클릭합니다.${NC}"

    read -p "따옴표를 제외한 리프레시토큰을 입력하세요. (쉼표로 구분): " refreshtk
    read -p "프라이빗키를 입력하세요 (쉼표로 구분): " account
    
    # IFS 설정 후 배열 초기화
    IFS=',' read -r -a private_keys <<< "$account"
    IFS=',' read -r -a refresh <<< "$refreshtk"

    # 월렛정보저장
        {
            echo "export const accountLists = ["
            for i in "${!private_keys[@]}"; do
                echo "  {"
                echo "    refreshToken: \"${refresh[$i]}\","
                echo "    pk: \"${private_keys[$i]}\","
                echo "  },"
            done
            echo "];"
        } > $WORK_DIR/accounts/accounts.js
      cp $WORK_DIR/accounts/accounts.js $WORK_DIR/app/accounts/accounts.js

    # 봇 구동
    npm run start
    ;;
    
  2)
    echo -e "${GREEN}hanafuda-bot을 재실행합니다.${NC}"
    
    # nvm을 로드합니다
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # nvm을 로드합니다
    cd "$WORK"

    # 봇 구동
    npm run start
    ;;

  *)
    echo -e "${RED}잘못된 선택입니다. 다시 시도하세요.${NC}"
    ;;
esac
