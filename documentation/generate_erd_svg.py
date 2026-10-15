#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Generates an attractive, professional, high-resolution vector SVG ERD diagram
for Ground Handling Contract Factors & Relational Architecture (TAS Engine).
"""

import os
import subprocess

SVG_CONTENT = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1680 1140" width="100%" height="100%">
  <defs>
    <!-- Deep Canvas Gradient -->
    <linearGradient id="bgGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#050a14"/>
      <stop offset="40%" stop-color="#0a1224"/>
      <stop offset="100%" stop-color="#0f172a"/>
    </linearGradient>

    <!-- Domain Clusters Gradients -->
    <linearGradient id="clusterBlue" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#1e3a8a" stop-opacity="0.35"/>
      <stop offset="100%" stop-color="#0f172a" stop-opacity="0.2"/>
    </linearGradient>
    <linearGradient id="clusterGreen" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#064e3b" stop-opacity="0.35"/>
      <stop offset="100%" stop-color="#0f172a" stop-opacity="0.2"/>
    </linearGradient>
    <linearGradient id="clusterSky" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#0369a1" stop-opacity="0.35"/>
      <stop offset="100%" stop-color="#0f172a" stop-opacity="0.2"/>
    </linearGradient>
    <linearGradient id="clusterAmber" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#78350f" stop-opacity="0.35"/>
      <stop offset="100%" stop-color="#0f172a" stop-opacity="0.2"/>
    </linearGradient>
    <linearGradient id="clusterPurple" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#4c1d95" stop-opacity="0.35"/>
      <stop offset="100%" stop-color="#0f172a" stop-opacity="0.2"/>
    </linearGradient>

    <!-- Table Header Gradients -->
    <linearGradient id="hdrBlue" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" stop-color="#1d4ed8"/>
      <stop offset="100%" stop-color="#3b82f6"/>
    </linearGradient>
    <linearGradient id="hdrGreen" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" stop-color="#047857"/>
      <stop offset="100%" stop-color="#10b981"/>
    </linearGradient>
    <linearGradient id="hdrSky" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" stop-color="#0284c7"/>
      <stop offset="100%" stop-color="#38bdf8"/>
    </linearGradient>
    <linearGradient id="hdrAmber" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" stop-color="#b45309"/>
      <stop offset="100%" stop-color="#f59e0b"/>
    </linearGradient>
    <linearGradient id="hdrPurple" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" stop-color="#6d28d9"/>
      <stop offset="100%" stop-color="#a855f7"/>
    </linearGradient>
    <linearGradient id="hdrRose" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" stop-color="#be123c"/>
      <stop offset="100%" stop-color="#f43f5e"/>
    </linearGradient>

    <!-- Table Card Background -->
    <linearGradient id="tableCardBg" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#1e293b"/>
      <stop offset="100%" stop-color="#0b1329"/>
    </linearGradient>

    <!-- Drop Shadows -->
    <filter id="cardShadow" x="-10%" y="-10%" width="120%" height="120%">
      <feDropShadow dx="0" dy="6" stdDeviation="8" flood-color="#000000" flood-opacity="0.55"/>
    </filter>
    <filter id="glowGlow" x="-20%" y="-20%" width="140%" height="140%">
      <feGaussianBlur stdDeviation="8" result="blur"/>
      <feComposite in="SourceGraphic" in2="blur" operator="over"/>
    </filter>

    <!-- Relation Arrow Markers -->
    <marker id="arrowBlue" viewBox="0 0 10 10" refX="7" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M 0 1.5 L 8 5 L 0 8.5 z" fill="#60a5fa"/>
    </marker>
    <marker id="arrowGreen" viewBox="0 0 10 10" refX="7" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M 0 1.5 L 8 5 L 0 8.5 z" fill="#34d399"/>
    </marker>
    <marker id="arrowAmber" viewBox="0 0 10 10" refX="7" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M 0 1.5 L 8 5 L 0 8.5 z" fill="#fbbf24"/>
    </marker>
    <marker id="arrowPurple" viewBox="0 0 10 10" refX="7" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M 0 1.5 L 8 5 L 0 8.5 z" fill="#c084fc"/>
    </marker>
    <marker id="arrowRose" viewBox="0 0 10 10" refX="7" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M 0 1.5 L 8 5 L 0 8.5 z" fill="#fb7185"/>
    </marker>
    <marker id="circleDot" viewBox="0 0 10 10" refX="5" refY="5" markerWidth="6" markerHeight="6">
      <circle cx="5" cy="5" r="3.5" fill="#94a3b8"/>
    </marker>
  </defs>

  <style>
    .erd-title { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Cairo", sans-serif; font-size: 25px; font-weight: 900; fill: #ffffff; }
    .erd-subtitle { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Cairo", sans-serif; font-size: 14.5px; font-weight: 600; fill: #94a3b8; }
    .cluster-label { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; font-size: 16px; font-weight: 900; fill: #ffffff; letter-spacing: 0.5px; }
    .tbl-title { font-family: "JetBrains Mono", "SF Mono", Consolas, monospace; font-size: 14.5px; font-weight: 800; fill: #ffffff; }
    .col-pk { font-family: "JetBrains Mono", Consolas, monospace; font-size: 12.5px; font-weight: 800; fill: #fde047; }
    .col-fk { font-family: "JetBrains Mono", Consolas, monospace; font-size: 12.5px; font-weight: 800; fill: #38bdf8; }
    .col-attr { font-family: "JetBrains Mono", Consolas, monospace; font-size: 12px; font-weight: 700; fill: #ffffff; }
    .col-type { font-family: "JetBrains Mono", Consolas, monospace; font-size: 11px; font-weight: 700; fill: #94a3b8; }
    .cardinality { font-family: "JetBrains Mono", Consolas, monospace; font-size: 12px; font-weight: 900; fill: #ffffff; }
    .pill-badge { font-family: -apple-system, sans-serif; font-size: 11px; font-weight: 800; }
    .line-blue { stroke: #3b82f6; stroke-width: 2.2; fill: none; }
    .line-green { stroke: #10b981; stroke-width: 2.2; fill: none; }
    .line-amber { stroke: #f59e0b; stroke-width: 2.2; fill: none; }
    .line-purple { stroke: #a855f7; stroke-width: 2.2; fill: none; }
    .line-rose { stroke: #f43f5e; stroke-width: 2.2; stroke-dasharray: 6,4; fill: none; }
    .line-dim { stroke: #475569; stroke-width: 1.5; stroke-dasharray: 4,4; fill: none; }
  </style>

  <!-- Background Base Canvas -->
  <rect width="1680" height="1140" rx="16" fill="url(#bgGrad)" stroke="#1e293b" stroke-width="2"/>

  <!-- ========================================================================= -->
  <!-- TOP BANNER & LEGEND -->
  <!-- ========================================================================= -->
  <g transform="translate(30, 20)">
    <rect width="1620" height="70" rx="12" fill="#0b1324" stroke="rgba(56, 189, 248, 0.4)" stroke-width="1.5" filter="url(#cardShadow)"/>
    <rect x="20" y="15" width="6" height="40" rx="3" fill="#38bdf8"/>
    <text x="36" y="38" class="erd-title">مخطط العلاقات الكيانية لمحددات إنشاء العقود والفوترة (TAS Relational Architecture ERD - 3NF)</text>
    <text x="36" y="58" class="erd-subtitle">Multi-Dimensional Contract Factor Connections, Normalized Junctions, Turnaround Facts &amp; Revenue Margin Guard</text>

    <!-- Legend Tags -->
    <g transform="translate(1040, 22)">
      <rect x="0" y="0" width="95" height="26" rx="6" fill="#1e3a8a" stroke="#3b82f6" stroke-width="1.2"/>
      <text x="47" y="17" text-anchor="middle" font-size="12" fill="#ffffff" font-family="sans-serif" font-weight="800">1:N Master</text>
      
      <rect x="105" y="0" width="105" height="26" rx="6" fill="#064e3b" stroke="#10b981" stroke-width="1.2"/>
      <text x="157" y="17" text-anchor="middle" font-size="12" fill="#ffffff" font-family="sans-serif" font-weight="800">N:M Junction</text>
      
      <rect x="220" y="0" width="95" height="26" rx="6" fill="#78350f" stroke="#f59e0b" stroke-width="1.2"/>
      <text x="267" y="17" text-anchor="middle" font-size="12" fill="#ffffff" font-family="sans-serif" font-weight="800">Tariff Rules</text>

      <rect x="325" y="0" width="105" height="26" rx="6" fill="#881337" stroke="#f43f5e" stroke-width="1.2"/>
      <text x="377" y="17" text-anchor="middle" font-size="12" fill="#ffffff" font-family="sans-serif" font-weight="800">Margin Shield</text>
      
      <rect x="440" y="0" width="130" height="26" rx="6" fill="#4c1d95" stroke="#a855f7" stroke-width="1.2"/>
      <text x="505" y="17" text-anchor="middle" font-size="12" fill="#ffffff" font-family="sans-serif" font-weight="800">1:1 WorkOrder Hub</text>
    </g>
  </g>

  <!-- ========================================================================= -->
  <!-- DOMAIN CLUSTER 1: COMMERCIAL CONTRACT & BILLING ENTITY (Top Left) -->
  <!-- ========================================================================= -->
  <g transform="translate(30, 105)">
    <rect width="490" height="370" rx="14" fill="url(#clusterBlue)" stroke="#2563eb" stroke-width="1.2" stroke-dasharray="6,4"/>
    <rect x="14" y="12" width="220" height="26" rx="6" fill="url(#hdrBlue)"/>
    <text x="124" y="29" text-anchor="middle" class="cluster-label">1. Commercial &amp; Contract Hub</text>

    <!-- Table: AR_Customers -->
    <g transform="translate(20, 50)" filter="url(#cardShadow)">
      <rect width="210" height="190" rx="8" fill="url(#tableCardBg)" stroke="#3b82f6" stroke-width="1"/>
      <rect width="210" height="26" rx="8" fill="url(#hdrBlue)"/>
      <text x="10" y="18" class="tbl-title">AR_Customers</text>
      <text x="10" y="46" class="col-pk">🔑 CustomerID <tspan class="col-type">INT (PK)</tspan></text>
      <text x="10" y="66" class="col-attr">CustomerCode <tspan class="col-type">VARCHAR(20)</tspan></text>
      <text x="10" y="86" class="col-attr">CustomerName <tspan class="col-type">NVARCHAR</tspan></text>
      <text x="10" y="106" class="col-attr">BillingCurrency <tspan class="col-type">CHAR(3)</tspan></text>
      <text x="10" y="126" class="col-attr">PaymentTerms <tspan class="col-type">Net-30/Cash</tspan></text>
      <text x="10" y="146" class="col-attr">CreditLimitUSD <tspan class="col-type">DEC(18,2)</tspan></text>
      <text x="10" y="166" class="col-attr">CreditBlock <tspan class="col-type">BIT (Flag)</tspan></text>
      <text x="10" y="182" font-size="9" fill="#93c5fd" font-family="sans-serif">🛡️ الجهة المحاسبية المدينة بالدفع</text>
    </g>

    <!-- Table: Com_Contracts (The Master Centerpiece) -->
    <g transform="translate(250, 50)" filter="url(#cardShadow)">
      <rect width="220" height="295" rx="8" fill="url(#tableCardBg)" stroke="#60a5fa" stroke-width="1.8"/>
      <rect width="220" height="26" rx="8" fill="url(#hdrBlue)"/>
      <text x="10" y="18" class="tbl-title">Com_Contracts (Hub)</text>
      <text x="10" y="46" class="col-pk">🔑 ContractID <tspan class="col-type">INT (PK)</tspan></text>
      <text x="10" y="66" class="col-attr">ContractNumber <tspan class="col-type">VARCHAR(30)</tspan></text>
      <text x="10" y="86" class="col-attr">VersionNumber <tspan class="col-type">INT (v1,v2)</tspan></text>
      <text x="10" y="106" class="col-fk">🔗 CustomerID <tspan class="col-type">INT (FK)</tspan></text>
      <text x="10" y="126" class="col-attr">EffectiveFrom <tspan class="col-type">DATE</tspan></text>
      <text x="10" y="146" class="col-attr">ValidTo <tspan class="col-type">DATE</tspan></text>
      <text x="10" y="166" class="col-attr">FreeGroundTimeNarrow <tspan class="col-type">60m</tspan></text>
      <text x="10" y="186" class="col-attr">FreeGroundTimeWide <tspan class="col-type">90m</tspan></text>
      <text x="10" y="206" class="col-attr">MinimumPriceGuarantee <tspan class="col-type">DEC</tspan></text>
      <text x="10" y="226" class="col-attr">DisbursementFeePct <tspan class="col-type">5.00%</tspan></text>
      <text x="10" y="246" class="col-attr">VolumeRebateTier <tspan class="col-type">INT (30)</tspan></text>
      <text x="10" y="266" class="col-attr">Status <tspan class="col-type">Active/Expired</tspan></text>
      <text x="10" y="286" font-size="9" fill="#38bdf8" font-family="sans-serif">🎯 القلب النابض لحساب الفوترة</text>
    </g>
  </g>

  <!-- ========================================================================= -->
  <!-- DOMAIN CLUSTER 2: STATIONS & OPERATING AIRLINES (Top Center) -->
  <!-- ========================================================================= -->
  <g transform="translate(540, 105)">
    <rect width="530" height="370" rx="14" fill="url(#clusterGreen)" stroke="#059669" stroke-width="1.2" stroke-dasharray="6,4"/>
    <rect x="14" y="12" width="260" height="26" rx="6" fill="url(#hdrGreen)"/>
    <text x="144" y="29" text-anchor="middle" class="cluster-label">2. Stations &amp; Operating Carriers</text>

    <!-- Table: Opr_Airports -->
    <g transform="translate(20, 50)" filter="url(#cardShadow)">
      <rect width="230" height="135" rx="8" fill="url(#tableCardBg)" stroke="#10b981" stroke-width="1"/>
      <rect width="230" height="24" rx="8" fill="url(#hdrGreen)"/>
      <text x="10" y="17" class="tbl-title">Opr_Airports (Stations)</text>
      <text x="10" y="42" class="col-pk">🔑 AirportID <tspan class="col-type">INT (PK)</tspan></text>
      <text x="10" y="60" class="col-attr">AirportCode <tspan class="col-type">CHAR(3) [CAI/SSH]</tspan></text>
      <text x="10" y="78" class="col-attr">ICAOCode <tspan class="col-type">CHAR(4) [HECA]</tspan></text>
      <text x="10" y="96" class="col-attr">AuthorityTaxFeeUSD <tspan class="col-type">DEC(10,2)</tspan></text>
      <text x="10" y="114" class="col-attr">NightSurchargeRate <tspan class="col-type">20.0%</tspan></text>
      <text x="10" y="130" font-size="9" fill="#34d399" font-family="sans-serif">📍 المحطات والمطارات التشغيلية</text>
    </g>

    <!-- Table: Com_ContractAirports (Junction N:M) -->
    <g transform="translate(270, 50)" filter="url(#cardShadow)">
      <rect width="240" height="135" rx="8" fill="url(#tableCardBg)" stroke="#34d399" stroke-width="1.5"/>
      <rect width="240" height="24" rx="8" fill="#047857"/>
      <text x="10" y="17" class="tbl-title">Com_ContractAirports (N:M)</text>
      <text x="10" y="42" class="col-pk">🔑🔗 ContractID <tspan class="col-type">INT (PK, FK)</tspan></text>
      <text x="10" y="62" class="col-pk">🔑🔗 AirportID <tspan class="col-type">INT (PK, FK)</tspan></text>
      <text x="10" y="82" class="col-attr">IsPrimaryStation <tspan class="col-type">BIT</tspan></text>
      <text x="10" y="102" class="col-attr">StationConcessionFee <tspan class="col-type">DEC</tspan></text>
      <text x="10" y="122" font-size="9" fill="#6ee7b7" font-family="sans-serif">✓ تفكيك القوائم النصية CAI,HRG (1NF)</text>
    </g>

    <!-- Table: Opr_Airlines -->
    <g transform="translate(20, 205)" filter="url(#cardShadow)">
      <rect width="230" height="145" rx="8" fill="url(#tableCardBg)" stroke="#10b981" stroke-width="1"/>
      <rect width="230" height="24" rx="8" fill="url(#hdrGreen)"/>
      <text x="10" y="17" class="tbl-title">Opr_Airlines (Operating)</text>
      <text x="10" y="42" class="col-pk">🔑 AirlineID <tspan class="col-type">INT (PK)</tspan></text>
      <text x="10" y="60" class="col-attr">AirlineCode <tspan class="col-type">VARCHAR(3) [MS/FZ]</tspan></text>
      <text x="10" y="78" class="col-attr">ICAOCode <tspan class="col-type">CHAR(4) [MSR]</tspan></text>
      <text x="10" y="96" class="col-attr">AirlineName <tspan class="col-type">NVARCHAR(100)</tspan></text>
      <text x="10" y="114" class="col-attr">IsScheduled / IsCargo <tspan class="col-type">BIT</tspan></text>
      <text x="10" y="132" font-size="9" fill="#34d399" font-family="sans-serif">✈️ الناقل المشغل الفعلي للرحلة</text>
    </g>

    <!-- Table: Com_ContractAirlines (Junction N:M) -->
    <g transform="translate(270, 205)" filter="url(#cardShadow)">
      <rect width="240" height="145" rx="8" fill="url(#tableCardBg)" stroke="#34d399" stroke-width="1.5"/>
      <rect width="240" height="24" rx="8" fill="#047857"/>
      <text x="10" y="17" class="tbl-title">Com_ContractAirlines (N:M)</text>
      <text x="10" y="42" class="col-pk">🔑🔗 ContractID <tspan class="col-type">INT (PK, FK)</tspan></text>
      <text x="10" y="62" class="col-pk">🔑🔗 AirlineID <tspan class="col-type">INT (PK, FK)</tspan></text>
      <text x="10" y="82" class="col-attr">AllianceCode <tspan class="col-type">Star/SkyTeam</tspan></text>
      <text x="10" y="102" class="col-attr">IsCoveredUnderGroup <tspan class="col-type">BIT</tspan></text>
      <text x="10" y="128" font-size="9" fill="#6ee7b7" font-family="sans-serif">✓ شمول عدة خطوط طيران شقيقة بعقد موحد</text>
    </g>
  </g>

  <!-- ========================================================================= -->
  <!-- DOMAIN CLUSTER 3: SERVICES CATALOG & TARIFF RULES (Top Right) -->
  <!-- ========================================================================= -->
  <g transform="translate(1090, 105)">
    <rect width="560" height="370" rx="14" fill="url(#clusterAmber)" stroke="#d97706" stroke-width="1.2" stroke-dasharray="6,4"/>
    <rect x="14" y="12" width="270" height="26" rx="6" fill="url(#hdrAmber)"/>
    <text x="149" y="29" text-anchor="middle" class="cluster-label">3. Tariff, Services &amp; Margin Shield</text>

    <!-- Table: Com_Services (Master Catalog) -->
    <g transform="translate(20, 50)" filter="url(#cardShadow)">
      <rect width="240" height="140" rx="8" fill="url(#tableCardBg)" stroke="#f59e0b" stroke-width="1"/>
      <rect width="240" height="24" rx="8" fill="url(#hdrAmber)"/>
      <text x="10" y="17" class="tbl-title">Com_Services (IATA SGHA)</text>
      <text x="10" y="42" class="col-pk">🔑 ServiceID <tspan class="col-type">INT (PK)</tspan></text>
      <text x="10" y="60" class="col-attr">ServiceCode <tspan class="col-type">VARCHAR(30)</tspan></text>
      <text x="10" y="78" class="col-attr">IATASGHACode <tspan class="col-type">CHAR(4) [GPU,ASU]</tspan></text>
      <text x="10" y="96" class="col-attr">ServiceCategory <tspan class="col-type">RAMP/CABIN/PASS</tspan></text>
      <text x="10" y="114" class="col-attr">DefaultUOM <tspan class="col-type">HOUR / START / TURN</tspan></text>
      <text x="10" y="130" font-size="9" fill="#fcd34d" font-family="sans-serif">🧰 فهرس خدمات المناولة المعياري الدولي</text>
    </g>

    <!-- Table: AP_Suppliers (Pass-Through Vendors) -->
    <g transform="translate(280, 50)" filter="url(#cardShadow)">
      <rect width="255" height="140" rx="8" fill="url(#tableCardBg)" stroke="#f59e0b" stroke-width="1"/>
      <rect width="255" height="24" rx="8" fill="url(#hdrAmber)"/>
      <text x="10" y="17" class="tbl-title">AP_Suppliers (Vendors)</text>
      <text x="10" y="42" class="col-pk">🔑 SupplierID <tspan class="col-type">INT (PK)</tspan></text>
      <text x="10" y="60" class="col-attr">SupplierCode <tspan class="col-type">VARCHAR(20) [MISR_PET]</tspan></text>
      <text x="10" y="78" class="col-attr">SupplierType <tspan class="col-type">FUEL / CATERING / BUS</tspan></text>
      <text x="10" y="96" class="col-attr">DisbursementFeePct <tspan class="col-type">5.0%</tspan></text>
      <text x="10" y="114" class="col-attr">PaymentTerms <tspan class="col-type">Net-15</tspan></text>
      <text x="10" y="130" font-size="9" fill="#fcd34d" font-family="sans-serif">⛽ مقاولو الباطن المحملين بهامش إدارة</text>
    </g>

    <!-- Table: Com_ContractServices (The Pricing Rules Matrix) -->
    <g transform="translate(20, 205)" filter="url(#cardShadow)">
      <rect width="515" height="150" rx="8" fill="url(#tableCardBg)" stroke="#fbbf24" stroke-width="1.8"/>
      <rect width="515" height="24" rx="8" fill="#b45309"/>
      <text x="10" y="17" class="tbl-title">Com_ContractServices (Negotiated Tariff &amp; Overtime Rules)</text>
      <text x="10" y="44" class="col-pk">🔑 ContractServiceID <tspan class="col-type">BIGINT (PK)</tspan></text>
      <text x="10" y="64" class="col-fk">🔗 ContractID <tspan class="col-type">INT (FK)</tspan>  |  🔗 ServiceID <tspan class="col-type">INT (FK)</tspan>  |  🔗 SupplierID <tspan class="col-type">INT (FK, Nullable)</tspan></text>
      <text x="10" y="84" class="col-attr">NegotiatedPriceUSD: <tspan class="col-type">DEC(18,4)</tspan> | OvertimeRatePerHalfHour: <tspan class="col-type">DEC(18,2)</tspan> | FreeUnitsAllowed: <tspan class="col-type">INT</tspan></text>
      <text x="10" y="104" class="col-attr">NightSurchargePct: <tspan class="col-type">20%</tspan> | HolidaySurchargePct: <tspan class="col-type">25%</tspan> | MandatoryTaxIncluded: <tspan class="col-type">BIT</tspan></text>
      <rect x="10" y="114" width="495" height="18" rx="4" fill="#451a03"/>
      <text x="15" y="127" font-size="10" font-family="'JetBrains Mono', monospace" fill="#fed7aa">
        🛡️ Negative Margin Shield: CustomerBilledPrice &gt;= SupplierCost * (1 + 0.05)
      </text>
    </g>
  </g>

  <!-- ========================================================================= -->
  <!-- DOMAIN CLUSTER 4: FLEET MTOW & AIRCRAFT REGISTRATIONS (Bottom Left) -->
  <!-- ========================================================================= -->
  <g transform="translate(30, 495)">
    <rect width="490" height="280" rx="14" fill="url(#clusterSky)" stroke="#0284c7" stroke-width="1.2" stroke-dasharray="6,4"/>
    <rect x="14" y="12" width="220" height="26" rx="6" fill="url(#hdrSky)"/>
    <text x="124" y="29" text-anchor="middle" class="cluster-label">4. Aircraft Fleet &amp; MTOW Matrix</text>

    <!-- Table: Opr_AircraftModels -->
    <g transform="translate(20, 50)" filter="url(#cardShadow)">
      <rect width="210" height="195" rx="8" fill="url(#tableCardBg)" stroke="#38bdf8" stroke-width="1"/>
      <rect width="210" height="24" rx="8" fill="url(#hdrSky)"/>
      <text x="10" y="17" class="tbl-title">Opr_AircraftModels</text>
      <text x="10" y="44" class="col-pk">🔑 ModelID <tspan class="col-type">INT (PK)</tspan></text>
      <text x="10" y="64" class="col-attr">ModelCode <tspan class="col-type">VARCHAR(20) [A320/B777]</tspan></text>
      <text x="10" y="84" class="col-attr">Manufacturer <tspan class="col-type">Airbus / Boeing</tspan></text>
      <text x="10" y="104" class="col-attr">BodyType <tspan class="col-type">CHAR(1) [N / W]</tspan></text>
      <text x="10" y="124" class="col-attr">StandardMTOWTon <tspan class="col-type">DEC(8,2)</tspan></text>
      <text x="10" y="144" class="col-attr">RequiredBuses <tspan class="col-type">INT (Remote)</tspan></text>
      <text x="10" y="164" class="col-attr">TurnaroundStandardMin <tspan class="col-type">INT</tspan></text>
      <text x="10" y="184" font-size="9" fill="#7dd3fc" font-family="sans-serif">📐 تصنيف البدن وتحديد شرائح الوزن</text>
    </g>

    <!-- Table: Opr_AircraftRegistrations -->
    <g transform="translate(250, 50)" filter="url(#cardShadow)">
      <rect width="220" height="195" rx="8" fill="url(#tableCardBg)" stroke="#38bdf8" stroke-width="1.2"/>
      <rect width="220" height="24" rx="8" fill="url(#hdrSky)"/>
      <text x="10" y="17" class="tbl-title">Opr_AircraftRegistrations</text>
      <text x="10" y="44" class="col-pk">🔑 RegistrationID <tspan class="col-type">INT (PK)</tspan></text>
      <text x="10" y="64" class="col-attr">TailNumber <tspan class="col-type">VARCHAR(20) [SU-GBD]</tspan></text>
      <text x="10" y="84" class="col-fk">🔗 AirlineID <tspan class="col-type">INT (FK)</tspan></text>
      <text x="10" y="104" class="col-fk">🔗 ModelID <tspan class="col-type">INT (FK)</tspan></text>
      <text x="10" y="124" class="col-attr">CertifiedMTOWKg <tspan class="col-type">DEC(10,2)</tspan></text>
      <text x="10" y="144" class="col-attr">HasWinglets <tspan class="col-type">BIT</tspan></text>
      <text x="10" y="164" class="col-attr">IsActive <tspan class="col-type">BIT</tspan></text>
      <text x="10" y="184" font-size="9" fill="#7dd3fc" font-family="sans-serif">🛩️ سجل الطائرة الفعلي المعتمد بالشهادة</text>
    </g>
  </g>

  <!-- ========================================================================= -->
  <!-- DOMAIN CLUSTER 5: APRON EXECUTION & REVENUE GUARD BILLING (Bottom Center & Right) -->
  <!-- ========================================================================= -->
  <g transform="translate(540, 495)">
    <rect width="1110" height="615" rx="14" fill="url(#clusterPurple)" stroke="#7c3aed" stroke-width="1.2" stroke-dasharray="6,4"/>
    <rect x="14" y="12" width="310" height="26" rx="6" fill="url(#hdrPurple)"/>
    <text x="169" y="29" text-anchor="middle" class="cluster-label">5. Apron WorkOrders &amp; Revenue Guard Billing</text>

    <!-- Table: Opr_TurnaroundWorkOrders (The Execution Convergence Hub) -->
    <g transform="translate(20, 50)" filter="url(#cardShadow)">
      <rect width="255" height="265" rx="8" fill="url(#tableCardBg)" stroke="#c084fc" stroke-width="2"/>
      <rect width="255" height="26" rx="8" fill="url(#hdrPurple)"/>
      <text x="10" y="18" class="tbl-title">Opr_TurnaroundWorkOrders</text>
      <text x="10" y="44" class="col-pk">🔑 WorkOrderID <tspan class="col-type">BIGINT (PK)</tspan></text>
      <text x="10" y="64" class="col-attr">WorkOrderNo <tspan class="col-type">VARCHAR(30) [UQ]</tspan></text>
      <text x="10" y="84" class="col-fk">🔗 ContractID <tspan class="col-type">INT (FK)</tspan></text>
      <text x="10" y="104" class="col-fk">🔗 AirportID <tspan class="col-type">INT (FK)</tspan></text>
      <text x="10" y="124" class="col-fk">🔗 AirlineID <tspan class="col-type">INT (FK)</tspan></text>
      <text x="10" y="144" class="col-fk">🔗 RegistrationID <tspan class="col-type">INT (FK)</tspan></text>
      <text x="10" y="164" class="col-attr">FlightNumber <tspan class="col-type">VARCHAR(10) [MS777]</tspan></text>
      <text x="10" y="184" class="col-attr">FlightType <tspan class="col-type">Scheduled/Charter/Cargo</tspan></text>
      <text x="10" y="204" class="col-attr">ChocksOnUtc / OffUtc <tspan class="col-type">DATETIME2(3)</tspan></text>
      <text x="10" y="224" class="col-attr">ActualGroundMinutes <tspan class="col-type">INT (Calculated)</tspan></text>
      <text x="10" y="244" class="col-attr">CaptainSignHash <tspan class="col-type">SHA-256 (Locked)</tspan></text>
      <text x="10" y="258" font-size="9" fill="#d8b4fe" font-family="sans-serif">🎯 نقطة الالتقاء التشغيلي ومصدر الفاتورة</text>
    </g>

    <!-- Table: Opr_TurnaroundServiceExecutions (Decoupled Ramp Facts) -->
    <g transform="translate(295, 50)" filter="url(#cardShadow)">
      <rect width="250" height="265" rx="8" fill="url(#tableCardBg)" stroke="#a855f7" stroke-width="1.2"/>
      <rect width="250" height="26" rx="8" fill="#6d28d9"/>
      <text x="10" y="18" class="tbl-title">Opr_ServiceExecutions</text>
      <text x="10" y="44" class="col-pk">🔑 ServiceExecutionID <tspan class="col-type">BIGINT (PK)</tspan></text>
      <text x="10" y="64" class="col-fk">🔗 WorkOrderID <tspan class="col-type">BIGINT (FK)</tspan></text>
      <text x="10" y="84" class="col-fk">🔗 ServiceID <tspan class="col-type">INT (FK)</tspan></text>
      <text x="10" y="104" class="col-fk">🔗 SupplierID <tspan class="col-type">INT (FK, Null)</tspan></text>
      <text x="10" y="124" class="col-attr">DeliveredQuantity <tspan class="col-type">DEC(10,3)</tspan></text>
      <text x="10" y="144" class="col-attr">StartTimeUtc / EndTime <tspan class="col-type">DT2(3)</tspan></text>
      <text x="10" y="164" class="col-attr">MeterStart / MeterEnd <tspan class="col-type">DEC(12,2)</tspan></text>
      <text x="10" y="184" class="col-attr">FreeAllowanceDeducted <tspan class="col-type">DEC(10,2)</tspan></text>
      <text x="10" y="204" class="col-attr">BillableUnitsOvertime <tspan class="col-type">DEC(10,2)</tspan></text>
      <text x="10" y="224" class="col-attr">IsNightTimingApplied <tspan class="col-type">BIT</tspan></text>
      <text x="10" y="244" class="col-attr">CaptainConfirmed <tspan class="col-type">BIT (1=Approved)</tspan></text>
      <text x="10" y="258" font-size="9" fill="#d8b4fe" font-family="sans-serif">📋 السجل الفعلي لاستهلاك الطاقة والخدمات</text>
    </g>

    <!-- Table: Bil_TurnaroundInvoices (Calculated Master Invoice) -->
    <g transform="translate(565, 50)" filter="url(#cardShadow)">
      <rect width="255" height="265" rx="8" fill="url(#tableCardBg)" stroke="#f43f5e" stroke-width="1.8"/>
      <rect width="255" height="26" rx="8" fill="url(#hdrRose)"/>
      <text x="10" y="18" class="tbl-title">Bil_TurnaroundInvoices (AR)</text>
      <text x="10" y="44" class="col-pk">🔑 InvoiceID <tspan class="col-type">BIGINT (PK)</tspan></text>
      <text x="10" y="64" class="col-fk">🔗 WorkOrderID <tspan class="col-type">BIGINT (FK, UQ)</tspan></text>
      <text x="10" y="84" class="col-fk">🔗 ContractID <tspan class="col-type">INT (FK)</tspan></text>
      <text x="10" y="104" class="col-fk">🔗 CustomerID <tspan class="col-type">INT (FK)</tspan></text>
      <text x="10" y="124" class="col-attr">BaseHandlingFee <tspan class="col-type">DEC(18,2)</tspan></text>
      <text x="10" y="144" class="col-attr">OvertimeGroundFee <tspan class="col-type">DEC(18,2)</tspan></text>
      <text x="10" y="164" class="col-attr">GSEExtraCharges <tspan class="col-type">DEC(18,2)</tspan></text>
      <text x="10" y="184" class="col-attr">NightSurchargeAmount <tspan class="col-type">DEC(18,2)</tspan></text>
      <text x="10" y="204" class="col-attr">DisbursementCostPlusFee <tspan class="col-type">DEC(18,2)</tspan></text>
      <text x="10" y="224" class="col-attr">AirportTaxesTotal <tspan class="col-type">DEC(18,2)</tspan></text>
      <text x="10" y="244" class="col-attr">VolumeRebateDiscount <tspan class="col-type">DEC(18,2)</tspan></text>
      <text x="10" y="258" font-size="9" fill="#fda4af" font-family="sans-serif">💰 ناتج تطبيق معادلة التسعير الشاملة</text>
    </g>

    <!-- Table: Bil_CustomerInvoiceLines (Line Item Billing Facts) -->
    <g transform="translate(840, 50)" filter="url(#cardShadow)">
      <rect width="250" height="200" rx="8" fill="url(#tableCardBg)" stroke="#f43f5e" stroke-width="1.2"/>
      <rect width="250" height="24" rx="8" fill="#9f1239"/>
      <text x="10" y="17" class="tbl-title">Bil_CustomerInvoiceLines</text>
      <text x="10" y="44" class="col-pk">🔑 InvoiceLineID <tspan class="col-type">BIGINT (PK)</tspan></text>
      <text x="10" y="64" class="col-fk">🔗 InvoiceID <tspan class="col-type">BIGINT (FK)</tspan></text>
      <text x="10" y="84" class="col-fk">🔗 ServiceExecutionID <tspan class="col-type">BIGINT (FK)</tspan></text>
      <text x="10" y="104" class="col-attr">BilledQuantity <tspan class="col-type">DEC(10,3)</tspan></text>
      <text x="10" y="124" class="col-attr">AppliedUnitPrice <tspan class="col-type">DEC(18,4)</tspan></text>
      <text x="10" y="144" class="col-attr">NightSurchargePct <tspan class="col-type">20.00%</tspan></text>
      <text x="10" y="164" class="col-attr">LineExtendedAmount <tspan class="col-type">PERSISTED</tspan></text>
      <text x="10" y="190" font-size="9" fill="#fda4af" font-family="sans-serif">🧾 تفاصيل بنود الفاتورة الضريبية للعميل</text>
    </g>

    <!-- Table: Bil_ServiceReconciliations (Negative Margin Shield & 3-Way Reconciliation) -->
    <g transform="translate(20, 345)" filter="url(#cardShadow)">
      <rect width="1070" height="240" rx="10" fill="#180726" stroke="#c084fc" stroke-width="2.2"/>
      <rect width="1070" height="28" rx="10" fill="url(#hdrPurple)"/>
      <text x="16" y="20" class="tbl-title">🛡️ Bil_ServiceReconciliations (3-Way Matching Engine &amp; Automated Negative Margin Shield)</text>
      
      <g transform="translate(16, 45)">
        <text x="0" y="16" class="col-pk">🔑 ReconciliationID <tspan class="col-type">BIGINT (PK)</tspan></text>
        <text x="0" y="38" class="col-fk">🔗 WorkOrderID <tspan class="col-type">BIGINT (FK)</tspan>  |  🔗 ServiceExecutionID <tspan class="col-type">BIGINT (FK, UQ)</tspan>  |  🔗 InvoiceLineID <tspan class="col-type">BIGINT (AR)</tspan>  |  🔗 VendorBillLineID <tspan class="col-type">BIGINT (AP)</tspan></text>
        <text x="0" y="60" class="col-attr">FlightCaptainSignedQty: <tspan class="col-type">40.00 Ton</tspan> | VendorBilledQty: <tspan class="col-type">40.00 Ton</tspan> | VarianceQty: <tspan font-weight="bold" fill="#34d399">0.00 (Pass)</tspan></text>
        <text x="0" y="82" class="col-attr">SupplierVendorCost: <tspan class="col-type">$2,400.00</tspan> | MandatoryMarkup(5%): <tspan class="col-type">+$120.00</tspan> | CustomerBilledRevenue: <tspan class="col-type">$2,520.00</tspan></text>
        <text x="0" y="104" class="col-attr">NetTurnaroundMargin: <tspan class="col-type">+$120.00 (Positive)</tspan> | MarginShieldPassed: <tspan font-weight="bold" fill="#4ade80">TRUE (1)</tspan> | AuditLockTimestamp: <tspan class="col-type">2026-10-15 UTC</tspan></text>
        
        <rect x="0" y="118" width="1038" height="34" rx="6" fill="#3b0764" stroke="#a855f7" stroke-width="1"/>
        <text x="14" y="140" font-size="11.5" font-family="'JetBrains Mono', Consolas, monospace" font-weight="bold" fill="#f472b6">
          SQL INTEGRITY CONSTRAINT: CK_MarginShield CHECK (CustomerRevenue &gt;= (VendorCost * (1.0 + DisbursementCommissionPct)))
        </text>

        <rect x="0" y="160" width="1038" height="26" rx="6" fill="#0f172a" stroke="#475569" stroke-width="0.8"/>
        <text x="14" y="177" font-size="10.5" font-family="-apple-system, sans-serif" fill="#cbd5e1">
          💡 الوظيفة المعمارية: منع ترحيل الفاتورة للـ ERP وإيقاف اعتماد أمر العمل فوراً في حال كانت تكلفة المورد أعلى من سعر فوترة العميل، لضمان استحالة حدوث خسارة تشغيلية.
        </text>
      </g>
    </g>
  </g>

  <!-- ========================================================================= -->
  <!-- CONNECTIVE RELATIONSHIP PATHS & CARDINALITY (With Glow & Colors) -->
  <!-- ========================================================================= -->

  <!-- 1. AR_Customers to Com_Contracts -->
  <path d="M 260 250 L 300 250" class="line-blue" marker-end="url(#arrowBlue)"/>
  <rect x="268" y="238" width="24" height="15" rx="3" fill="#1e3a8a"/>
  <text x="280" y="249" text-anchor="middle" class="cardinality">1:N</text>

  <!-- 2. Com_Contracts to Com_ContractAirports -->
  <path d="M 500 200 L 760 170 L 810 170" class="line-green" marker-end="url(#arrowGreen)"/>
  <rect x="735" y="160" width="28" height="15" rx="3" fill="#064e3b"/>
  <text x="749" y="171" text-anchor="middle" class="cardinality">1:N</text>

  <!-- 3. Opr_Airports to Com_ContractAirports -->
  <path d="M 790 190 L 810 190" class="line-green" marker-end="url(#arrowGreen)"/>

  <!-- 4. Com_Contracts to Com_ContractAirlines -->
  <path d="M 500 290 L 760 330 L 810 330" class="line-green" marker-end="url(#arrowGreen)"/>
  <rect x="735" y="320" width="28" height="15" rx="3" fill="#064e3b"/>
  <text x="749" y="331" text-anchor="middle" class="cardinality">1:N</text>

  <!-- 5. Opr_Airlines to Com_ContractAirlines -->
  <path d="M 790 350 L 810 350" class="line-green" marker-end="url(#arrowGreen)"/>

  <!-- 6. Opr_Airlines to Opr_AircraftRegistrations -->
  <path d="M 560 380 L 515 380 L 515 570 L 490 570" class="line-blue" marker-end="url(#arrowBlue)"/>

  <!-- 7. Opr_AircraftModels to Opr_AircraftRegistrations -->
  <path d="M 260 640 L 280 640" class="line-blue" marker-end="url(#arrowBlue)"/>
  <rect x="264" y="628" width="24" height="15" rx="3" fill="#0369a1"/>
  <text x="276" y="639" text-anchor="middle" class="cardinality">1:N</text>

  <!-- 8. Com_Contracts to Com_ContractServices -->
  <path d="M 500 340 L 1110 325" class="line-amber" marker-end="url(#arrowAmber)"/>
  <rect x="990" y="325" width="28" height="15" rx="3" fill="#78350f"/>
  <text x="1004" y="336" text-anchor="middle" class="cardinality">1:N</text>

  <!-- 9. Com_Services to Com_ContractServices -->
  <path d="M 1230 295 L 1230 310" class="line-amber" marker-end="url(#arrowAmber)"/>

  <!-- 10. AP_Suppliers to Com_ContractServices -->
  <path d="M 1490 295 L 1490 310" class="line-amber" marker-end="url(#arrowAmber)"/>

  <!-- 11. Com_Contracts to Opr_TurnaroundWorkOrders (Core Operational Link) -->
  <path d="M 400 450 L 400 660 L 560 660" class="line-purple" stroke-width="2.2" marker-end="url(#arrowPurple)"/>
  <rect x="445" y="648" width="30" height="15" rx="3" fill="#4c1d95"/>
  <text x="460" y="659" text-anchor="middle" class="cardinality">1:N</text>

  <!-- 12. Opr_AircraftRegistrations to Opr_TurnaroundWorkOrders -->
  <path d="M 500 680 L 560 680" class="line-blue" marker-end="url(#arrowBlue)"/>

  <!-- 13. Opr_TurnaroundWorkOrders to Opr_ServiceExecutions -->
  <path d="M 815 670 L 835 670" class="line-purple" marker-end="url(#arrowPurple)"/>
  <rect x="815" y="658" width="24" height="15" rx="3" fill="#4c1d95"/>
  <text x="827" y="669" text-anchor="middle" class="cardinality">1:N</text>

  <!-- 14. Opr_TurnaroundWorkOrders to Bil_TurnaroundInvoices (1:1 Locked Link) -->
  <path d="M 700 810 L 700 830 L 1105 830 L 1105 700" class="line-rose" stroke-width="2" marker-end="url(#arrowRose)"/>
  <rect x="880" y="822" width="65" height="16" rx="4" fill="#9f1239"/>
  <text x="912" y="834" text-anchor="middle" class="cardinality">1:1 Invoice Hub</text>

  <!-- 15. Bil_TurnaroundInvoices to Bil_CustomerInvoiceLines -->
  <path d="M 1360 670 L 1380 670" class="line-rose" marker-end="url(#arrowRose)"/>
  <rect x="1360" y="658" width="24" height="15" rx="3" fill="#9f1239"/>
  <text x="1372" y="669" text-anchor="middle" class="cardinality">1:N</text>

  <!-- 16. Opr_ServiceExecutions to Bil_CustomerInvoiceLines -->
  <path d="M 1085 640 L 1380 640" class="line-purple" marker-end="url(#arrowPurple)"/>

  <!-- 17. Reconciliations to InvoiceLines and ServiceExecutions -->
  <path d="M 960 760 L 960 840" class="line-purple" marker-end="url(#arrowPurple)"/>
  <path d="M 1500 750 L 1500 840" class="line-rose" marker-end="url(#arrowRose)"/>

</svg>
'''

output_dir = os.path.join(os.path.dirname(__file__), 'images')
os.makedirs(output_dir, exist_ok=True)
svg_path = os.path.join(output_dir, 'contract_factors_erd.svg')
png_path = os.path.join(output_dir, 'contract_factors_erd.png')

with open(svg_path, 'w', encoding='utf-8') as f:
    f.write(SVG_CONTENT.strip())
print(f'Successfully wrote: {svg_path}')

# Render Ultra-HD PNG via qlmanage (3400px)
cmd = f'qlmanage -t -s 3400 -o "{output_dir}" "{svg_path}"'
res = subprocess.run(cmd, shell=True, capture_output=True, text=True)
temp_png = os.path.join(output_dir, 'contract_factors_erd.svg.png')
if os.path.exists(temp_png):
    os.rename(temp_png, png_path)
    print(f'Successfully generated ultra high-res PNG: {png_path}')
else:
    print('qlmanage result:', res.stdout, res.stderr)
