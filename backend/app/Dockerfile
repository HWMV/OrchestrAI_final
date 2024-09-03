FROM python:3.11-slim

WORKDIR /app

# 필요한 빌드 도구 및 의존성 설치
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

# pip 업그레이드 및 패키지 설치
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8080

# 환경 변수로 포트 설정
ENV PORT 8080

# 애플리케이션 실행
CMD exec uvicorn main:app --host 0.0.0.0 --port $PORT