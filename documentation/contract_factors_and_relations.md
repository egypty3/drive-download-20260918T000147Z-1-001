# دليل محددات إنشاء العقود وشبكة العلاقات البينية في منظومة المناولة الأرضية
## Ground Handling Contract Factors, Parameters & Relational Architecture Guide (TAS Engine)

---

## 📌 1. مقدمة عامة ورؤية معمارية (Executive Overview)

في صناعة المناولة الأرضية للطيران الدولي (**Aviation Ground Handling & Turnaround Services**)، لا يُعد العقد مجرد وثيقة قانونية أو نص أرشيفي؛ بل هو **محرك حسابي وتشغيلي متعدد الأبعاد (Multi-Dimensional Active Calculation Engine)**. 

عند تأسيس عقد جديد (**New Contract Master Setup**)، تتشابك مجموعة مترابطة من المحددات التشغيلية، والفيزيائية (كأوزان الطائرات)، والجغرافية (المحطات والمطارات)، والتجارية (شروط الائتمان وهوامش الربح). يُحدد هذا العقد بدقة:
1. **الغطاء التعاقدي:** من هي شركات الطيران المشمولة، وأي محطات مسموح لها بالهبوط فيها.
2. **حدود التشغيل في المهبط:** ما هي المعدات وساعات الطاقة (GPU) المسموحة مجاناً لكل طراز طائرة.
3. **محرك الفوترة الآلية:** كيفية احتساب التكلفة الفعلية استناداً إلى وزن الطائرة (MTOW)، والتوقيت (ليلي/نهاري)، والخدمات الإضافية، وحماية هوامش الربح مع مقاولي الباطن.

---

## 🗺️ 2. المخطط البصري العام: شبكة محددات العقد والعلاقات البينية

يوضح المخطط التالي الأبعاد الستة الرئيسية الحاكمة لإنشاء أي عقد أرضي، وكيف تلتقي جميعها في جدول العقد الرئيسي (`Com_Contracts`)، لتتحول في النهاية إلى **أمر تشغيل في المهبط (`Opr_WorkOrder`)** و**فاتورة معتمدة ومحمية من الهامش السالب**:

<div align="center" style="margin: 24px 0;">
  <a href="./images/contract_factors_relationship_matrix.svg" target="_blank">
    <img src="./images/contract_factors_relationship_matrix.png" alt="شبكة محددات العقد والعلاقات البينية" style="max-width: 100%; border-radius: 14px; border: 1px solid rgba(56, 189, 248, 0.35); box-shadow: 0 12px 36px rgba(0,0,0,0.5);" />
  </a>
  <p style="font-size: 12px; color: #94a3b8; margin-top: 8px;">💡 يمكنك النقر على المخطط أعلاه لفتحه بصيغة الفيكتور فائقة الدقة (SVG).</p>
</div>

---

## 🧩 3. الفهرس التفصيلي لمحددات العقد (Core Contract Factors)

عند النقر على زر **"إنشاء عقد جديد" (Create New Contract)** داخل نظام TAS، يتطلب النظام ضبط وتغذية 7 مجموعات محددات جوهرية:

<div style="display: flex; flex-direction: column; gap: 18px; margin: 24px 0;">

  <!-- FACTOR 1: CARRIER & CUSTOMER -->
  <div style="background: rgba(30, 41, 59, 0.5); border: 1px solid rgba(129, 140, 248, 0.35); border-radius: 12px; padding: 20px; box-shadow: 0 4px 16px rgba(0,0,0,0.3);">
    <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid rgba(129, 140, 248, 0.25); padding-bottom: 12px; margin-bottom: 14px;">
      <div style="display: flex; align-items: center; gap: 10px;">
        <span style="font-size: 24px;">🏢</span>
        <h3 style="margin: 0; color: #a5b4fc; font-size: 18px;">1. محددات الناقل والعميل المالي (Carrier &amp; Billing Entity Factors)</h3>
      </div>
      <span style="background: rgba(99, 102, 241, 0.2); color: #c7d2fe; border: 1px solid #6366f1; padding: 4px 10px; border-radius: 6px; font-size: 11px; font-weight: 700;">COMMERCIAL &amp; CREDIT</span>
    </div>
    <div style="color: #cbd5e1; font-size: 13.5px; line-height: 1.7;">
      <p>يُميز النظام بدقة بين <strong>الجهة التي تدفع الفاتورة (Customer / Debtor)</strong> وبين <strong>شركة الطيران المشغلة للرحلة (Operating Carrier)</strong>:</p>
      <ul style="margin: 10px 24px;">
        <li><strong style="color: #f8fafc;">العميل المالي المحاسبي (<code>CustomerID / AR_Customers</code>):</strong> قد يكون شركة الطيران نفسها، أو وسيط رحلات عارضة (Charter Broker)، أو منظم رحلات سياحية (Tour Operator مثل TUI)، أو وكيل خدمات ملاحة وإشراف (Trip Support Agency مثل Jetex أو Hadid).</li>
        <li><strong style="color: #f8fafc;">رمز الناقل الجوي (<code>AirlineID / Opr_Airlines</code>):</strong> الرموز المعتمدة لمنظمة الطيران المدني الدولي والاتحاد الدولي للنقل الجوي (IATA/ICAO Codes مثل <code>MS / MSR</code> لمصر للطيران، <code>FZ / FDB</code> لفلاي دبي، <code>TK / THY</code> للتركية). يمكن للعقد الواحد تغطية عدة خطوط طيران شقيقة تتبع نفس المجموعة القابضة.</li>
        <li><strong style="color: #f8fafc;">شروط الائتمان والسداد (<code>PaymentTermsID</code>):</strong>
          <span style="display: inline-block; background: rgba(16, 185, 129, 0.15); color: #34d399; padding: 1px 6px; border-radius: 4px; font-size: 11px; margin: 0 4px;">Net-14 / Net-30 Days</span> للرحلات المجدولة الموثوقة، أو 
          <span style="display: inline-block; background: rgba(244, 63, 94, 0.15); color: #fb7185; padding: 1px 6px; border-radius: 4px; font-size: 11px; margin: 0 4px;">Pre-flight Cash / Proforma Wire Transfer</span> بنسبة 100% للرحلات العارضة غير المنتظمة.</li>
        <li><strong style="color: #f8fafc;">عملة العقد والفوترة (<code>BillingCurrency</code>):</strong> العملة التعاقدية الملزمة (USD، EUR، أو EGP محلياً)، مع قاعدة ربط سعر الصرف الرسمي للبنك المركزي بتاريخ تنفيذ الرحلة.</li>
        <li><strong style="color: #f8fafc;">سقف الائتمان والضمان البنكي (Credit Limit &amp; Bank Guarantee):</strong> الحد المالي الأقصى المسموح به للمديونية قبل إيقاف إصدار أوامر التشغيل تلقائياً.</li>
      </ul>
    </div>
  </div>

  <!-- FACTOR 2: AIRPORT & STATIONS -->
  <div style="background: rgba(30, 41, 59, 0.5); border: 1px solid rgba(52, 211, 153, 0.35); border-radius: 12px; padding: 20px; box-shadow: 0 4px 16px rgba(0,0,0,0.3);">
    <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid rgba(52, 211, 153, 0.25); padding-bottom: 12px; margin-bottom: 14px;">
      <div style="display: flex; align-items: center; gap: 10px;">
        <span style="font-size: 24px;">📍</span>
        <h3 style="margin: 0; color: #6ee7b7; font-size: 18px;">2. محددات النطاق الجغرافي والمحطات (Airport &amp; Station Scope Factors)</h3>
      </div>
      <span style="background: rgba(16, 185, 129, 0.2); color: #a7f3d0; border: 1px solid #10b981; padding: 4px 10px; border-radius: 6px; font-size: 11px; font-weight: 700;">STATIONS &amp; APPRON</span>
    </div>
    <div style="color: #cbd5e1; font-size: 13.5px; line-height: 1.7;">
      <p>يحدد العقد المحطات الجوية المرخص بتقديم خدمات المناولة فيها:</p>
      <ul style="margin: 10px 24px;">
        <li><strong style="color: #f8fafc;">المطارات المعتمدة (<code>AirportID / Opr_Airports</code>):</strong> كود المطار الدولي (مثل: <code>CAI</code> مطار القاهرة، <code>HRG</code> الغردقة، <code>SSH</code> شرم الشيخ، <code>LXR</code> الأقصر، <code>HBE</code> برج العرب).</li>
        <li><strong style="color: #f8fafc;">نوع الاتفاقية الجغرافية:</strong> إما اتفاقية محطة واحدة (Single-Station Handling Agreement) أو اتفاقية شبكة مطارات موحدة (Multi-Station National Network Agreement).</li>
        <li><strong style="color: #f8fafc;">طبيعة مواقف الطائرات بالمحطة (Stand Infrastructure):</strong>
          <ul>
            <li><strong>مواقف متصلة بالمبنى (Contact Stands / Jet Bridges):</strong> تقتضي احتساب رسوم استهلاك خرطوم الركاب، وتلغي الحاجة لحافلات المهبط.</li>
            <li><strong>مواقف نائية (Remote Apron Stands):</strong> تقتضي إلزامياً توفير سلالم متحركة (Mobile Passenger Stairs) وحافلات نقل ركاب المهبط (Cobus).</li>
          </ul>
        </li>
        <li><strong style="color: #f8fafc;">رسوم وامتيازات سلطة الطيران المدني (CAA Concession &amp; Royalties):</strong> الرسوم السيادية ونسب الإتاوة التي تختلف من مطار لآخر (مثال: رسوم مطار القاهرة الدولي تختلف عن رسوم مطارات الجذب السياحي الإقليمية).</li>
      </ul>
    </div>
  </div>

  <!-- FACTOR 3: FLEET & AIRCRAFT TYPE -->
  <div style="background: rgba(30, 41, 59, 0.5); border: 1px solid rgba(56, 189, 248, 0.35); border-radius: 12px; padding: 20px; box-shadow: 0 4px 16px rgba(0,0,0,0.3);">
    <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid rgba(56, 189, 248, 0.25); padding-bottom: 12px; margin-bottom: 14px;">
      <div style="display: flex; align-items: center; gap: 10px;">
        <span style="font-size: 24px;">🛫</span>
        <h3 style="margin: 0; color: #7dd3fc; font-size: 18px;">3. محددات الأسطول وطراز الطائرات (Aircraft Fleet &amp; Weight Factors)</h3>
      </div>
      <span style="background: rgba(14, 165, 233, 0.2); color: #bae6fd; border: 1px solid #0284c7; padding: 4px 10px; border-radius: 6px; font-size: 11px; font-weight: 700;">MTOW &amp; BODY CLASS</span>
    </div>
    <div style="color: #cbd5e1; font-size: 13.5px; line-height: 1.7;">
      <p>يُمثل وزن الطائرة وهيكلها الأساس الفيزيائي الأول لتسعير المناولة حول العالم وفق معايير IATA AHM:</p>
      <ul style="margin: 10px 24px;">
        <li><strong style="color: #f8fafc;">طراز الطائرة (<code>ModelCode / Opr_AircraftModels</code>):</strong> كود الطراز العالمي (مثل: A320, A321, B737-800, B777-300ER, A330-300, B787-9).</li>
        <li><strong style="color: #f8fafc;">وزن الإقلاع الأقصى (MTOW - Maximum Take-Off Weight):</strong> المقياس القياسي لتحديد شريحة السعر الأساسي للمناولة (Handling Tonnage Bracket). تقسم الشرائح عادة إلى:
          <span style="color: #38bdf8; font-weight: 600;">[0-25t], [26-50t], [51-80t], [81-120t], [121-160t], [&gt;160t]</span>.</li>
        <li><strong style="color: #f8fafc;">تصنيف البدن (<code>BodyType</code>):</strong>
          <ul>
            <li><strong>بدن ضيق (Narrow-body / Code C):</strong> ممر واحد (مثل A320 / B737) - يحتاج وحدة طاقة أرضية (GPU 90 kVA)، وسلم ركاب واحد أو اثنين، ومعدل دوران قياسي 45 إلى 60 دقيقة.</li>
            <li><strong>بدن عريض (Wide-body / Code D/E/F):</strong> ممران (مثل B777 / A350) - يحتاج وحدة طاقة أرضية ثقيلة (GPU 140+ kVA)، رافعة منصات شحن سفلية (Main Deck Loader)، ومعدل دوران قياسي 90 إلى 120 دقيقة.</li>
          </ul>
        </li>
        <li><strong style="color: #f8fafc;">سعة المقاعد والركاب (Seat Capacity - Y/C/F):</strong> الحد الأقصى للمقاعد في الدرجة السياحية ورجال الأعمال والأولى (يستخدم عند احتساب رسوم الركاب Per-Passenger Head Charge).</li>
        <li><strong style="color: #f8fafc;">تسجيلات ذيل الطائرة (<code>Tail Number / Opr_AircraftRegistrations</code>):</strong> الحروف المعرفة للطائرة الفعلية المسجلة لدى الناقل (مثل: <code>SU-GCT</code> لمصر للطيران) لضمان الربط المباشر مع حركة الرادار وسجلات برج المراقبة.</li>
      </ul>
    </div>
  </div>

  <!-- FACTOR 4: FLIGHT OPERATION TYPE -->
  <div style="background: rgba(30, 41, 59, 0.5); border: 1px solid rgba(217, 70, 239, 0.35); border-radius: 12px; padding: 20px; box-shadow: 0 4px 16px rgba(0,0,0,0.3);">
    <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid rgba(217, 70, 239, 0.25); padding-bottom: 12px; margin-bottom: 14px;">
      <div style="display: flex; align-items: center; gap: 10px;">
        <span style="font-size: 24px;">🔄</span>
        <h3 style="margin: 0; color: #f0abfc; font-size: 18px;">4. محددات تصنيف الرحلة والغرض التشغيلي (Flight Mission &amp; Type Factors)</h3>
      </div>
      <span style="background: rgba(192, 38, 211, 0.2); color: #f5d0fe; border: 1px solid #c026d3; padding: 4px 10px; border-radius: 6px; font-size: 11px; font-weight: 700;">FLIGHT CATEGORY</span>
    </div>
    <div style="color: #cbd5e1; font-size: 13.5px; line-height: 1.7;">
      <p>تختلف باقة الخدمات المطلوبة وشروط السداد وفقاً للغرض من تسيير الرحلة:</p>
      <ul style="margin: 10px 24px;">
        <li><strong style="color: #f8fafc;">رحلات تجارية مجدولة (Scheduled Flights):</strong> رحلات يومية أو أسبوعية منتظمة بجدول معلن. يطبق عليها خصومات الحجم، وشروط الائتمان القياسية (Net-30)، وباقات المناولة الشاملة الكاملة.</li>
        <li><strong style="color: #f8fafc;">رحلات عارضة / سياحية (Charter Flights):</strong> رحلات موسمية أو عارضة غير منتظمة. تتطلب سداد الفاتورة المبدئية (Proforma) بنسبة 100% قبل صدور تصريح الهبوط وفتح أمر العمل.</li>
        <li><strong style="color: #f8fafc;">رحلات شحن بضائع (Cargo / Freighter Flights):</strong> طائرات شحن بدون ركاب. تستبعد خدمات الركاب والسلالم والمقصورة، وتلزم بإضافة رافعات المنصات (Main Deck Loaders) وعربات حاويات الشحن (ULD Dollies) واحتساب السعر بالطن المشحون.</li>
        <li><strong style="color: #f8fafc;">هبوط فني للتزود بالوقود (Technical Stop / Ferry Flight):</strong> هبوط سريع لا يشمل ركاباً أو تفريغ حقائب. يقتصر على الإرشاد، وتأمين الوقود، والأوتاد، بزمن مكوث قصير وسعر مخفض ومحدد سلفاً.</li>
        <li><strong style="color: #f8fafc;">طيران خاص ورجال أعمال (VIP / Business Aviation):</strong> متطلبات خدمة استثنائية تشمل صالات كبار الزوار، النقل بسيارات الليموزين بالمهبط، وحراسة خاصة.</li>
      </ul>
    </div>
  </div>

  <!-- FACTOR 5: SERVICES CATALOG & GSE -->
  <div style="background: rgba(30, 41, 59, 0.5); border: 1px solid rgba(245, 158, 11, 0.35); border-radius: 12px; padding: 20px; box-shadow: 0 4px 16px rgba(0,0,0,0.3);">
    <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid rgba(245, 158, 11, 0.25); padding-bottom: 12px; margin-bottom: 14px;">
      <div style="display: flex; align-items: center; gap: 10px;">
        <span style="font-size: 24px;">🧰</span>
        <h3 style="margin: 0; color: #fcd34d; font-size: 18px;">5. محددات فهرس الخدمات ومعدات المهبط (Services Catalog &amp; GSE Scope)</h3>
      </div>
      <span style="background: rgba(217, 119, 6, 0.2); color: #fef08a; border: 1px solid #d97706; padding: 4px 10px; border-radius: 6px; font-size: 11px; font-weight: 700;">IATA SGHA AHM 810</span>
    </div>
    <div style="color: #cbd5e1; font-size: 13.5px; line-height: 1.7;">
      <p>هيكلة بنود الاتفاقية وفق الفصول الدولية للاتحاد الدولي للنقل الجوي (IATA Standard Ground Handling Agreement):</p>
      <ul style="margin: 10px 24px;">
        <li><strong style="color: #f8fafc;">خدمات ساحة الطيران (Ramp Operations - Section 3):</strong> وضع وسحب الأوتاد (Chocks On/Off)، الإرشاد (Marshalling)، القاطرة والدفع للخلف (Pushback Tractor)، تحميل وتفريغ الحقائب.</li>
        <li><strong style="color: #f8fafc;">معدات الدعم الأرضي ووحدات الطاقة (GSE Units):</strong>
          <span style="color: #fbbf24; font-weight: 600;">GPU (Ground Power Unit)</span> بنظام النصف ساعة أو الساعة، 
          <span style="color: #fbbf24; font-weight: 600;">ASU (Air Start Unit)</span> لبدء تشغيل المحركات، 
          <span style="color: #fbbf24; font-weight: 600;">ACU (Air Conditioning Unit)</span> لتبريد المقصورة.</li>
        <li><strong style="color: #f8fafc;">مرافق مقصورة الطائرة (Cabin Services):</strong> تزويد مياه الشرب العذبة النقية (Potable Water)، تفريغ ومعالجة الصرف الصحي (Lavatory Waste)، والنظافة السريعة (Transit Cleaning).</li>
        <li><strong style="color: #f8fafc;">خدمات الركاب (Passenger Services - Section 2):</strong> مكاتب وزن الأمتعة وقبول الركاب (Check-in Desks)، بوابات الصعود، مكاتب الحقائب الضائعة (Lost &amp; Found / WorldTracer).</li>
        <li><strong style="color: #f8fafc;">خدمات مقاولي الباطن والوقود (Third-Party / Disbursed Services):</strong> تنسيق شاحنات الوقود وسيارات الإطفاء المرافقة، التموين (Catering)، وتخضع لنسبة عمولة إدارة (Disbursement Handling Fee 5% إلى 10%).</li>
      </ul>
    </div>
  </div>

  <!-- FACTOR 6: TIME TOLERANCES & OVERTIME -->
  <div style="background: rgba(30, 41, 59, 0.5); border: 1px solid rgba(148, 163, 184, 0.35); border-radius: 12px; padding: 20px; box-shadow: 0 4px 16px rgba(0,0,0,0.3);">
    <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid rgba(148, 163, 184, 0.25); padding-bottom: 12px; margin-bottom: 14px;">
      <div style="display: flex; align-items: center; gap: 10px;">
        <span style="font-size: 24px;">⏱️</span>
        <h3 style="margin: 0; color: #e2e8f0; font-size: 18px;">6. محددات زمن المكوث والسماحية (Turnaround Ground Time &amp; Tolerances)</h3>
      </div>
      <span style="background: rgba(71, 85, 105, 0.3); color: #f1f5f9; border: 1px solid #64748b; padding: 4px 10px; border-radius: 6px; font-size: 11px; font-weight: 700;">TIME WINDOWS</span>
    </div>
    <div style="color: #cbd5e1; font-size: 13.5px; line-height: 1.7;">
      <p>الزمن هو المحدد المالي الحاسم؛ فبقاؤ الطائرة على أرض المهبط يُكلف موارد بشرية ومعدات حيوية:</p>
      <ul style="margin: 10px 24px;">
        <li><strong style="color: #f8fafc;">وقت المكوث القياسي المشمول مجاناً (<code>GroundRange / TimeInclude</code>):</strong>
          زمن دوران الطائرة المشمول ضمن السعر الأساسي (مثال: أول ساعتين مجاناً للطائرات ضيقة البدن، و3 ساعات للطائرات عريضة البدن).</li>
        <li><strong style="color: #f8fafc;">شرائح احتساب الوقت الإضافي (Overtime Parking Gradients):</strong>
          في حال تأخر إقلاع الطائرة عن وقت السماح، يبدأ النظام في احتساب غرامات إشغال المهبط تلقائياً مجزأة لكل نصف ساعة إضافية.</li>
        <li><strong style="color: #f8fafc;">ساعات الطاقة المشمولة مجاناً (Included GPU Hours):</strong>
          تحديد عدد ساعات عمل وحدة الكهرباء المشمولة مع الباقة (مثلاً: أول ساعة مجاناً؛ وما زاد عنها يُفوتر تلقائياً بسعر الساعة المقررة في العقد).</li>
      </ul>
    </div>
  </div>

  <!-- FACTOR 7: PRICING LOGIC, SURCHARGES & VOLUME -->
  <div style="background: rgba(30, 41, 59, 0.5); border: 1px solid rgba(244, 63, 94, 0.35); border-radius: 12px; padding: 20px; box-shadow: 0 4px 16px rgba(0,0,0,0.3);">
    <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid rgba(244, 63, 94, 0.25); padding-bottom: 12px; margin-bottom: 14px;">
      <div style="display: flex; align-items: center; gap: 10px;">
        <span style="font-size: 24px;">💰</span>
        <h3 style="margin: 0; color: #fda4af; font-size: 18px;">7. محددات التسعير والبدلات وحوافز الحجم (Pricing Mechanics &amp; Margin Rules)</h3>
      </div>
      <span style="background: rgba(225, 29, 72, 0.2); color: #fecdd3; border: 1px solid #e11d48; padding: 4px 10px; border-radius: 6px; font-size: 11px; font-weight: 700;">MARGIN &amp; REBATE</span>
    </div>
    <div style="color: #cbd5e1; font-size: 13.5px; line-height: 1.7;">
      <p>القواعد المالية الصارمة التي تضمن ربحية المناول وتمنع التسرب:</p>
      <ul style="margin: 10px 24px;">
        <li><strong style="color: #f8fafc;">ضمان الحد الأدنى للإيراد (<code>MinimumPrice Guarantee</code>):</strong> سقف أدنى مالي لا يمكن فوترة الرحلة بأقل منه تحت أي ظرف (حتى لو كانت الطائرة فارغة أو بحمولة منخفضة) لتغطية تكاليف الطاقم والمعدات.</li>
        <li><strong style="color: #f8fafc;">البدلات الإضافية للتشغيل الاستثنائي (<code>SureCharge</code>):</strong>
          نسب مئوية إضافية تضاف على السعر الأساسي للرحلة:
          <span style="color: #fda4af; font-weight: 600;">بدل عمل ليلي (Night Surcharge +20% بين 22:00 و 06:00)</span>، 
          <span style="color: #fda4af; font-weight: 600;">بدل عطلات وأعياد رسمية (+25%)</span>، 
          وبدل طلب خدمة طارئة في أقل من 24 ساعة (+30%).</li>
        <li><strong style="color: #f8fafc;">حائط صد الهامش السالب مع الموردين (Margin Shield):</strong>
          قاعدة برمجية ملزمة تمنع فوترة أي خدمة منفذة عبر مقاول خارجي (وقود/تموين) بسعر يقل عن فاتورة المقاول الفعلية، وتضيف آلياً عمولة المناول (مثلاً: <code>تكلفة الوقود + 5% Disbursement Fee</code>).</li>
        <li><strong style="color: #f8fafc;">شرائح خصم الحجم التراكمي (Volume Rebates):</strong>
          مكافأة الناقل عند تجاوزه عتبة عدد رحلات شهرياً (مثال: &gt; 25 رحلة شهرياً = خصم 5%؛ &gt; 50 رحلة شهرياً = خصم 10% يُمنح في نهاية الشهر كإشعار دائن Credit Note).</li>
      </ul>
    </div>
  </div>

</div>

---

## 🔗 4. مصفوفة العلاقات والتشابك البيني بين المحددات (Interdependence Matrix)

الجدول التالي يشرح **العلاقة الدقيقة (The Exact Relationship)** بين كل محددين، وكيف تؤثر التغييرات في محدد معين على باقي محددات النظام:

<div style="background: #0f172a; border: 1px solid rgba(56, 189, 248, 0.35); border-radius: 14px; overflow: hidden; margin: 24px 0; box-shadow: 0 10px 30px rgba(0,0,0,0.5);">
  <div style="background: linear-gradient(135deg, rgba(30, 58, 138, 0.6), rgba(15, 23, 42, 0.9)); padding: 14px 20px; border-bottom: 1px solid rgba(56, 189, 248, 0.25); display: flex; align-items: center; justify-content: space-between;">
    <span style="font-weight: 700; color: #f8fafc; font-size: 15px;">📊 مصفوفة التأثير المتبادل والقواعد التشغيلية والمالية (Cross-Factor Interdependence Matrix)</span>
    <span style="font-size: 12px; color: #38bdf8; font-weight: 600;">تكامل فيزيائي وتشغيلي ومالي</span>
  </div>
  <div style="overflow-x: auto;">
    <table style="width: 100%; border-collapse: collapse; text-align: right; font-size: 13px;">
      <thead>
        <tr style="border-bottom: 1px solid rgba(148, 163, 184, 0.2); background: rgba(30, 41, 59, 0.6); color: #38bdf8;">
          <th style="padding: 12px 16px; font-weight: 700;">المحدد الأول (Factor A)</th>
          <th style="padding: 12px 16px; font-weight: 700;">المحدد الثاني (Factor B)</th>
          <th style="padding: 12px 16px; font-weight: 700;">نوع العلاقة والترابط</th>
          <th style="padding: 12px 16px; font-weight: 700;">الأثر التشغيلي والمالي (Operational &amp; Financial Impact)</th>
          <th style="padding: 12px 16px; font-weight: 700;">القاعدة الحاكمة في النظام (TAS Business Rule)</th>
        </tr>
      </thead>
      <tbody>
        <!-- Row 1 -->
        <tr style="border-bottom: 1px solid rgba(148, 163, 184, 0.08); background: rgba(30, 41, 59, 0.25);">
          <td style="padding: 12px 16px; font-weight: 700; color: #f8fafc;">طراز الطائرة (MTOW)</td>
          <td style="padding: 12px 16px; color: #38bdf8; font-weight: 600;">السعر الأساسي للمناولة (Base Rate)</td>
          <td style="padding: 12px 16px;"><span style="background: rgba(56, 189, 248, 0.15); color: #38bdf8; padding: 2px 8px; border-radius: 4px; font-size: 11px;">تناسب طردي حسب الوزن</span></td>
          <td style="padding: 12px 16px; color: #cbd5e1;">كلما زاد وزن الطائرة (طن)، زادت شريحة المناولة ومقدار استهلاك معدات السحب والأوتاد.</td>
          <td style="padding: 12px 16px; color: #34d399; font-family: monospace; font-size: 12px;">BaseRate = MTOW_Band_Rate(Model.MTOW)</td>
        </tr>
        <!-- Row 2 -->
        <tr style="border-bottom: 1px solid rgba(148, 163, 184, 0.08); background: rgba(30, 41, 59, 0.15);">
          <td style="padding: 12px 16px; font-weight: 700; color: #f8fafc;">طراز الطائرة (Body Type)</td>
          <td style="padding: 12px 16px; color: #38bdf8; font-weight: 600;">سماحية زمن المكوث (Ground Tolerance)</td>
          <td style="padding: 12px 16px;"><span style="background: rgba(16, 185, 129, 0.15); color: #34d399; padding: 2px 8px; border-radius: 4px; font-size: 11px;">محدد فيزيائي للبنية</span></td>
          <td style="padding: 12px 16px; color: #cbd5e1;">البدن الضيق يمنح 60 دقيقة مجاناً، بينما العريض يمنح 90-120 دقيقة لكثافة الركاب وسعة العفش.</td>
          <td style="padding: 12px 16px; color: #34d399; font-family: monospace; font-size: 12px;">FreeTime = IF(BodyType='W', 120m, 60m)</td>
        </tr>
        <!-- Row 3 -->
        <tr style="border-bottom: 1px solid rgba(148, 163, 184, 0.08); background: rgba(30, 41, 59, 0.25);">
          <td style="padding: 12px 16px; font-weight: 700; color: #f8fafc;">طراز الطائرة (Body Type)</td>
          <td style="padding: 12px 16px; color: #38bdf8; font-weight: 600;">قدرة ونوع المعدات الأرضية (GSE Specification)</td>
          <td style="padding: 12px 16px;"><span style="background: rgba(245, 158, 11, 0.15); color: #fbbf24; padding: 2px 8px; border-radius: 4px; font-size: 11px;">اشتراط هندسي إلزامي</span></td>
          <td style="padding: 12px 16px; color: #cbd5e1;">البدن العريض يلزم بتعيين GPU 140 kVA بدلاً من 90 kVA، وقاطرة سحب ثقيلة (Heavy Pushback).</td>
          <td style="padding: 12px 16px; color: #34d399; font-family: monospace; font-size: 12px;">ValidateGSE(Model.BodyType, AssignedGSE)</td>
        </tr>
        <!-- Row 4 -->
        <tr style="border-bottom: 1px solid rgba(148, 163, 184, 0.08); background: rgba(30, 41, 59, 0.15);">
          <td style="padding: 12px 16px; font-weight: 700; color: #f8fafc;">المطار (Airport / Station)</td>
          <td style="padding: 12px 16px; color: #38bdf8; font-weight: 600;">طبيعة الخدمات الإلزامية (Mandatory Services)</td>
          <td style="padding: 12px 16px;"><span style="background: rgba(14, 165, 233, 0.15); color: #38bdf8; padding: 2px 8px; border-radius: 4px; font-size: 11px;">محدد بنية تحتية للموقف</span></td>
          <td style="padding: 12px 16px; color: #cbd5e1;">المواقف النائية بمطارات HRG/SSH تلزم بتشغيل حافلات وسلالم، بينما مواقف الكباري تلغيها.</td>
          <td style="padding: 12px 16px; color: #34d399; font-family: monospace; font-size: 12px;">Mutex(JetBridge, PassengerStairs + Bus)</td>
        </tr>
        <!-- Row 5 -->
        <tr style="border-bottom: 1px solid rgba(148, 163, 184, 0.08); background: rgba(30, 41, 59, 0.25);">
          <td style="padding: 12px 16px; font-weight: 700; color: #f8fafc;">تصنيف الرحلة (Flight Type)</td>
          <td style="padding: 12px 16px; color: #38bdf8; font-weight: 600;">شروط السداد (Payment Terms)</td>
          <td style="padding: 12px 16px;"><span style="background: rgba(244, 63, 94, 0.15); color: #fb7185; padding: 2px 8px; border-radius: 4px; font-size: 11px;">حوكمة ومخاطر ائتمانية</span></td>
          <td style="padding: 12px 16px; color: #cbd5e1;">الرحلات العارضة (Charter) تلزم بسداد 100% مسبقاً، بينما المجدولة (Scheduled) تمنح Net-30.</td>
          <td style="padding: 12px 16px; color: #34d399; font-family: monospace; font-size: 12px;">IF(FlightType='Charter') Enforce_Proforma()</td>
        </tr>
        <!-- Row 6 -->
        <tr style="border-bottom: 1px solid rgba(148, 163, 184, 0.08); background: rgba(30, 41, 59, 0.15);">
          <td style="padding: 12px 16px; font-weight: 700; color: #f8fafc;">تصنيف الرحلة (Technical Stop)</td>
          <td style="padding: 12px 16px; color: #38bdf8; font-weight: 600;">باقة الخدمات (Service Scope)</td>
          <td style="padding: 12px 16px;"><span style="background: rgba(168, 85, 247, 0.15); color: #c084fc; padding: 2px 8px; border-radius: 4px; font-size: 11px;">استبعاد خدمات الركاب</span></td>
          <td style="padding: 12px 16px; color: #cbd5e1;">الهبوط الفني يستبعد تلقائياً صعود الركاب، والتنظيف، والحقائب، ويقتصر على الوقود والأوتاد.</td>
          <td style="padding: 12px 16px; color: #34d399; font-family: monospace; font-size: 12px;">Suppress(PassengerCheckIn, BaggageLoading)</td>
        </tr>
        <!-- Row 7 -->
        <tr style="border-bottom: 1px solid rgba(148, 163, 184, 0.08); background: rgba(30, 41, 59, 0.25);">
          <td style="padding: 12px 16px; font-weight: 700; color: #f8fafc;">زمن المهبط الفعلي (Actual Ramp Time)</td>
          <td style="padding: 12px 16px; color: #38bdf8; font-weight: 600;">غرامات الوقت الإضافي (Overtime Billing)</td>
          <td style="padding: 12px 16px;"><span style="background: rgba(239, 68, 68, 0.15); color: #f87171; padding: 2px 8px; border-radius: 4px; font-size: 11px;">تجاوز حدود العقد</span></td>
          <td style="padding: 12px 16px; color: #cbd5e1;">إذا تجاوز مكوث الطائرة من لحظة الأوتاد وقت السماح، تُحسب تلقائياً شرائح انتظار إضافية.</td>
          <td style="padding: 12px 16px; color: #34d399; font-family: monospace; font-size: 12px;">OvertimeUnits = CEIL((RampTime - FreeTime)/30m)</td>
        </tr>
        <!-- Row 8 -->
        <tr style="border-bottom: 1px solid rgba(148, 163, 184, 0.08); background: rgba(30, 41, 59, 0.15);">
          <td style="padding: 12px 16px; font-weight: 700; color: #f8fafc;">فاتورة المورد (Supplier Cost)</td>
          <td style="padding: 12px 16px; color: #38bdf8; font-weight: 600;">سعر فوترة العميل (Customer Disbursed Price)</td>
          <td style="padding: 12px 16px;"><span style="background: rgba(16, 185, 129, 0.15); color: #34d399; padding: 2px 8px; border-radius: 4px; font-size: 11px;">حماية الهامش الربحي</span></td>
          <td style="padding: 12px 16px; color: #cbd5e1;">يُمنع فوترة خدمات الوقود والتموين بخسارة؛ يضاف هامش عمولة إدارة إلزامي فوق تكلفة المورد.</td>
          <td style="padding: 12px 16px; color: #34d399; font-family: monospace; font-size: 12px;">CustomerBill = SupplierCost * (1 + MarkupPct)</td>
        </tr>
        <!-- Row 9 -->
        <tr style="background: rgba(30, 41, 59, 0.25);">
          <td style="padding: 12px 16px; font-weight: 700; color: #f8fafc;">حجم الرحلات الشهري (Monthly Volume)</td>
          <td style="padding: 12px 16px; color: #38bdf8; font-weight: 600;">خصم الحجم التجاري (Volume Rebate)</td>
          <td style="padding: 12px 16px;"><span style="background: rgba(99, 102, 241, 0.15); color: #818cf8; padding: 2px 8px; border-radius: 4px; font-size: 11px;">حافز ولاء تجاري</span></td>
          <td style="padding: 12px 16px; color: #cbd5e1;">وصول الناقل لأكثر من 30 رحلة شهرياً يُفعل خصم 5% على الفواتير التالية كإشعار دائن.</td>
          <td style="padding: 12px 16px; color: #34d399; font-family: monospace; font-size: 12px;">IF(FlightCount &gt;= Tier) Apply_Rebate()</td>
        </tr>
      </tbody>
    </table>
  </div>
</div>

---

## 🧮 5. مكعب التسعير متعدد الأبعاد والمعادلة الحسابية (Multi-Dimensional Pricing Cube)

عند تشغيل رحلة فعلية على أرض المهبط، يقوم **محرك الفوترة (TAS Pricing Engine)** بجمع وتطبيق جميع هذه المحددات عبر دالة رياضية موحدة:

<div style="background: rgba(15, 23, 42, 0.85); border: 1px solid rgba(56, 189, 248, 0.4); border-radius: 12px; padding: 20px; margin: 20px 0; font-family: 'Courier New', monospace; color: #38bdf8; font-size: 13.5px; line-height: 1.8;">
  <span style="color: #34d399; font-weight: 700;">// المعادلة الرياضية الشاملة لاحتساب فاتورة الرحلة في نظام TAS</span><br/>
  <strong>TotalFlightInvoice</strong> = <br/>
  &nbsp;&nbsp;&nbsp;&nbsp;<strong>MAX</strong>( <br/>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong>MinimumPriceGuarantee</strong>,<br/>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;( <br/>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong>BaseHandlingFee</strong>(AirportID, Model.MTOW, FlightType) <br/>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;+ <strong>OvertimeGroundFee</strong>(ActualGroundMinutes, GroundRangeLimit, OvertimeRatePerHalfHour) <br/>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;+ <strong>ExtraGSECharges</strong>(ExtraGPUHours, ASUStarts, ACUHours) <br/>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;+ <strong>AdHocCabinServices</strong>(WaterFlushes, ToiletFlushes, ExtraClean) <br/>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;) * ( 1 + <strong>NightOrHolidaySurchargePct</strong> ) <br/>
  &nbsp;&nbsp;&nbsp;&nbsp;) <br/>
  &nbsp;&nbsp;&nbsp;&nbsp;+ <strong>SubcontractorDisbursements</strong> [ ActualFuelCost + CateringCost ] * ( 1 + <strong>DisbursementFeePct 5%</strong> ) <br/>
  &nbsp;&nbsp;&nbsp;&nbsp;+ <strong>MandatoryAirportAuthorityTaxes</strong>(AirportID) <br/>
  &nbsp;&nbsp;&nbsp;&nbsp;- <strong>VolumeTierDiscount</strong>(MonthlyAccumulatedFlights)
</div>

---

### 📝 3 سيناريوهات تشغيلية واقعية من المطارات المصرية

لتوضيح كيفية تفاعل هذه المحددات في الواقع العملي:

<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(340px, 1fr)); gap: 16px; margin: 24px 0;">

  <!-- Scenario 1: Scheduled A320 in CAI -->
  <div style="background: rgba(15, 23, 42, 0.7); border: 1px solid rgba(52, 211, 153, 0.3); border-radius: 12px; padding: 18px;">
    <div style="color: #34d399; font-weight: 700; font-size: 14px; margin-bottom: 10px; display: flex; align-items: center; gap: 8px;">
      <span>🟢 السيناريو 1: رحلة مجدولة منتظمة (مطار القاهرة CAI)</span>
    </div>
    <ul style="color: #cbd5e1; font-size: 12.5px; line-height: 1.6; margin: 0; padding-right: 18px;">
      <li><strong>الناقل والعميل:</strong> مصر للطيران (MS) - شروط سداد Net-30.</li>
      <li><strong>الطراز:</strong> Airbus A320 (Narrow-body / MTOW 77t).</li>
      <li><strong>الموقف:</strong> موقف كوبري (Contact Gate TB3).</li>
      <li><strong>التنفيذ:</strong> مكوث 55 دقيقة (ضمن سماح 60 دقيقة).</li>
      <li><strong>النتيجة المالية:</strong> تطبيق السعر الأساسي للبدن الضيق فقط ($1,250) + رسوم الكوبري، دون أي غرامات تأخير أو حافلات، وترحيل الفاتورة لدفتر الأستاذ العام مباشرة.</li>
    </ul>
  </div>

  <!-- Scenario 2: Charter B737 in SSH with Overtime -->
  <div style="background: rgba(15, 23, 42, 0.7); border: 1px solid rgba(245, 158, 11, 0.3); border-radius: 12px; padding: 18px;">
    <div style="color: #fbbf24; font-weight: 700; font-size: 14px; margin-bottom: 10px; display: flex; align-items: center; gap: 8px;">
      <span>🟡 السيناريو 2: رحلة سياحية عارضة مع تأخير (شرم الشيخ SSH)</span>
    </div>
    <ul style="color: #cbd5e1; font-size: 12.5px; line-height: 1.6; margin: 0; padding-right: 18px;">
      <li><strong>الناقل والعميل:</strong> فلاي دبي (FZ) عبر وكيل سياحي - سداد 100% Proforma مسبقاً.</li>
      <li><strong>الطراز:</strong> Boeing 737-800 (MTOW 79t).</li>
      <li><strong>الموقف:</strong> موقف نائي (Remote Stand) يستلزم سلالم وحافلتين.</li>
      <li><strong>التنفيذ:</strong> مكوث 110 دقيقة (تجاوز حد السماح بـ 50 دقيقة) + ساعة GPU إضافية.</li>
      <li><strong>النتيجة المالية:</strong> احتساب شريحتين وقت إضافي (2 × $150 = $300) + ساعة GPU ($90) لتُخصم من الضمان المودع أو تصدر بها فاتورة فورية للكابتن.</li>
    </ul>
  </div>

  <!-- Scenario 3: Widebody Cargo B777 in HRG -->
  <div style="background: rgba(15, 23, 42, 0.7); border: 1px solid rgba(244, 63, 94, 0.3); border-radius: 12px; padding: 18px;">
    <div style="color: #f87171; font-weight: 700; font-size: 14px; margin-bottom: 10px; display: flex; align-items: center; gap: 8px;">
      <span>🔴 السيناريو 3: طيران شحن عريض البدن ليلي (الغردقة HRG)</span>
    </div>
    <ul style="color: #cbd5e1; font-size: 12.5px; line-height: 1.6; margin: 0; padding-right: 18px;">
      <li><strong>الناقل:</strong> الخطوط التركية للشحن (TK Cargo) - B777F (MTOW 347t).</li>
      <li><strong>التصنيف:</strong> Cargo / Freighter - لا يوجد ركاب، إلغاء السلالم والحافلات.</li>
      <li><strong>المعدات:</strong> رافعة منصات شحن سفلية (Main Deck Loader) + قاطرة سحب ثقيلة.</li>
      <li><strong>التوقيت:</strong> الوصول 02:30 فجراً (تطبيق بدل التشغيل الليلي +20%).</li>
      <li><strong>النتيجة المالية:</strong> تطبيق أعلى شريحة MTOW للشحن ($3,800) + إضافة 20% بدل ليلي ($760) + تزويد 40 طن وقود مع عمولة إدارة 5% محمية.</li>
    </ul>
  </div>

</div>

---

## 🗄️ 6. البنية العلائقية وقواعد البيانات (3NF Database Architecture)

لكي يعالج النظام هذه المحددات دون تعارض أو تكرار بيانات، يتم توزيعها على جداول مطبعة وفق معايير **المستوى الطبيعي الثالث (3NF)**:

<div style="background: #061512; border: 1px solid rgba(16, 185, 129, 0.35); border-radius: 14px; overflow: hidden; margin: 24px 0; box-shadow: 0 10px 30px rgba(0,0,0,0.5);">
<div style="background: linear-gradient(135deg, rgba(16, 185, 129, 0.25), rgba(30, 41, 59, 0.85)); padding: 14px 20px; border-bottom: 1px solid rgba(16, 185, 129, 0.3); display: flex; align-items: center; justify-content: space-between;">
<span style="color: #34d399; font-weight: 700; font-size: 15px;">📐 مصفوفة جداول قاعدة البيانات وحقول الربط المفتاحية (Relational DDL &amp; Schema Mapping)</span>
<span style="font-size: 11px; background: rgba(16, 185, 129, 0.2); color: #34d399; padding: 3px 10px; border-radius: 6px; font-weight: 700; border: 1px solid rgba(16, 185, 129, 0.4);">3NF NORMALIZED</span>
</div>
<div style="overflow-x: auto;">
<table style="width: 100%; border-collapse: collapse; text-align: right; font-size: 12.5px;">
<thead>
<tr style="border-bottom: 1px solid rgba(148, 163, 184, 0.2); background: rgba(15, 23, 42, 0.85); color: #34d399;">
<th style="padding: 12px 14px; font-weight: 700;">اسم الجدول (Table Name)</th>
<th style="padding: 12px 14px; font-weight: 700;">نوع الكيان</th>
<th style="padding: 12px 14px; font-weight: 700;">المفتاح الأساسي (PK)</th>
<th style="padding: 12px 14px; font-weight: 700;">المفاتيح الأجنبية والربط (FK References)</th>
<th style="padding: 12px 14px; font-weight: 700; text-align: center;">العلاقة</th>
<th style="padding: 12px 14px; font-weight: 700;">قيد التكامل والأثر الرقابي</th>
</tr>
</thead>
<tbody>
<tr style="border-bottom: 1px solid rgba(148, 163, 184, 0.08); background: rgba(30, 41, 59, 0.25);">
<td style="padding: 12px 14px; font-weight: 700; color: #f8fafc;"><code>dbo.Com_Contracts</code></td>
<td style="padding: 12px 14px; color: #38bdf8;">رأس العقد (Master Hub)</td>
<td style="padding: 12px 14px; color: #fbbf24; font-family: monospace;">ContractID</td>
<td style="padding: 12px 14px; color: #cbd5e1;"><code>CustomerID ➔ AR_Customers</code></td>
<td style="padding: 12px 14px; text-align: center; color: #38bdf8; font-weight: 700;">1 : N</td>
<td style="padding: 12px 14px; color: #34d399;">حظر حذف العميل المرتبط بعقد نشط (RESTRICT)</td>
</tr>
<tr style="border-bottom: 1px solid rgba(148, 163, 184, 0.08); background: rgba(30, 41, 59, 0.15);">
<td style="padding: 12px 14px; font-weight: 700; color: #f8fafc;"><code>dbo.Com_ContractAirports</code></td>
<td style="padding: 12px 14px; color: #34d399;">جدول ربط المطارات</td>
<td style="padding: 12px 14px; color: #fbbf24; font-family: monospace;">(ContractID, AirportID)</td>
<td style="padding: 12px 14px; color: #cbd5e1;"><code>AirportID ➔ Opr_Airports</code></td>
<td style="padding: 12px 14px; text-align: center; color: #38bdf8; font-weight: 700;">N : M</td>
<td style="padding: 12px 14px; color: #cbd5e1;">حذف تابع تلقائي مع العقد (CASCADE)</td>
</tr>
<tr style="border-bottom: 1px solid rgba(148, 163, 184, 0.08); background: rgba(30, 41, 59, 0.25);">
<td style="padding: 12px 14px; font-weight: 700; color: #f8fafc;"><code>dbo.Com_ContractAirlines</code></td>
<td style="padding: 12px 14px; color: #a5b4fc;">جدول ربط شركات الطيران</td>
<td style="padding: 12px 14px; color: #fbbf24; font-family: monospace;">(ContractID, AirlineID)</td>
<td style="padding: 12px 14px; color: #cbd5e1;"><code>AirlineID ➔ Opr_Airlines</code></td>
<td style="padding: 12px 14px; text-align: center; color: #38bdf8; font-weight: 700;">N : M</td>
<td style="padding: 12px 14px; color: #cbd5e1;">حذف تابع تلقائي مع العقد (CASCADE)</td>
</tr>
<tr style="border-bottom: 1px solid rgba(148, 163, 184, 0.08); background: rgba(30, 41, 59, 0.15);">
<td style="padding: 12px 14px; font-weight: 700; color: #f8fafc;"><code>dbo.Com_ContractServices</code></td>
<td style="padding: 12px 14px; color: #fbbf24;">تعرفة الخدمات والبدلات</td>
<td style="padding: 12px 14px; color: #fbbf24; font-family: monospace;">ContractServiceID</td>
<td style="padding: 12px 14px; color: #cbd5e1;"><code>ServiceID ➔ Com_Services</code><br/><code>SupplierID ➔ AP_Suppliers</code></td>
<td style="padding: 12px 14px; text-align: center; color: #38bdf8; font-weight: 700;">1 : N</td>
<td style="padding: 12px 14px; color: #34d399;">تطبيق قاعدة حائط صد الهامش (Margin Shield)</td>
</tr>
<tr style="background: rgba(30, 41, 59, 0.25);">
<td style="padding: 12px 14px; font-weight: 700; color: #f8fafc;"><code>dbo.Opr_TurnaroundWorkOrders</code></td>
<td style="padding: 12px 14px; color: #fb7185;">نقطة الالتقاء والفوترة</td>
<td style="padding: 12px 14px; color: #fbbf24; font-family: monospace;">WorkOrderID</td>
<td style="padding: 12px 14px; color: #cbd5e1;"><code>ContractID, AirportID, AirlineID, RegistrationID</code></td>
<td style="padding: 12px 14px; text-align: center; color: #38bdf8; font-weight: 700;">1 : N</td>
<td style="padding: 12px 14px; color: #34d399;">منع الفوترة أو فتح أمر تشغيل خارج غطاء العقد</td>
</tr>
</tbody>
</table>
</div>
<div style="padding: 16px; background: rgba(15, 23, 42, 0.6); border-top: 1px solid rgba(16, 185, 129, 0.2);">
<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 14px;">
<div style="background: rgba(15, 23, 42, 0.85); border: 1px solid rgba(56, 189, 248, 0.25); border-radius: 8px; padding: 14px;">
<div style="font-weight: 700; color: #38bdf8; font-size: 13px; margin-bottom: 8px; border-bottom: 1px solid rgba(56, 189, 248, 0.2); padding-bottom: 6px;">📄 رأس العقد: <code>dbo.Com_Contracts</code></div>
<div style="font-size: 12px; color: #cbd5e1; line-height: 1.7;">
<div>• <code>ContractID (PK, bigint)</code>: المعرف التعاقدي الفريد.</div>
<div>• <code>ContractNumber (nvarchar 50)</code>: رقم الاتفاقية المرجعي.</div>
<div>• <code>VersionNumber (int)</code>: إصدار العقد (v1, v2) للتعديلات الموسمية.</div>
<div>• <code>CustomerID (FK)</code>: يربط بجدول العميل المالي <code>AR_Customers</code>.</div>
<div>• <code>EffectiveFrom / ValidTo</code>: نافذة الصلاحية الزمنية وسريان العقد.</div>
<div>• <code>CurrencyCode / PaymentTermID</code>: عملة الفوترة وشروط الائتمان.</div>
</div>
</div>
<div style="background: rgba(15, 23, 42, 0.85); border: 1px solid rgba(52, 211, 153, 0.25); border-radius: 8px; padding: 14px;">
<div style="font-weight: 700; color: #34d399; font-size: 13px; margin-bottom: 8px; border-bottom: 1px solid rgba(52, 211, 153, 0.2); padding-bottom: 6px;">📍 ربط المطارات: <code>dbo.Com_ContractAirports</code> (N:M)</div>
<div style="font-size: 12px; color: #cbd5e1; line-height: 1.7;">
<div>• <code>ContractID (PK/FK)</code>: مرجع العقد (Cascade Delete).</div>
<div>• <code>AirportID (PK/FK)</code>: مرجع المطار المصرح به (CAI, HRG...).</div>
<div>• <code>IsPrimaryStation (bit)</code>: المحطة الرئيسية لعمليات الناقل.</div>
<div>• <code>StationConcessionFee (decimal)</code>: رسوم امتياز سلطة المطار.</div>
</div>
</div>
<div style="background: rgba(15, 23, 42, 0.85); border: 1px solid rgba(129, 140, 248, 0.25); border-radius: 8px; padding: 14px;">
<div style="font-weight: 700; color: #a5b4fc; font-size: 13px; margin-bottom: 8px; border-bottom: 1px solid rgba(129, 140, 248, 0.2); padding-bottom: 6px;">✈️ ربط شركات الطيران: <code>dbo.Com_ContractAirlines</code> (N:M)</div>
<div style="font-size: 12px; color: #cbd5e1; line-height: 1.7;">
<div>• <code>ContractID (PK/FK)</code>: مرجع العقد.</div>
<div>• <code>AirlineID (PK/FK)</code>: مرجع خط الطيران (MS, FZ, TK...).</div>
<div>• <code>AllianceCode (nvarchar 20)</code>: تحالف الطيران المشترك.</div>
</div>
</div>
<div style="background: rgba(15, 23, 42, 0.85); border: 1px solid rgba(245, 158, 11, 0.25); border-radius: 8px; padding: 14px;">
<div style="font-weight: 700; color: #fbbf24; font-size: 13px; margin-bottom: 8px; border-bottom: 1px solid rgba(245, 158, 11, 0.2); padding-bottom: 6px;">🧰 تعرفة الخدمات: <code>dbo.Com_ContractServices</code></div>
<div style="font-size: 12px; color: #cbd5e1; line-height: 1.7;">
<div>• <code>ContractServiceID (PK, bigint)</code>: معرف البند الفريد.</div>
<div>• <code>ServiceID (FK)</code>: يربط بفهرس خدمات المناولة IATA SGHA.</div>
<div>• <code>NegotiatedPrice</code>: السعر التعاقدي المتفق عليه.</div>
<div>• <code>OvertimePrice</code>: سعر الساعة أو النصف ساعة الإضافية.</div>
<div>• <code>DefaultSupplierID (FK)</code>: المقاول المعتمد للخدمة.</div>
</div>
</div>
<div style="background: rgba(15, 23, 42, 0.85); border: 1px solid rgba(244, 63, 94, 0.25); border-radius: 8px; padding: 14px; grid-column: 1 / -1;">
<div style="font-weight: 700; color: #fb7185; font-size: 13px; margin-bottom: 8px; border-bottom: 1px solid rgba(244, 63, 94, 0.2); padding-bottom: 6px;">🎯 نقطة الالتقاء التشغيلي والفوترة: <code>dbo.Opr_TurnaroundWorkOrders</code></div>
<div style="font-size: 12.5px; color: #cbd5e1; line-height: 1.7;">
يرتبط هذا الجدول الميداني بجميع المفاتيح لضمان التحقق الفوري: <code>ContractID</code> + <code>AirportID</code> + <code>AirlineID</code> + <code>RegistrationID (طراز الطائرة والوزن)</code> + <code>FlightTypeCode</code>. يتحكم بالمهبط ويولد الفاتورة التلقائية والمطابقة الثلاثية (3-Way Matching).
</div>
</div>
</div>
</div>
</div>

---

## 📋 7. قائمة التحقق العملية عند إنشاء عقد جديد (Step-by-Step Contract Creation Checklist)

لضمان عدم إغفال أي محدد أو علاقة عند إدخال عقد جديد على شاشة TAS:

<div style="background: rgba(15, 23, 42, 0.7); border: 1px solid rgba(148, 163, 184, 0.2); border-radius: 12px; padding: 20px; margin: 24px 0;">
  <div style="display: flex; flex-direction: column; gap: 12px; font-size: 13px; color: #cbd5e1;">
    <div style="display: flex; align-items: center; gap: 10px;">
      <span style="background: #10b981; color: #fff; width: 22px; height: 22px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: 700;">1</span>
      <span><strong>تحديد هوية العميل والناقلين:</strong> اختر العميل المالي المحاسبي، وحدد قائمة خطوط الطيران المشمولة في الاتفاقية.</span>
    </div>
    <div style="display: flex; align-items: center; gap: 10px;">
      <span style="background: #10b981; color: #fff; width: 22px; height: 22px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: 700;">2</span>
      <span><strong>تحديد نطاق المحطات:</strong> علم على المطارات المعتمدة للناقل (CAI, HRG, SSH) وحدد شروط كل محطة.</span>
    </div>
    <div style="display: flex; align-items: center; gap: 10px;">
      <span style="background: #10b981; color: #fff; width: 22px; height: 22px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: 700;">3</span>
      <span><strong>اعتماد مصفوفة أسطول الطائرات:</strong> ربط طرازات الطائرات المتوقعة للناقل والتأكد من أوزان MTOW وتصنيف البدن (Narrow vs Wide).</span>
    </div>
    <div style="display: flex; align-items: center; gap: 10px;">
      <span style="background: #10b981; color: #fff; width: 22px; height: 22px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: 700;">4</span>
      <span><strong>ضبط سقف السماحية والوقت المجاني:</strong> حدد مدة المكوث القياسية (مثلاً 60 دقيقة للبدن الضيق) وسعر نصف ساعة الانتظار الإضافي.</span>
    </div>
    <div style="display: flex; align-items: center; gap: 10px;">
      <span style="background: #10b981; color: #fff; width: 22px; height: 22px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: 700;">5</span>
      <span><strong>تحديد شروط الائتمان وسداد الـ Proforma:</strong> إذا كان الناقل يطير رحلات عارضة، فعل شرط "سداد الفاتورة المبدئية إلزامي قبل أمر العمل".</span>
    </div>
    <div style="display: flex; align-items: center; gap: 10px;">
      <span style="background: #10b981; color: #fff; width: 22px; height: 22px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: 700;">6</span>
      <span><strong>تفعيل حائط صد الهامش السالب (Margin Shield):</strong> حدد نسبة عمولة المناولة لموردي الوقود والتموين (بحد أدنى 5%).</span>
    </div>
    <div style="display: flex; align-items: center; gap: 10px;">
      <span style="background: #10b981; color: #fff; width: 22px; height: 22px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: 700;">7</span>
      <span><strong>اعتماد وحفظ العقد:</strong> بعد مراجعة الإدارة التجارية، يتم اعتماد العقد وتفعيله ليصبح جاهزاً لاستقبال طلبات الرحلات آلياً.</span>
    </div>
  </div>
</div>

---

*تم إعداد وتوثيق هذا الدليل المعماري كمرجع شامل لهندسة العقود وعلاقاتها في منظومة TAS Ground Handling Engine.*
