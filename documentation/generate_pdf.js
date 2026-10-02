const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const rootDir = path.resolve(__dirname, '..');
const docPath = path.join(rootDir, 'documentation', 'contract_lifecycle.md');
const imagesDir = path.join(rootDir, 'documentation', 'images');
const tempHtmlPath = path.join(rootDir, 'documentation', 'marked_temp.html');
const htmlOutputPath = path.join(rootDir, 'documentation', 'contract_lifecycle_print.html');
const pdfOutputPath = path.join(rootDir, 'documentation', 'contract_lifecycle.pdf');

console.log('Reading Markdown source:', docPath);

// Convert full Markdown to HTML using marked with file output to avoid buffer truncation
console.log('Running npx marked with file flags (-i and -o)...');
execSync(`npx -y marked -i "${docPath}" -o "${tempHtmlPath}"`, { stdio: 'inherit' });

let rawHtml = fs.readFileSync(tempHtmlPath, 'utf8');
console.log(`Raw HTML generated: ${rawHtml.length} characters.`);

// Clean up temporary marked file
if (fs.existsSync(tempHtmlPath)) {
  fs.unlinkSync(tempHtmlPath);
}

// Base64 encode all 5 SVG vector graphics so the document is 100% self-contained
console.log('Embedding vector graphics (SVGs) as base64 data URIs...');
const processedHtml = rawHtml.replace(/<p><img src="\.\/images\/([a-zA-Z0-9_\-]+)\.svg" alt="([^"]*)"><\/p>/g, (match, filename, alt) => {
  const svgPath = path.join(imagesDir, `${filename}.svg`);
  if (fs.existsSync(svgPath)) {
    console.log(` -> Inlining SVG: ${filename}.svg`);
    const svgData = fs.readFileSync(svgPath, 'utf8');
    const base64 = Buffer.from(svgData).toString('base64');
    const dataUri = `data:image/svg+xml;base64,${base64}`;
    return `
      <figure class="diagram-figure">
        <img src="${dataUri}" alt="${alt}" class="diagram-img" />
        <figcaption class="diagram-caption">${alt}</figcaption>
      </figure>
    `;
  }
  return match;
});

// Full Executive HTML Template with Google Fonts, RTL typesetting, and Print Styles
const fullHtml = `<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
  <meta charset="UTF-8">
  <title>دليل دورة حياة العقود في نظام إدارة المناولة الأرضية والفوترة (TAS)</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;500;600;700;800;900&family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500;600&display=swap" rel="stylesheet">
  <style>
    @page {
      size: A4 portrait;
      margin: 12mm 12mm 14mm 12mm;
      @bottom-center {
        content: counter(page);
        font-family: 'Inter', sans-serif;
        font-size: 8.5pt;
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
      font-size: 9.5pt;
      -webkit-print-color-adjust: exact;
      print-color-adjust: exact;
      padding: 0;
    }

    /* Document Header Banner */
    .doc-header-banner {
      background: linear-gradient(135deg, #090e17, #0f172a);
      color: #ffffff;
      padding: 22px 26px;
      border-radius: 12px;
      margin-bottom: 20px;
      border: 1px solid #1e293b;
      page-break-after: avoid;
      break-after: avoid;
    }
    .badge-top {
      display: inline-block;
      background: linear-gradient(135deg, #0284c7, #6366f1);
      color: #ffffff;
      font-family: 'Inter', sans-serif;
      font-size: 8.5pt;
      font-weight: 700;
      padding: 3px 10px;
      border-radius: 4px;
      text-transform: uppercase;
      letter-spacing: 0.5px;
      margin-bottom: 10px;
    }
    .main-title {
      font-family: 'Cairo', sans-serif;
      font-size: 19pt;
      font-weight: 900;
      color: #f8fafc;
      line-height: 1.3;
      margin-bottom: 4px;
    }
    .sub-title {
      font-family: 'Inter', sans-serif;
      font-size: 10.5pt;
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
      display: none; /* Already rendered in banner */
    }
    h2 {
      font-family: 'Cairo', sans-serif;
      font-size: 13pt;
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
      font-size: 11pt;
      font-weight: 700;
      color: #0f172a;
      margin-top: 16px;
      margin-bottom: 8px;
      page-break-after: avoid;
      break-after: avoid;
    }
    h4 {
      font-family: 'Cairo', sans-serif;
      font-size: 10pt;
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
    }

    ul, ol {
      margin-right: 20px;
      margin-bottom: 10px;
    }
    li {
      margin-bottom: 5px;
      color: #334155;
    }

    strong {
      color: #0f172a;
      font-weight: 700;
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
      background: #090e17;
      border: 1px solid #1e293b;
      border-radius: 8px;
      padding: 12px 14px;
      margin: 12px 0;
      page-break-inside: avoid;
      break-inside: avoid;
      overflow-x: auto;
      direction: ltr;
      text-align: left;
    }
    pre code {
      background: transparent;
      border: none;
      color: #38bdf8;
      font-size: 8pt;
      line-height: 1.4;
      padding: 0;
      display: block;
      white-space: pre;
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
    tr:nth-child(even) td {
      background: #f8fafc;
    }

    /* Diagram & Figure Containers */
    .diagram-figure {
      margin: 16px 0;
      text-align: center;
      page-break-inside: avoid;
      break-inside: avoid;
      border: 1px solid #1e293b;
      border-radius: 10px;
      padding: 10px;
      background: #090e17;
      box-shadow: 0 4px 14px rgba(0, 0, 0, 0.15);
    }
    .diagram-img {
      max-width: 100%;
      height: auto;
      display: block;
      margin: 0 auto;
      border-radius: 6px;
    }
    .diagram-caption {
      font-family: 'Cairo', sans-serif;
      font-size: 8.5pt;
      font-weight: 700;
      color: #94a3b8;
      margin-top: 8px;
      text-align: center;
    }

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
    <div class="badge-top">Ground Handling Operations &amp; Turnaround Billing Architecture</div>
    <div class="main-title">دليل دورة حياة العقود في نظام إدارة المناولة الأرضية والفوترة (TAS)</div>
    <div class="sub-title">End-to-End Contract Governance, Dynamic Pricing &amp; Turnaround Billing Reference Guide</div>
    <div class="meta-row">
      <div class="meta-item"><span>🏢</span> <strong>الجهة:</strong> قطاع الطيران والمناولة الأرضية</div>
      <div class="meta-item"><span>📋</span> <strong>النظام:</strong> TAS Turnaround Billing Engine</div>
      <div class="meta-item"><span>🔖</span> <strong>الإصدار:</strong> Ver 2.4 (Enterprise Edition)</div>
      <div class="meta-item"><span>📅</span> <strong>التاريخ:</strong> سبتمبر 2026</div>
    </div>
  </div>

  <!-- Main Content Body -->
  <div class="content-body">
    ${processedHtml}
  </div>

  <!-- Document Footer -->
  <div class="doc-footer">
    <div>TAS Aviation Solutions — وثيقة مرجعية لحوكمة العقود والمناولة الأرضية</div>
    <div>مرجع التوثيق الداخلي الرسمي</div>
  </div>

</body>
</html>
`;

console.log('Writing print-ready HTML to:', htmlOutputPath);
fs.writeFileSync(htmlOutputPath, fullHtml, 'utf8');

// Generate PDF via Headless Google Chrome
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
