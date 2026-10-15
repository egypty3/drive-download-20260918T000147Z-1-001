const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const rootDir = path.resolve(__dirname, '..');
const docPath = path.join(rootDir, 'documentation', 'contract_factors_and_relations.md');
const imagesDir = path.join(rootDir, 'documentation', 'images');
const tempHtmlPath = path.join(rootDir, 'documentation', 'marked_factors_temp.html');
const htmlOutputPath = path.join(rootDir, 'documentation', 'contract_factors_and_relations_print.html');
const pdfOutputPath = path.join(rootDir, 'documentation', 'contract_factors_and_relations.pdf');

console.log('Reading Markdown source:', docPath);
if (!fs.existsSync(docPath)) {
  console.error('Source file not found:', docPath);
  process.exit(1);
}

// 1. Convert Markdown to HTML using npx marked
console.log('Running npx marked with file flags (-i and -o)...');
execSync(`npx -y marked -i "${docPath}" -o "${tempHtmlPath}"`, { stdio: 'inherit' });

let rawHtml = fs.readFileSync(tempHtmlPath, 'utf8');
console.log(`Raw HTML generated: ${rawHtml.length} characters.`);

// Clean up temporary marked file
if (fs.existsSync(tempHtmlPath)) {
  fs.unlinkSync(tempHtmlPath);
}

// 2. Base64 encode all images (PNG & SVG) so the HTML is 100% self-contained
console.log('Inlining images (SVG & PNG) as base64 data URIs...');

// Replace <img src="./images/..." ... />
rawHtml = rawHtml.replace(/<img\s+([^>]*?)src=["']\.\/images\/([a-zA-Z0-9_\-\.]+)(["'])/gi, (match, prefix, filename, suffix) => {
  const ext = path.extname(filename).toLowerCase();
  const imgPath = path.join(imagesDir, filename);
  if (fs.existsSync(imgPath)) {
    console.log(` -> Inlining image: ${filename}`);
    const data = fs.readFileSync(imgPath);
    let mimeType = 'image/png';
    if (ext === '.svg') mimeType = 'image/svg+xml';
    else if (ext === '.jpg' || ext === '.jpeg') mimeType = 'image/jpeg';
    const base64 = data.toString('base64');
    return `<img ${prefix}src="data:${mimeType};base64,${base64}"`;
  }
  return match;
});

// Also handle standard markdown images if any: ![alt](./images/...)
rawHtml = rawHtml.replace(/<img\s+src=["']\.\/images\/([a-zA-Z0-9_\-\.]+)(["'])/gi, (match, filename) => {
  const ext = path.extname(filename).toLowerCase();
  const imgPath = path.join(imagesDir, filename);
  if (fs.existsSync(imgPath)) {
    console.log(` -> Inlining standard markdown image: ${filename}`);
    const data = fs.readFileSync(imgPath);
    let mimeType = 'image/png';
    if (ext === '.svg') mimeType = 'image/svg+xml';
    const base64 = data.toString('base64');
    return `<img src="data:${mimeType};base64,${base64}"`;
  }
  return match;
});

// 3. Full Executive Print HTML Template with A4 settings, Google Fonts, and RTL styling
const fullHtml = `<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
  <meta charset="UTF-8">
  <title>دليل محددات إنشاء العقود وشبكة العلاقات البينية في منظومة المناولة الأرضية (TAS)</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;500;600;700;800;900&family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500;600;700&display=swap" rel="stylesheet">
  <style>
    @page {
      size: A4 portrait;
      margin: 12mm 12mm 14mm 12mm;
      @bottom-center {
        content: "صفحة " counter(page);
        font-family: 'Cairo', 'Inter', sans-serif;
        font-size: 8pt;
        color: #64748b;
      }
    }

    @page erd_landscape {
      size: A4 landscape;
      margin: 8mm 8mm 8mm 8mm;
      @bottom-center {
        content: "صفحة " counter(page);
        font-family: 'Cairo', 'Inter', sans-serif;
        font-size: 8pt;
        color: #64748b;
      }
    }

    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }

    body {
      font-family: 'Cairo', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      direction: rtl;
      text-align: right;
      color: #1e293b;
      background: #ffffff;
      line-height: 1.6;
      font-size: 9pt;
      -webkit-print-color-adjust: exact;
      print-color-adjust: exact;
      padding: 0;
    }

    /* Document Header Banner */
    .doc-header-banner {
      background: linear-gradient(135deg, #070d1a, #0f172a);
      color: #ffffff;
      padding: 22px 26px;
      border-radius: 12px;
      margin-bottom: 22px;
      border: 1px solid #1e293b;
      page-break-after: avoid;
      break-after: avoid;
    }
    .badge-top {
      display: inline-block;
      background: linear-gradient(135deg, #0284c7, #6366f1);
      color: #ffffff;
      font-family: 'Inter', sans-serif;
      font-size: 8pt;
      font-weight: 700;
      padding: 3px 10px;
      border-radius: 4px;
      text-transform: uppercase;
      letter-spacing: 0.5px;
      margin-bottom: 10px;
    }
    .main-title {
      font-family: 'Cairo', sans-serif;
      font-size: 18pt;
      font-weight: 900;
      color: #f8fafc;
      line-height: 1.35;
      margin-bottom: 6px;
    }
    .sub-title {
      font-family: 'Inter', sans-serif;
      font-size: 10pt;
      color: #94a3b8;
      font-weight: 500;
      margin-bottom: 14px;
      direction: ltr;
      text-align: right;
    }
    .meta-row {
      display: flex;
      align-items: center;
      justify-content: space-between;
      border-top: 1px solid rgba(148, 163, 184, 0.2);
      padding-top: 10px;
      font-size: 8pt;
      color: #cbd5e1;
    }
    .meta-item {
      display: flex;
      align-items: center;
      gap: 6px;
    }

    /* Headings */
    h1 {
      display: none; /* Already in banner */
    }
    h2 {
      font-family: 'Cairo', sans-serif;
      font-size: 12.5pt;
      font-weight: 800;
      color: #0369a1;
      border-bottom: 2px solid #e2e8f0;
      padding-bottom: 5px;
      margin-top: 22px;
      margin-bottom: 10px;
      page-break-after: avoid;
      break-after: avoid;
      display: flex;
      align-items: center;
      gap: 8px;
    }
    h3 {
      font-family: 'Cairo', sans-serif;
      font-size: 10.5pt;
      font-weight: 700;
      color: #0f172a;
      margin-top: 16px;
      margin-bottom: 8px;
      page-break-after: avoid;
      break-after: avoid;
    }
    h4 {
      font-family: 'Cairo', sans-serif;
      font-size: 9.5pt;
      font-weight: 700;
      color: #334155;
      margin-top: 12px;
      margin-bottom: 6px;
      page-break-after: avoid;
      break-after: avoid;
    }

    p {
      margin-bottom: 8px;
      color: #334155;
      text-align: justify;
      line-height: 1.6;
    }

    ul, ol {
      margin-right: 20px;
      margin-bottom: 10px;
    }
    li {
      margin-bottom: 4px;
      color: #334155;
      line-height: 1.55;
    }

    strong {
      color: #0f172a;
      font-weight: 700;
    }

    /* High Contrast Text Protection for Dark Cards & Containers */
    div[style*="background: #0f172a"] p,
    div[style*="background: #0f172a"] li,
    div[style*="background: #0f172a"] span:not([style*="color"]) {
      color: #ffffff !important;
    }
    div[style*="background: #0f172a"] strong:not([style*="color"]) {
      color: #38bdf8 !important;
    }

    /* Scenario 1: Scheduled flight (Green Card) */
    div[style*="background: #061f18"] li {
      color: #ffffff !important;
    }
    div[style*="background: #061f18"] strong {
      color: #6ee7b7 !important;
    }

    /* Scenario 2: Charter flight (Amber Card) */
    div[style*="background: #241a05"] li {
      color: #ffffff !important;
    }
    div[style*="background: #241a05"] strong {
      color: #fcd34d !important;
    }

    /* Scenario 3: Cargo flight (Red Card) */
    div[style*="background: #23080e"] li {
      color: #ffffff !important;
    }
    div[style*="background: #23080e"] strong {
      color: #fda4af !important;
    }

    /* 3NF Schema & Checklist Cards */
    div[style*="background: #0b1324"] div,
    div[style*="background: #0f172a"] div {
      color: #ffffff;
    }

    /* Code and Technical Identifiers */
    code {
      font-family: 'JetBrains Mono', 'Fira Code', monospace;
      font-size: 8pt;
      background: #f1f5f9;
      color: #0369a1;
      padding: 1px 5px;
      border-radius: 4px;
      border: 1px solid #e2e8f0;
      direction: ltr;
      display: inline-block;
      unicode-bidi: embed;
    }

    pre {
      background: #070d1e !important;
      border: 1px solid #1e293b;
      border-radius: 8px;
      padding: 12px 14px;
      margin: 12px 0;
      page-break-inside: avoid;
      break-inside: avoid;
      overflow-x: auto;
      direction: ltr !important;
      text-align: left !important;
    }
    pre code {
      background: transparent !important;
      border: none !important;
      color: #38bdf8 !important;
      font-size: 8pt !important;
      line-height: 1.45 !important;
      padding: 0 !important;
      display: block !important;
      white-space: pre !important;
      direction: ltr !important;
      text-align: left !important;
    }

    /* Tables */
    table {
      width: 100%;
      border-collapse: collapse;
      margin: 14px 0;
      font-size: 8pt;
      page-break-inside: auto;
      border: 1px solid #cbd5e1;
      border-radius: 6px;
      overflow: hidden;
      box-shadow: 0 1px 3px rgba(0,0,0,0.05);
    }
    tr {
      page-break-inside: avoid;
      break-inside: avoid;
    }
    th {
      background: #0f172a;
      color: #ffffff;
      padding: 7px 9px;
      font-weight: 700;
      font-size: 8pt;
      text-align: right;
      border: 1px solid #334155;
      line-height: 1.35;
    }
    td {
      padding: 6px 8px;
      border: 1px solid #e2e8f0;
      vertical-align: top;
      line-height: 1.4;
      color: #1e293b;
    }
    td code {
      font-size: 7.5pt;
      white-space: normal;
      word-break: break-all;
    }

    /* Zebra stripe ONLY on standard tables, never on matrix dark tables */
    table:not(.matrix-table-dark) tr:nth-child(even) td {
      background: #f8fafc;
    }

    /* Matrix Dark Tables - Guarantee High Contrast */
    table.matrix-table-dark {
      border: 1.5px solid #0284c7 !important;
      background: #0f172a !important;
      box-shadow: 0 4px 14px rgba(0,0,0,0.3) !important;
    }
    table.matrix-table-dark th {
      background: #1e293b !important;
      color: #ffffff !important;
      border: 1px solid #334155 !important;
      font-size: 8.5pt !important;
      font-weight: 800 !important;
    }
    table.matrix-table-dark td {
      border: 1px solid #334155 !important;
      color: #ffffff;
      font-size: 8pt !important;
      font-weight: 500 !important;
      line-height: 1.55 !important;
    }
    table.matrix-table-dark tr:nth-child(odd) td {
      background: #0f172a !important;
    }
    table.matrix-table-dark tr:nth-child(even) td {
      background: #17223b !important;
    }
    table.matrix-table-dark code {
      background: #020617 !important;
      color: #38bdf8 !important;
      border: 1px solid #1e40af !important;
      padding: 3px 6px !important;
      border-radius: 4px !important;
      font-size: 8pt !important;
      font-weight: 700 !important;
      display: inline-block !important;
    }
    table.matrix-table-dark td span {
      display: inline-block !important;
      white-space: nowrap !important;
      text-align: center !important;
      line-height: 1.3 !important;
    }

    /* ERD Dedicated Landscape Page */
    .erd-landscape-page {
      page: erd_landscape;
      page-break-before: always;
      page-break-after: always;
      break-before: page;
      break-after: page;
      page-break-inside: avoid;
      break-inside: avoid;
      width: 100%;
      text-align: center;
      margin: 0 auto;
      padding: 0;
    }
    .erd-landscape-page img {
      max-width: 100%;
      width: 100%;
      height: auto;
      max-height: 154mm;
      object-fit: contain;
      border-radius: 10px;
      box-shadow: 0 10px 30px rgba(0,0,0,0.5);
      margin: 0 auto;
      display: block;
    }

    /* Diagram Images */
    img {
      max-width: 100%;
      height: auto;
      display: block;
      margin: 0 auto;
      border-radius: 8px;
      page-break-inside: avoid;
      break-inside: avoid;
    }

    /* Divider */
    hr {
      border: none;
      height: 1px;
      background: #e2e8f0;
      margin: 18px 0;
    }

    /* Footer Note */
    .doc-footer {
      border-top: 2px solid #e2e8f0;
      margin-top: 24px;
      padding-top: 10px;
      display: flex;
      justify-content: space-between;
      font-size: 8pt;
      color: #64748b;
      page-break-inside: avoid;
      break-inside: avoid;
    }
  </style>
</head>
<body>

  <!-- Cover Header Banner -->
  <div class="doc-header-banner">
    <div class="badge-top">Ground Handling Contract Architecture &amp; Interdependence Guide</div>
    <div class="main-title">دليل محددات إنشاء العقود وشبكة العلاقات البينية في منظومة المناولة الأرضية (TAS)</div>
    <div class="sub-title">Contract Factors, Relational Parameters, Multi-Dimensional Pricing &amp; 3NF Database Design</div>
    <div class="meta-row">
      <div class="meta-item"><span>🏢</span> <strong>القطاع:</strong> الطيران المدني والمناولة الأرضية</div>
      <div class="meta-item"><span>⚙️</span> <strong>المحرك:</strong> TAS Commercial &amp; Pricing Engine</div>
      <div class="meta-item"><span>🔖</span> <strong>الإصدار:</strong> Ver 2.4 (Enterprise Edition)</div>
      <div class="meta-item"><span>📅</span> <strong>التاريخ:</strong> أكتوبر 2026</div>
    </div>
  </div>

  <!-- Main Content Body -->
  <div class="content-body">
    ${rawHtml}
  </div>

  <!-- Document Footer -->
  <div class="doc-footer">
    <div>TAS Aviation Solutions — وثيقة الدليل المعماري لمحددات العقود وشبكة العلاقات البينية</div>
    <div>مرجع التوثيق الهندسي الداخلي الرسمي</div>
  </div>

</body>
</html>
`;

console.log('Writing print-ready HTML to:', htmlOutputPath);
fs.writeFileSync(htmlOutputPath, fullHtml, 'utf8');

// 4. Generate PDF via Headless Google Chrome
console.log('Generating PDF via headless Google Chrome...');
const chromePath = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
const chromeCmd = `"${chromePath}" --headless --disable-gpu --no-pdf-header-footer --print-to-pdf="${pdfOutputPath}" "${htmlOutputPath}"`;

execSync(chromeCmd, { stdio: 'inherit' });

if (fs.existsSync(pdfOutputPath)) {
  const stats = fs.statSync(pdfOutputPath);
  console.log(`✅ Success! Complete PDF successfully generated: ${pdfOutputPath}`);
  console.log(`📊 File Size: ${(stats.size / 1024).toFixed(1)} KB (${stats.size} bytes)`);
} else {
  console.error('❌ Error: PDF output file was not created.');
  process.exit(1);
}
