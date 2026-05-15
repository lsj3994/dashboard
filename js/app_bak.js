/**
 * 대시보드 메인 제어 로직 (App Controller)
 */

document.addEventListener('DOMContentLoaded', async () => {
진료비 마이너스  const loadingOverlay = document.getElementById('loadingOverlay');
진료비 마이너스  const targetDisplay = document.getElementById('targetDisplay');
진료비 마이너스  const latestDisplay = document.getElementById('latestDisplay');
진료비 마이너스  const typeButtons = document.querySelectorAll('[data-type]');

진료비 마이너스  // 금액 포맷터 (한국 원화)
진료비 마이너스  const formatCurrency = (val) => {
진료비 마이너스 진료비 마이너스   return new Intl.NumberFormat('ko-KR', { style: 'currency', currency: 'KRW' }).format(val);
진료비 마이너스  };

진료비 마이너스  // 1. API 데이터 비동기 호출
진료비 마이너스  const apiData = await FinanceAPI.getDailyAssetData();
진료비 마이너스  
진료비 마이너스  // 로딩 오버레이 페이드 아웃
진료비 마이너스  if (loadingOverlay) {
진료비 마이너스 진료비 마이너스   loadingOverlay.style.opacity = '0';
진료비 마이너스 진료비 마이너스   setTimeout(() => loadingOverlay.remove(), 400);
진료비 마이너스  }

진료비 마이너스  const { targetValue, targetX, chartData } = apiData;

진료비 마이너스  // 데이터 가공 (X축 날짜 배열, Y축 금액 배열)
진료비 마이너스  const categories = chartData.map(item => item.date);
진료비 마이너스  const seriesData = chartData.map(item => item.amount);

진료비 마이너스  // 상단 요약 지표 업데이트 (요소가 DOM에 존재할 때만 실행)
진료비 마이너스  if (targetDisplay) {
진료비 마이너스 진료비 마이너스   targetDisplay.textContent = formatCurrency(targetValue);
진료비 마이너스  }
진료비 마이너스  if (latestDisplay && seriesData.length > 0) {
진료비 마이너스 진료비 마이너스   latestDisplay.textContent = formatCurrency(seriesData[seriesData.length - 1]);
진료비 마이너스  }

진료비 마이너스  // [최신 트렌드 고도화] 실시간 동적 요약 통계 계산 및 바인딩
진료비 마이너스  const statMaxDom = document.getElementById('statMax');
진료비 마이너스  const statMinDom = document.getElementById('statMin');
진료비 마이너스  const statAvgDom = document.getElementById('statAvg');

진료비 마이너스  if (seriesData.length > 0) {
진료비 마이너스 진료비 마이너스   const maxVal = Math.max(...seriesData);
진료비 마이너스 진료비 마이너스   const minVal = Math.min(...seriesData);
진료비 마이너스 진료비 마이너스   const avgVal = seriesData.reduce((acc, curr) => acc + curr, 0) / seriesData.length;

진료비 마이너스 진료비 마이너스   if (statMaxDom) statMaxDom.textContent = formatCurrency(maxVal);
진료비 마이너스 진료비 마이너스   if (statMinDom) statMinDom.textContent = formatCurrency(minVal);
진료비 마이너스 진료비 마이너스   if (statAvgDom) statAvgDom.textContent = formatCurrency(Math.round(avgVal));
진료비 마이너스  }

진료비 마이너스  // 2. 6가지 프리미엄 테마별 차트 구성 매핑
진료비 마이너스  const THEME_CONFIGS = {
진료비 마이너스 진료비 마이너스   cyan: {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 colors: ['#00f2fe'],
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 fillStops: [
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  { offset: 0, color: '#00f2fe', opacity: 0.65 },
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  { offset: 50, color: '#7f00ff', opacity: 0.35 },
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  { offset: 100, color: '#ff2a85', opacity: 0.05 }
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 ],
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 annotationColor: '#ff2a85',
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 annotationTextColor: '#ffffff',
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 statHighlightColor: '#00f2fe'
진료비 마이너스 진료비 마이너스   },
진료비 마이너스 진료비 마이너스   magenta: {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 colors: ['#ff2a85'],
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 fillStops: [
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  { offset: 0, color: '#ff2a85', opacity: 0.65 },
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  { offset: 50, color: '#ff0055', opacity: 0.35 },
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  { offset: 100, color: '#ffaa00', opacity: 0.05 }
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 ],
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 annotationColor: '#ffaa00',
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 annotationTextColor: '#12121b',
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 statHighlightColor: '#ff2a85'
진료비 마이너스 진료비 마이너스   },
진료비 마이너스 진료비 마이너스   emerald: {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 colors: ['#00e676'],
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 fillStops: [
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  { offset: 0, color: '#00e676', opacity: 0.65 },
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  { offset: 50, color: '#00b0ff', opacity: 0.35 },
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  { offset: 100, color: '#1de9b6', opacity: 0.05 }
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 ],
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 annotationColor: '#00b0ff',
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 annotationTextColor: '#ffffff',
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 statHighlightColor: '#00e676'
진료비 마이너스 진료비 마이너스   },
진료비 마이너스 진료비 마이너스   sunset: {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 colors: ['#ff9100'],
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 fillStops: [
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  { offset: 0, color: '#ff9100', opacity: 0.65 },
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  { offset: 50, color: '#ff3d00', opacity: 0.35 },
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  { offset: 100, color: '#ffd600', opacity: 0.05 }
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 ],
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 annotationColor: '#ffd600',
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 annotationTextColor: '#12121b',
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 statHighlightColor: '#ff9100'
진료비 마이너스 진료비 마이너스   },
진료비 마이너스 진료비 마이너스   sapphire: {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 colors: ['#2979ff'],
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 fillStops: [
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  { offset: 0, color: '#2979ff', opacity: 0.65 },
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  { offset: 50, color: '#651fff', opacity: 0.35 },
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  { offset: 100, color: '#00e5ff', opacity: 0.05 }
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 ],
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 annotationColor: '#00e5ff',
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 annotationTextColor: '#12121b',
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 statHighlightColor: '#2979ff'
진료비 마이너스 진료비 마이너스   },
진료비 마이너스 진료비 마이너스   white: {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 colors: ['#ffffff'],
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 fillStops: [
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  { offset: 0, color: '#ffffff', opacity: 0.7 },
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  { offset: 50, color: '#cccccc', opacity: 0.35 },
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  { offset: 100, color: '#888888', opacity: 0.05 }
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 ],
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 annotationColor: '#e0e0e0',
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 annotationTextColor: '#12121b',
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 statHighlightColor: '#ffffff'
진료비 마이너스 진료비 마이너스   }
진료비 마이너스  };

진료비 마이너스  // 상태 관리 변수 (현재 활성화된 테마 및 차트 유형)
진료비 마이너스  let currentTheme = 'sapphire';
진료비 마이너스  let currentType = 'area';
진료비 마이너스  let currentMode = 'light';
진료비 마이너스  
진료비 마이너스  // 초기 테마 모드 즉시 적용
진료비 마이너스  document.body.setAttribute('data-color-mode', currentMode);

진료비 마이너스  // 초기 차트 옵션 (기본값: Neon Cyan 테마)
진료비 마이너스  const initTheme = THEME_CONFIGS[currentTheme];

진료비 마이너스  // 동적으로 테마별 기준값(Annotation) 설정을 반환하는 헬퍼 함수
진료비 마이너스  const getAnnotationsConfig = (themeCfg) => {
진료비 마이너스 진료비 마이너스   const yAnnotations = targetValue ? [{
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 y: targetValue,
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 borderColor: themeCfg.annotationColor,
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 borderWidth: 2, strokeDashArray: 6,
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 label: {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  borderColor: themeCfg.annotationColor,
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  style: {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스   color: themeCfg.annotationTextColor || '#fff', background: themeCfg.annotationColor,
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스   fontFamily: 'Outfit, sans-serif', fontWeight: 600,
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스   padding: { left: 10, right: 10, top: 4, bottom: 4 }
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  },
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  text: new Intl.NumberFormat('ko-KR').format(targetValue),
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  position: 'right', textAnchor: 'end', offsetX: -5
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 }
진료비 마이너스 진료비 마이너스   }] : [];

진료비 마이너스 진료비 마이너스   const xAnnotations = targetX ? [{
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 x: targetX,
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 borderColor: '#00e676', // 에메랄드 그린 컬러
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 borderWidth: 2,
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 strokeDashArray: 5,
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 label: {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  borderColor: '#00e676',
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  style: {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스   color: '#ffffff',
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스   background: '#00e676',
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스   fontFamily: 'Outfit, sans-serif',
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스   fontWeight: 700,
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스   fontSize: '14px',
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스   padding: { left: 14, right: 14, top: 8, bottom: 8 }
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  },
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  text: '진료비 마이너스 ?', // 화살표 기호 추가
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  position: 'top',
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  orientation: 'horizontal',
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  offsetX: 75, // 선의 우측으로 라벨 이동
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  offsetY: 30
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 }
진료비 마이너스 진료비 마이너스   }] : [];

진료비 마이너스 진료비 마이너스   return {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 yaxis: yAnnotations,
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 xaxis: xAnnotations
진료비 마이너스 진료비 마이너스   };
진료비 마이너스  };

진료비 마이너스  const chartOptions = {
진료비 마이너스 진료비 마이너스   series: [{
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 name: "진료비 금액",
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 // 엣지 기반 웹뷰(WebView4Delphi 등) 환경에서 초기 로딩 억제를 우회하기 위해
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 // 최초 렌더링 시에는 기준선(0)으로 평탄화된 초기 데이터를 바인딩합니다.
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 data: seriesData.map(() => 0)
진료비 마이너스 진료비 마이너스   }],
진료비 마이너스 진료비 마이너스   chart: {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 type: currentType,
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 height: 400,
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 foreColor: '#9e9ea7',
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 toolbar: {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  show: true,
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  tools: {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스   download: true, selection: true, zoom: true,
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스   zoomin: true, zoomout: true, pan: true, reset: true
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  },
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  autoSelected: 'zoom'
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 },
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 animations: {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  enabled: true,
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  easing: 'easeinout',
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  speed: 600, // 생성/전환 속도 50% 향상 (1200ms -> 600ms)
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  animateGradually: {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스   enabled: true,
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스   delay: 75
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  },
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  dynamicAnimation: { enabled: true, speed: 200 }
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 },
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 dropShadow: {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  enabled: true, top: 14, left: 0, blur: 8,
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  color: initTheme.colors[0], opacity: 0.25 // 곡선 색상과 동일한 입체 글로우 부여
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 }
진료비 마이너스 진료비 마이너스   },
진료비 마이너스 진료비 마이너스   colors: initTheme.colors,
진료비 마이너스 진료비 마이너스   fill: {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 type: 'gradient',
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 gradient: {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  shadeIntensity: 1, opacityFrom: 0.7, opacityTo: 0.05,
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  stops: [0, 85, 100], colorStops: initTheme.fillStops
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 }
진료비 마이너스 진료비 마이너스   },
진료비 마이너스 진료비 마이너스   stroke: { curve: 'smooth', width: 4 },
진료비 마이너스 진료비 마이너스   dataLabels: { enabled: false },
진료비 마이너스 진료비 마이너스   grid: {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 borderColor: 'rgba(255, 255, 255, 0.05)', strokeDashArray: 5,
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 xaxis: { lines: { show: true } }, yaxis: { lines: { show: true } },
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 padding: { top: 20, right: 20, bottom: 10, left: 20 }
진료비 마이너스 진료비 마이너스   },
진료비 마이너스 진료비 마이너스   markers: {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 size: 0, colors: [initTheme.annotationColor],
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 strokeColors: '#fff', strokeWidth: 2,
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 hover: { size: 8, sizeOffset: 4 }
진료비 마이너스 진료비 마이너스   },
진료비 마이너스 진료비 마이너스   xaxis: {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 categories: categories,
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 axisBorder: { show: false }, axisTicks: { show: false },
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 labels: { style: { colors: '#9e9ea7', fontFamily: 'Inter, sans-serif' } },
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 crosshairs: {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  show: true,
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  position: 'back',
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  stroke: { color: initTheme.colors[0], width: 1, dashArray: 4 }
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 }
진료비 마이너스 진료비 마이너스   },
진료비 마이너스 진료비 마이너스   yaxis: {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 labels: {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  formatter: function (value) {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스   if (value >= 1000000) {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 return new Intl.NumberFormat('ko-KR', { notation: 'compact', maximumFractionDigits: 1 }).format(value);
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스   }
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스   return new Intl.NumberFormat('ko-KR').format(value);
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  },
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  style: { colors: '#9e9ea7', fontFamily: 'Inter, sans-serif' }
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 }
진료비 마이너스 진료비 마이너스   },
진료비 마이너스 진료비 마이너스   tooltip: {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 theme: 'dark',
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 style: { fontSize: '13px', fontFamily: 'Inter, sans-serif' },
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 y: { formatter: function (val) { return formatCurrency(val); } }
진료비 마이너스 진료비 마이너스   },
진료비 마이너스 진료비 마이너스   annotations: getAnnotationsConfig(initTheme)
진료비 마이너스  };

진료비 마이너스  // 3. 차트 렌더링 및 동적 시리즈 업데이트 (Dynamic Series Update Strategy)
진료비 마이너스  // 엣지 기반 웹뷰(WebView4Delphi / Edge WebView2)에서는 페이지 초기 로드 시점의 드로잉 애니메이션을
진료비 마이너스  // 백그라운드 최적화로 간주하여 생략하거나, 컨테이너 가시화 전 처리해버리는 경향이 강합니다.
진료비 마이너스  // 이를 완벽히 해결하기 위해 1단계로 기준선(0) 차트를 즉시 렌더링한 후,
진료비 마이너스  // 2단계로 500ms 후 실제 데이터를 updateSeries()로 밀어넣어 아름다운 상승 다이내믹 애니메이션을 강제 유도합니다.
진료비 마이너스  let chart = new ApexCharts(document.querySelector("#chartContainer"), chartOptions);
진료비 마이너스  chart.render();

진료비 마이너스  setTimeout(() => {
진료비 마이너스 진료비 마이너스   // updateSeries 호출 시 내부적으로 Y축 스케일을 재계산하면서 커스텀 annotation이 누락되는 현상 방지
진료비 마이너스 진료비 마이너스   // updateOptions를 통해 시리즈 데이터와 기준값(Annotation) 설정을 동시에 주입하여 유지
진료비 마이너스 진료비 마이너스   chart.updateOptions({
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 series: [{
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  name: "진료비 금액",
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  data: seriesData
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 }],
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 annotations: getAnnotationsConfig(THEME_CONFIGS[currentTheme])
진료비 마이너스 진료비 마이너스   }, false, true, true);
진료비 마이너스  }, 250); // 초기 데이터 주입 대기 시간 50% 단축 (500ms -> 250ms)

진료비 마이너스  // 글로벌 chartOptions 갱신 및 차트 업데이트 헬퍼 함수
진료비 마이너스  const rebuildChartInstance = () => {
진료비 마이너스 진료비 마이너스   const themeCfg = THEME_CONFIGS[currentTheme];
진료비 마이너스 진료비 마이너스   // DOM에 설정된 현재 모드를 직접 읽어와서 동기화합니다.
진료비 마이너스 진료비 마이너스   const activeMode = document.body.getAttribute('data-color-mode') || 'light';
진료비 마이너스 진료비 마이너스   const isLight = activeMode === 'light';
진료비 마이너스 진료비 마이너스   
진료비 마이너스 진료비 마이너스   // 공통 속성 동적 갱신
진료비 마이너스 진료비 마이너스   const newOptions = {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 chart: {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  type: currentType,
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  foreColor: isLight ? '#5f6368' : '#9e9ea7',
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  dropShadow: {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스   color: themeCfg.colors[0]
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  }
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 },
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 colors: themeCfg.colors,
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 grid: {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  borderColor: isLight ? 'rgba(0, 0, 0, 0.05)' : 'rgba(255, 255, 255, 0.05)',
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 },
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 markers: {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  colors: [themeCfg.annotationColor]
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 },
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 xaxis: {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  categories: categories,
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  labels: { style: { colors: isLight ? '#5f6368' : '#9e9ea7' } },
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  crosshairs: { stroke: { color: themeCfg.colors[0] } }
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 },
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 yaxis: {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  labels: { style: { colors: isLight ? '#5f6368' : '#9e9ea7' } }
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 },
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 tooltip: { theme: activeMode },
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 annotations: getAnnotationsConfig(themeCfg)
진료비 마이너스 진료비 마이너스   };

진료비 마이너스 진료비 마이너스   // 차트 형태(Type)별 특화 스타일 및 필링(Fill) 완벽 갱신
진료비 마이너스 진료비 마이너스   if (currentType === 'bar') {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 newOptions.stroke = { width: 0 };
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 newOptions.plotOptions = { bar: { borderRadius: 6, columnWidth: '55%' } };
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 newOptions.fill = {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  type: 'gradient',
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  gradient: {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스   shade: isLight ? 'light' : 'dark',
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스   type: 'vertical',
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스   shadeIntensity: 0.5,
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스   gradientToColors: [themeCfg.fillStops[1].color],
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스   inverseColors: true,
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스   opacityFrom: 1,
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스   opacityTo: 0.85,
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스   stops: [0, 100]
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  }
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 };
진료비 마이너스 진료비 마이너스   } else if (currentType === 'line') {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 newOptions.stroke = { curve: 'straight', width: 4 };
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 newOptions.fill = { type: 'solid', opacity: 1 };
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 newOptions.plotOptions = { bar: { columnWidth: '0%' } }; // 기존 plotOptions 잔상 제거
진료비 마이너스 진료비 마이너스   } else {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 newOptions.stroke = { curve: 'smooth', width: 4 };
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 newOptions.fill = {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  type: 'gradient',
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  gradient: {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스   shadeIntensity: 1, opacityFrom: 0.7, opacityTo: 0.05,
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스   stops: [0, 85, 100], colorStops: themeCfg.fillStops
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스  }
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 };
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 newOptions.plotOptions = { bar: { columnWidth: '0%' } };
진료비 마이너스 진료비 마이너스   }

진료비 마이너스 진료비 마이너스   // updateOptions를 통해 인스턴스 파괴 없이 부드럽게 전환 (애니메이션 유지)
진료비 마이너스 진료비 마이너스   chart.updateOptions(newOptions, false, true).then(() => {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 // 강제 주석 업데이트 (ApexCharts 렌더링 버그 방지 - Promise 사용으로 타이밍 완벽 일치)
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 chart.clearAnnotations();
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 const ann = getAnnotationsConfig(themeCfg);
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 if (ann.yaxis && ann.yaxis.length > 0) chart.addYaxisAnnotation(ann.yaxis[0], false);
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 if (ann.xaxis && ann.xaxis.length > 0) chart.addXaxisAnnotation(ann.xaxis[0], false);
진료비 마이너스 진료비 마이너스   });
진료비 마이너스  };

진료비 마이너스  };

진료비 마이너스  // 4. 테마 선택 스와치 버튼 이벤트 리스너
진료비 마이너스  const themeSwatches = document.querySelectorAll('.swatch');
진료비 마이너스  themeSwatches.forEach(swatch => {
진료비 마이너스 진료비 마이너스   swatch.addEventListener('click', (e) => {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 themeSwatches.forEach(btn => btn.classList.remove('active'));
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 const targetSwatch = e.currentTarget;
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 targetSwatch.classList.add('active');

진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 currentTheme = targetSwatch.getAttribute('data-theme');
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 document.body.setAttribute('data-theme', currentTheme);

진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 rebuildChartInstance();
진료비 마이너스 진료비 마이너스   });
진료비 마이너스  });

진료비 마이너스  // 5. 차트 유형 변환 이벤트 리스너
진료비 마이너스  typeButtons.forEach(button => {
진료비 마이너스 진료비 마이너스   button.addEventListener('click', (e) => {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 typeButtons.forEach(btn => btn.classList.remove('active'));
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 const targetBtn = e.currentTarget;
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 targetBtn.classList.add('active');

진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 currentType = targetBtn.getAttribute('data-type');
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 rebuildChartInstance();
진료비 마이너스 진료비 마이너스   });
진료비 마이너스  });

진료비 마이너스  // 6. 다크/라이트 모드 전환 이벤트 리스너
진료비 마이너스  const modeButtons = document.querySelectorAll('.mode-switch-group .btn-switch');
진료비 마이너스  modeButtons.forEach(button => {
진료비 마이너스 진료비 마이너스   button.addEventListener('click', (e) => {
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 modeButtons.forEach(btn => btn.classList.remove('active'));
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 const targetBtn = e.currentTarget;
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 targetBtn.classList.add('active');

진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 currentMode = targetBtn.getAttribute('data-mode');
진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 document.body.setAttribute('data-color-mode', currentMode);

진료비 마이너스 진료비 마이너스 진료비 마이너스 진료비 마이너스 rebuildChartInstance();
진료비 마이너스 진료비 마이너스   });
진료비 마이너스  });
});
