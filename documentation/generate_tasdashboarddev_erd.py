#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
High-Resolution Vector SVG ERD & Interactive HTML Explorer Generator
for TasDashBoardDev Database (117 Tables, 292 Inferred Relational Keys).
"""

import json
import os
import subprocess
import html
import math

# Load clean ERD data
with open("/tmp/tas_clean_erd_data.json") as f:
    erd_data = json.load(f)

tables = erd_data["tables"]
relations = erd_data["relations"]

DOMAINS = {
    "FINANCIAL": {
        "title": "Financial Entities (AR Debtors & AP Suppliers)",
        "color": "#f43f5e",
        "border": "rgba(244, 63, 94, 0.5)",
        "bg": "rgba(244, 63, 94, 0.06)",
        "hdr": "linear-gradient(135deg, #be123c, #f43f5e)",
        "prefix": "AR/AP",
        "desc": "Commercial debtors, ground handling service providers, and subcontracted vendors"
    },
    "COMMERCIAL": {
        "title": "Commercial Contracts, Tariffs & Services Catalog",
        "color": "#f59e0b",
        "border": "rgba(245, 158, 11, 0.5)",
        "bg": "rgba(245, 158, 11, 0.06)",
        "hdr": "linear-gradient(135deg, #b45309, #f59e0b)",
        "prefix": "Com/COM",
        "desc": "Contract SLAs, SGHA clauses, standard price lists, formula rules, and package bundles"
    },
    "OPERATIONS": {
        "title": "Turnaround Operations & Apron Work Orders",
        "color": "#c084fc",
        "border": "rgba(192, 132, 252, 0.5)",
        "bg": "rgba(168, 85, 247, 0.06)",
        "hdr": "linear-gradient(135deg, #6d28d9, #a855f7)",
        "prefix": "Opr_WorkOrder",
        "desc": "Apron ramp work orders, delivered service execution lines, and field turnaround facts"
    },
    "FLEET_STATIONS": {
        "title": "Fleet, Airlines & Station Infrastructure",
        "color": "#10b981",
        "border": "rgba(16, 185, 129, 0.5)",
        "bg": "rgba(16, 185, 129, 0.06)",
        "hdr": "linear-gradient(135deg, #047857, #10b981)",
        "prefix": "Opr_Air",
        "desc": "Airports, terminals, gates, counters, aircraft models, tail registrations, and carrier fleets"
    },
    "PLANNING": {
        "title": "Flight Planning, Patterns & Schedules",
        "color": "#06b6d4",
        "border": "rgba(6, 182, 212, 0.5)",
        "bg": "rgba(6, 182, 212, 0.06)",
        "hdr": "linear-gradient(135deg, #0e7490, #06b6d4)",
        "prefix": "Opr_Plan/Schedule",
        "desc": "Seasonal flight schedules, weekly pattern templates, landing frequencies, and delay logs"
    },
    "SYSTEM_ADMIN": {
        "title": "System Org, Multi-Company, UOM & Administration",
        "color": "#818cf8",
        "border": "rgba(129, 140, 248, 0.5)",
        "bg": "rgba(99, 102, 241, 0.06)",
        "hdr": "linear-gradient(135deg, #4338ca, #6366f1)",
        "prefix": "Tas_",
        "desc": "Company branches, multi-currency rates, countries/cities, UOM converters, users, and audit logs"
    }
}

def get_table_domain(tname):
    if tname.startswith("AR_") or tname.startswith("AP_"):
        return "FINANCIAL"
    elif tname.startswith("Com_") or tname.startswith("COM_") or tname.startswith("com_"):
        return "COMMERCIAL"
    elif tname.startswith("Opr_Plan") or tname.startswith("Opr_Schedule"):
        return "PLANNING"
    elif tname.startswith("Opr_WorkOrder") or tname in [
        "Opr_Hotel", "Opr_Transportion", "Opr_Shipment", "Opr_Fuel", "Opr_FuelType", "Opr_FuelDiscount", "Opr_AuditReasons"
    ]:
        return "OPERATIONS"
    elif tname.startswith("Opr_") or tname.startswith("AGSH_"):
        return "FLEET_STATIONS"
    elif tname.startswith("Tas_"):
        return "SYSTEM_ADMIN"
    return "SYSTEM_ADMIN"

# Collect relations per table
table_incoming = {t: [] for t in tables}
table_outgoing = {t: [] for t in tables}
for r in relations:
    table_outgoing[r["from_table"]].append(r)
    table_incoming[r["to_table"]].append(r)

# Define Core Spotlight Tables for the Primary ERD Map (top ~45 most critical structural tables)
# All 117 tables are rendered and searchable in the interactive viewer!
SPOTLIGHT_LAYOUT = {
    # FINANCIAL (Top-Left)
    "AR_Customers":            {"x": 55,   "y": 155, "w": 280, "dom": "FINANCIAL"},
    "AR_Customer_Group":      {"x": 60,   "y": 480, "w": 260, "dom": "FINANCIAL"},
    "AP_Supplierpliers":       {"x": 60,   "y": 660, "w": 280, "dom": "FINANCIAL"},
    "AP_Supplier_Group":       {"x": 60,   "y": 1020,"w": 260, "dom": "FINANCIAL"},
    "AP_Vendor_Type":          {"x": 60,   "y": 1180,"w": 260, "dom": "FINANCIAL"},

    # COMMERCIAL (Left-Center)
    "Com_ContractSetup":       {"x": 410,  "y": 155, "w": 320, "dom": "COMMERCIAL"},
    "Com_ContractTypeSetup":   {"x": 420,  "y": 570, "w": 280, "dom": "COMMERCIAL"},
    "Com_ContractRule":        {"x": 420,  "y": 760, "w": 320, "dom": "COMMERCIAL"},
    "Com_PriceList":           {"x": 420,  "y": 1160,"w": 320, "dom": "COMMERCIAL"},
    "Com_Services":            {"x": 800,  "y": 760, "w": 300, "dom": "COMMERCIAL"},
    "Com_ServiceGroups":       {"x": 800,  "y": 1120,"w": 280, "dom": "COMMERCIAL"},
    "Com_PackagesHeader":      {"x": 800,  "y": 1280,"w": 280, "dom": "COMMERCIAL"},
    "com_Packages":            {"x": 800,  "y": 1460,"w": 280, "dom": "COMMERCIAL"},
    "Com_PackageServices":     {"x": 800,  "y": 1660,"w": 280, "dom": "COMMERCIAL"},
    "COM_IATASetup":           {"x": 420,  "y": 1540,"w": 280, "dom": "COMMERCIAL"},
    "COM_IATAVersions":        {"x": 420,  "y": 1720,"w": 280, "dom": "COMMERCIAL"},

    # OPERATIONS (Center & Center-Bottom)
    "Opr_WorkOrder":           {"x": 780,  "y": 155, "w": 340, "dom": "OPERATIONS"},
    "Opr_WorkOrderServices":   {"x": 1180, "y": 155, "w": 340, "dom": "OPERATIONS"},
    "Opr_WorkOrderPAXCount":   {"x": 1200, "y": 580, "w": 300, "dom": "OPERATIONS"},
    "Opr_WorkOrderPAXList":    {"x": 1200, "y": 770, "w": 300, "dom": "OPERATIONS"},
    "Opr_WorkOrderMovement":   {"x": 1200, "y": 960, "w": 300, "dom": "OPERATIONS"},
    "Opr_WorkOrderResources":  {"x": 1200, "y": 1140,"w": 300, "dom": "OPERATIONS"},
    "Opr_WorkOrderCatering":   {"x": 1200, "y": 1320,"w": 300, "dom": "OPERATIONS"},
    "Opr_WorkOrderExpenses":   {"x": 1200, "y": 1500,"w": 300, "dom": "OPERATIONS"},
    "Opr_WorkOrderSecurity":   {"x": 1200, "y": 1680,"w": 300, "dom": "OPERATIONS"},
    "Opr_Hotel":               {"x": 1200, "y": 1840,"w": 280, "dom": "OPERATIONS"},
    "Opr_Transportion":        {"x": 1200, "y": 2010,"w": 280, "dom": "OPERATIONS"},

    # FLEET & STATIONS (Right-Top)
    "Opr_Airports":            {"x": 1610, "y": 155, "w": 320, "dom": "FLEET_STATIONS"},
    "Opr_AirportGroups":       {"x": 1620, "y": 560, "w": 280, "dom": "FLEET_STATIONS"},
    "Opr_AirportTerminals":    {"x": 1620, "y": 730, "w": 300, "dom": "FLEET_STATIONS"},
    "Opr_AirportParkingArea":  {"x": 1620, "y": 920, "w": 290, "dom": "FLEET_STATIONS"},
    "Opr_AirportParkingPosition":{"x":1620, "y": 1100,"w": 300, "dom": "FLEET_STATIONS"},
    "Opr_AirportGateInformation":{"x":1620, "y": 1290,"w": 300, "dom": "FLEET_STATIONS"},
    "Opr_AirportCounterInformation":{"x":1620,"y": 1470,"w": 300, "dom": "FLEET_STATIONS"},
    "Opr_AirCraftModel":       {"x": 1990, "y": 155, "w": 320, "dom": "FLEET_STATIONS"},
    "Opr_AircraftRregistration":{"x":2000, "y": 550, "w": 320, "dom": "FLEET_STATIONS"},
    "Opr_Airlines":            {"x": 2000, "y": 960, "w": 300, "dom": "FLEET_STATIONS"},
    "Opr_AirLineGroup":        {"x": 2000, "y": 1330,"w": 280, "dom": "FLEET_STATIONS"},
    "Opr_DayTypes":            {"x": 2000, "y": 1500,"w": 260, "dom": "FLEET_STATIONS"},

    # PLANNING & SCHEDULES (Right-Center)
    "Opr_Schedule":            {"x": 2380, "y": 155, "w": 320, "dom": "PLANNING"},
    "Opr_ScheduleReason":      {"x": 2380, "y": 550, "w": 260, "dom": "PLANNING"},
    "Opr_PlanHeader":          {"x": 2380, "y": 720, "w": 280, "dom": "PLANNING"},
    "Opr_PlanWeekPattern":     {"x": 2380, "y": 940, "w": 280, "dom": "PLANNING"},
    "Opr_PlanPatternDay":      {"x": 2380, "y": 1140,"w": 300, "dom": "PLANNING"},
    "Opr_PlanPatternDayLands": {"x": 2380, "y": 1360,"w": 300, "dom": "PLANNING"},

    # SYSTEM ADMIN (Right & Far Right / Bottom)
    "Tas_Company":             {"x": 2760, "y": 155, "w": 300, "dom": "SYSTEM_ADMIN"},
    "Tas_CompanyBranches":     {"x": 2760, "y": 480, "w": 300, "dom": "SYSTEM_ADMIN"},
    "Tas_Company_Branches_Setup":{"x":2760, "y": 740, "w": 310, "dom": "SYSTEM_ADMIN"},
    "Tas_Currency":            {"x": 2760, "y": 970, "w": 280, "dom": "SYSTEM_ADMIN"},
    "Tas_Currency_Rate":       {"x": 2760, "y": 1170,"w": 280, "dom": "SYSTEM_ADMIN"},
    "Tas_Country_Setup":       {"x": 2760, "y": 1380,"w": 280, "dom": "SYSTEM_ADMIN"},
    "Tas_Subdivison":          {"x": 2760, "y": 1560,"w": 280, "dom": "SYSTEM_ADMIN"},
    "Tas_City":                {"x": 2760, "y": 1740,"w": 280, "dom": "SYSTEM_ADMIN"},
    "Tas_Area":                {"x": 2760, "y": 1920,"w": 280, "dom": "SYSTEM_ADMIN"},
    "Tas_Uom":                 {"x": 3140, "y": 155, "w": 260, "dom": "SYSTEM_ADMIN"},
    "Tas_Uom_Group":           {"x": 3120, "y": 340, "w": 260, "dom": "SYSTEM_ADMIN"},
    "Tas_UserSetup":           {"x": 3120, "y": 520, "w": 280, "dom": "SYSTEM_ADMIN"},
    "Tas_UserGroupSetup":      {"x": 3120, "y": 740, "w": 260, "dom": "SYSTEM_ADMIN"},
    "Tas_Log":                 {"x": 3120, "y": 920, "w": 280, "dom": "SYSTEM_ADMIN"},
    "Tas_Menus":               {"x": 3120, "y": 1140,"w": 280, "dom": "SYSTEM_ADMIN"}
}

# Calculate height for each spotlight table based on its columns
for tname, pos in SPOTLIGHT_LAYOUT.items():
    tinfo = tables.get(tname, {"columns": [], "rows": 0, "pks": []})
    cols = tinfo["columns"]
    # We display up to 8 key columns in the SVG card
    disp_cols = min(len(cols), 8)
    # Header: 36px, Each column: 22px, Footer: 24px, padding: 10px
    pos["h"] = 38 + (disp_cols * 22) + 26
    pos["rows"] = tinfo["rows"]
    pos["col_count"] = len(cols)
    pos["pks"] = tinfo["pks"]

print(f"Configured layout for {len(SPOTLIGHT_LAYOUT)} spotlight tables.")

# Build SVG
CANVAS_W = 3560
CANVAS_H = 2250

svg_parts = []
svg_parts.append(f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {CANVAS_W} {CANVAS_H}" width="100%" height="100%" style="background:#070b14;">
  <defs>
    <!-- Background Canvas Gradients -->
    <linearGradient id="bgGradient" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#050811"/>
      <stop offset="50%" stop-color="#090f1d"/>
      <stop offset="100%" stop-color="#0b1326"/>
    </linearGradient>

    <!-- Domain Glow & Header Gradients -->
    <linearGradient id="hdrFinancial" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" stop-color="#be123c"/>
      <stop offset="100%" stop-color="#f43f5e"/>
    </linearGradient>
    <linearGradient id="hdrCommercial" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" stop-color="#b45309"/>
      <stop offset="100%" stop-color="#f59e0b"/>
    </linearGradient>
    <linearGradient id="hdrOperations" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" stop-color="#6d28d9"/>
      <stop offset="100%" stop-color="#a855f7"/>
    </linearGradient>
    <linearGradient id="hdrFleet" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" stop-color="#047857"/>
      <stop offset="100%" stop-color="#10b981"/>
    </linearGradient>
    <linearGradient id="hdrPlanning" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" stop-color="#0e7490"/>
      <stop offset="100%" stop-color="#06b6d4"/>
    </linearGradient>
    <linearGradient id="hdrAdmin" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" stop-color="#4338ca"/>
      <stop offset="100%" stop-color="#6366f1"/>
    </linearGradient>

    <!-- Table Card Background Gradient -->
    <linearGradient id="tableCardBg" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#141c2e"/>
      <stop offset="100%" stop-color="#0d1424"/>
    </linearGradient>

    <!-- Filters -->
    <filter id="cardShadow" x="-10%" y="-10%" width="120%" height="120%">
      <feDropShadow dx="0" dy="6" stdDeviation="6" flood-color="#000000" flood-opacity="0.6"/>
    </filter>

    <!-- Relation Arrow Markers -->
    <marker id="arrowRose" viewBox="0 0 10 10" refX="7" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M 0 1.5 L 8 5 L 0 8.5 z" fill="#f43f5e"/>
    </marker>
    <marker id="arrowAmber" viewBox="0 0 10 10" refX="7" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M 0 1.5 L 8 5 L 0 8.5 z" fill="#f59e0b"/>
    </marker>
    <marker id="arrowPurple" viewBox="0 0 10 10" refX="7" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M 0 1.5 L 8 5 L 0 8.5 z" fill="#c084fc"/>
    </marker>
    <marker id="arrowEmerald" viewBox="0 0 10 10" refX="7" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M 0 1.5 L 8 5 L 0 8.5 z" fill="#10b981"/>
    </marker>
    <marker id="arrowCyan" viewBox="0 0 10 10" refX="7" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M 0 1.5 L 8 5 L 0 8.5 z" fill="#06b6d4"/>
    </marker>
    <marker id="arrowIndigo" viewBox="0 0 10 10" refX="7" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M 0 1.5 L 8 5 L 0 8.5 z" fill="#818cf8"/>
    </marker>
    <marker id="circleStart" viewBox="0 0 10 10" refX="5" refY="5" markerWidth="6" markerHeight="6">
      <circle cx="5" cy="5" r="3.5" fill="#94a3b8"/>
    </marker>
  </defs>

  <style>
    .banner-title {{ font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Cairo", sans-serif; font-size: 26px; font-weight: 900; fill: #ffffff; }}
    .banner-sub {{ font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Cairo", sans-serif; font-size: 14px; font-weight: 500; fill: #94a3b8; }}
    .domain-label {{ font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; font-size: 15px; font-weight: 800; letter-spacing: 0.5px; fill: #ffffff; }}
    .tbl-title {{ font-family: "JetBrains Mono", "SF Mono", Consolas, monospace; font-size: 13.5px; font-weight: 800; fill: #ffffff; }}
    .tbl-rows {{ font-family: "JetBrains Mono", Consolas, monospace; font-size: 10px; font-weight: 700; fill: #e2e8f0; }}
    .col-pk {{ font-family: "JetBrains Mono", Consolas, monospace; font-size: 11.5px; font-weight: 800; fill: #fde047; }}
    .col-fk {{ font-family: "JetBrains Mono", Consolas, monospace; font-size: 11.5px; font-weight: 800; fill: #38bdf8; }}
    .col-norm {{ font-family: "JetBrains Mono", Consolas, monospace; font-size: 11px; font-weight: 600; fill: #cbd5e1; }}
    .col-type {{ font-family: "JetBrains Mono", Consolas, monospace; font-size: 9.5px; font-weight: 600; fill: #64748b; }}
    .cardinality-txt {{ font-family: "JetBrains Mono", Consolas, monospace; font-size: 11px; font-weight: 900; fill: #f8fafc; }}
  </style>

  <!-- Background Base Canvas -->
  <rect width="{CANVAS_W}" height="{CANVAS_H}" fill="url(#bgGradient)"/>
  <!-- Subtle Grid Overlay -->
  <pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse">
    <path d="M 40 0 L 0 0 0 40" fill="none" stroke="rgba(148, 163, 184, 0.04)" stroke-width="1"/>
  </pattern>
  <rect width="{CANVAS_W}" height="{CANVAS_H}" fill="url(#grid)"/>
''')

# Render Top Executive Banner
svg_parts.append(f'''
  <!-- TOP BANNER & STATS -->
  <g transform="translate(40, 20)">
    <rect width="{CANVAS_W - 80}" height="80" rx="14" fill="#0c1222" stroke="rgba(56, 189, 248, 0.3)" stroke-width="1.5" filter="url(#cardShadow)"/>
    <rect x="20" y="16" width="6" height="48" rx="3" fill="#38bdf8"/>
    <text x="38" y="44" class="banner-title">TasDashBoardDev — Full Entity-Relationship Architecture Diagram (ERD &amp; Inferred Keys)</text>
    <text x="38" y="66" class="banner-sub">Complete Reverse-Engineered Relational Graph of Ground Handling, Commercial Turnaround Contracts, Fleet &amp; Billing Engine</text>

    <!-- KPI Badges -->
    <g transform="translate({CANVAS_W - 1380}, 24)">
      <rect x="0" y="0" width="180" height="34" rx="8" fill="#1e293b" stroke="#334155" stroke-width="1"/>
      <text x="90" y="22" text-anchor="middle" font-size="12" fill="#38bdf8" font-family="'JetBrains Mono', monospace" font-weight="800">📊 117 Total Tables</text>

      <rect x="195" y="0" width="220" height="34" rx="8" fill="rgba(244, 63, 94, 0.15)" stroke="rgba(244, 63, 94, 0.4)" stroke-width="1"/>
      <text x="305" y="22" text-anchor="middle" font-size="12" fill="#fb7185" font-family="'JetBrains Mono', monospace" font-weight="800">❌ 0 DB Physical FKs</text>

      <rect x="430" y="0" width="250" height="34" rx="8" fill="rgba(16, 185, 129, 0.15)" stroke="rgba(16, 185, 129, 0.4)" stroke-width="1"/>
      <text x="555" y="22" text-anchor="middle" font-size="12" fill="#34d399" font-family="'JetBrains Mono', monospace" font-weight="800">🔗 292 Inferred Relational FKs</text>

      <rect x="695" y="0" width="200" height="34" rx="8" fill="rgba(168, 85, 247, 0.15)" stroke="rgba(168, 85, 247, 0.4)" stroke-width="1"/>
      <text x="795" y="22" text-anchor="middle" font-size="12" fill="#c084fc" font-family="'JetBrains Mono', monospace" font-weight="800">🏛️ 6 Functional Domains</text>

      <rect x="910" y="0" width="160" height="34" rx="8" fill="rgba(245, 158, 11, 0.15)" stroke="rgba(245, 158, 11, 0.4)" stroke-width="1"/>
      <text x="990" y="22" text-anchor="middle" font-size="12" fill="#fcd34d" font-family="'JetBrains Mono', monospace" font-weight="800">⚙️ MS SQL Server</text>
    </g>
  </g>
''')

# Render Domain Background Cluster Zones

hdr_ids = {
    "FINANCIAL": "hdrFinancial",
    "COMMERCIAL": "hdrCommercial",
    "OPERATIONS": "hdrOperations",
    "FLEET_STATIONS": "hdrFleet",
    "PLANNING": "hdrPlanning",
    "SYSTEM_ADMIN": "hdrAdmin"
}

domain_bounds = {
    "FINANCIAL":     {"x": 35,   "y": 120, "w": 330, "h": 2090, "color": DOMAINS["FINANCIAL"]["color"], "title": "1. Financial: AR Customers &amp; AP Suppliers"},
    "COMMERCIAL":    {"x": 385,  "y": 120, "w": 745, "h": 2090, "color": DOMAINS["COMMERCIAL"]["color"], "title": "2. Commercial Contracts &amp; Tariffs"},
    "OPERATIONS":    {"x": 1150, "y": 120, "w": 420, "h": 2090, "color": DOMAINS["OPERATIONS"]["color"], "title": "3. Operations &amp; Apron Work Orders"},
    "FLEET_STATIONS":{"x": 1590, "y": 120, "w": 750, "h": 2090, "color": DOMAINS["FLEET_STATIONS"]["color"], "title": "4. Fleet &amp; Station Infrastructure"},
    "PLANNING":      {"x": 2360, "y": 120, "w": 360, "h": 2090, "color": DOMAINS["PLANNING"]["color"], "title": "5. Flight Planning &amp; Schedules"},
    "SYSTEM_ADMIN":  {"x": 2740, "y": 120, "w": 780, "h": 2090, "color": DOMAINS["SYSTEM_ADMIN"]["color"], "title": "6. System Org &amp; Master Setup"}
}

for d_key, bounds in domain_bounds.items():
    d_conf = DOMAINS[d_key]
    svg_parts.append(f'''
    <!-- Cluster: {d_key} -->
    <rect x="{bounds['x']}" y="{bounds['y']}" width="{bounds['w']}" height="{bounds['h']}" rx="14" fill="{d_conf['bg']}" stroke="{d_conf['border']}" stroke-width="1.2" stroke-dasharray="6,4"/>
    <g transform="translate({bounds['x'] + 14}, {bounds['y'] + 12})">
      <rect width="{bounds['w'] - 28}" height="26" rx="6" fill="url(#{hdr_ids[d_key]})"/>
      <text x="{(bounds['w'] - 28) / 2}" y="18" text-anchor="middle" class="domain-label">{bounds['title']}</text>
    </g>
''')

# Connectors: Filter to relationships where BOTH source and target are in SPOTLIGHT_LAYOUT
spotlight_relations = []
for r in relations:
    if r["from_table"] in SPOTLIGHT_LAYOUT and r["to_table"] in SPOTLIGHT_LAYOUT:
        spotlight_relations.append(r)

print(f"Drawing {len(spotlight_relations)} connection curves between spotlight tables...")

# Draw Relation Curves first (so tables render on top)
svg_parts.append('  <!-- ================= RELATIONAL CONNECTIONS ================= -->\n  <g class="relationships-layer">\n')

color_by_domain = {
    "FINANCIAL": ("#f43f5e", "arrowRose"),
    "COMMERCIAL": ("#f59e0b", "arrowAmber"),
    "OPERATIONS": ("#c084fc", "arrowPurple"),
    "FLEET_STATIONS": ("#10b981", "arrowEmerald"),
    "PLANNING": ("#06b6d4", "arrowCyan"),
    "SYSTEM_ADMIN": ("#818cf8", "arrowIndigo")
}

for r in spotlight_relations:
    src_t = r["from_table"]
    dst_t = r["to_table"]
    p_src = SPOTLIGHT_LAYOUT[src_t]
    p_dst = SPOTLIGHT_LAYOUT[dst_t]

    # Calculate connection anchor points
    # If source is to the left of dest: connect src right edge to dst left edge
    if p_src["x"] + p_src["w"] < p_dst["x"]:
        x1 = p_src["x"] + p_src["w"]
        y1 = p_src["y"] + (p_src["h"] * 0.4)
        x2 = p_dst["x"]
        y2 = p_dst["y"] + (p_dst["h"] * 0.4)
        cx1 = x1 + (x2 - x1) * 0.45
        cy1 = y1
        cx2 = x2 - (x2 - x1) * 0.45
        cy2 = y2
    elif p_dst["x"] + p_dst["w"] < p_src["x"]:
        x1 = p_src["x"]
        y1 = p_src["y"] + (p_src["h"] * 0.4)
        x2 = p_dst["x"] + p_dst["w"]
        y2 = p_dst["y"] + (p_dst["h"] * 0.4)
        cx1 = x1 - (x1 - x2) * 0.45
        cy1 = y1
        cx2 = x2 + (x1 - x2) * 0.45
        cy2 = y2
    else:
        # Vertical stacking
        if p_src["y"] < p_dst["y"]:
            x1 = p_src["x"] + (p_src["w"] * 0.5)
            y1 = p_src["y"] + p_src["h"]
            x2 = p_dst["x"] + (p_dst["w"] * 0.5)
            y2 = p_dst["y"]
            cx1 = x1
            cy1 = y1 + (y2 - y1) * 0.5
            cx2 = x2
            cy2 = y2 - (y2 - y1) * 0.5
        else:
            x1 = p_src["x"] + (p_src["w"] * 0.5)
            y1 = p_src["y"]
            x2 = p_dst["x"] + (p_dst["w"] * 0.5)
            y2 = p_dst["y"] + p_dst["h"]
            cx1 = x1
            cy1 = y1 - (y1 - y2) * 0.5
            cx2 = x2
            cy2 = y2 + (y1 - y2) * 0.5

    d_key = p_src["dom"]
    stroke_color, marker_id = color_by_domain.get(d_key, ("#38bdf8", "arrowAmber"))

    path_d = f"M {x1:.1f} {y1:.1f} C {cx1:.1f} {cy1:.1f}, {cx2:.1f} {cy2:.1f}, {x2:.1f} {y2:.1f}"
    svg_parts.append(f'''    <path d="{path_d}" fill="none" stroke="{stroke_color}" stroke-width="1.8" stroke-opacity="0.65" marker-end="url(#{marker_id})" marker-start="url(#circleStart)"/>\n''')

svg_parts.append('  </g>\n')

# Render Spotlight Table Cards
svg_parts.append('  <!-- ================= TABLE CARDS ================= -->\n  <g class="tables-layer">\n')

for tname, pos in SPOTLIGHT_LAYOUT.items():
    tinfo = tables.get(tname, {"columns": [], "rows": 0, "pks": []})
    cols = tinfo["columns"]
    pks = set(tinfo["pks"])
    dom_key = pos["dom"]
    d_conf = DOMAINS[dom_key]

    x, y, w, h = pos["x"], pos["y"], pos["w"], pos["h"]
    row_count = pos["rows"]

    # Header gradient
    hdr_id = f"hdr{dom_key.capitalize()}"
    if dom_key == "FLEET_STATIONS": hdr_id = "hdrFleet"
    elif dom_key == "SYSTEM_ADMIN": hdr_id = "hdrAdmin"

    svg_parts.append(f'''
    <!-- Table: {tname} -->
    <g transform="translate({x}, {y})" filter="url(#cardShadow)" id="table-card-{tname}">
      <!-- Card Body -->
      <rect width="{w}" height="{h}" rx="9" fill="url(#tableCardBg)" stroke="{d_conf['color']}" stroke-width="1.4"/>
      <!-- Header Bar -->
      <rect width="{w}" height="32" rx="9" fill="url(#{hdr_id})"/>
      <rect y="24" width="{w}" height="8" fill="url(#{hdr_id})"/>
      <!-- Table Name & Row count -->
      <text x="10" y="21" class="tbl-title">{tname}</text>
      <rect x="{w - 76}" y="6" width="68" height="20" rx="4" fill="rgba(15, 23, 42, 0.6)"/>
      <text x="{w - 42}" y="20" text-anchor="middle" class="tbl-rows">{row_count:,} rows</text>
''')

    # Columns display: up to 8 columns
    cur_y = 52
    disp_cols = cols[:8]
    for c in disp_cols:
        cname = c["name"]
        ctype = c["type"]
        is_pk = cname in pks

        # Check if column is an inferred foreign key
        is_fk = False
        target_t = ""
        for r in table_outgoing.get(tname, []):
            if cname in r["from_col"].split(", "):
                is_fk = True
                target_t = r["to_table"]
                break

        if is_pk:
            icon_badge = "🔑"
            col_class = "col-pk"
            tag = "PK"
        elif is_fk:
            icon_badge = "🔗"
            col_class = "col-fk"
            tag = f"FK ➔ {target_t.split('_')[-1]}"
        else:
            icon_badge = "•"
            col_class = "col-norm"
            tag = ""

        # Truncate tag if too long
        if len(tag) > 18:
            tag = tag[:16] + ".."

        svg_parts.append(f'''      <text x="10" y="{cur_y}" class="{col_class}">{icon_badge} {cname} <tspan class="col-type">{ctype}</tspan></text>''')
        if tag:
            svg_parts.append(f'''      <text x="{w - 8}" y="{cur_y}" text-anchor="end" font-size="9" font-family="'JetBrains Mono', monospace" fill="{d_conf['color']}">{tag}</text>''')
        cur_y += 22

    # Extra columns indicator
    if len(cols) > 8:
        remaining = len(cols) - 8
        svg_parts.append(f'''      <text x="10" y="{cur_y + 2}" font-size="9.5" font-family="sans-serif" font-style="italic" fill="#64748b">+ {remaining} more columns ({len(cols)} total)</text>''')

    svg_parts.append('    </g>\n')

svg_parts.append('  </g>\n')

# Close SVG
svg_parts.append('</svg>')

svg_content = "".join(svg_parts)
svg_path = "documentation/images/tasdashboarddev_erd_diagram.svg"
with open(svg_path, "w", encoding="utf-8") as f:
    f.write(svg_content)

print(f"Generated complete vector SVG diagram: {svg_path} ({len(svg_content)} bytes)")

# Generate Interactive HTML Explorer
html_content = f'''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>TasDashBoardDev — Interactive Relational ERD Explorer</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@600;700;800;900&family=Inter:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;500;600;700&display=swap" rel="stylesheet">
  <style>
    :root {{
      --bg-canvas: #070b14;
      --bg-panel: rgba(15, 23, 42, 0.85);
      --bg-card: rgba(30, 41, 59, 0.7);
      --border-color: rgba(148, 163, 184, 0.15);
      --border-glow: rgba(56, 189, 248, 0.4);
      --accent-blue: #38bdf8;
      --accent-rose: #f43f5e;
      --accent-amber: #f59e0b;
      --accent-purple: #c084fc;
      --accent-emerald: #10b981;
      --accent-cyan: #06b6d4;
      --accent-indigo: #818cf8;
      --text-main: #f8fafc;
      --text-muted: #94a3b8;
      --text-dim: #64748b;
    }}

    * {{ box-sizing: border-box; margin: 0; padding: 0; }}
    body {{
      font-family: 'Inter', sans-serif;
      background: var(--bg-canvas);
      color: var(--text-main);
      overflow: hidden;
      height: 100vh;
      display: flex;
      flex-direction: column;
    }}

    /* Top Navigation Header */
    header {{
      background: rgba(11, 18, 33, 0.95);
      border-bottom: 1px solid var(--border-color);
      backdrop-filter: blur(16px);
      padding: 12px 24px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      z-index: 50;
      flex-shrink: 0;
    }}

    .brand-section {{
      display: flex;
      align-items: center;
      gap: 14px;
    }}

    .brand-badge {{
      background: linear-gradient(135deg, #0284c7, #6366f1);
      color: white;
      font-weight: 800;
      font-size: 12px;
      padding: 4px 10px;
      border-radius: 6px;
      letter-spacing: 0.5px;
    }}

    .brand-title {{
      font-size: 16px;
      font-weight: 700;
      display: flex;
      align-items: center;
      gap: 8px;
    }}

    .brand-sub {{
      font-size: 12.5px;
      color: var(--text-muted);
      margin-left: 6px;
    }}

    /* Filter & Search Bar */
    .controls-bar {{
      display: flex;
      align-items: center;
      gap: 12px;
    }}

    .search-box {{
      position: relative;
      display: flex;
      align-items: center;
    }}

    .search-box input {{
      background: rgba(15, 23, 42, 0.8);
      border: 1px solid var(--border-color);
      border-radius: 8px;
      color: var(--text-main);
      padding: 8px 14px 8px 34px;
      font-size: 13px;
      font-family: inherit;
      width: 240px;
      transition: all 0.2s ease;
    }}

    .search-box input:focus {{
      outline: none;
      border-color: var(--accent-blue);
      box-shadow: 0 0 12px rgba(56, 189, 248, 0.25);
      width: 300px;
    }}

    .search-icon {{
      position: absolute;
      left: 10px;
      color: var(--text-dim);
      font-size: 14px;
      pointer-events: none;
    }}

    .domain-filters {{
      display: flex;
      gap: 6px;
      overflow-x: auto;
    }}

    .filter-btn {{
      background: rgba(30, 41, 59, 0.6);
      border: 1px solid var(--border-color);
      color: var(--text-muted);
      padding: 6px 12px;
      border-radius: 6px;
      font-size: 12px;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.2s ease;
      white-space: nowrap;
    }}

    .filter-btn:hover, .filter-btn.active {{
      background: rgba(56, 189, 248, 0.15);
      color: var(--accent-blue);
      border-color: var(--accent-blue);
    }}

    .action-btn {{
      background: linear-gradient(135deg, #0284c7, #2563eb);
      color: white;
      border: none;
      padding: 7px 14px;
      border-radius: 6px;
      font-size: 12.5px;
      font-weight: 600;
      cursor: pointer;
      transition: opacity 0.2s ease;
    }}

    .action-btn:hover {{
      opacity: 0.9;
    }}

    /* Main Workspace Layout */
    .workspace {{
      flex: 1;
      display: flex;
      position: relative;
      overflow: hidden;
    }}

    /* Diagram Canvas Container */
    .canvas-container {{
      flex: 1;
      height: 100%;
      position: relative;
      overflow: hidden;
      cursor: grab;
      user-select: none;
    }}

    .canvas-container:active {{
      cursor: grabbing;
    }}

    .canvas-svg {{
      width: 100%;
      height: 100%;
      transform-origin: 0 0;
      transition: transform 0.05s ease-out;
    }}

    /* Floating Zoom Controls */
    .zoom-hud {{
      position: absolute;
      bottom: 24px;
      left: 24px;
      background: rgba(15, 23, 42, 0.9);
      border: 1px solid var(--border-color);
      backdrop-filter: blur(12px);
      border-radius: 10px;
      padding: 6px;
      display: flex;
      flex-direction: column;
      gap: 6px;
      box-shadow: 0 10px 25px rgba(0, 0, 0, 0.5);
      z-index: 40;
    }}

    .hud-btn {{
      background: rgba(30, 41, 59, 0.8);
      border: 1px solid var(--border-color);
      color: var(--text-main);
      width: 34px;
      height: 34px;
      border-radius: 6px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 16px;
      cursor: pointer;
      transition: all 0.2s ease;
    }}

    .hud-btn:hover {{
      background: var(--accent-blue);
      color: #000;
    }}

    /* Side Drawer / Inspector */
    .inspector-panel {{
      width: 440px;
      background: rgba(11, 18, 33, 0.98);
      border-left: 1px solid var(--border-color);
      backdrop-filter: blur(20px);
      height: 100%;
      display: flex;
      flex-direction: column;
      box-shadow: -10px 0 30px rgba(0, 0, 0, 0.6);
      transition: transform 0.3s cubic-bezier(0.16, 1, 0.3, 1);
      z-index: 45;
      overflow-y: auto;
    }}

    .inspector-panel.collapsed {{
      transform: translateX(100%);
    }}

    .inspector-header {{
      padding: 16px 20px;
      background: rgba(15, 23, 42, 0.85);
      border-bottom: 1px solid var(--border-color);
      display: flex;
      justify-content: space-between;
      align-items: center;
      position: sticky;
      top: 0;
      z-index: 10;
    }}

    .inspector-title {{
      font-size: 16px;
      font-weight: 700;
      font-family: 'JetBrains Mono', monospace;
      color: var(--accent-blue);
    }}

    .close-btn {{
      background: none;
      border: none;
      color: var(--text-muted);
      font-size: 20px;
      cursor: pointer;
    }}

    .close-btn:hover {{
      color: var(--text-main);
    }}

    .inspector-body {{
      padding: 20px;
      display: flex;
      flex-direction: column;
      gap: 18px;
    }}

    .stat-badge-grid {{
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 10px;
    }}

    .stat-badge {{
      background: rgba(30, 41, 59, 0.6);
      border: 1px solid var(--border-color);
      border-radius: 8px;
      padding: 10px 14px;
    }}

    .stat-lbl {{
      font-size: 11px;
      color: var(--text-muted);
      text-transform: uppercase;
      font-weight: 600;
    }}

    .stat-val {{
      font-size: 17px;
      font-weight: 800;
      font-family: 'JetBrains Mono', monospace;
      margin-top: 4px;
    }}

    .section-title {{
      font-size: 13.5px;
      font-weight: 700;
      color: var(--text-main);
      display: flex;
      align-items: center;
      gap: 8px;
      margin-bottom: 8px;
      border-bottom: 1px solid var(--border-color);
      padding-bottom: 6px;
    }}

    .rel-list {{
      display: flex;
      flex-direction: column;
      gap: 8px;
    }}

    .rel-card {{
      background: rgba(30, 41, 59, 0.5);
      border: 1px solid var(--border-color);
      border-radius: 6px;
      padding: 10px 12px;
      font-size: 12.5px;
      display: flex;
      flex-direction: column;
      gap: 4px;
    }}

    .rel-card:hover {{
      border-color: var(--accent-blue);
      background: rgba(56, 189, 248, 0.08);
    }}

    .code-box {{
      background: #040711;
      border: 1px solid rgba(56, 189, 248, 0.25);
      border-radius: 8px;
      padding: 12px;
      font-family: 'JetBrains Mono', monospace;
      font-size: 11.5px;
      color: #7dd3fc;
      overflow-x: auto;
      white-space: pre-wrap;
      word-break: break-all;
    }}

    /* Tab switcher for Inspector vs Full Matrix */
    .tab-nav {{
      display: flex;
      border-bottom: 1px solid var(--border-color);
      background: rgba(15, 23, 42, 0.6);
    }}

    .tab-btn {{
      flex: 1;
      padding: 10px;
      background: none;
      border: none;
      color: var(--text-muted);
      font-size: 12.5px;
      font-weight: 600;
      cursor: pointer;
      border-bottom: 2px solid transparent;
    }}

    .tab-btn.active {{
      color: var(--accent-blue);
      border-color: var(--accent-blue);
      background: rgba(56, 189, 248, 0.08);
    }}

    /* Global Table Node Styling in SVG */
    svg g[id^="table-card-"] {{
      cursor: pointer;
      transition: filter 0.2s ease, transform 0.2s ease;
    }}

    svg g[id^="table-card-"]:hover {{
      filter: drop-shadow(0 0 14px rgba(56, 189, 248, 0.8)) !important;
    }}

    .table-selected rect:first-child {{
      stroke: #38bdf8 !important;
      stroke-width: 3px !important;
    }}
  </style>
</head>
<body>

  <!-- Top Navigation Header -->
  <header>
    <div class="brand-section">
      <span class="brand-badge">TAS ENGINE</span>
      <div class="brand-title">
        TasDashBoardDev — ERD Explorer
        <span class="brand-sub">Visual Relational Graph with Inferred Integrity Keys</span>
      </div>
    </div>

    <!-- Controls & Search -->
    <div class="controls-bar">
      <div class="search-box">
        <span class="search-icon">🔍</span>
        <input type="text" id="searchInput" placeholder="Search 117 tables or columns..." oninput="handleSearch(this.value)">
      </div>

      <div class="domain-filters">
        <button class="filter-btn active" onclick="filterDomain('ALL')">All Tables (117)</button>
        <button class="filter-btn" onclick="filterDomain('COMMERCIAL')">Commercial (25)</button>
        <button class="filter-btn" onclick="filterDomain('OPERATIONS')">Operations (17)</button>
        <button class="filter-btn" onclick="filterDomain('FLEET_STATIONS')">Fleet &amp; Stations (26)</button>
        <button class="filter-btn" onclick="filterDomain('FINANCIAL')">Financial (6)</button>
        <button class="filter-btn" onclick="filterDomain('PLANNING')">Planning (11)</button>
        <button class="filter-btn" onclick="filterDomain('SYSTEM_ADMIN')">System Admin (32)</button>
      </div>

      <button class="action-btn" onclick="resetView()">⟲ Reset Zoom</button>
      <button class="action-btn" onclick="toggleInspector()">📋 Inspector</button>
    </div>
  </header>

  <!-- Main Workspace -->
  <div class="workspace">
    <!-- SVG Canvas -->
    <div class="canvas-container" id="canvasContainer">
      <div id="svgWrapper" style="transform: matrix(0.42, 0, 0, 0.42, 20, 20); transform-origin: 0 0;">
        {svg_content}
      </div>

      <!-- Floating Zoom HUD -->
      <div class="zoom-hud">
        <button class="hud-btn" onclick="zoomIn()" title="Zoom In">+</button>
        <button class="hud-btn" onclick="zoomOut()" title="Zoom Out">−</button>
        <button class="hud-btn" onclick="resetView()" title="Fit to Screen">⤢</button>
      </div>
    </div>

    <!-- Right Side Inspector Panel -->
    <div class="inspector-panel" id="inspectorPanel">
      <div class="inspector-header">
        <div class="inspector-title" id="inspectorTableName">Opr_WorkOrder</div>
        <button class="close-btn" onclick="toggleInspector()">✕</button>
      </div>

      <div class="tab-nav">
        <button class="tab-btn active" id="tabBtnDetails" onclick="switchInspectorTab('details')">Table Overview</button>
        <button class="tab-btn" id="tabBtnRelations" onclick="switchInspectorTab('relations')">Inferred Relations</button>
        <button class="tab-btn" id="tabBtnSql" onclick="switchInspectorTab('sql')">Add FK SQL</button>
      </div>

      <div class="inspector-body" id="inspectorContent">
        <!-- Rendered dynamically -->
      </div>
    </div>
  </div>

  <script>
    // Embedded Database Data
    const DB_DATA = {json.dumps(erd_data)};
    const SPOTLIGHT_TABLES = {json.dumps(list(SPOTLIGHT_LAYOUT.keys()))};

    let selectedTable = "Opr_WorkOrder";
    let currentScale = 0.45;
    let panX = 40;
    let panY = 20;
    let isDragging = false;
    let startX, startY;

    const wrapper = document.getElementById('svgWrapper');
    const container = document.getElementById('canvasContainer');

    function updateTransform() {{
      wrapper.style.transform = `translate(${{panX}}px, ${{panY}}px) scale(${{currentScale}})`;
    }}

    // Pan & Zoom Event Listeners
    container.addEventListener('mousedown', (e) => {{
      if (e.target.closest('g[id^="table-card-"]')) return;
      isDragging = true;
      startX = e.clientX - panX;
      startY = e.clientY - panY;
    }});

    window.addEventListener('mousemove', (e) => {{
      if (!isDragging) return;
      panX = e.clientX - startX;
      panY = e.clientY - startY;
      updateTransform();
    }});

    window.addEventListener('mouseup', () => isDragging = false);

    container.addEventListener('wheel', (e) => {{
      e.preventDefault();
      const zoomFactor = 1.1;
      if (e.deltaY < 0) {{
        currentScale = Math.min(currentScale * zoomFactor, 2.5);
      }} else {{
        currentScale = Math.max(currentScale / zoomFactor, 0.15);
      }}
      updateTransform();
    }}, {{ passive: false }});

    function zoomIn() {{
      currentScale = Math.min(currentScale * 1.25, 2.5);
      updateTransform();
    }}

    function zoomOut() {{
      currentScale = Math.max(currentScale / 1.25, 0.15);
      updateTransform();
    }}

    function resetView() {{
      currentScale = 0.45;
      panX = 40;
      panY = 20;
      updateTransform();
    }}

    function toggleInspector() {{
      document.getElementById('inspectorPanel').classList.toggle('collapsed');
    }}

    // Table click handler in SVG
    document.querySelectorAll('g[id^="table-card-"]').forEach(el => {{
      el.addEventListener('click', (e) => {{
        const tname = el.id.replace('table-card-', '');
        selectTable(tname);
      }});
    }});

    function selectTable(tname) {{
      selectedTable = tname;
      document.querySelectorAll('g[id^="table-card-"]').forEach(el => el.classList.remove('table-selected'));
      const activeEl = document.getElementById(`table-card-${{tname}}`);
      if (activeEl) activeEl.classList.add('table-selected');

      document.getElementById('inspectorPanel').classList.remove('collapsed');
      renderInspector();
    }}

    let currentTab = 'details';
    function switchInspectorTab(tab) {{
      currentTab = tab;
      document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
      if (tab === 'details') document.getElementById('tabBtnDetails').classList.add('active');
      if (tab === 'relations') document.getElementById('tabBtnRelations').classList.add('active');
      if (tab === 'sql') document.getElementById('tabBtnSql').classList.add('active');
      renderInspector();
    }}

    function renderInspector() {{
      const tinfo = DB_DATA.tables[selectedTable];
      if (!tinfo) return;

      document.getElementById('inspectorTableName').textContent = selectedTable;
      const content = document.getElementById('inspectorContent');

      // Find relations
      const outgoing = DB_DATA.relations.filter(r => r.from_table === selectedTable);
      const incoming = DB_DATA.relations.filter(r => r.to_table === selectedTable);

      if (currentTab === 'details') {{
        content.innerHTML = `
          <div class="stat-badge-grid">
            <div class="stat-badge">
              <div class="stat-lbl">Row Count</div>
              <div class="stat-val" style="color: #38bdf8;">${{tinfo.rows.toLocaleString()}}</div>
            </div>
            <div class="stat-badge">
              <div class="stat-lbl">Columns</div>
              <div class="stat-val" style="color: #a855f7;">${{tinfo.columns.length}}</div>
            </div>
            <div class="stat-badge">
              <div class="stat-lbl">Primary Key(s)</div>
              <div class="stat-val" style="color: #fde047; font-size: 13px;">${{tinfo.pks.join(', ') || 'None (Heap)'}}</div>
            </div>
            <div class="stat-badge">
              <div class="stat-lbl">Inferred Links</div>
              <div class="stat-val" style="color: #34d399;">${{outgoing.length + incoming.length}}</div>
            </div>
          </div>

          <div>
            <div class="section-title">🔑 Table Columns (${{tinfo.columns.length}})</div>
            <div style="max-height: 380px; overflow-y: auto; background: rgba(15, 23, 42, 0.6); border: 1px solid var(--border-color); border-radius: 8px; padding: 10px;">
              ${{tinfo.columns.map(c => `
                <div style="display: flex; justify-content: space-between; padding: 5px 0; border-bottom: 1px solid rgba(148, 163, 184, 0.08); font-size: 12px; font-family: 'JetBrains Mono', monospace;">
                  <span style="color: ${{c.pk ? '#fde047' : '#f8fafc'}};">
                    ${{c.pk ? '🔑 ' : '• '}}${{c.name}}
                  </span>
                  <span style="color: #94a3b8;">${{c.type}}</span>
                </div>
              `).join('')}}
            </div>
          </div>
        `;
      }} else if (currentTab === 'relations') {{
        content.innerHTML = `
          <div>
            <div class="section-title">📤 Outgoing Inferred Foreign Keys (${{outgoing.length}})</div>
            <div class="rel-list">
              ${{outgoing.length ? outgoing.map(r => `
                <div class="rel-card">
                  <div style="display: flex; justify-content: space-between; font-weight: 700; color: #38bdf8;">
                    <span>🔗 ${{r.from_col}}</span>
                    <span style="color: #cbd5e1;">➔ ${{r.to_table}}</span>
                  </div>
                  <div style="color: #94a3b8; font-size: 11.5px;">References: <code>${{r.to_table}}.${{r.to_col}}</code> (${{r.cardinality}})</div>
                </div>
              `).join('') : '<div style="color: #64748b; font-size: 12px;">No outgoing references</div>'}}
            </div>
          </div>

          <div>
            <div class="section-title">📥 Incoming Inferred References (${{incoming.length}})</div>
            <div class="rel-list" style="max-height: 280px; overflow-y: auto;">
              ${{incoming.length ? incoming.map(r => `
                <div class="rel-card">
                  <div style="display: flex; justify-content: space-between; font-weight: 700; color: #34d399;">
                    <span>⬅ ${{r.from_table}}</span>
                    <span style="color: #cbd5e1;">(FK: ${{r.from_col}})</span>
                  </div>
                  <div style="color: #94a3b8; font-size: 11.5px;">Target Key: <code>${{r.to_col}}</code></div>
                </div>
              `).join('') : '<div style="color: #64748b; font-size: 12px;">No incoming references</div>'}}
            </div>
          </div>
        `;
      }} else if (currentTab === 'sql') {{
        const sqlStatements = outgoing.map(r => 
          `-- Enforce integrity between ${{r.from_table}} and ${{r.to_table}}\n` +
          `ALTER TABLE dbo.${{r.from_table}}\n` +
          `  ADD CONSTRAINT FK_${{r.from_table}}_${{r.to_table}}_${{r.from_col.replace(/[^a-zA-Z0-9]/g, '')}}\n` +
          `  FOREIGN KEY (${{r.from_col}})\n` +
          `  REFERENCES dbo.${{r.to_table}} (${{r.to_col}});\n`
        ).join('\n');

        content.innerHTML = `
          <div>
            <div class="section-title">💻 Recommended SQL DDL Script</div>
            <p style="font-size: 12px; color: #94a3b8; margin-bottom: 10px;">
              Copy and execute these statements on <code>TasDashBoardDev</code> to convert the inferred logical foreign keys into database-enforced integrity constraints.
            </p>
            <div class="code-box">${{sqlStatements || '-- No outgoing foreign keys to declare for this table.'}}</div>
          </div>
        `;
      }}
    }}

    function handleSearch(term) {{
      const q = term.toLowerCase().trim();
      document.querySelectorAll('g[id^="table-card-"]').forEach(el => {{
        const tname = el.id.replace('table-card-', '').toLowerCase();
        if (!q || tname.includes(q)) {{
          el.style.opacity = '1';
        }} else {{
          el.style.opacity = '0.15';
        }}
      }});
    }}

    function filterDomain(dom) {{
      document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
      event.target.classList.add('active');

      document.querySelectorAll('g[id^="table-card-"]').forEach(el => {{
        const tname = el.id.replace('table-card-', '');
        if (dom === 'ALL') {{
          el.style.opacity = '1';
        }} else {{
          // check table prefix/domain
          let tdom = "SYSTEM_ADMIN";
          if (tname.startsWith("AR_") || tname.startsWith("AP_")) tdom = "FINANCIAL";
          else if (tname.startsWith("Com_") || tname.startsWith("COM_") || tname.startsWith("com_")) tdom = "COMMERCIAL";
          else if (tname.startsWith("Opr_Plan") || tname.startsWith("Opr_Schedule")) tdom = "PLANNING";
          else if (tname.startsWith("Opr_WorkOrder") || ["Opr_Hotel", "Opr_Transportion", "Opr_Shipment", "Opr_Fuel"].includes(tname)) tdom = "OPERATIONS";
          else if (tname.startsWith("Opr_") || tname.startsWith("AGSH_")) tdom = "FLEET_STATIONS";

          el.style.opacity = (tdom === dom) ? '1' : '0.12';
        }}
      }});
    }}

    // Initialize inspector
    selectTable("Opr_WorkOrder");
    updateTransform();
  </script>
</body>
</html>
'''

html_path = "documentation/tasdashboarddev_erd_explorer.html"
with open(html_path, "w", encoding="utf-8") as f:
    f.write(html_content)

print(f"Generated standalone interactive ERD Explorer web application: {html_path} ({len(html_content)} bytes)")

# Convert SVG to PNG via Headless Google Chrome
png_path = "documentation/images/tasdashboarddev_erd_diagram.png"
print(f"Rasterizing SVG to high-res PNG via Headless Google Chrome...")
chrome_path = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
cmd = [
    chrome_path,
    "--headless",
    "--disable-gpu",
    f"--window-size={CANVAS_W},{CANVAS_H}",
    f"--screenshot={png_path}",
    f"file://{os.path.abspath(svg_path)}"
]
res = subprocess.run(cmd, capture_output=True, text=True)
if os.path.exists(png_path) and os.path.getsize(png_path) > 0:
    print(f"✅ Successfully created high-res PNG preview: {png_path} ({os.path.getsize(png_path):,} bytes)")
else:
    print(f"Chrome screenshot error: {res.stderr}")

print("\nAll ERD generation tasks completed successfully!")
