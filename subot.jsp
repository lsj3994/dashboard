<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%!
    private String getReqData(HttpServletRequest req, String key) {
        String val = req.getParameter(key);
        if (val == null || val.trim().isEmpty()) {
            Object attr = req.getAttribute(key);
            if (attr != null) val = String.valueOf(attr);
        }
        if (val == null || val.trim().isEmpty()) {
            String altKey = key.substring(0, 1).toLowerCase() + key.substring(1);
            val = req.getParameter(altKey);
            if (val == null || val.trim().isEmpty()) {
                Object attr = req.getAttribute(altKey);
                if (attr != null) val = String.valueOf(attr);
            }
        }
        return val != null ? val.replace("`", "\\`") : "";
    }
%>
<%
    request.setCharacterEncoding("UTF-8");

    String reqMetaData    = getReqData(request, "MetaData");
    String reqCharDate    = getReqData(request, "CharDate");
    String reqStandData   = getReqData(request, "StandData");
    String reqCompareData = getReqData(request, "CompareData");
    String reqCompareName = getReqData(request, "CompareName");
    String reqTheme       = getReqData(request, "Theme");
    String reqMode        = getReqData(request, "Mode");
    String reqType        = getReqData(request, "Type");
    String reqChartTitle  = getReqData(request, "ChartTitle");
    String reqHospDays    = getReqData(request, "HospDays");
    String reqDailyCost   = getReqData(request, "DailyCost");
    String reqDeficitDay  = getReqData(request, "DeficitDay");
%>
<!DOCTYPE html>
<html lang="ko">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>일자별 진료비 변동 그래프 – 누적 대시보드</title>
    <meta name="description" content="일자별 누적 진료비 변동을 시각화하는 고품격 대시보드 – 구간별 색상, 기준선 표시">

    <script>
        window.__SERVER_PAYLOAD__ = {
            MetaData:    `<%= reqMetaData %>`,
            CharDate:    `<%= reqCharDate %>`,
            StandData:   `<%= reqStandData %>`,
            CompareData: `<%= reqCompareData %>`,
            CompareName: `<%= reqCompareName %>`,
            Theme:       `<%= reqTheme %>`,
            Mode:        `<%= reqMode %>`,
            Type:        `<%= reqType %>`,
            ChartTitle:  `<%= reqChartTitle %>`,
            HospDays:    `<%= reqHospDays %>`,
            DailyCost:   `<%= reqDailyCost %>`,
            DeficitDay:  `<%= reqDeficitDay %>`
        };
    </script>

    <!--
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600&family=Outfit:wght@400;500;600;700&display=swap" rel="stylesheet">
    -->

    <script src="js/apexcharts.min.js"></script>
    <link rel="stylesheet" href="css/style.css?v=5">

    <style>
        .mode-btn {
            background: transparent;
            border: none;
            color: var(--text-muted);
            padding: 8px 16px;
            border-radius: 8px;
            font-family: var(--font-body);
            font-size: 0.85rem;
            font-weight: 500;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            transition: var(--transition-smooth);
        }

        .mode-btn:hover { color: var(--text-main); }

        .mode-btn.active,
        .btn-switch.active {
            background: rgba(255, 255, 255, 0.15) !important;
            color: #ffffff !important;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2) !important;
        }

        body[data-color-mode="light"] {
            --bg-base: #f4f6f8;
            --card-bg: rgba(255, 255, 255, 0.85);
            --card-border: rgba(0, 0, 0, 0.08);
            --card-border-hover: rgba(0, 0, 0, 0.15);
            --text-main: #12121b;
            --text-muted: #5f6368;
            background-color: var(--bg-base);
            color: var(--text-main);
        }

        body[data-color-mode="light"] .bg-glow { opacity: 0.15; }

        body[data-color-mode="light"] h1,
        body[data-color-mode="light"] h2 {
            background: linear-gradient(to right, #12121b, var(--text-muted));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        body[data-color-mode="light"] .theme-swatches,
        body[data-color-mode="light"] .button-group {
            background: rgba(0, 0, 0, 0.05);
            border: 1px solid rgba(0, 0, 0, 0.05);
        }

        body[data-color-mode="light"] .mini-stat-card {
            background: rgba(255, 255, 255, 0.6);
            border: 1px solid rgba(0, 0, 0, 0.08);
        }

        body[data-color-mode="light"] .mini-stat-card:hover {
            background: rgba(255, 255, 255, 0.9);
            border-color: rgba(0, 0, 0, 0.15);
        }

        body[data-color-mode="light"] .chart-header {
            border-bottom: 1px solid rgba(0, 0, 0, 0.05);
        }

        body[data-color-mode="light"] .mode-btn,
        body[data-color-mode="light"] .btn-switch { color: var(--text-muted); }

        body[data-color-mode="light"] .mode-btn:hover,
        body[data-color-mode="light"] .btn-switch:hover { color: var(--text-main); }

        body[data-color-mode="light"] .mode-btn.active,
        body[data-color-mode="light"] .btn-switch.active {
            background: rgba(0, 0, 0, 0.1) !important;
            color: #12121b !important;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1) !important;
        }

        body[data-color-mode="light"] .apexcharts-text { fill: #5f6368 !important; }
        body[data-color-mode="light"] .apexcharts-gridline { stroke: rgba(0, 0, 0, 0.05) !important; }

        body[data-color-mode="light"] .apexcharts-tooltip {
            background: rgba(255, 255, 255, 0.95) !important;
            border: 1px solid rgba(0, 0, 0, 0.1) !important;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1) !important;
        }

        body[data-color-mode="light"] .apexcharts-tooltip-title {
            background: rgba(0, 0, 0, 0.03) !important;
            border-bottom: 1px solid rgba(0, 0, 0, 0.05) !important;
            color: #5f6368 !important;
        }

        body[data-color-mode="light"] .apexcharts-tooltip-text { color: #12121b !important; }

        body[data-color-mode="light"] .apexcharts-menu {
            background: rgba(255, 255, 255, 0.95) !important;
            border: 1px solid rgba(0, 0, 0, 0.1) !important;
            color: #12121b !important;
        }

        /* ===== 범례 블록 ===== */
        .legend-block {
            display: flex;
            align-items: center;
            gap: 16px;
            flex-wrap: wrap;
            margin-bottom: 6px;
            padding: 6px 12px;
            border-radius: 8px;
            background: rgba(0, 0, 0, 0.04);
        }

        body[data-color-mode="dark"] .legend-block { background: rgba(255, 255, 255, 0.04); }

        .legend-item {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 0.8rem;
            font-weight: 500;
            color: var(--text-muted);
        }

        .legend-dot { width: 12px; height: 12px; border-radius: 3px; display: inline-block; }
        .legend-line { width: 24px; height: 3px; display: inline-block; border-radius: 2px; }
        .legend-dashed { width: 24px; height: 0; display: inline-block; border-top: 3px dashed; }

        .chart-section {
            display: flex;
            flex-direction: column;
            height: 100%;
        }

        /* ===== 차트 래퍼 (배경 구간 색 캔버스 지원) ===== */
        .chart-canvas-wrapper {
            position: relative;
            flex: 1 1 0;
            min-height: 0;
            width: 100%;
        }

        .zone-bg-canvas {
            position: absolute;
            top: 0; left: 0; width: 100%; height: 100%;
            pointer-events: none;
            z-index: 0;
            border-radius: 8px;
            overflow: hidden;
        }

        .chart-canvas-wrapper #chartContainer {
            position: absolute;
            top: 0; left: 0; right: 0; bottom: 0;
            z-index: 1;
        }

        /* 로딩 오버레이 */
        .loading-overlay {
            position: absolute;
            inset: 0;
            background: rgba(244, 246, 248, 0.85);
            backdrop-filter: blur(8px);
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            gap: 16px;
            z-index: 10;
            border-radius: var(--radius-lg);
            transition: opacity 0.4s ease;
        }

        /* ===== 설정 숨김 토글 버튼 ===== */
        .chart-controls-wrapper {
            display: flex;
            align-items: center;
            flex-wrap: nowrap !important;
            gap: 12px !important;
            white-space: nowrap;
        }

        .chart-controls-wrapper.hidden {
            display: none !important;
        }
        
        .header-actions {
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .fixed-switches-group {
            position: absolute;
            top: 16px;
            right: 24px;
            display: flex;
            align-items: center;
            gap: 20px;
            z-index: 20;
        }

        /* 토글 스위치 형태 (파란색) */
        .toggle-switch-wrapper {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            cursor: pointer;
        }

        .chart-header {
            padding-right: 220px; /* 고정된 스위치 영역 2개 확보 */
        }

        /* 챠트 타이틀 한 줄 처리 및 크기 축소 */
        .chart-title-area {
            min-width: 0; 
        }
        
        #dashboardTitle {
            font-size: 1.65rem !important;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .switch-label {
            font-size: 0.85rem;
            font-weight: 600;
            color: var(--text-muted);
            user-select: none;
        }

        .toggle-switch {
            position: relative;
            display: inline-block;
            width: 44px;
            height: 24px;
        }

        .toggle-switch input {
            opacity: 0;
            width: 0;
            height: 0;
        }

        .toggle-slider {
            position: absolute;
            cursor: pointer;
            top: 0; left: 0; right: 0; bottom: 0;
            background-color: rgba(0, 0, 0, 0.2);
            transition: .4s;
            border-radius: 24px;
        }

        body[data-color-mode="dark"] .toggle-slider {
            background-color: rgba(255, 255, 255, 0.2);
        }

        .toggle-slider:before {
            position: absolute;
            content: "";
            height: 18px;
            width: 18px;
            left: 3px;
            bottom: 3px;
            background-color: white;
            transition: .4s;
            border-radius: 50%;
            box-shadow: 0 2px 4px rgba(0,0,0,0.2);
        }

        .toggle-switch input:checked + .toggle-slider {
            background-color: #2979ff;
        }

        .toggle-switch input:checked + .toggle-slider:before {
            transform: translateX(20px);
        }

        body[data-color-mode="dark"] .loading-overlay { background: rgba(11, 11, 18, 0.85); }
    </style>
</head>

<body>
    <div class="app-container">
        <div class="bg-glow glow-top-left"></div>
        <div class="bg-glow glow-bottom-right"></div>

        <main class="dashboard-wrapper">
            <section class="chart-section glass-card">
                <div class="dashboard-top-panel">
                    <div class="chart-header">
                        <div class="chart-title-area">
                            <h2 id="dashboardTitle">진료비 변동 그래프</h2>
                        </div>

                        <div class="header-actions">
                            <div class="chart-controls-wrapper hidden" id="chartControls">
                            <!-- 다크/라이트 모드 전환 -->
                            <div class="control-group">
                                <span class="control-label">Mode:</span>
                                <div class="button-group mode-switch-group">
                                    <button class="mode-btn" data-mode="dark">
                                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path></svg>
                                        Dark
                                    </button>
                                    <button class="mode-btn active" data-mode="light">
                                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="5"></circle><line x1="12" y1="1" x2="12" y2="3"></line><line x1="12" y1="21" x2="12" y2="23"></line><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line><line x1="1" y1="12" x2="3" y2="12"></line><line x1="21" y1="12" x2="23" y2="12"></line><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line></svg>
                                        Light
                                    </button>
                                </div>
                            </div>

                            <!-- 테마 선택 스와치 -->
                            <div class="control-group">
                                <span class="control-label">Theme:</span>
                                <div class="theme-swatches">
                                    <button class="swatch" data-theme="cyan" title="Neon Cyan" style="--swatch-color: #00f2fe;"></button>
                                    <button class="swatch" data-theme="magenta" title="Cyberpunk Magenta" style="--swatch-color: #ff2a85;"></button>
                                    <button class="swatch" data-theme="emerald" title="Emerald Forest" style="--swatch-color: #00e676;"></button>
                                    <button class="swatch" data-theme="sunset" title="Sunset Glow" style="--swatch-color: #ff9100;"></button>
                                    <button class="swatch active" data-theme="sapphire" title="Royal Sapphire" style="--swatch-color: #2979ff;"></button>
                                    <button class="swatch" data-theme="white" title="Pure White" style="--swatch-color: #ffffff;"></button>
                                </div>
                            </div>

                            <!-- 차트 유형 전환 (Line / Bar) -->
                            <div class="control-group">
                                <span class="control-label">Type:</span>
                                <div class="button-group">
                                    <button class="btn-switch active" data-type="line">
                                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 3v18h18" /><path d="M7 12l5-5 5 5 4-4" /></svg>
                                        Line
                                    </button>
                                    <button class="btn-switch" data-type="bar">
                                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 3v18h18" /><path d="M18 17V9" /><path d="M12 17v-4" /><path d="M6 17v-6" /></svg>
                                        Bar
                                    </button>
                                </div>
                            </div>
                        </div>
                        
                        <!-- 우측 상단 고정 토글 스위치 그룹 -->
                        <div class="fixed-switches-group">
                            <!-- 금액 표기 토글 스위치 (기본: 숨김) -->
                            <label class="toggle-switch-wrapper" title="차트 금액 표시/숨기기">
                                <span class="switch-label">금액 표기</span>
                                <div class="toggle-switch">
                                    <input type="checkbox" id="toggleLabelsCheckbox">
                                    <span class="toggle-slider"></span>
                                </div>
                            </label>

                            <!-- 설정(Mode, Theme) 토글 스위치 -->
                            <label class="toggle-switch-wrapper" title="설정(Mode, Theme) 표시/숨기기">
                                <span class="switch-label">테마 변경</span>
                                <div class="toggle-switch">
                                    <input type="checkbox" id="toggleControlsCheckbox">
                                    <span class="toggle-slider"></span>
                                </div>
                            </label>
                        </div>
                        </div>
                    </div>

                    <!-- 기준수가 정보 카드 (mini-stat-card 스타일) -->
                    <div class="chart-quick-stats" id="standardInfoCards">
                        <div class="mini-stat-card" id="cardStandard" style="display:none;">
                            <span class="mini-label">기준수가</span>
                            <strong class="mini-val highlight-pink" id="cardStandValue">₩0</strong>
                        </div>
                        <div class="mini-stat-card" id="cardDaily" style="display:none;">
                            <span class="mini-label">일당수가</span>
                            <strong class="mini-val highlight-cyan" id="cardDailyValue">₩0</strong>
                        </div>
                        <div class="mini-stat-card" id="cardHospDays" style="display:none;">
                            <span class="mini-label">평균 재원일수</span>
                            <strong class="mini-val highlight-avg" id="cardHospDaysValue">-</strong>
                        </div>
                    </div>

                    <!-- 범례 블록 -->
                    <div class="legend-block" id="legendBlock">
                        <div class="legend-item">
                            <span class="legend-dot" style="background: #1565c0;"></span>
                            누적 진료비
                        </div>
                        <div class="legend-item" id="legendCompare" style="display:none;">
                            <span class="legend-line" id="legendCompareLine" style="background: #ff9100;"></span>
                            <span id="legendCompareName">비교 데이터</span>
                        </div>
                        <div class="legend-item" id="legendStand">
                            <span class="legend-dashed" style="border-color: #d32f2f;"></span>
                            기준수가
                        </div>
                        <div class="legend-item" id="legendSafe">
                            <span class="legend-dot" style="background: rgba(76,175,80,0.4);"></span>
                            수익 안전
                        </div>
                        <div class="legend-item" id="legendWarn">
                            <span class="legend-dot" style="background: rgba(255,193,7,0.4);"></span>
                            손익분기 근접
                        </div>
                        <div class="legend-item" id="legendDanger">
                            <span class="legend-dot" style="background: rgba(244,67,54,0.35);"></span>
                            적자전환 예상
                        </div>
                    </div>
                </div>

                <!-- 차트 캔버스 래퍼 -->
                <div class="chart-canvas-wrapper">
                    <canvas id="zoneBgCanvas" class="zone-bg-canvas"></canvas>

                    <!-- ApexCharts 렌더링 컨테이너 -->
                    <div id="chartContainer"></div>

                    <!-- 로딩 스피너 -->
                    <div id="loadingOverlay" class="loading-overlay">
                        <div class="spinner"></div>
                        <span>Loading Data...</span>
                    </div>
                </div>
            </section>
        </main>
    </div>

    <script src="js/api.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', async () => {
            /* ============================================================
               1. 동적 타이틀 적용 (ChartTitle 파라미터)
               ============================================================ */
            const payloadTitle = window.__SERVER_PAYLOAD__ && window.__SERVER_PAYLOAD__.ChartTitle;
            if (payloadTitle && payloadTitle.trim() !== "" && !payloadTitle.includes("<" + "%=")) {
                document.getElementById('dashboardTitle').innerText = payloadTitle;
            }

            /* ============================================================
               2. 데이터 로드
               ============================================================ */
            const apiData = await FinanceAPI.getDailyAssetData();
            const loadingOverlay = document.getElementById('loadingOverlay');
            if (loadingOverlay) setTimeout(() => loadingOverlay.remove(), 400);

            const { targetValue, chartData } = apiData;
            let categories = chartData.map(item => item.date);

            // 0이나 null 데이터를 앞뒤 값으로 선형 보간(Interpolation)하여 빈 공간에서도 툴팁이 표시되도록 처리
            const fillMissingData = (arr) => {
                let res = [...arr];
                for (let i = 0; i < res.length; i++) {
                    if (res[i] === 0 || res[i] === null) {
                        let prev = null, prevIdx = -1;
                        for (let j = i - 1; j >= 0; j--) {
                            if (res[j] !== 0 && res[j] !== null) { prev = res[j]; prevIdx = j; break; }
                        }
                        let next = null, nextIdx = -1;
                        for (let j = i + 1; j < res.length; j++) {
                            if (res[j] !== 0 && res[j] !== null) { next = res[j]; nextIdx = j; break; }
                        }
                        if (prev !== null && next !== null) {
                            // 중간에 데이터가 빈 날(주말 등)은 앞뒤 값을 연결(보간)하여 툴팁과 선을 유지
                            res[i] = prev + (next - prev) * ((i - prevIdx) / (nextIdx - prevIdx));
                        } else {
                            // 뒤에 더 이상 진짜 데이터가 없는 미래 날짜(trailing 0)이거나, 
                            // 시작 전의 빈 데이터(leading 0)인 경우 차트를 평행하게 긋지 않고 끊어지도록 null 처리
                            res[i] = null;
                        }
                    }
                }
                return res;
            };

            const seriesData = fillMissingData(chartData.map(item => item.amount));

            /* ============================================================
               3. 추가 파라미터 파싱
               ============================================================ */
            const unescapeHTML = (str) => {
                if (!str) return str;
                return str.replace(/&quot;/g, '"').replace(/&#34;/g, '"').replace(/&#39;/g, "'").replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&amp;/g, '&');
            };

            const payload = window.__SERVER_PAYLOAD__ || {};
            const isPayloadValid = (v) => v && v.trim() !== "" && !v.includes("<" + "%=");

            let compareData = [];
            let compareName = '비교 데이터';
            let hospDays = 0;
            let dailyCost = 0;
            let deficitDay = 22;  // 적자전환 시작 일수 (기본 22)

            if (isPayloadValid(payload.CompareData)) {
                try { compareData = JSON.parse(unescapeHTML(payload.CompareData)); } catch(e) { compareData = []; }
            }
            if (isPayloadValid(payload.CompareName)) {
                compareName = unescapeHTML(payload.CompareName).replace(/^"/, '').replace(/"$/, '');
            }
            if (isPayloadValid(payload.HospDays)) {
                hospDays = parseInt(payload.HospDays) || 0;
            }
            if (isPayloadValid(payload.DailyCost)) {
                dailyCost = parseFloat(payload.DailyCost.replace(/,/g, '')) || 0;
            }
            if (isPayloadValid(payload.DeficitDay)) {
                deficitDay = parseInt(payload.DeficitDay) || 22;
            }

            // URL 파라미터에서도 파싱 (GET 방식)
            if (compareData.length === 0) {
                const href = window.location.href;
                let paramString = "";
                if (href.includes('?')) paramString = href.substring(href.indexOf('?') + 1);
                else if (href.includes('&')) paramString = href.substring(href.indexOf('&') + 1);
                if (paramString) {
                    const urlParams = new URLSearchParams(paramString);
                    const pc = urlParams.get('CompareData');
                    if (pc) { try { compareData = JSON.parse(pc); } catch(e) { compareData = []; } }
                    const pcn = urlParams.get('CompareName');
                    if (pcn) compareName = pcn.replace(/^"/, '').replace(/"$/, '');
                    if (!hospDays) { const ph = urlParams.get('HospDays'); if (ph) hospDays = parseInt(ph) || 0; }
                    if (!dailyCost) { const pd = urlParams.get('DailyCost'); if (pd) dailyCost = parseFloat(pd.replace(/,/g, '')) || 0; }
                    const dd = urlParams.get('DeficitDay');
                    if (dd) deficitDay = parseInt(dd) || 22;
                }
            }

            if (compareData.length > 0) {
                compareData = fillMissingData(compareData);
            }
            if (compareName === "평균 실적" || compareName === "평균실적") {
                compareName = "평균 진료비";
            }
            let hasCompare = compareData.some(v => v !== null);
            if (!hasCompare) {
                compareData = [];
            }

            if (hasCompare) {
                const maxLen = Math.max(seriesData.length, compareData.length);
                if (categories.length < maxLen && categories.length > 0) {
                    let lastStr = categories[categories.length - 1];
                    let lastNum = parseInt(lastStr);
                    let suffix = lastStr.replace(/[0-9]/g, '');
                    if (isNaN(lastNum)) lastNum = categories.length;
                    for (let i = categories.length; i < maxLen; i++) {
                        lastNum++;
                        categories.push(lastNum + suffix);
                    }
                }
                
                // ApexCharts에서 두 데이터의 길이가 다를 경우 shared 툴팁이 깨지는 버그를 방지하기 위해 빈 공간을 null로 채움
                while (seriesData.length < maxLen) {
                    seriesData.push(null);
                }
                while (compareData.length < maxLen) {
                    compareData.push(null);
                }
            }

            const zoneData = hasCompare ? compareData : seriesData;

            /* ============================================================
               4. 수익안전 구간 끝 인덱스 계산
                  공식: (데이터값 / 기준수가) >= 0.9 이면 손익분기 근접
                  → 수익안전 끝 = (데이터값 / 기준수가) >= 0.9 인 첫 인덱스
               ============================================================ */
            let safeEndIdx = categories.length;  // 기본: 전체 안전

            if (targetValue) {
                for (let i = 0; i < zoneData.length; i++) {
                    if (zoneData[i] !== null && (zoneData[i] / targetValue) >= 0.9) {
                        safeEndIdx = i;
                        break;
                    }
                }
            }

            /* ============================================================
               5. 적자전환 시작 인덱스 계산 (기준수가의 110% 초과)
               ============================================================ */
            let deficitStartIdx = categories.length;

            if (targetValue) {
                for (let i = 0; i < zoneData.length; i++) {
                    if (zoneData[i] !== null && (zoneData[i] / targetValue) > 1.1) {
                        deficitStartIdx = i;
                        break;
                    }
                }
            }

            // 적자전환 시작점의 카테고리 라벨 (X축 annotation용)
            const deficitLabel = deficitStartIdx < categories.length ? categories[deficitStartIdx] : null;

            /* ============================================================
               6. 기준수가 정보 카드 표시
               ============================================================ */
            const formatNum = (val) => new Intl.NumberFormat('ko-KR').format(val);
            const formatCurrency = (val) => new Intl.NumberFormat('ko-KR').format(val) + '원';
            const formatThousands = (val) => {
                if (!val) return '0';
                return new Intl.NumberFormat('ko-KR').format(Math.round(val / 1000)) + '천';
            };
            const formatThousandsWon = (val) => {
                if (!val) return '0원';
                return new Intl.NumberFormat('ko-KR').format(Math.round(val / 1000)) + '천원';
            };

            // 기준수가 카드
            if (targetValue) {
                document.getElementById('cardStandard').style.display = '';
                document.getElementById('cardStandValue').textContent = formatCurrency(targetValue);
            }

            // 일당수가 카드
            if (dailyCost) {
                document.getElementById('cardDaily').style.display = '';
                document.getElementById('cardDailyValue').textContent = formatCurrency(dailyCost);
            }

            // 기준일자 카드 (HospDays)
            if (hospDays) {
                document.getElementById('cardHospDays').style.display = '';
                document.getElementById('cardHospDaysValue').textContent = hospDays + '일';
            }

            // 타겟(기준수가)이 0이거나 없을 경우 관련 범례 숨김
            if (!targetValue) {
                const hideIds = ['legendStand', 'legendSafe', 'legendWarn', 'legendDanger'];
                hideIds.forEach(id => {
                    const el = document.getElementById(id);
                    if (el) el.style.display = 'none';
                });
            }

            /* ============================================================
               7. 비교 데이터 범례 표시
               ============================================================ */
            if (hasCompare) {
                document.getElementById('legendCompare').style.display = 'inline-flex';
                document.getElementById('legendCompareName').textContent = compareName;
            }

            /* ============================================================
               8. 테마 설정
               ============================================================ */
            const THEME_CONFIGS = {
                cyan:     { colors: ['#00838f', '#ff9100'], labelColor: '#ffffff', compareColor: '#ff9100' },
                magenta:  { colors: ['#ad1457', '#ff9100'], labelColor: '#ffffff', compareColor: '#ff9100' },
                emerald:  { colors: ['#2e7d32', '#ff9100'], labelColor: '#ffffff', compareColor: '#ff9100' },
                sunset:   { colors: ['#e65100', '#2979ff'], labelColor: '#ffffff', compareColor: '#2979ff' },
                sapphire: { colors: ['#1565c0', '#ff9100'], labelColor: '#ffffff', compareColor: '#ff9100' },
                white:    { colors: ['#37474f', '#ff9100'], labelColor: '#ffffff', compareColor: '#ff9100' }
            };

            let currentTheme = payload.Theme?.trim() || 'sapphire';
            let currentType  = payload.Type?.trim()  || 'line';
            let currentMode  = payload.Mode?.trim()  || 'light';
            let currentShowLabels = false; // 기본으로 표 금액 숨김

            if (currentTheme === '' || currentTheme.includes('<' + '%=')) currentTheme = 'sapphire';
            if (currentType  === '' || currentType.includes('<' + '%=') || currentType === 'area') currentType = 'line';
            if (currentMode  === '' || currentMode.includes('<' + '%=')) currentMode = 'light';

            document.body.setAttribute('data-color-mode', currentMode);
            document.body.setAttribute('data-theme', currentTheme);

            document.querySelectorAll('.swatch').forEach(b => b.classList.toggle('active', b.getAttribute('data-theme') === currentTheme));
            document.querySelectorAll('.btn-switch').forEach(b => b.classList.toggle('active', b.getAttribute('data-type') === currentType));
            document.querySelectorAll('.mode-btn').forEach(b => b.classList.toggle('active', b.getAttribute('data-mode') === currentMode));

            /* ============================================================
               9. 배경 구간 색상 캔버스 그리기
               ============================================================ */
            const drawZoneBg = () => {
                const canvas = document.getElementById('zoneBgCanvas');
                if (!canvas) return;
                const wrapper = canvas.parentElement;
                canvas.width = wrapper.offsetWidth;
                canvas.height = wrapper.offsetHeight;
                const ctx = canvas.getContext('2d');
                ctx.clearRect(0, 0, canvas.width, canvas.height);

                if (!targetValue || categories.length === 0) return;

                const total = categories.length;
                const chartLeft = 65;
                const chartRight = 25;
                const chartTop = 10;
                const chartBottom = 40;
                const drawWidth = canvas.width - chartLeft - chartRight;
                const drawHeight = canvas.height - chartTop - chartBottom;

                const isLight = document.body.getAttribute('data-color-mode') === 'light';

                // 녹색 구간 (수익 안전)
                if (safeEndIdx > 0) {
                    const x1 = chartLeft;
                    const x2 = chartLeft + (Math.min(safeEndIdx, total) / total) * drawWidth;
                    ctx.fillStyle = isLight ? 'rgba(76, 175, 80, 0.18)' : 'rgba(76, 175, 80, 0.12)';
                    ctx.fillRect(x1, chartTop, x2 - x1, drawHeight);
                }

                // 노란색 구간 (손익분기 근접)
                const yellowStart = Math.min(safeEndIdx, total);
                const yellowEnd = Math.min(deficitStartIdx, total);
                if (yellowEnd > yellowStart) {
                    const x1 = chartLeft + (yellowStart / total) * drawWidth;
                    const x2 = chartLeft + (yellowEnd / total) * drawWidth;
                    ctx.fillStyle = isLight ? 'rgba(255, 193, 7, 0.18)' : 'rgba(255, 193, 7, 0.12)';
                    ctx.fillRect(x1, chartTop, x2 - x1, drawHeight);
                }

                // 빨간색 구간 (적자전환 예상)
                if (deficitStartIdx < total) {
                    const x1 = chartLeft + (deficitStartIdx / total) * drawWidth;
                    const x2 = chartLeft + drawWidth;
                    ctx.fillStyle = isLight ? 'rgba(244, 67, 54, 0.15)' : 'rgba(244, 67, 54, 0.10)';
                    ctx.fillRect(x1, chartTop, x2 - x1, drawHeight);
                }

                // 구간 텍스트 그리기
                ctx.font = `bold ${Math.max(16, Math.min(24, drawWidth / 25))}px 'Outfit', sans-serif`;
                ctx.textAlign = 'center';
                ctx.textBaseline = 'middle';
                const midY = chartTop + drawHeight * 0.45;

                if (safeEndIdx > 0) {
                    const cx = chartLeft + (Math.min(safeEndIdx, total) / total) * drawWidth / 2;
                    ctx.fillStyle = isLight ? 'rgba(46, 125, 50, 0.5)' : 'rgba(76, 175, 80, 0.45)';
                    ctx.fillText('수익 안전', cx, midY);
                }

                if (yellowEnd > yellowStart) {
                    const cx = chartLeft + ((yellowStart + yellowEnd) / 2 / total) * drawWidth;
                    ctx.fillStyle = isLight ? 'rgba(245, 124, 0, 0.55)' : 'rgba(255, 193, 7, 0.5)';
                    ctx.fillText('손익분기 근접', cx, midY);
                }

                if (deficitStartIdx < total) {
                    const cx = chartLeft + ((deficitStartIdx + total) / 2 / total) * drawWidth;
                    ctx.fillStyle = isLight ? 'rgba(211, 47, 47, 0.5)' : 'rgba(244, 67, 54, 0.45)';
                    ctx.fillText('적자전환 예상', cx, midY);
                }
            };

            setTimeout(drawZoneBg, 500);
            window.addEventListener('resize', drawZoneBg);

            /* ============================================================
               10. Annotation 설정 (기준선 + 적자전환 X축 진료비 마이너스)
               ============================================================ */
            const getAnnotationsConfig = () => {
                const yAnnotations = [];
                const xAnnotations = [];

                // 기준수가 Y축 기준선 (빨간 점선, 큰 글씨 + 보색)
                if (targetValue) {
                    yAnnotations.push({
                        y: targetValue,
                        borderColor: '#d32f2f',
                        borderWidth: 3,
                        strokeDashArray: 6,
                        label: {
                            borderColor: '#d32f2f',
                            style: {
                                color: '#d32f2f',
                                background: '#ffffff',
                                fontFamily: 'Outfit, sans-serif',
                                fontWeight: 700,
                                fontSize: '16px',
                                padding: { left: 14, right: 14, top: 6, bottom: 6 }
                            },
                            text: '기준수가 : ' + formatCurrency(targetValue),
                            position: 'left',
                            textAnchor: 'start',
                            offsetX: 5
                        }
                    });
                }

                // 적자전환 X축 기준선 (진료비 마이너스 표시 – dashboard.jsp 스타일)
                if (deficitLabel) {
                    xAnnotations.push({
                        x: deficitLabel,
                        borderColor: '#00e676',
                        borderWidth: 2,
                        strokeDashArray: 5,
                        label: {
                            borderColor: '#00e676',
                            style: {
                                color: '#ffffff',
                                background: '#00e676',
                                fontFamily: 'Outfit, sans-serif',
                                fontWeight: 700,
                                fontSize: '14px',
                                padding: { left: 14, right: 14, top: 8, bottom: 8 }
                            },
                            text: '\uc9c4\ub8cc\ube44 \ub9c8\uc774\ub108\uc2a4 \u27A4',
                            position: 'top',
                            orientation: 'horizontal',
                            offsetX: 75,
                            offsetY: 30
                        }
                    });
                }

                return { yaxis: yAnnotations, xaxis: xAnnotations };
            };

            /* ============================================================
               11. 데이터 라벨 설정
               ============================================================ */
            const getDataLabelsConfig = (themeCfg) => ({
                enabled: currentShowLabels,
                formatter: function (val) {
                    if (val === null || val === 0 || val === undefined) return '';
                    return formatThousandsWon(val);
                },
                offsetY: -5,
                style: {
                    fontSize: '10px',
                    fontFamily: 'Inter, sans-serif',
                    fontWeight: 700,
                    colors: [themeCfg.colors[0], themeCfg.compareColor || '#ff9100']
                },
                background: {
                    enabled: true,
                    foreColor: themeCfg.labelColor,
                    padding: 5,
                    borderRadius: 5,
                    borderWidth: 0,
                    opacity: 1,
                    dropShadow: { enabled: true, top: 2, left: 2, blur: 3, color: '#000', opacity: 0.2 }
                }
            });

            /* ============================================================
               12. Y축 최대값 계산
               ============================================================ */
            const calcYMax = () => {
                const vals = [...seriesData];
                if (targetValue) vals.push(targetValue);
                if (hasCompare) vals.push(...compareData);
                const maxVal = Math.max(...vals);
                return Math.ceil(maxVal * 1.15);
            };

            /* ============================================================
               13. 시리즈 구성
               ============================================================ */
            const buildSeries = () => {
                const series = [{ name: '누적 진료비', data: seriesData }];
                if (hasCompare) series.push({ name: compareName, data: compareData });
                return series;
            };

            /* ============================================================
               14. 차트 생성
               ============================================================ */
            const initTheme = THEME_CONFIGS[currentTheme];
            const isLightInit = currentMode === 'light';
            const chartColors = hasCompare ? [initTheme.colors[0], initTheme.compareColor] : [initTheme.colors[0]];

            const chartOptions = {
                series: buildSeries(),
                chart: {
                    type: currentType,
                    height: '100%',
                    parentHeightOffset: 35,
                    foreColor: isLightInit ? '#5f6368' : '#9e9ea7',
                    toolbar: { show: true },
                    background: 'transparent'
                },
                colors: chartColors,
                stroke: {
                    curve: 'smooth',
                    width: currentType === 'bar' ? 0 : [4, hasCompare ? 3 : 0],
                    dashArray: [0, hasCompare ? 5 : 0]
                },
                markers: {
                    size: currentType === 'bar' ? 0 : [5, hasCompare ? 4 : 0],
                    colors: chartColors,
                    strokeColors: '#fff',
                    strokeWidth: 2,
                    hover: { sizeOffset: 3 }
                },
                plotOptions: currentType === 'bar' ? { bar: { borderRadius: 6, columnWidth: '55%', dataLabels: { position: 'top' } } } : { bar: { columnWidth: '0%' } },
                grid: {
                    borderColor: isLightInit ? 'rgba(0, 0, 0, 0.08)' : 'rgba(255, 255, 255, 0.05)',
                    strokeDashArray: 5,
                    padding: { bottom: 20 }
                },
                xaxis: {
                    categories: categories,
                    labels: { style: { colors: isLightInit ? '#5f6368' : '#9e9ea7', fontSize: '11px' } },
                    axisBorder: { color: isLightInit ? 'rgba(0,0,0,0.12)' : 'rgba(255,255,255,0.12)' },
                    axisTicks: { color: isLightInit ? 'rgba(0,0,0,0.12)' : 'rgba(255,255,255,0.12)' }
                },
                yaxis: {
                    min: 0,
                    max: calcYMax(),
                    labels: {
                        style: { colors: isLightInit ? '#5f6368' : '#9e9ea7' },
                        formatter: (val) => formatThousands(val)
                    }
                },
                tooltip: {
                    theme: currentMode,
                    shared: true,
                    intersect: false,
                    y: { formatter: (val) => formatThousandsWon(val) }
                },
                dataLabels: getDataLabelsConfig(initTheme),
                annotations: getAnnotationsConfig(),
                fill: { type: 'solid' },
                legend: { show: false }
            };

            let chart = new ApexCharts(document.querySelector("#chartContainer"), chartOptions);
            chart.render();

            /* ============================================================
               15. 차트 재구성 함수
               ============================================================ */
            const rebuildChart = () => {
                const themeCfg = THEME_CONFIGS[currentTheme];
                const mode = document.body.getAttribute('data-color-mode') || 'light';
                const isLight = mode === 'light';
                const rebuildColors = hasCompare ? [themeCfg.colors[0], themeCfg.compareColor] : [themeCfg.colors[0]];

                const updateCfg = {
                    chart: { type: currentType, parentHeightOffset: 35, foreColor: isLight ? '#5f6368' : '#9e9ea7', background: 'transparent' },
                    colors: rebuildColors,
                    grid: { borderColor: isLight ? 'rgba(0,0,0,0.08)' : 'rgba(255,255,255,0.05)', strokeDashArray: 5, padding: { bottom: 20 } },
                    xaxis: {
                        categories: categories,
                        labels: { style: { colors: isLight ? '#5f6368' : '#9e9ea7', fontSize: '11px' } },
                        axisBorder: { color: isLight ? 'rgba(0,0,0,0.12)' : 'rgba(255,255,255,0.12)' },
                        axisTicks: { color: isLight ? 'rgba(0,0,0,0.12)' : 'rgba(255,255,255,0.12)' }
                    },
                    yaxis: {
                        min: 0,
                        max: calcYMax(),
                        labels: { style: { colors: isLight ? '#5f6368' : '#9e9ea7' }, formatter: (val) => formatThousands(val) }
                    },
                    tooltip: { theme: mode, shared: true, intersect: false, y: { formatter: (val) => formatThousandsWon(val) } },
                    dataLabels: getDataLabelsConfig(themeCfg),
                    annotations: getAnnotationsConfig(),
                    fill: { type: 'solid' },
                    markers: {
                        size: currentType === 'bar' ? 0 : [5, hasCompare ? 4 : 0],
                        colors: rebuildColors,
                        strokeColors: '#fff',
                        strokeWidth: 2,
                        hover: { sizeOffset: 3 }
                    },
                    legend: { show: false }
                };

                if (currentType === 'bar') {
                    updateCfg.stroke = { width: 0 };
                    updateCfg.plotOptions = { bar: { borderRadius: 6, columnWidth: '55%', dataLabels: { position: 'top' } } };
                } else {
                    updateCfg.stroke = { curve: 'smooth', width: [4, hasCompare ? 3 : 0], dashArray: [0, hasCompare ? 5 : 0] };
                    updateCfg.plotOptions = { bar: { columnWidth: '0%' } };
                }

                chart.updateOptions(updateCfg, false, true).then(() => {
                    chart.clearAnnotations();
                    const ann = getAnnotationsConfig();
                    ann.yaxis.forEach(a => chart.addYaxisAnnotation(a, false));
                    ann.xaxis.forEach(a => chart.addXaxisAnnotation(a, false));
                });

                setTimeout(drawZoneBg, 300);
            };

            /* ============================================================
               16. 이벤트 핸들러
               ============================================================ */
            document.querySelectorAll('.swatch').forEach(el => {
                el.addEventListener('click', (e) => {
                    document.querySelectorAll('.swatch').forEach(b => b.classList.remove('active'));
                    e.currentTarget.classList.add('active');
                    currentTheme = e.currentTarget.getAttribute('data-theme');
                    document.body.setAttribute('data-theme', currentTheme);
                    rebuildChart();
                });
            });

            document.querySelectorAll('.btn-switch').forEach(el => {
                el.addEventListener('click', (e) => {
                    document.querySelectorAll('.btn-switch').forEach(b => b.classList.remove('active'));
                    e.currentTarget.classList.add('active');
                    currentType = e.currentTarget.getAttribute('data-type');
                    rebuildChart();
                });
            });

            document.querySelectorAll('.mode-btn').forEach(el => {
                el.addEventListener('click', (e) => {
                    document.querySelectorAll('.mode-btn').forEach(b => b.classList.remove('active'));
                    e.currentTarget.classList.add('active');
                    const mode = e.currentTarget.getAttribute('data-mode');
                    document.body.setAttribute('data-color-mode', mode);
                    rebuildChart();
                });
            });

            // 설정 토글 스위치 핸들러
            const toggleCheckbox = document.getElementById('toggleControlsCheckbox');
            const controlsWrapper = document.getElementById('chartControls');
            if (toggleCheckbox && controlsWrapper) {
                toggleCheckbox.addEventListener('change', (e) => {
                    if (e.target.checked) {
                        controlsWrapper.classList.remove('hidden');
                    } else {
                        controlsWrapper.classList.add('hidden');
                    }
                    // 레이아웃 변경 후 차트와 캔버스가 새 크기에 맞게 다시 그려지도록 리사이즈 이벤트 발생
                    setTimeout(() => window.dispatchEvent(new Event('resize')), 100);
                });
            }

            // 금액 표기 토글 스위치 핸들러
            const toggleLabelsCheckbox = document.getElementById('toggleLabelsCheckbox');
            if (toggleLabelsCheckbox) {
                toggleLabelsCheckbox.addEventListener('change', (e) => {
                    currentShowLabels = e.target.checked;
                    rebuildChart();
                });
            }
        });
    </script>
</body>

</html>
