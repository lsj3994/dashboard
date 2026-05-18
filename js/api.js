/**
 * API 통신 모듈 (Mocked API Fetcher)
 * 실제 백엔드 API 연동으로 전환할 때 이 파일의 엔드포인트 및 파싱 로직만 수정하면 됩니다.
 */

class FinanceAPI {
    /**
     * 서버에서 일자별 차트 데이터 및 타겟 기준값을 비동기로 가져옵니다.
     * @returns {Promise<{targetValue: number, targetX: string|null, chartData: Array<{date: string, amount: number}>}>}
     */
    static async getDailyAssetData() {
        // [JSP 실전 연동 및 URL 파라미터 JSON 동적 파싱 지원]
        // 주소창으로 전달된 매개변수나 서버사이드(POST)에서 주입된 변수를 모두 처리합니다.
        try {
            // 1. 서버(JSP)에서 주입된 POST 방식의 페이로드가 있는지 먼저 확인
            if (window.__SERVER_PAYLOAD__ && 
                window.__SERVER_PAYLOAD__.MetaData && 
                window.__SERVER_PAYLOAD__.MetaData.trim() !== "" &&
                !window.__SERVER_PAYLOAD__.MetaData.includes("<%=")) { // JSP 코드가 그대로 노출되는 로컬 환경 제외
                
                const pMeta = window.__SERVER_PAYLOAD__.MetaData;
                const pDate = window.__SERVER_PAYLOAD__.CharDate;
                const pStand = window.__SERVER_PAYLOAD__.StandData;
                const pPoint = window.__SERVER_PAYLOAD__.StandPoint;

                if (pMeta && pDate) {
                    const parsedAmounts = JSON.parse(pMeta);
                    const parsedDates = JSON.parse(pDate);
                    const parsedTarget = pStand ? JSON.parse(pStand) : 0;
                    
                    let parsedTargetX = null;
                    if (pPoint) {
                        try { parsedTargetX = JSON.parse(pPoint); } 
                        catch(e) { parsedTargetX = pPoint; }
                    }

                    const combinedChartData = parsedDates.map((dateStr, idx) => ({
                        date: dateStr,
                        amount: parsedAmounts[idx] || 0
                    }));

                    return { targetValue: parsedTarget, targetX: parsedTargetX, chartData: combinedChartData };
                }
            }

            // 2. 서버 주입 변수가 없다면 기존처럼 URL 파라미터(GET)에서 찾기
            const href = window.location.href;
            let paramString = "";
            
            // 표준 쿼리스트링(?)뿐만 아니라, 라우팅 형태(&로 시작하는 파라미터)까지 완벽 지원
            if (href.includes('?')) {
                paramString = href.substring(href.indexOf('?') + 1);
            } else if (href.includes('&')) {
                paramString = href.substring(href.indexOf('&') + 1);
            }

            if (paramString) {
                const urlParams = new URLSearchParams(paramString);

                // 영문 매개변수 키 매핑 (기존 한글/표준 키도 하위 호환 유지)
                const paramChartData = urlParams.get('MetaData') || urlParams.get('chartData');
                const paramChartDates = urlParams.get('CharDate') || urlParams.get('ChartDate') || urlParams.get('categories');
                const paramTargetValue = urlParams.get('StandData') || urlParams.get('targetValue');
                const paramTargetX = urlParams.get('StandPoint') || urlParams.get('targetX');

                if (paramChartData && paramChartDates) {
                    const parsedAmounts = JSON.parse(paramChartData);
                    const parsedDates = JSON.parse(paramChartDates);
                    const parsedTarget = paramTargetValue ? JSON.parse(paramTargetValue) : 0;
                    
                    // 기준점(targetX) 파싱 - JSON 문자열 또는 일반 텍스트 모두 지원
                    let parsedTargetX = null;
                    if (paramTargetX) {
                        try {
                            parsedTargetX = JSON.parse(paramTargetX);
                        } catch(e) {
                            parsedTargetX = paramTargetX;
                        }
                    }

                    // 차트 렌더러가 소비하는 표준 규격 데이터로 매핑
                    const combinedChartData = parsedDates.map((dateStr, idx) => ({
                        date: dateStr,
                        amount: parsedAmounts[idx] || 0
                    }));

                    return {
                        targetValue: parsedTarget,
                        targetX: parsedTargetX,
                        chartData: combinedChartData
                    };
                }
            }
        } catch (e) {
            console.warn("데이터 파싱 실패, mock 데이터로 대체합니다.", e);
        }

        // 내장 모의 데이터 (file:// 프로토콜 실행 시 fetch CORS 에러 대응)
        const fallbackData = {
            targetValue: 0,
            targetX: null,
            chartData: []
        };

        try {
            const response = await fetch('./mock-data.json');
            if (!response.ok) throw new Error('Network response was not ok');
            return await response.json();
        } catch (error) {
            console.error('Fetch error:', error);
            return fallbackData;
        }
    }
}
