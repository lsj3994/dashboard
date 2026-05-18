const http = require('http');
const fs = require('fs');
const path = require('path');
const querystring = require('querystring');

const PORT = 8080; // 로컬 테스트 포트

const server = http.createServer((req, res) => {
    // URL에서 쿼리 파라미터 분리
    const urlPath = req.url.split('?')[0];

    // POST 방식으로 dashboard.jsp를 요청받았을 때 (JSP 서버 기능 시뮬레이션)
    if (req.method === 'POST' && urlPath.includes('dashboard.jsp')) {
        let body = '';
        req.on('data', chunk => {
            body += chunk.toString();
        });
        req.on('end', () => {
            // URL 인코딩된 POST 데이터 파싱
            const postData = querystring.parse(body);
            
            // dashboard.jsp 파일 읽기
            fs.readFile(path.join(__dirname, 'dashboard.jsp'), 'utf8', (err, data) => {
                if (err) {
                    res.writeHead(500);
                    res.end('Error reading dashboard.jsp');
                    return;
                }
                
                // 실제 JSP가 서버에서 처리하는 것처럼 <%= ... %> 부분을 POST 데이터로 치환
                let html = data.replace('<%= reqMetaData %>', postData.MetaData || '')
                               .replace('<%= reqCharDate %>', postData.CharDate || '')
                               .replace('<%= reqStandData %>', postData.StandData || '')
                               .replace('<%= reqStandPoint %>', postData.StandPoint || '')
                               .replace('<%= reqTheme %>', postData.Theme || '')
                               .replace('<%= reqMode %>', postData.Mode || '')
                               .replace('<%= reqType %>', postData.Type || '')
                               .replace('<%= reqChartTitle %>', postData.ChartTitle || '');
                
                res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
                res.end(html);
            });
        });
        return;
    }

    // 정적 파일 라우팅 (html, css, js 등)
    let filePath = path.join(__dirname, urlPath === '/' ? 'post_test.html' : urlPath);
    const extname = path.extname(filePath);
    let contentType = 'text/html; charset=utf-8';
    
    switch (extname) {
        case '.js': contentType = 'text/javascript'; break;
        case '.css': contentType = 'text/css'; break;
        case '.json': contentType = 'application/json'; break;
        case '.png': contentType = 'image/png'; break;
        case '.jsp': contentType = 'text/html; charset=utf-8'; break; // GET으로 접근 시 단순히 html로 제공
    }

    fs.readFile(filePath, (err, content) => {
        if (err) {
            if(err.code === 'ENOENT') {
                res.writeHead(404);
                res.end('File not found: ' + req.url);
            } else {
                res.writeHead(500);
                res.end('Server Error: ' + err.code);
            }
        } else {
            res.writeHead(200, { 'Content-Type': contentType });
            res.end(content);
        }
    });
});

server.listen(PORT, () => {
    console.log(`=========================================`);
    console.log(`🚀 내 PC 전용 로컬 테스트 서버 실행 완료!`);
    console.log(`👉 접속 주소: http://localhost:${PORT}/post_test.html`);
    console.log(`=========================================`);
    console.log(`종료하려면 터미널에서 Ctrl + C를 누르세요.`);
});
