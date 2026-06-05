<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%!
    // 파라미터(POST/GET)와 어트리뷰트(서버 내부 Forward) 모두 탐색하는 헬퍼 함수
    private String getReqData(HttpServletRequest req, String key) {
        String val = req.getParameter(key);
        if (val == null || val.trim().isEmpty()) {
            Object attr = req.getAttribute(key);
            if (attr != null) val = String.valueOf(attr);
        }
        // 혹시 모를 대소문자 차이 (예: metaData vs MetaData) 방어
        if (val == null || val.trim().isEmpty()) {
            String altKey = key.substring(0, 1).toLowerCase() + key.substring(1);
            val = req.getParameter(altKey);
            if (val == null || val.trim().isEmpty()) {
                Object attr = req.getAttribute(altKey);
                if (attr != null) val = String.valueOf(attr);
            }
        }
        // 자바스크립트 백틱 문법 충돌 방지
        return val != null ? val.replace("`", "\\`") : "";
    }
%>
<%
    // 수신 인코딩을 UTF-8로 강제하여 한글 및 JSON 파싱 깨짐 방지
    request.setCharacterEncoding("UTF-8");

    String reqMetaData = getReqData(request, "MetaData");
    String reqCharDate = getReqData(request, "CharDate");
    String reqStandData = getReqData(request, "StandData");
    String reqStandPoint = getReqData(request, "StandPoint");
    String reqTheme = getReqData(request, "Theme");
    String reqMode = getReqData(request, "Mode");
    String reqType = getReqData(request, "Type");
    String reqChartTitle = getReqData(request, "ChartTitle");
%>
<!DOCTYPE html>
<html lang="ko">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>일자별 행위별 진료비 변동 (JSP 실전 대시보드)</title>
    <!-- SEO & Metadata -->
    <meta name="description" content="고품격 다크모드 및 글래스모피즘 기반 일자별 행위별 진료비 변동 동적 대시보드">

    <!-- 서버에서 수신한 POST 파라미터를 클라이언트 JS로 주입 -->
    <script>
        window.__SERVER_PAYLOAD__ = {
            MetaData: `<%= reqMetaData %>`,
            CharDate: `<%= reqCharDate %>`,
            StandData: `<%= reqStandData %>`,
            StandPoint: `<%= reqStandPoint %>`,
            Theme: `<%= reqTheme %>`,
            Mode: `<%= reqMode %>`,
            Type: `<%= reqType %>`,
            ChartTitle: `<%= reqChartTitle %>`
        };
    </script>

    <!-- 
      [실전 JSP 연동 안내]
      클라이언트 단에서 주소창의 파라미터(예: filename.jsp&MetaData=Json&CharDate=Json&StandData=JSON)를 
      자동 감지하여 차트를 동적으로 렌더링하도록 api.js에 URL 파싱 로직이 완벽하게 구현되어 있습니다.
      표준 쿼리스트링(?)뿐만 아니라 라우팅에 의한 & 기호 시작 파라미터까지 모두 유연하게 인식합니다.
    -->

    <!-- Google Fonts: Outfit (헤딩/강조) & Inter (본문/데이터) -->
    <!-- 폐쇄망(오프라인) 환경에서는 아래 폰트 로딩으로 인해 지연이 발생할 수 있어 주석 처리합니다. -->
    <!--
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link
        href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600&family=Outfit:wght@400;500;600;700&display=swap"
        rel="stylesheet">
    -->

    <!-- ApexCharts Library (Local) -->
    <script src="js/apexcharts.min.js"></script>

    <!-- Custom CSS -->
    <link rel="stylesheet" href="css/style.css?v=5">
    <style>
        /* 공통: 모드 변경 버튼 스타일 */
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

        .mode-btn:hover {
            color: var(--text-main);
        }

        /* 1. Mode, Type 활성화 버튼 및 글로우 효과 (커스텀 그래디언트 적용) */
        .mode-btn.active,
        .btn-switch.active {
            background: rgba(255, 255, 255, 0.15) !important;
            color: #ffffff !important;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2) !important;
        }

        /* 2. Light 모드 스타일 정의 (dashboard.jsp 전용) */
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

        body[data-color-mode="light"] .bg-glow {
            opacity: 0.15;
        }

        body[data-color-mode="light"] h1 {
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
        body[data-color-mode="light"] .btn-switch {
            color: var(--text-muted);
        }

        body[data-color-mode="light"] .mode-btn:hover,
        body[data-color-mode="light"] .btn-switch:hover {
            color: var(--text-main);
        }

        body[data-color-mode="light"] .mode-btn.active,
        body[data-color-mode="light"] .btn-switch.active {
            background: rgba(0, 0, 0, 0.1) !important;
            color: #12121b !important;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1) !important;
        }

        /* ApexCharts 스타일 오버라이드 (Light 모드) */
        body[data-color-mode="light"] .apexcharts-text {
            fill: #5f6368 !important;
        }

        body[data-color-mode="light"] .apexcharts-gridline {
            stroke: rgba(0, 0, 0, 0.05) !important;
        }

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

        body[data-color-mode="light"] .apexcharts-tooltip-text {
            color: #12121b !important;
        }

        body[data-color-mode="light"] .apexcharts-menu {
            background: rgba(255, 255, 255, 0.95) !important;
            border: 1px solid rgba(0, 0, 0, 0.1) !important;
            color: #12121b !important;
        }
    </style>
</head>

<body>
    <div class="app-container">
        <!-- 배경 장식용 네온 글로우 효과 엘리먼트 -->
        <div class="bg-glow glow-top-left"></div>
        <div class="bg-glow glow-bottom-right"></div>

        <!-- 메인 대시보드 영역 -->
        <main class="dashboard-wrapper">


            <!-- 메인 차트 컨테이너 (글래스모피즘 패널) -->
            <section class="chart-section glass-card">
                <div class="dashboard-top-panel">
                    <div class="chart-header">
                    <div class="chart-title-area">
                        <h2 id="dashboardTitle">진료비 변동 그래프</h2>
                    </div>

                    <!-- 차트 통합 제어 패널 (테마 선택 및 차트 유형 전환) -->
                    <div class="chart-controls-wrapper">
                        <!-- 다크/라이트 모드 전환 패널 -->
                        <div class="control-group">
                            <span class="control-label">Mode:</span>
                            <div class="button-group mode-switch-group">
                                <button class="mode-btn" data-mode="dark">
                                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                        stroke-width="2">
                                        <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path>
                                    </svg>
                                    Dark
                                </button>
                                <button class="mode-btn active" data-mode="light">
                                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                        stroke-width="2">
                                        <circle cx="12" cy="12" r="5"></circle>
                                        <line x1="12" y1="1" x2="12" y2="3"></line>
                                        <line x1="12" y1="21" x2="12" y2="23"></line>
                                        <line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line>
                                        <line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line>
                                        <line x1="1" y1="12" x2="3" y2="12"></line>
                                        <line x1="21" y1="12" x2="23" y2="12"></line>
                                        <line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line>
                                        <line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line>
                                    </svg>
                                    Light
                                </button>
                            </div>
                        </div>

                        <!-- 테마 선택 스와치 패널 -->
                        <div class="control-group">
                            <span class="control-label">Theme:</span>
                            <div class="theme-swatches">
                                <button class="swatch" data-theme="cyan" title="Neon Cyan"
                                    style="--swatch-color: #00f2fe;"></button>
                                <button class="swatch" data-theme="magenta" title="Cyberpunk Magenta"
                                    style="--swatch-color: #ff2a85;"></button>
                                <button class="swatch" data-theme="emerald" title="Emerald Forest"
                                    style="--swatch-color: #00e676;"></button>
                                <button class="swatch" data-theme="sunset" title="Sunset Glow"
                                    style="--swatch-color: #ff9100;"></button>
                                <button class="swatch active" data-theme="sapphire" title="Royal Sapphire"
                                    style="--swatch-color: #2979ff;"></button>
                                <button class="swatch" data-theme="white" title="Pure White"
                                    style="--swatch-color: #ffffff;"></button>
                            </div>
                        </div>

                        <!-- 차트 유형 전환 패널 -->
                        <div class="control-group">
                            <span class="control-label">Type:</span>
                            <div class="button-group">
                                <button class="btn-switch active" data-type="area">
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                        stroke-width="2">
                                        <path d="M3 3v18h18" />
                                        <path d="M7 14l5-5 5 5 4-4" />
                                    </svg>
                                    Area
                                </button>
                                <button class="btn-switch" data-type="line">
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                        stroke-width="2">
                                        <path d="M3 3v18h18" />
                                        <path d="M7 12l5-5 5 5 4-4" />
                                    </svg>
                                    Line
                                </button>
                                <button class="btn-switch" data-type="bar">
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                        stroke-width="2">
                                        <path d="M3 3v18h18" />
                                        <path d="M18 17V9" />
                                        <path d="M12 17v-4" />
                                        <path d="M6 17v-6" />
                                    </svg>
                                    Bar
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- 실시간 동적 요약 지표 리본 (Max, Min, Avg) -->
                <div class="chart-quick-stats">
                    <div class="mini-stat-card">
                        <span class="mini-label">최고 진료비 (Max)</span>
                        <strong class="mini-val highlight-max" id="statMax">₩0</strong>
                    </div>
                    <div class="mini-stat-card">
                        <span class="mini-label">최저 진료비 (Min)</span>
                        <strong class="mini-val highlight-min" id="statMin">₩0</strong>
                    </div>
                    <div class="mini-stat-card">
                        <span class="mini-label">평균 진료비 (Avg)</span>
                        <strong class="mini-val highlight-avg" id="statAvg">₩0</strong>
                    </div>
                    <div class="mini-stat-card">
                        <span class="mini-label">일당 진료비 (Target)</span>
                        <strong class="mini-val highlight-pink" id="targetDisplay">₩0</strong>
                    </div>
                </div>
                </div>

                <!-- 차트 레이아웃 래퍼 -->
                <div class="chart-render-area">
                    <!-- ApexCharts 실제 렌더링 컨테이너 (절대 위치로 부모 영역을 100% 채움) -->
                    <div id="chartContainer" style="position: absolute; top: 0; left: 0; right: 0; bottom: 0;"></div>
                    <!-- 로딩 스피너 (초기 데이터 fetch 시 표시) -->
                    <div id="loadingOverlay" class="loading-overlay">
                        <div class="spinner"></div>
                        <span>Loading API Data...</span>
                    </div>
                </div>
            </section>
        </main>
    </div>

    <!-- Custom Modules JS -->
    <script src="js/api.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', async () => {
            // 동적 타이틀 적용
            const payloadTitle = window.__SERVER_PAYLOAD__ && window.__SERVER_PAYLOAD__.ChartTitle;
            if (payloadTitle && payloadTitle.trim() !== "" && !payloadTitle.includes("<" + "%=")) {
                document.getElementById('dashboardTitle').innerText = payloadTitle;
            }

            const apiData = await FinanceAPI.getDailyAssetData();
            const targetDisplay = document.getElementById('targetDisplay');
            const loadingOverlay = document.getElementById('loadingOverlay');

            if (loadingOverlay) {
                setTimeout(() => loadingOverlay.remove(), 400);
            }

            const { targetValue, targetX, chartData } = apiData;

            const categories = chartData.map(item => item.date);
            const seriesData = chartData.map(item => item.amount);

            const formatCurrency = (val) => new Intl.NumberFormat('ko-KR', { style: 'currency', currency: 'KRW' }).format(val);

            if (targetDisplay) targetDisplay.textContent = formatCurrency(targetValue);

            const statMaxDom = document.getElementById('statMax');
            const statMinDom = document.getElementById('statMin');
            const statAvgDom = document.getElementById('statAvg');

            if (seriesData.length > 0) {
                const maxVal = Math.max(...seriesData);
                const minVal = Math.min(...seriesData);
                const avgVal = seriesData.reduce((acc, curr) => acc + curr, 0) / seriesData.length;
                if (statMaxDom) statMaxDom.textContent = formatCurrency(maxVal);
                if (statMinDom) statMinDom.textContent = formatCurrency(minVal);
                if (statAvgDom) statAvgDom.textContent = formatCurrency(Math.round(avgVal));
            }

            /* ============================================================
               테마 색상 설정 (각 테마별 차트 색상, 그라데이션, 주석 색상, 라벨 텍스트 색상)
               ============================================================ */
            const THEME_CONFIGS = {
                cyan: { colors: ['#00f2fe'], labelColor: '#12121b', fillStops: [{ offset: 0, color: '#00f2fe', opacity: 0.65 }, { offset: 50, color: '#00f2fe', opacity: 0.35 }, { offset: 100, color: '#00f2fe', opacity: 0.05 }], annotationColor: '#ff2a85', annotationTextColor: '#ffffff' },
                magenta: { colors: ['#ff2a85'], labelColor: '#ffffff', fillStops: [{ offset: 0, color: '#ff2a85', opacity: 0.65 }, { offset: 50, color: '#ff2a85', opacity: 0.35 }, { offset: 100, color: '#ff2a85', opacity: 0.05 }], annotationColor: '#ffaa00', annotationTextColor: '#12121b' },
                emerald: { colors: ['#00e676'], labelColor: '#12121b', fillStops: [{ offset: 0, color: '#00e676', opacity: 0.65 }, { offset: 50, color: '#00e676', opacity: 0.35 }, { offset: 100, color: '#00e676', opacity: 0.05 }], annotationColor: '#00b0ff', annotationTextColor: '#ffffff' },
                sunset: { colors: ['#ff9100'], labelColor: '#12121b', fillStops: [{ offset: 0, color: '#ff9100', opacity: 0.65 }, { offset: 50, color: '#ff9100', opacity: 0.35 }, { offset: 100, color: '#ff9100', opacity: 0.05 }], annotationColor: '#ffd600', annotationTextColor: '#12121b' },
                sapphire: { colors: ['#2979ff'], labelColor: '#ffffff', fillStops: [{ offset: 0, color: '#2979ff', opacity: 0.65 }, { offset: 50, color: '#2979ff', opacity: 0.35 }, { offset: 100, color: '#2979ff', opacity: 0.05 }], annotationColor: '#00e5ff', annotationTextColor: '#12121b' },
                white: { colors: ['#ffffff'], labelColor: '#12121b', fillStops: [{ offset: 0, color: '#ffffff', opacity: 0.7 }, { offset: 50, color: '#ffffff', opacity: 0.35 }, { offset: 100, color: '#ffffff', opacity: 0.05 }], annotationColor: '#e0e0e0', annotationTextColor: '#12121b' }
            };

            /* 상태 관리 변수 (서버에서 전달받은 테마, 모드, 차트 유형 우선 적용) */
            let currentTheme = window.__SERVER_PAYLOAD__?.Theme?.trim() || 'sapphire';
            let currentType = window.__SERVER_PAYLOAD__?.Type?.trim() || 'area';
            let currentMode = window.__SERVER_PAYLOAD__?.Mode?.trim() || 'light';

            if (currentTheme === '' || currentTheme.includes('<' + '%=')) currentTheme = 'sapphire';
            if (currentType === '' || currentType.includes('<' + '%=')) currentType = 'area';
            if (currentMode === '' || currentMode.includes('<' + '%=')) currentMode = 'light';

            /* 설정 반영 */
            document.body.setAttribute('data-color-mode', currentMode);
            document.body.setAttribute('data-theme', currentTheme);

            // 버튼 active 클래스 동적 동기화
            document.querySelectorAll('.swatch').forEach(b => {
                b.classList.toggle('active', b.getAttribute('data-theme') === currentTheme);
            });
            document.querySelectorAll('.btn-switch').forEach(b => {
                b.classList.toggle('active', b.getAttribute('data-type') === currentType);
            });
            document.querySelectorAll('.mode-btn').forEach(b => {
                b.classList.toggle('active', b.getAttribute('data-mode') === currentMode);
            });

            /* ============================================================
               동적으로 테마별 기준값(Annotation) 설정을 반환하는 헬퍼 함수
               - targetValue가 비어있으면 Y축 기준선 숨김
               - targetX가 비어있으면 X축 기준점(화살표) 숨김
               ============================================================ */
            const getAnnotationsConfig = (themeCfg) => {
                const yAnnotations = targetValue ? [{
                    y: targetValue, borderColor: themeCfg.annotationColor, borderWidth: 4, strokeDashArray: 4,
                    label: {
                        borderColor: themeCfg.annotationColor,
                        style: { color: themeCfg.annotationTextColor || '#fff', background: themeCfg.annotationColor, fontFamily: 'Outfit, sans-serif', fontWeight: 600, padding: { left: 10, right: 10, top: 4, bottom: 4 } },
                        text: new Intl.NumberFormat('ko-KR').format(targetValue), position: 'right', textAnchor: 'end', offsetX: -5
                    }
                }] : [];

                const xAnnotations = targetX ? [{
                    x: targetX,
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
                        text: '\uc9c4\ub8cc\ube44 \ub9c8\uc774\ub108\uc2a4 \u27a4',
                        position: 'top',
                        orientation: 'horizontal',
                        offsetX: 75,
                        offsetY: 30
                    }
                }] : [];

                return {
                    yaxis: yAnnotations,
                    xaxis: xAnnotations
                };
            };

            /* ============================================================
               데이터 라벨(진료비 금액) 동적 스타일 헬퍼 함수
               ============================================================ */
            const getDataLabelsConfig = (themeCfg) => {
                return {
                    enabled: true,
                    formatter: function (val) {
                        if(val >= 10000) return Math.round(val / 10000) + '만';
                        return new Intl.NumberFormat('ko-KR').format(val);
                    },
                    offsetY: -5,
                    style: {
                        fontSize: '11px',
                        fontFamily: 'Inter, sans-serif',
                        fontWeight: 700,
                        // ApexCharts에서 style.colors는 라벨 배경(Pill)의 색상을 결정합니다.
                        colors: themeCfg.colors
                    },
                    background: {
                        enabled: true,
                        // background.foreColor가 Pill 내부의 텍스트 색상을 결정합니다.
                        foreColor: themeCfg.labelColor,
                        padding: 6,
                        borderRadius: 6,
                        borderWidth: 0,
                        opacity: 1,
                        dropShadow: {
                            enabled: true,
                            top: 2,
                            left: 2,
                            blur: 3,
                            color: '#000',
                            opacity: 0.25
                        }
                    }
                };
            };

            /* ============================================================
               차트 채우기(Fill) 동적 스타일 헬퍼 함수 (Line/Area/Bar 전환 버그 방지)
               ============================================================ */
            const getFillConfig = (themeCfg, type) => {
                return {
                    type: type === 'line' ? 'solid' : 'gradient',
                    gradient: {
                        type: 'vertical',
                        shadeIntensity: 1,
                        opacityFrom: 0.7,
                        opacityTo: 0.1,
                        stops: [0, 90, 100],
                        colorStops: themeCfg.fillStops
                    }
                };
            };

            /* ============================================================
               초기 차트 생성 및 렌더링
               ============================================================ */
            const initTheme = THEME_CONFIGS[currentTheme];
            const isLightInit = currentMode === 'light';
            const chartOptions = {
                series: [{ name: "\uc9c4\ub8cc\ube44 \uae08\uc561", data: seriesData }],
                chart: { type: currentType, height: '100%', parentHeightOffset: 35, foreColor: isLightInit ? '#5f6368' : '#9e9ea7', toolbar: { show: true } },
                colors: initTheme.colors,
                stroke: { curve: currentType === 'line' ? 'straight' : 'smooth', width: currentType === 'bar' ? 0 : 4 },
                plotOptions: currentType === 'bar' ? { bar: { borderRadius: 6, columnWidth: '55%', dataLabels: { position: 'top' } } } : { bar: { columnWidth: '0%' } },
                grid: { borderColor: isLightInit ? 'rgba(0, 0, 0, 0.05)' : 'rgba(255, 255, 255, 0.05)', strokeDashArray: 5, padding: { bottom: 20 } },
                xaxis: { categories: categories, labels: { style: { colors: isLightInit ? '#5f6368' : '#9e9ea7' } } },
                yaxis: { labels: { style: { colors: isLightInit ? '#5f6368' : '#9e9ea7' } } },
                tooltip: { theme: currentMode, shared: true, intersect: false },
                dataLabels: getDataLabelsConfig(initTheme),
                annotations: getAnnotationsConfig(initTheme),
                fill: getFillConfig(initTheme, currentType)
            };

            let chart = new ApexCharts(document.querySelector("#chartContainer"), chartOptions);
            chart.render();

            /* ============================================================
               차트 재구성 함수 (테마/타입/모드 변경 시 호출)
               - chart.updateOptions 후 Promise.then()으로 주석 강제 재렌더링
               - 이 방식으로 Area/Bar/Line 전환 시 주석이 사라지는 버그를 해결
               ============================================================ */
            const rebuildChart = () => {
                const themeCfg = THEME_CONFIGS[currentTheme];
                const mode = document.body.getAttribute('data-color-mode') || 'light';
                const isLight = mode === 'light';

                const updateCfg = {
                    chart: { type: currentType, parentHeightOffset: 35, foreColor: isLight ? '#5f6368' : '#9e9ea7' },
                    colors: themeCfg.colors,
                    grid: { borderColor: isLight ? 'rgba(0, 0, 0, 0.05)' : 'rgba(255, 255, 255, 0.05)', strokeDashArray: 5, padding: { bottom: 20 } },
                    xaxis: { categories: categories, labels: { style: { colors: isLight ? '#5f6368' : '#9e9ea7' } } },
                    yaxis: { labels: { style: { colors: isLight ? '#5f6368' : '#9e9ea7' } } },
                    tooltip: { theme: mode, shared: true, intersect: false },
                    dataLabels: getDataLabelsConfig(themeCfg),
                    annotations: getAnnotationsConfig(themeCfg),
                    fill: getFillConfig(themeCfg, currentType)
                };

                if (currentType === 'bar') {
                    updateCfg.stroke = { width: 0 };
                    updateCfg.plotOptions = { bar: { borderRadius: 6, columnWidth: '55%', dataLabels: { position: 'top' } } };
                } else {
                    updateCfg.stroke = { curve: currentType === 'line' ? 'straight' : 'smooth', width: 4 };
                    updateCfg.plotOptions = { bar: { columnWidth: '0%' } };
                }

                /* 차트 업데이트 완료 후 주석 강제 재적용 (ApexCharts 렌더링 버그 방지) */
                chart.updateOptions(updateCfg, false, true).then(() => {
                    chart.clearAnnotations();
                    const ann = getAnnotationsConfig(themeCfg);
                    if (ann.yaxis && ann.yaxis.length > 0) chart.addYaxisAnnotation(ann.yaxis[0], false);
                    if (ann.xaxis && ann.xaxis.length > 0) chart.addXaxisAnnotation(ann.xaxis[0], false);
                });
            };

            /* ============================================================
               이벤트 핸들러: 테마 스와치 클릭
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

            /* 이벤트 핸들러: 차트 유형(Area/Line/Bar) 전환 */
            document.querySelectorAll('.btn-switch').forEach(el => {
                el.addEventListener('click', (e) => {
                    document.querySelectorAll('.btn-switch').forEach(b => b.classList.remove('active'));
                    e.currentTarget.classList.add('active');
                    currentType = e.currentTarget.getAttribute('data-type');
                    rebuildChart();
                });
            });

            /* 이벤트 핸들러: 다크/라이트 모드 전환 */
            document.querySelectorAll('.mode-btn').forEach(el => {
                el.addEventListener('click', (e) => {
                    document.querySelectorAll('.mode-btn').forEach(b => b.classList.remove('active'));
                    e.currentTarget.classList.add('active');
                    const mode = e.currentTarget.getAttribute('data-mode');
                    document.body.setAttribute('data-color-mode', mode);
                    rebuildChart();
                });
            });
        });
    </script>
</body>

</html>