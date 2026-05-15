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
        // 주소창으로 전달된 매개변수를 완벽하게 감지하여 동적 차트 렌더링용 객체로 즉시 변환합니다.
        try {
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
            console.warn("URL 파라미터 파싱 실패, mock 데이터로 대체합니다.", e);
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
