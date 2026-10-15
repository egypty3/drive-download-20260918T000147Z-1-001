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
  <div style="background: #0f172a; border: 1.5px solid rgba(129, 140, 248, 0.4); border-radius: 12px; padding: 20px; box-shadow: 0 6px 20px rgba(0,0,0,0.4);">
  <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1.5px solid rgba(129, 140, 248, 0.3); padding-bottom: 12px; margin-bottom: 14px;">
  <div style="display: flex; align-items: center; gap: 10px;">
  <span style="font-size: 24px;">🏢</span>
  <h3 style="margin: 0; color: #c7d2fe; font-size: 18px; font-weight: 800;">1. محددات الناقل والعميل المالي (Carrier &amp; Billing Entity Factors)</h3>
  </div>
  <span style="background: #1e1b4b; color: #a5b4fc; border: 1px solid #6366f1; padding: 4px 10px; border-radius: 6px; font-size: 11px; font-weight: 800;">COMMERCIAL &amp; CREDIT</span>
  </div>
  <div style="color: #f8fafc; font-size: 13.5px; line-height: 1.75;">
  <p style="color: #f8fafc;">يُميز النظام بدقة بين <strong style="color: #ffffff;">الجهة التي تدفع الفاتورة (Customer / Debtor)</strong> وبين <strong style="color: #ffffff;">شركة الطيران المشغلة للرحلة (Operating Carrier)</strong>:</p>
  <ul style="margin: 10px 24px; color: #f8fafc;">
  <li><strong style="color: #38bdf8;">العميل المالي المحاسبي (<code>CustomerID / AR_Customers</code>):</strong> قد يكون شركة الطيران نفسها، أو وسيط رحلات عارضة (Charter Broker)، أو منظم رحلات سياحية (Tour Operator مثل TUI)، أو وكيل خدمات ملاحة وإشراف (Trip Support Agency مثل Jetex أو Hadid).</li>
  <li><strong style="color: #38bdf8;">رمز الناقل الجوي (<code>AirlineID / Opr_Airlines</code>):</strong> الرموز المعتمدة لمنظمة الطيران المدني الدولي والاتحاد الدولي للنقل الجوي (IATA/ICAO Codes مثل <code>MS / MSR</code> لمصر للطيران، <code>FZ / FDB</code> لفلاي دبي، <code>TK / THY</code> للتركية). يمكن للعقد الواحد تغطية عدة خطوط طيران شقيقة تتبع نفس المجموعة القابضة.</li>
  <li><strong style="color: #38bdf8;">شروط الائتمان والسداد (<code>PaymentTermsID</code>):</strong>
  <span style="display: inline-block; background: #022c22; color: #4ade80; border: 1px solid #10b981; font-weight: 700; padding: 2px 8px; border-radius: 4px; font-size: 11px; margin: 0 4px;">Net-14 / Net-30 Days</span> للرحلات المجدولة الموثوقة، أو
  <span style="display: inline-block; background: #4c0519; color: #fda4af; border: 1px solid #f43f5e; font-weight: 700; padding: 2px 8px; border-radius: 4px; font-size: 11px; margin: 0 4px;">Pre-flight Cash / Proforma Wire Transfer</span> بنسبة 100% للرحلات العارضة غير المنتظمة.</li>
  <li><strong style="color: #38bdf8;">عملة العقد والفوترة (<code>BillingCurrency</code>):</strong> العملة التعاقدية الملزمة (USD، EUR، أو EGP محلياً)، مع قاعدة ربط سعر الصرف الرسمي للبنك المركزي بتاريخ تنفيذ الرحلة.</li>
  <li><strong style="color: #38bdf8;">سقف الائتمان والضمان البنكي (Credit Limit &amp; Bank Guarantee):</strong> الحد المالي الأقصى المسموح به للمديونية قبل إيقاف إصدار أوامر التشغيل تلقائياً.</li>
  </ul>
  </div>
  </div>

  <!-- FACTOR 2: AIRPORT & STATIONS -->
  <div style="background: #0f172a; border: 1.5px solid rgba(52, 211, 153, 0.4); border-radius: 12px; padding: 20px; box-shadow: 0 6px 20px rgba(0,0,0,0.4);">
  <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1.5px solid rgba(52, 211, 153, 0.3); padding-bottom: 12px; margin-bottom: 14px;">
  <div style="display: flex; align-items: center; gap: 10px;">
  <span style="font-size: 24px;">📍</span>
  <h3 style="margin: 0; color: #6ee7b7; font-size: 18px; font-weight: 800;">2. محددات النطاق الجغرافي والمحطات (Airport &amp; Station Scope Factors)</h3>
  </div>
  <span style="background: #064e3b; color: #a7f3d0; border: 1px solid #10b981; padding: 4px 10px; border-radius: 6px; font-size: 11px; font-weight: 800;">STATIONS &amp; APPRON</span>
  </div>
  <div style="color: #f8fafc; font-size: 13.5px; line-height: 1.75;">
  <p style="color: #f8fafc;">يحدد العقد المحطات الجوية المرخص بتقديم خدمات المناولة فيها:</p>
  <ul style="margin: 10px 24px; color: #f8fafc;">
  <li><strong style="color: #34d399;">المطارات المعتمدة (<code>AirportID / Opr_Airports</code>):</strong> كود المطار الدولي (مثل: <code>CAI</code> مطار القاهرة، <code>HRG</code> الغردقة، <code>SSH</code> شرم الشيخ، <code>LXR</code> الأقصر، <code>HBE</code> برج العرب).</li>
  <li><strong style="color: #34d399;">نوع الاتفاقية الجغرافية:</strong> إما اتفاقية محطة واحدة (Single-Station Handling Agreement) أو اتفاقية شبكة مطارات موحدة (Multi-Station National Network Agreement).</li>
  <li><strong style="color: #34d399;">طبيعة مواقف الطائرات بالمحطة (Stand Infrastructure):</strong>
  <ul style="margin: 6px 20px;">
  <li><strong style="color: #ffffff;">مواقف متصلة بالمبنى (Contact Stands / Jet Bridges):</strong> تقتضي احتساب رسوم استهلاك خرطوم الركاب، وتلغي الحاجة لحافلات المهبط.</li>
  <li><strong style="color: #ffffff;">مواقف نائية (Remote Apron Stands):</strong> تقتضي إلزامياً توفير سلالم متحركة (Mobile Passenger Stairs) وحافلات نقل ركاب المهبط (Cobus).</li>
  </ul>
  </li>
  <li><strong style="color: #34d399;">رسوم وامتيازات سلطة الطيران المدني (CAA Concession &amp; Royalties):</strong> الرسوم السيادية ونسب الإتاوة التي تختلف من مطار لآخر (مثال: رسوم مطار القاهرة الدولي تختلف عن رسوم مطارات الجذب السياحي الإقليمية).</li>
  </ul>
  </div>
  </div>

  <!-- FACTOR 3: FLEET & AIRCRAFT TYPE -->
  <div style="background: #0f172a; border: 1.5px solid rgba(56, 189, 248, 0.4); border-radius: 12px; padding: 20px; box-shadow: 0 6px 20px rgba(0,0,0,0.4);">
  <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1.5px solid rgba(56, 189, 248, 0.3); padding-bottom: 12px; margin-bottom: 14px;">
  <div style="display: flex; align-items: center; gap: 10px;">
  <span style="font-size: 24px;">🛫</span>
  <h3 style="margin: 0; color: #7dd3fc; font-size: 18px; font-weight: 800;">3. محددات الأسطول وطراز الطائرات (Aircraft Fleet &amp; Weight Factors)</h3>
  </div>
  <span style="background: #0c4a6e; color: #bae6fd; border: 1px solid #0284c7; padding: 4px 10px; border-radius: 6px; font-size: 11px; font-weight: 800;">MTOW &amp; BODY CLASS</span>
  </div>
  <div style="color: #f8fafc; font-size: 13.5px; line-height: 1.75;">
  <p style="color: #f8fafc;">يُمثل وزن الطائرة وهيكلها الأساس الفيزيائي الأول لتسعير المناولة حول العالم وفق معايير IATA AHM:</p>
  <ul style="margin: 10px 24px; color: #f8fafc;">
  <li><strong style="color: #38bdf8;">طراز الطائرة (<code>ModelCode / Opr_AircraftModels</code>):</strong> كود الطراز العالمي (مثل: A320, A321, B737-800, B777-300ER, A330-300, B787-9).</li>
  <li><strong style="color: #38bdf8;">وزن الإقلاع الأقصى (MTOW - Maximum Take-Off Weight):</strong> المقياس القياسي لتحديد شريحة السعر الأساسي للمناولة (Handling Tonnage Bracket). تقسم الشرائح عادة إلى:
  <span style="color: #38bdf8; font-weight: 700; background: #1e293b; padding: 2px 8px; border-radius: 4px; border: 1px solid #334155;">[0-25t], [26-50t], [51-80t], [81-120t], [121-160t], [&gt;160t]</span>.</li>
  <li><strong style="color: #38bdf8;">تصنيف البدن (<code>BodyType</code>):</strong>
  <ul style="margin: 6px 20px;">
  <li><strong style="color: #ffffff;">بدن ضيق (Narrow-body / Code C):</strong> ممر واحد (مثل A320 / B737) - يحتاج وحدة طاقة أرضية (GPU 90 kVA)، وسلم ركاب واحد أو اثنين، ومعدل دوران قياسي 45 إلى 60 دقيقة.</li>
  <li><strong style="color: #ffffff;">بدن عريض (Wide-body / Code D/E/F):</strong> ممران (مثل B777 / A350) - يحتاج وحدة طاقة أرضية ثقيلة (GPU 140+ kVA)، رافعة منصات شحن سفلية (Main Deck Loader)، ومعدل دوران قياسي 90 إلى 120 دقيقة.</li>
  </ul>
  </li>
  <li><strong style="color: #38bdf8;">سعة المقاعد والركاب (Seat Capacity - Y/C/F):</strong> الحد الأقصى للمقاعد في الدرجة السياحية ورجال الأعمال والأولى (يستخدم عند احتساب رسوم الركاب Per-Passenger Head Charge).</li>
  <li><strong style="color: #38bdf8;">تسجيلات ذيل الطائرة (<code>Tail Number / Opr_AircraftRegistrations</code>):</strong> الحروف المعرفة للطائرة الفعلية المسجلة لدى الناقل (مثل: <code>SU-GCT</code> لمصر للطيران) لضمان الربط المباشر مع حركة الرادار وسجلات برج المراقبة.</li>
  </ul>
  </div>
  </div>

  <!-- FACTOR 4: FLIGHT OPERATION TYPE -->
  <div style="background: #0f172a; border: 1.5px solid rgba(217, 70, 239, 0.4); border-radius: 12px; padding: 20px; box-shadow: 0 6px 20px rgba(0,0,0,0.4);">
  <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1.5px solid rgba(217, 70, 239, 0.3); padding-bottom: 12px; margin-bottom: 14px;">
  <div style="display: flex; align-items: center; gap: 10px;">
  <span style="font-size: 24px;">🔄</span>
  <h3 style="margin: 0; color: #f0abfc; font-size: 18px; font-weight: 800;">4. محددات تصنيف الرحلة والغرض التشغيلي (Flight Mission &amp; Type Factors)</h3>
  </div>
  <span style="background: #701a75; color: #f5d0fe; border: 1px solid #c026d3; padding: 4px 10px; border-radius: 6px; font-size: 11px; font-weight: 800;">FLIGHT CATEGORY</span>
  </div>
  <div style="color: #f8fafc; font-size: 13.5px; line-height: 1.75;">
  <p style="color: #f8fafc;">تختلف باقة الخدمات المطلوبة وشروط السداد وفقاً للغرض من تسيير الرحلة:</p>
  <ul style="margin: 10px 24px; color: #f8fafc;">
  <li><strong style="color: #e879f9;">رحلات تجارية مجدولة (Scheduled Flights):</strong> رحلات يومية أو أسبوعية منتظمة بجدول معلن. يطبق عليها خصومات الحجم، وشروط الائتمان القياسية (Net-30)، وباقات المناولة الشاملة الكاملة.</li>
  <li><strong style="color: #e879f9;">رحلات عارضة / سياحية (Charter Flights):</strong> رحلات موسمية أو عارضة غير منتظمة. تتطلب سداد الفاتورة المبدئية (Proforma) بنسبة 100% قبل صدور تصريح الهبوط وفتح أمر العمل.</li>
  <li><strong style="color: #e879f9;">رحلات شحن بضائع (Cargo / Freighter Flights):</strong> طائرات شحن بدون ركاب. تستبعد خدمات الركاب والسلالم والمقصورة، وتلزم بإضافة رافعات المنصات (Main Deck Loaders) وعربات حاويات الشحن (ULD Dollies) واحتساب السعر بالطن المشحون.</li>
  <li><strong style="color: #e879f9;">هبوط فني للتزود بالوقود (Technical Stop / Ferry Flight):</strong> هبوط سريع لا يشمل ركاباً أو تفريغ حقائب. يقتصر على الإرشاد، وتأمين الوقود، والأوتاد، بزمن مكوث قصير وسعر مخفض ومحدد سلفاً.</li>
  <li><strong style="color: #e879f9;">طيران خاص ورجال أعمال (VIP / Business Aviation):</strong> متطلبات خدمة استثنائية تشمل صالات كبار الزوار، النقل بسيارات الليموزين بالمهبط، وحراسة خاصة.</li>
  </ul>
  </div>
  </div>

  <!-- FACTOR 5: SERVICES CATALOG & GSE -->
  <div style="background: #0f172a; border: 1.5px solid rgba(245, 158, 11, 0.4); border-radius: 12px; padding: 20px; box-shadow: 0 6px 20px rgba(0,0,0,0.4);">
  <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1.5px solid rgba(245, 158, 11, 0.3); padding-bottom: 12px; margin-bottom: 14px;">
  <div style="display: flex; align-items: center; gap: 10px;">
  <span style="font-size: 24px;">🧰</span>
  <h3 style="margin: 0; color: #fcd34d; font-size: 18px; font-weight: 800;">5. محددات فهرس الخدمات ومعدات المهبط (Services Catalog &amp; GSE Scope)</h3>
  </div>
  <span style="background: #78350f; color: #fef08a; border: 1px solid #d97706; padding: 4px 10px; border-radius: 6px; font-size: 11px; font-weight: 800;">IATA SGHA AHM 810</span>
  </div>
  <div style="color: #f8fafc; font-size: 13.5px; line-height: 1.75;">
  <p style="color: #f8fafc;">هيكلة بنود الاتفاقية وفق الفصول الدولية للاتحاد الدولي للنقل الجوي (IATA Standard Ground Handling Agreement):</p>
  <ul style="margin: 10px 24px; color: #f8fafc;">
  <li><strong style="color: #fbbf24;">خدمات ساحة الطيران (Ramp Operations - Section 3):</strong> وضع وسحب الأوتاد (Chocks On/Off)، الإرشاد (Marshalling)، القاطرة والدفع للخلف (Pushback Tractor)، تحميل وتفريغ الحقائب.</li>
  <li><strong style="color: #fbbf24;">معدات الدعم الأرضي ووحدات الطاقة (GSE Units):</strong>
  <span style="color: #fde047; font-weight: 700; background: #1e293b; padding: 2px 6px; border-radius: 4px; border: 1px solid #334155;">GPU (Ground Power Unit)</span> بنظام النصف ساعة أو الساعة،
  <span style="color: #fde047; font-weight: 700; background: #1e293b; padding: 2px 6px; border-radius: 4px; border: 1px solid #334155;">ASU (Air Start Unit)</span> لبدء تشغيل المحركات،
  <span style="color: #fde047; font-weight: 700; background: #1e293b; padding: 2px 6px; border-radius: 4px; border: 1px solid #334155;">ACU (Air Conditioning Unit)</span> لتبريد المقصورة.</li>
  <li><strong style="color: #fbbf24;">مرافق مقصورة الطائرة (Cabin Services):</strong> تزويد مياه الشرب العذبة النقية (Potable Water)، تفريغ ومعالجة الصرف الصحي (Lavatory Waste)، والنظافة السريعة (Transit Cleaning).</li>
  <li><strong style="color: #fbbf24;">خدمات الركاب (Passenger Services - Section 2):</strong> مكاتب وزن الأمتعة وقبول الركاب (Check-in Desks)، بوابات الصعود، مكاتب الحقائب الضائعة (Lost &amp; Found / WorldTracer).</li>
  <li><strong style="color: #fbbf24;">خدمات مقاولي الباطن والوقود (Third-Party / Disbursed Services):</strong> تنسيق شاحنات الوقود وسيارات الإطفاء المرافقة، التموين (Catering)، وتخضع لنسبة عمولة إدارة (Disbursement Handling Fee 5% إلى 10%).</li>
  </ul>
  </div>
  </div>

  <!-- FACTOR 6: TIME TOLERANCES & OVERTIME -->
  <div style="background: #0f172a; border: 1.5px solid rgba(148, 163, 184, 0.4); border-radius: 12px; padding: 20px; box-shadow: 0 6px 20px rgba(0,0,0,0.4);">
  <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1.5px solid rgba(148, 163, 184, 0.3); padding-bottom: 12px; margin-bottom: 14px;">
  <div style="display: flex; align-items: center; gap: 10px;">
  <span style="font-size: 24px;">⏱️</span>
  <h3 style="margin: 0; color: #f1f5f9; font-size: 18px; font-weight: 800;">6. محددات زمن المكوث والسماحية (Turnaround Ground Time &amp; Tolerances)</h3>
  </div>
  <span style="background: #334155; color: #ffffff; border: 1px solid #64748b; padding: 4px 10px; border-radius: 6px; font-size: 11px; font-weight: 800;">TIME WINDOWS</span>
  </div>
  <div style="color: #f8fafc; font-size: 13.5px; line-height: 1.75;">
  <p style="color: #f8fafc;">الزمن هو المحدد المالي الحاسم؛ فبقاؤ الطائرة على أرض المهبط يُكلف موارد بشرية ومعدات حيوية:</p>
  <ul style="margin: 10px 24px; color: #f8fafc;">
  <li><strong style="color: #ffffff;">وقت المكوث القياسي المشمول مجاناً (<code>GroundRange / TimeInclude</code>):</strong>
  زمن دوران الطائرة المشمول ضمن السعر الأساسي (مثال: أول ساعتين مجاناً للطائرات ضيقة البدن، و3 ساعات للطائرات عريضة البدن).</li>
  <li><strong style="color: #ffffff;">شرائح احتساب الوقت الإضافي (Overtime Parking Gradients):</strong>
  في حال تأخر إقلاع الطائرة عن وقت السماح، يبدأ النظام في احتساب غرامات إشغال المهبط تلقائياً مجزأة لكل نصف ساعة إضافية.</li>
  <li><strong style="color: #ffffff;">ساعات الطاقة المشمولة مجاناً (Included GPU Hours):</strong>
  تحديد عدد ساعات عمل وحدة الكهرباء المشمولة مع الباقة (مثلاً: أول ساعة مجاناً؛ وما زاد عنها يُفوتر تلقائياً بسعر الساعة المقررة في العقد).</li>
  </ul>
  </div>
  </div>

  <!-- FACTOR 7: PRICING LOGIC, SURCHARGES & VOLUME -->
  <div style="background: #0f172a; border: 1.5px solid rgba(244, 63, 94, 0.4); border-radius: 12px; padding: 20px; box-shadow: 0 6px 20px rgba(0,0,0,0.4);">
  <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1.5px solid rgba(244, 63, 94, 0.3); padding-bottom: 12px; margin-bottom: 14px;">
  <div style="display: flex; align-items: center; gap: 10px;">
  <span style="font-size: 24px;">💰</span>
  <h3 style="margin: 0; color: #fda4af; font-size: 18px; font-weight: 800;">7. محددات التسعير والبدلات وحوافز الحجم (Pricing Mechanics &amp; Margin Rules)</h3>
  </div>
  <span style="background: #881337; color: #fecdd3; border: 1px solid #e11d48; padding: 4px 10px; border-radius: 6px; font-size: 11px; font-weight: 800;">MARGIN &amp; REBATE</span>
  </div>
  <div style="color: #f8fafc; font-size: 13.5px; line-height: 1.75;">
  <p style="color: #f8fafc;">القواعد المالية الصارمة التي تضمن ربحية المناول وتمنع التسرب:</p>
  <ul style="margin: 10px 24px; color: #f8fafc;">
  <li><strong style="color: #fb7185;">ضمان الحد الأدنى للإيراد (<code>MinimumPrice Guarantee</code>):</strong> سقف أدنى مالي لا يمكن فوترة الرحلة بأقل منه تحت أي ظرف (حتى لو كانت الطائرة فارغة أو بحمولة منخفضة) لتغطية تكاليف الطاقم والمعدات.</li>
  <li><strong style="color: #fb7185;">البدلات الإضافية للتشغيل الاستثنائي (<code>SureCharge</code>):</strong>
  نسب مئوية إضافية تضاف على السعر الأساسي للرحلة:
  <span style="color: #fda4af; font-weight: 700; background: #1e293b; padding: 2px 6px; border-radius: 4px;">بدل عمل ليلي (Night Surcharge +20% بين 22:00 و 06:00)</span>،
  <span style="color: #fda4af; font-weight: 700; background: #1e293b; padding: 2px 6px; border-radius: 4px;">بدل عطلات وأعياد رسمية (+25%)</span>،
  وبدل طلب خدمة طارئة في أقل من 24 ساعة (+30%).</li>
  <li><strong style="color: #fb7185;">حائط صد الهامش السالب مع الموردين (Margin Shield):</strong>
  قاعدة برمجية ملزمة تمنع فوترة أي خدمة منفذة عبر مقاول خارجي (وقود/تموين) بسعر يقل عن فاتورة المقاول الفعلية، وتضيف آلياً عمولة المناول (مثلاً: <code>تكلفة الوقود + 5% Disbursement Fee</code>).</li>
  <li><strong style="color: #fb7185;">شرائح خصم الحجم التراكمي (Volume Rebates):</strong>
  مكافأة الناقل عند تجاوزه عتبة عدد رحلات شهرياً (مثال: &gt; 25 رحلة شهرياً = خصم 5%؛ &gt; 50 رحلة شهرياً = خصم 10% يُمنح في نهاية الشهر كإشعار دائن Credit Note).</li>
  </ul>
  </div>
  </div>

</div>

---

## 🔗 4. مصفوفة العلاقات والتشابك البيني بين المحددات (Interdependence Matrix)

الجدول التالي يشرح **العلاقة الدقيقة (The Exact Relationship)** بين كل محددين، وكيف تؤثر التغييرات في محدد معين على باقي محددات النظام:

<div style="background: #0f172a; border: 1.5px solid #0284c7; border-radius: 14px; overflow: hidden; margin: 24px 0; box-shadow: 0 10px 30px rgba(0,0,0,0.5);">
  <div style="background: linear-gradient(135deg, #1e3a8a, #0f172a); padding: 14px 20px; border-bottom: 1.5px solid #0284c7; display: flex; align-items: center; justify-content: space-between;">
  <span style="font-weight: 800; color: #ffffff; font-size: 15px;">📊 مصفوفة التأثير المتبادل والقواعد التشغيلية والمالية (Cross-Factor Interdependence Matrix)</span>
  <span style="font-size: 12px; color: #38bdf8; font-weight: 700;">تكامل فيزيائي وتشغيلي ومالي</span>
  </div>
  <div style="overflow-x: auto;">
  <table class="matrix-table-dark" style="width: 100%; border-collapse: collapse; text-align: right; font-size: 13px;">
  <thead>
  <tr style="border-bottom: 2px solid #334155; background: #1e293b; color: #38bdf8;">
  <th style="padding: 12px 14px; font-weight: 800; color: #ffffff;">المحدد الأول (Factor A)</th>
  <th style="padding: 12px 14px; font-weight: 800; color: #38bdf8;">المحدد الثاني (Factor B)</th>
  <th style="padding: 12px 14px; font-weight: 800; color: #ffffff;">نوع العلاقة والترابط</th>
  <th style="padding: 12px 14px; font-weight: 800; color: #ffffff;">الأثر التشغيلي والمالي (Operational &amp; Financial Impact)</th>
  <th style="padding: 12px 14px; font-weight: 800; color: #ffffff;">القاعدة الحاكمة في النظام (TAS Business Rule)</th>
  </tr>
  </thead>
  <tbody>
  <!-- Row 1 -->
  <tr style="border-bottom: 1px solid #334155; background: #0f172a;">
  <td style="padding: 12px 14px; font-weight: 800; color: #ffffff;">طراز الطائرة (MTOW)</td>
  <td style="padding: 12px 14px; color: #38bdf8; font-weight: 800;">السعر الأساسي للمناولة (Base Rate)</td>
  <td style="padding: 12px 14px;"><span style="background: #1e3a8a; color: #ffffff; border: 1px solid #3b82f6; padding: 4px 10px; border-radius: 4px; font-size: 11.5px; font-weight: 800;">تناسب طردي حسب الوزن</span></td>
  <td style="padding: 12px 14px; color: #ffffff; font-weight: 600; line-height: 1.6;">كلما زاد وزن الطائرة (طن)، زادت شريحة المناولة ومقدار استهلاك معدات السحب والأوتاد.</td>
  <td dir="ltr" style="padding: 12px 14px; text-align: left;"><code style="background: #020617; color: #38bdf8; border: 1px solid #1e40af; padding: 5px 10px; border-radius: 4px; font-family: monospace; font-size: 12px; font-weight: 700; display: inline-block;">BaseRate = MTOW_Band_Rate(Model.MTOW)</code></td>
  </tr>
  <!-- Row 2 -->
  <tr style="border-bottom: 1px solid #334155; background: #17223b;">
  <td style="padding: 12px 14px; font-weight: 800; color: #ffffff;">طراز الطائرة (Body Type)</td>
  <td style="padding: 12px 14px; color: #38bdf8; font-weight: 800;">سماحية زمن المكوث (Ground Tolerance)</td>
  <td style="padding: 12px 14px;"><span style="background: #064e3b; color: #ffffff; border: 1px solid #10b981; padding: 4px 10px; border-radius: 4px; font-size: 11.5px; font-weight: 800;">محدد فيزيائي للبنية</span></td>
  <td style="padding: 12px 14px; color: #ffffff; font-weight: 600; line-height: 1.6;">البدن الضيق يمنح 60 دقيقة مجاناً، بينما العريض يمنح 90-120 دقيقة لكثافة الركاب وسعة العفش.</td>
  <td dir="ltr" style="padding: 12px 14px; text-align: left;"><code style="background: #020617; color: #38bdf8; border: 1px solid #1e40af; padding: 5px 10px; border-radius: 4px; font-family: monospace; font-size: 12px; font-weight: 700; display: inline-block;">FreeTime = IF(BodyType='W', 120m, 60m)</code></td>
  </tr>
  <!-- Row 3 -->
  <tr style="border-bottom: 1px solid #334155; background: #0f172a;">
  <td style="padding: 12px 14px; font-weight: 800; color: #ffffff;">طراز الطائرة (Body Type)</td>
  <td style="padding: 12px 14px; color: #38bdf8; font-weight: 800;">قدرة ونوع المعدات الأرضية (GSE Specification)</td>
  <td style="padding: 12px 14px;"><span style="background: #78350f; color: #ffffff; border: 1px solid #f59e0b; padding: 4px 10px; border-radius: 4px; font-size: 11.5px; font-weight: 800;">اشتراط هندسي إلزامي</span></td>
  <td style="padding: 12px 14px; color: #ffffff; font-weight: 600; line-height: 1.6;">البدن العريض يلزم بتعيين GPU 140 kVA بدلاً من 90 kVA، وقاطرة سحب ثقيلة (Heavy Pushback).</td>
  <td dir="ltr" style="padding: 12px 14px; text-align: left;"><code style="background: #020617; color: #38bdf8; border: 1px solid #1e40af; padding: 5px 10px; border-radius: 4px; font-family: monospace; font-size: 12px; font-weight: 700; display: inline-block;">ValidateGSE(Model.BodyType, AssignedGSE)</code></td>
  </tr>
  <!-- Row 4 -->
  <tr style="border-bottom: 1px solid #334155; background: #17223b;">
  <td style="padding: 12px 14px; font-weight: 800; color: #ffffff;">المطار (Airport / Station)</td>
  <td style="padding: 12px 14px; color: #38bdf8; font-weight: 800;">طبيعة الخدمات الإلزامية (Mandatory Services)</td>
  <td style="padding: 12px 14px;"><span style="background: #0c4a6e; color: #ffffff; border: 1px solid #0284c7; padding: 4px 10px; border-radius: 4px; font-size: 11.5px; font-weight: 800;">محدد بنية تحتية للموقف</span></td>
  <td style="padding: 12px 14px; color: #ffffff; font-weight: 600; line-height: 1.6;">المواقف النائية بمطارات HRG/SSH تلزم بتشغيل حافلات وسلالم، بينما مواقف الكباري تلغيها.</td>
  <td dir="ltr" style="padding: 12px 14px; text-align: left;"><code style="background: #020617; color: #38bdf8; border: 1px solid #1e40af; padding: 5px 10px; border-radius: 4px; font-family: monospace; font-size: 12px; font-weight: 700; display: inline-block;">Mutex(JetBridge, PassengerStairs + Bus)</code></td>
  </tr>
  <!-- Row 5 -->
  <tr style="border-bottom: 1px solid #334155; background: #0f172a;">
  <td style="padding: 12px 14px; font-weight: 800; color: #ffffff;">تصنيف الرحلة (Flight Type)</td>
  <td style="padding: 12px 14px; color: #38bdf8; font-weight: 800;">شروط السداد (Payment Terms)</td>
  <td style="padding: 12px 14px;"><span style="background: #881337; color: #ffffff; border: 1px solid #f43f5e; padding: 4px 10px; border-radius: 4px; font-size: 11.5px; font-weight: 800;">حوكمة ومخاطر ائتمانية</span></td>
  <td style="padding: 12px 14px; color: #ffffff; font-weight: 600; line-height: 1.6;">الرحلات العارضة (Charter) تلزم بسداد 100% مسبقاً، بينما المجدولة (Scheduled) تمنح Net-30.</td>
  <td dir="ltr" style="padding: 12px 14px; text-align: left;"><code style="background: #020617; color: #38bdf8; border: 1px solid #1e40af; padding: 5px 10px; border-radius: 4px; font-family: monospace; font-size: 12px; font-weight: 700; display: inline-block;">IF(FlightType='Charter') Enforce_Proforma()</code></td>
  </tr>
  <!-- Row 6 -->
  <tr style="border-bottom: 1px solid #334155; background: #17223b;">
  <td style="padding: 12px 14px; font-weight: 800; color: #ffffff;">تصنيف الرحلة (Technical Stop)</td>
  <td style="padding: 12px 14px; color: #38bdf8; font-weight: 800;">باقة الخدمات (Service Scope)</td>
  <td style="padding: 12px 14px;"><span style="background: #581c87; color: #ffffff; border: 1px solid #a855f7; padding: 4px 10px; border-radius: 4px; font-size: 11.5px; font-weight: 800;">استبعاد خدمات الركاب</span></td>
  <td style="padding: 12px 14px; color: #ffffff; font-weight: 600; line-height: 1.6;">الهبوط الفني يستبعد تلقائياً صعود الركاب، والتنظيف، والحقائب، ويقتصر على الوقود والأوتاد.</td>
  <td dir="ltr" style="padding: 12px 14px; text-align: left;"><code style="background: #020617; color: #38bdf8; border: 1px solid #1e40af; padding: 5px 10px; border-radius: 4px; font-family: monospace; font-size: 12px; font-weight: 700; display: inline-block;">Suppress(PassengerCheckIn, BaggageLoading)</code></td>
  </tr>
  <!-- Row 7 -->
  <tr style="border-bottom: 1px solid #334155; background: #0f172a;">
  <td style="padding: 12px 14px; font-weight: 800; color: #ffffff;">زمن المهبط الفعلي (Actual Ramp Time)</td>
  <td style="padding: 12px 14px; color: #38bdf8; font-weight: 800;">غرامات الوقت الإضافي (Overtime Billing)</td>
  <td style="padding: 12px 14px;"><span style="background: #7f1d1d; color: #ffffff; border: 1px solid #ef4444; padding: 4px 10px; border-radius: 4px; font-size: 11.5px; font-weight: 800;">تجاوز حدود العقد</span></td>
  <td style="padding: 12px 14px; color: #ffffff; font-weight: 600; line-height: 1.6;">إذا تجاوز مكوث الطائرة من لحظة الأوتاد وقت السماح، تُحسب تلقائياً شرائح انتظار إضافية.</td>
  <td dir="ltr" style="padding: 12px 14px; text-align: left;"><code style="background: #020617; color: #38bdf8; border: 1px solid #1e40af; padding: 5px 10px; border-radius: 4px; font-family: monospace; font-size: 12px; font-weight: 700; display: inline-block;">OvertimeUnits = CEIL((RampTime - FreeTime) / 30m)</code></td>
  </tr>
  <!-- Row 8 -->
  <tr style="border-bottom: 1px solid #334155; background: #17223b;">
  <td style="padding: 12px 14px; font-weight: 800; color: #ffffff;">فاتورة المورد (Supplier Cost)</td>
  <td style="padding: 12px 14px; color: #38bdf8; font-weight: 800;">سعر فوترة العميل (Customer Disbursed Price)</td>
  <td style="padding: 12px 14px;"><span style="background: #064e3b; color: #ffffff; border: 1px solid #10b981; padding: 4px 10px; border-radius: 4px; font-size: 11.5px; font-weight: 800;">حماية الهامش الربحي</span></td>
  <td style="padding: 12px 14px; color: #ffffff; font-weight: 600; line-height: 1.6;">يُمنع فوترة خدمات الوقود والتموين بخسارة؛ يضاف هامش عمولة إدارة إلزامي فوق تكلفة المورد.</td>
  <td dir="ltr" style="padding: 12px 14px; text-align: left;"><code style="background: #020617; color: #38bdf8; border: 1px solid #1e40af; padding: 5px 10px; border-radius: 4px; font-family: monospace; font-size: 12px; font-weight: 700; display: inline-block;">CustomerBill = SupplierCost * (1 + MarkupPct)</code></td>
  </tr>
  <!-- Row 9 -->
  <tr style="background: #0f172a;">
  <td style="padding: 12px 14px; font-weight: 800; color: #ffffff;">حجم الرحلات الشهري (Monthly Volume)</td>
  <td style="padding: 12px 14px; color: #38bdf8; font-weight: 800;">خصم الحجم التجاري (Volume Rebate)</td>
  <td style="padding: 12px 14px;"><span style="background: #312e81; color: #ffffff; border: 1px solid #6366f1; padding: 4px 10px; border-radius: 4px; font-size: 11.5px; font-weight: 800;">حافز ولاء تجاري</span></td>
  <td style="padding: 12px 14px; color: #ffffff; font-weight: 600; line-height: 1.6;">وصول الناقل لأكثر من 30 رحلة شهرياً يُفعل خصم 5% على الفواتير التالية كإشعار دائن.</td>
  <td dir="ltr" style="padding: 12px 14px; text-align: left;"><code style="background: #020617; color: #38bdf8; border: 1px solid #1e40af; padding: 5px 10px; border-radius: 4px; font-family: monospace; font-size: 12px; font-weight: 700; display: inline-block;">IF(FlightCount &gt;= Tier) Apply_Rebate()</code></td>
  </tr>
  </tbody>
  </table>
  </div>
</div>

---

## 🧮 5. مكعب التسعير متعدد الأبعاد والمعادلة الحسابية (Multi-Dimensional Pricing Cube)

عند تشغيل رحلة فعلية على أرض المهبط، يقوم **محرك الفوترة (TAS Pricing Engine)** بجمع وتطبيق جميع هذه المحددات عبر دالة رياضية موحدة:

<div style="background: #070d1e; border: 1px solid rgba(56, 189, 248, 0.45); border-radius: 14px; overflow: hidden; margin: 24px 0; box-shadow: 0 12px 36px rgba(0,0,0,0.5); page-break-inside: avoid; break-inside: avoid;">
  <div style="background: rgba(30, 41, 59, 0.95); padding: 12px 18px; border-bottom: 1px solid rgba(56, 189, 248, 0.25); display: flex; align-items: center; justify-content: space-between;">
    <div style="color: #94a3b8; font-family: monospace; font-size: 13px; font-weight: 600;">tas_pricing_engine_formula.calc</div>
    <div style="color: #34d399; font-size: 13px; font-weight: 700;">المعادلة الحسابية الشاملة لاحتساب فاتورة الرحلة (TAS Engine)</div>
  </div>
  <pre dir="ltr" style="direction: ltr !important; text-align: left !important; unicode-bidi: isolate !important; margin: 0; padding: 22px; font-family: monospace; font-size: 13.5px; line-height: 1.85; background: #070d1e; overflow-x: auto; color: #f8fafc;"><span style="color: #64748b;">// TAS Unified Flight Invoice Pricing Formula (Left-to-Right Execution)</span>
<strong style="color: #38bdf8;">TotalFlightInvoice</strong> = 
    <strong style="color: #fbbf24;">MAX</strong>(
        <span style="color: #f43f5e; font-weight: 600;">MinimumPriceGuarantee</span>,
        (
            <span style="color: #a78bfa; font-weight: 600;">BaseHandlingFee</span>(<span style="color: #93c5fd;">AirportID</span>, <span style="color: #93c5fd;">Model.MTOW</span>, <span style="color: #93c5fd;">FlightType</span>)
            + <span style="color: #a78bfa; font-weight: 600;">OvertimeGroundFee</span>(<span style="color: #93c5fd;">ActualGroundMinutes</span>, <span style="color: #93c5fd;">GroundRangeLimit</span>, <span style="color: #93c5fd;">OvertimeRatePerHalfHour</span>)
            + <span style="color: #a78bfa; font-weight: 600;">ExtraGSECharges</span>(<span style="color: #93c5fd;">ExtraGPUHours</span>, <span style="color: #93c5fd;">ASUStarts</span>, <span style="color: #93c5fd;">ACUHours</span>)
            + <span style="color: #a78bfa; font-weight: 600;">AdHocCabinServices</span>(<span style="color: #93c5fd;">WaterFlushes</span>, <span style="color: #93c5fd;">ToiletFlushes</span>, <span style="color: #93c5fd;">ExtraClean</span>)
        ) * ( <span style="color: #e2e8f0;">1</span> + <span style="color: #fb923c; font-weight: 600;">NightOrHolidaySurchargePct</span> )
    )
    + <span style="color: #34d399; font-weight: 600;">SubcontractorDisbursements</span>[ <span style="color: #93c5fd;">ActualFuelCost</span> + <span style="color: #93c5fd;">CateringCost</span> ] * ( <span style="color: #e2e8f0;">1</span> + <span style="color: #fb923c; font-weight: 600;">DisbursementFeePct 5%</span> )
    + <span style="color: #f87171; font-weight: 600;">MandatoryAirportAuthorityTaxes</span>(<span style="color: #93c5fd;">AirportID</span>)
    - <span style="color: #67e8f9; font-weight: 600;">VolumeTierDiscount</span>(<span style="color: #93c5fd;">MonthlyAccumulatedFlights</span>)
</pre>
</div>

<div style="background: #0f172a; border: 1.5px solid #0284c7; border-radius: 12px; padding: 18px 20px; margin: 20px 0; box-shadow: 0 8px 24px rgba(0,0,0,0.4);">
  <div style="color: #38bdf8; font-weight: 800; font-size: 14px; margin-bottom: 12px;">📊 التحليل التفصيلي لمكونات المعادلة الخمسة وآلية عمل المحرك:</div>
  <table class="matrix-table-dark" style="width: 100%; border-collapse: collapse; text-align: right; font-size: 12.5px;">
    <thead>
      <tr style="border-bottom: 2px solid #334155; background: #1e293b; color: #38bdf8;">
        <th style="padding: 10px 12px; font-weight: 800; text-align: left; color: #ffffff;">المكون في المعادلة (Formula Component)</th>
        <th style="padding: 10px 12px; font-weight: 800; color: #38bdf8;">البيان الوظيفي</th>
        <th style="padding: 10px 12px; font-weight: 800; color: #ffffff;">طريقة التطبيق والأثر الرقابي</th>
      </tr>
    </thead>
    <tbody>
      <tr style="border-bottom: 1px solid #334155; background: #0f172a;">
        <td dir="ltr" style="padding: 11px 12px; color: #fde047; font-family: monospace; font-weight: 800; text-align: left; unicode-bidi: isolate;"><code style="background: #020617; color: #fde047; padding: 4px 8px; border-radius: 4px; border: 1px solid #78350f;">MAX(MinimumPriceGuarantee, ...)</code></td>
        <td style="padding: 11px 12px; font-weight: 800; color: #ffffff;">حماية الحد الأدنى للسعر</td>
        <td style="padding: 11px 12px; color: #ffffff; font-weight: 500; line-height: 1.6;">مقارنة إجمالي الخدمات الأساسية بالحد الأدنى المضمون وتطبيق الأعلى لضمان تغطية تكلفة النزول.</td>
      </tr>
      <tr style="border-bottom: 1px solid #334155; background: #17223b;">
        <td dir="ltr" style="padding: 11px 12px; color: #c084fc; font-family: monospace; font-weight: 800; text-align: left; unicode-bidi: isolate;"><code style="background: #020617; color: #c084fc; padding: 4px 8px; border-radius: 4px; border: 1px solid #581c87;">(Base + Overtime + GSE + Cabin) * (1 + NightSurcharge)</code></td>
        <td style="padding: 11px 12px; font-weight: 800; color: #ffffff;">باقة المهبط وبدل التوقيت</td>
        <td style="padding: 11px 12px; color: #ffffff; font-weight: 500; line-height: 1.6;">مجموع المناولة الأساسية + غرامات تجاوز المكوث + ساعات الطاقة الإضافية + تنظيف الكابينة × بدل الليل/العطلات.</td>
      </tr>
      <tr style="border-bottom: 1px solid #334155; background: #0f172a;">
        <td dir="ltr" style="padding: 11px 12px; color: #4ade80; font-family: monospace; font-weight: 800; text-align: left; unicode-bidi: isolate;"><code style="background: #020617; color: #4ade80; padding: 4px 8px; border-radius: 4px; border: 1px solid #064e3b;">SubcontractorDisbursements * (1 + DisbursementFeePct)</code></td>
        <td style="padding: 11px 12px; font-weight: 800; color: #ffffff;">مدفوعات مقاولي الباطن</td>
        <td style="padding: 11px 12px; color: #ffffff; font-weight: 500; line-height: 1.6;">تحميل تكلفة الوقود والتموين الفعلية مع إضافة عمولة إدارة إلزامي (5%) لمنع صدور الفاتورة بخسارة.</td>
      </tr>
      <tr style="border-bottom: 1px solid #334155; background: #17223b;">
        <td dir="ltr" style="padding: 11px 12px; color: #f87171; font-family: monospace; font-weight: 800; text-align: left; unicode-bidi: isolate;"><code style="background: #020617; color: #f87171; padding: 4px 8px; border-radius: 4px; border: 1px solid #7f1d1d;">+ MandatoryAirportAuthorityTaxes</code></td>
        <td style="padding: 11px 12px; font-weight: 800; color: #ffffff;">الضرائب والرسوم السيادية</td>
        <td style="padding: 11px 12px; color: #ffffff; font-weight: 500; line-height: 1.6;">رسوم سلطة الطيران المدني والمطار الإلزامية التي تُحصّل لصالح الدولة بحسب مطار الهبوط.</td>
      </tr>
      <tr style="background: #0f172a;">
        <td dir="ltr" style="padding: 11px 12px; color: #38bdf8; font-family: monospace; font-weight: 800; text-align: left; unicode-bidi: isolate;"><code style="background: #020617; color: #38bdf8; padding: 4px 8px; border-radius: 4px; border: 1px solid #0c4a6e;">- VolumeTierDiscount</code></td>
        <td style="padding: 11px 12px; font-weight: 800; color: #ffffff;">خصم الولاء التراكمي</td>
        <td style="padding: 11px 12px; color: #ffffff; font-weight: 500; line-height: 1.6;">حافز تجاري يُخصم تلقائياً عند تجاوز العميل عدد الرحلات الشهري المتفق عليه في شريحة العقد.</td>
      </tr>
    </tbody>
  </table>
</div>

---

### 📝 3 سيناريوهات تشغيلية واقعية من المطارات المصرية

لتوضيح كيفية تفاعل هذه المحددات في الواقع العملي:

<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(340px, 1fr)); gap: 18px; margin: 24px 0;">
  <!-- Scenario 1: Scheduled A320 in CAI -->
  <div style="background: #061f18; border: 2px solid #10b981; border-radius: 12px; overflow: hidden; box-shadow: 0 6px 20px rgba(0,0,0,0.45);">
    <div style="background: #047857; color: #ffffff; font-weight: 800; font-size: 14.5px; padding: 12px 16px; display: flex; align-items: center; gap: 8px;">
      <span>🟢 السيناريو 1: رحلة مجدولة منتظمة (مطار القاهرة CAI)</span>
    </div>
    <div style="padding: 16px 20px;">
      <ul style="color: #ffffff; font-size: 13px; line-height: 1.75; margin: 0; padding-right: 18px;">
        <li style="margin-bottom: 8px;"><strong style="color: #6ee7b7; font-weight: 800;">الناقل والعميل:</strong> مصر للطيران (MS) - شروط سداد Net-30.</li>
        <li style="margin-bottom: 8px;"><strong style="color: #6ee7b7; font-weight: 800;">الطراز:</strong> Airbus A320 (Narrow-body / MTOW 77t).</li>
        <li style="margin-bottom: 8px;"><strong style="color: #6ee7b7; font-weight: 800;">الموقف:</strong> موقف كوبري (Contact Gate TB3).</li>
        <li style="margin-bottom: 8px;"><strong style="color: #6ee7b7; font-weight: 800;">التنفيذ:</strong> مكوث 55 دقيقة (ضمن سماح 60 دقيقة).</li>
        <li><strong style="color: #6ee7b7; font-weight: 800;">النتيجة المالية:</strong> تطبيق السعر الأساسي للبدن الضيق فقط ($1,250) + رسوم الكوبري، دون أي غرامات تأخير أو حافلات، وترحيل الفاتورة لدفتر الأستاذ العام مباشرة.</li>
      </ul>
    </div>
  </div>

  <!-- Scenario 2: Charter B737 in SSH with Overtime -->
  <div style="background: #241a05; border: 2px solid #f59e0b; border-radius: 12px; overflow: hidden; box-shadow: 0 6px 20px rgba(0,0,0,0.45);">
    <div style="background: #b45309; color: #ffffff; font-weight: 800; font-size: 14.5px; padding: 12px 16px; display: flex; align-items: center; gap: 8px;">
      <span>🟡 السيناريو 2: رحلة سياحية عارضة مع تأخير (شرم الشيخ SSH)</span>
    </div>
    <div style="padding: 16px 20px;">
      <ul style="color: #ffffff; font-size: 13px; line-height: 1.75; margin: 0; padding-right: 18px;">
        <li style="margin-bottom: 8px;"><strong style="color: #fcd34d; font-weight: 800;">الناقل والعميل:</strong> فلاي دبي (FZ) عبر وكيل سياحي - سداد 100% Proforma مسبقاً.</li>
        <li style="margin-bottom: 8px;"><strong style="color: #fcd34d; font-weight: 800;">الطراز:</strong> Boeing 737-800 (MTOW 79t).</li>
        <li style="margin-bottom: 8px;"><strong style="color: #fcd34d; font-weight: 800;">الموقف:</strong> موقف نائي (Remote Stand) يستلزم سلالم وحافلتين.</li>
        <li style="margin-bottom: 8px;"><strong style="color: #fcd34d; font-weight: 800;">التنفيذ:</strong> مكوث 110 دقيقة (تجاوز حد السماح بـ 50 دقيقة) + ساعة GPU إضافية.</li>
        <li><strong style="color: #fcd34d; font-weight: 800;">النتيجة المالية:</strong> احتساب شريحتين وقت إضافي (2 × $150 = $300) + ساعة GPU ($90) لتُخصم من الضمان المودع أو تصدر بها فاتورة فورية للكابتن.</li>
      </ul>
    </div>
  </div>

  <!-- Scenario 3: Widebody Cargo B777 in HRG -->
  <div style="background: #23080e; border: 2px solid #ef4444; border-radius: 12px; overflow: hidden; box-shadow: 0 6px 20px rgba(0,0,0,0.45);">
    <div style="background: #be123c; color: #ffffff; font-weight: 800; font-size: 14.5px; padding: 12px 16px; display: flex; align-items: center; gap: 8px;">
      <span>🔴 السيناريو 3: طيران شحن عريض البدن ليلي (الغردقة HRG)</span>
    </div>
    <div style="padding: 16px 20px;">
      <ul style="color: #ffffff; font-size: 13px; line-height: 1.75; margin: 0; padding-right: 18px;">
        <li style="margin-bottom: 8px;"><strong style="color: #fda4af; font-weight: 800;">الناقل:</strong> الخطوط التركية للشحن (TK Cargo) - B777F (MTOW 347t).</li>
        <li style="margin-bottom: 8px;"><strong style="color: #fda4af; font-weight: 800;">التصنيف:</strong> Cargo / Freighter - لا يوجد ركاب، إلغاء السلالم والحافلات.</li>
        <li style="margin-bottom: 8px;"><strong style="color: #fda4af; font-weight: 800;">المعدات:</strong> رافعة منصات شحن سفلية (Main Deck Loader) + قاطرة سحب ثقيلة.</li>
        <li style="margin-bottom: 8px;"><strong style="color: #fda4af; font-weight: 800;">التوقيت:</strong> الوصول 02:30 فجراً (تطبيق بدل التشغيل الليلي +20%).</li>
        <li><strong style="color: #fda4af; font-weight: 800;">النتيجة المالية:</strong> تطبيق أعلى شريحة MTOW للشحن ($3,800) + إضافة 20% بدل ليلي ($760) + تزويد 40 طن وقود مع عمولة إدارة 5% محمية.</li>
      </ul>
    </div>
  </div>
</div>

---

## 🗄️ 6. البنية العلائقية وقواعد البيانات (3NF Database Architecture)

لكي يعالج النظام هذه المحددات دون تعارض أو تكرار بيانات، يتم توزيعها على جداول مطبعة وفق معايير **المستوى الطبيعي الثالث (3NF)** مع تفكيك القوائم النصية إلى جداول ربط متعددة (N:M Junctions)، وتطبيق قيود التكامل المرجعي وحائط صد الهامش السالب:

### 🗺️ مخطط الكيانات والعلاقات البينية الشامل (Entity Relationship Diagram - ERD)

يوضح المخطط العلائقي التالي شبكة الجداول المترابطة، وحقول المفاتيح الأساسية (PK) والمفاتيح الأجنبية (FK)، ودرجات الترابط (Cardinality: 1:N, N:M, 1:1) عبر النطاقات الخمسة الحاكمة للعقد والتشغيل والفوترة:

<div class="erd-landscape-page" style="margin: 0 auto; text-align: center; page-break-inside: avoid; break-inside: avoid;">
  <a href="./images/contract_factors_erd.svg" target="_blank">
    <img src="./images/contract_factors_erd.png" alt="مخطط العلاقات الكيانية لمحددات إنشاء العقود والفوترة (TAS Relational ERD)" style="width: 100%; height: auto; max-height: 154mm; object-fit: contain; border-radius: 10px; border: 1.5px solid #0284c7; box-shadow: 0 10px 30px rgba(0,0,0,0.5);" />
  </a>
  <div style="display: flex; justify-content: center; gap: 16px; margin-top: 8px; font-size: 11px; font-weight: 700;">
    <a href="./images/contract_factors_erd.svg" target="_blank" style="color: #0284c7; text-decoration: none; background: #e0f2fe; padding: 4px 12px; border-radius: 6px; border: 1px solid #38bdf8;">🔍 فتح المخطط الفيكتور عالي الدقة (Vector SVG) للتكبير بدون حدود ↗</a>
    <a href="./images/contract_factors_erd.png" target="_blank" style="color: #065f46; text-decoration: none; background: #d1fae5; padding: 4px 12px; border-radius: 6px; border: 1px solid #34d399;">🖼️ فتح صورة المخطط فائقة الدقة (Ultra-HD 3400px PNG) ↗</a>
  </div>
</div>

<div style="background: #0f172a; border: 1.5px solid #10b981; border-radius: 14px; overflow: hidden; margin: 24px 0; box-shadow: 0 10px 30px rgba(0,0,0,0.5);">
<div style="background: linear-gradient(135deg, rgba(6, 78, 59, 0.8), #0f172a); padding: 14px 20px; border-bottom: 1.5px solid #10b981; display: flex; align-items: center; justify-content: space-between;">
<span style="color: #ffffff; font-weight: 800; font-size: 15px;">📐 مصفوفة جداول قاعدة البيانات وحقول الربط المفتاحية (Relational DDL &amp; Schema Mapping)</span>
<span style="font-size: 11px; background: #064e3b; color: #a7f3d0; padding: 4px 10px; border-radius: 6px; font-weight: 800; border: 1px solid #10b981;">3NF NORMALIZED</span>
</div>
<div style="overflow-x: auto;">
<table class="matrix-table-dark" style="width: 100%; border-collapse: collapse; text-align: right; font-size: 12.5px;">
<thead>
<tr style="border-bottom: 2px solid #334155; background: #1e293b; color: #34d399;">
<th style="padding: 12px 14px; font-weight: 800; color: #ffffff;">اسم الجدول (Table Name)</th>
<th style="padding: 12px 14px; font-weight: 800; color: #38bdf8;">نوع الكيان</th>
<th style="padding: 12px 14px; font-weight: 800; color: #fde047;">المفتاح الأساسي (PK)</th>
<th style="padding: 12px 14px; font-weight: 800; color: #ffffff;">المفاتيح الأجنبية والربط (FK References)</th>
<th style="padding: 12px 14px; font-weight: 800; text-align: center; color: #38bdf8;">العلاقة</th>
<th style="padding: 12px 14px; font-weight: 800; color: #ffffff;">قيد التكامل والأثر الرقابي</th>
</tr>
</thead>
<tbody>
<tr style="border-bottom: 1px solid #334155; background: #0f172a;">
<td style="padding: 12px 14px; font-weight: 800; color: #ffffff;"><code>dbo.Com_Contracts</code></td>
<td style="padding: 12px 14px; color: #38bdf8; font-weight: 700;">رأس العقد (Master Hub)</td>
<td style="padding: 12px 14px; color: #fde047; font-family: monospace; font-weight: 800;">ContractID</td>
<td style="padding: 12px 14px; color: #ffffff;"><code style="background: #1e293b; color: #38bdf8; padding: 3px 6px; border-radius: 4px; font-weight: 700;">CustomerID ➔ AR_Customers</code></td>
<td style="padding: 12px 14px; text-align: center; color: #38bdf8; font-weight: 800;">1 : N</td>
<td style="padding: 12px 14px; color: #a7f3d0; font-weight: 700;">حظر حذف العميل المرتبط بعقد نشط (RESTRICT)</td>
</tr>
<tr style="border-bottom: 1px solid #334155; background: #17223b;">
<td style="padding: 12px 14px; font-weight: 800; color: #ffffff;"><code>dbo.Com_ContractAirports</code></td>
<td style="padding: 12px 14px; color: #34d399; font-weight: 700;">جدول ربط المطارات</td>
<td style="padding: 12px 14px; color: #fde047; font-family: monospace; font-weight: 800;">(ContractID, AirportID)</td>
<td style="padding: 12px 14px; color: #ffffff;"><code style="background: #1e293b; color: #38bdf8; padding: 3px 6px; border-radius: 4px; font-weight: 700;">AirportID ➔ Opr_Airports</code></td>
<td style="padding: 12px 14px; text-align: center; color: #38bdf8; font-weight: 800;">N : M</td>
<td style="padding: 12px 14px; color: #ffffff; font-weight: 600;">حذف تابع تلقائي مع العقد (CASCADE)</td>
</tr>
<tr style="border-bottom: 1px solid #334155; background: #0f172a;">
<td style="padding: 12px 14px; font-weight: 800; color: #ffffff;"><code>dbo.Com_ContractAirlines</code></td>
<td style="padding: 12px 14px; color: #a5b4fc; font-weight: 700;">جدول ربط شركات الطيران</td>
<td style="padding: 12px 14px; color: #fde047; font-family: monospace; font-weight: 800;">(ContractID, AirlineID)</td>
<td style="padding: 12px 14px; color: #ffffff;"><code style="background: #1e293b; color: #38bdf8; padding: 3px 6px; border-radius: 4px; font-weight: 700;">AirlineID ➔ Opr_Airlines</code></td>
<td style="padding: 12px 14px; text-align: center; color: #38bdf8; font-weight: 800;">N : M</td>
<td style="padding: 12px 14px; color: #ffffff; font-weight: 600;">حذف تابع تلقائي مع العقد (CASCADE)</td>
</tr>
<tr style="border-bottom: 1px solid #334155; background: #17223b;">
<td style="padding: 12px 14px; font-weight: 800; color: #ffffff;"><code>dbo.Com_ContractServices</code></td>
<td style="padding: 12px 14px; color: #fbbf24; font-weight: 700;">تعرفة الخدمات والبدلات</td>
<td style="padding: 12px 14px; color: #fde047; font-family: monospace; font-weight: 800;">ContractServiceID</td>
<td style="padding: 12px 14px; color: #ffffff;"><code style="background: #1e293b; color: #38bdf8; padding: 3px 6px; border-radius: 4px; font-weight: 700;">ServiceID ➔ Com_Services</code><br/><code style="background: #1e293b; color: #38bdf8; padding: 3px 6px; border-radius: 4px; font-weight: 700;">SupplierID ➔ AP_Suppliers</code></td>
<td style="padding: 12px 14px; text-align: center; color: #38bdf8; font-weight: 800;">1 : N</td>
<td style="padding: 12px 14px; color: #a7f3d0; font-weight: 700;">تطبيق قاعدة حائط صد الهامش (Margin Shield)</td>
</tr>
<tr style="background: #0f172a;">
<td style="padding: 12px 14px; font-weight: 800; color: #ffffff;"><code>dbo.Opr_TurnaroundWorkOrders</code></td>
<td style="padding: 12px 14px; color: #fb7185; font-weight: 700;">نقطة الالتقاء والفوترة</td>
<td style="padding: 12px 14px; color: #fde047; font-family: monospace; font-weight: 800;">WorkOrderID</td>
<td style="padding: 12px 14px; color: #ffffff;"><code style="background: #1e293b; color: #38bdf8; padding: 3px 6px; border-radius: 4px; font-weight: 700;">ContractID, AirportID, AirlineID, RegistrationID</code></td>
<td style="padding: 12px 14px; text-align: center; color: #38bdf8; font-weight: 800;">1 : N</td>
<td style="padding: 12px 14px; color: #a7f3d0; font-weight: 700;">منع الفوترة أو فتح أمر تشغيل خارج غطاء العقد</td>
</tr>
</tbody>
</table>
</div>
<div style="padding: 18px; background: #0b1324; border-top: 1.5px solid #10b981;">
<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 14px;">
<div style="background: #0f172a; border: 1.5px solid #0284c7; border-radius: 8px; padding: 14px;">
<div style="font-weight: 800; color: #38bdf8; font-size: 13.5px; margin-bottom: 8px; border-bottom: 1px solid rgba(56, 189, 248, 0.3); padding-bottom: 6px;">📄 رأس العقد: <bdi><code>dbo.Com_Contracts</code></bdi></div>
<div style="font-size: 12.5px; color: #ffffff; line-height: 1.85; font-weight: 500;">
<div>• <bdi style="color: #38bdf8; font-weight: 700;"><code>ContractID (PK, bigint)</code></bdi>: المعرف التعاقدي الفريد.</div>
<div>• <bdi style="color: #38bdf8; font-weight: 700;"><code>ContractNumber (nvarchar 50)</code></bdi>: رقم الاتفاقية المرجعي.</div>
<div>• <bdi style="color: #38bdf8; font-weight: 700;"><code>VersionNumber (int)</code></bdi>: إصدار العقد (v1, v2) للتعديلات الموسمية.</div>
<div>• <bdi style="color: #38bdf8; font-weight: 700;"><code>CustomerID (FK)</code></bdi>: يربط بجدول العميل المالي <bdi><code>AR_Customers</code></bdi>.</div>
<div>• <bdi style="color: #38bdf8; font-weight: 700;"><code>EffectiveFrom / ValidTo</code></bdi>: نافذة الصلاحية الزمنية وسريان العقد.</div>
<div>• <bdi style="color: #38bdf8; font-weight: 700;"><code>CurrencyCode / PaymentTermID</code></bdi>: عملة الفوترة وشروط الائتمان.</div>
</div>
</div>
<div style="background: #0f172a; border: 1.5px solid #10b981; border-radius: 8px; padding: 14px;">
<div style="font-weight: 800; color: #34d399; font-size: 13.5px; margin-bottom: 8px; border-bottom: 1px solid rgba(52, 211, 153, 0.3); padding-bottom: 6px;">📍 ربط المطارات: <bdi><code>dbo.Com_ContractAirports</code> (N:M)</bdi></div>
<div style="font-size: 12.5px; color: #ffffff; line-height: 1.85; font-weight: 500;">
<div>• <bdi style="color: #34d399; font-weight: 700;"><code>ContractID (PK/FK)</code></bdi>: مرجع العقد وحذف تابع تلقائي <bdi>(Cascade Delete)</bdi>.</div>
<div>• <bdi style="color: #34d399; font-weight: 700;"><code>AirportID (PK/FK)</code></bdi>: مرجع المطار المصرح به <bdi>(CAI, HRG, SSH...)</bdi>.</div>
<div>• <bdi style="color: #34d399; font-weight: 700;"><code>IsPrimaryStation (bit)</code></bdi>: المحطة الرئيسية لعمليات الناقل بالمطار.</div>
<div>• <bdi style="color: #34d399; font-weight: 700;"><code>StationConcessionFee (decimal)</code></bdi>: رسوم امتياز سلطة المطار.</div>
</div>
</div>
<div style="background: #0f172a; border: 1.5px solid #6366f1; border-radius: 8px; padding: 14px;">
<div style="font-weight: 800; color: #a5b4fc; font-size: 13.5px; margin-bottom: 8px; border-bottom: 1px solid rgba(129, 140, 248, 0.3); padding-bottom: 6px;">✈️ ربط شركات الطيران: <bdi><code>dbo.Com_ContractAirlines</code> (N:M)</bdi></div>
<div style="font-size: 12.5px; color: #ffffff; line-height: 1.85; font-weight: 500;">
<div>• <bdi style="color: #a5b4fc; font-weight: 700;"><code>ContractID (PK/FK)</code></bdi>: مرجع العقد وحذف تابع تلقائي <bdi>(Cascade Delete)</bdi>.</div>
<div>• <bdi style="color: #a5b4fc; font-weight: 700;"><code>AirlineID (PK/FK)</code></bdi>: مرجع خط الطيران <bdi>(MS, FZ, TK...)</bdi>.</div>
<div>• <bdi style="color: #a5b4fc; font-weight: 700;"><code>AllianceCode (nvarchar 20)</code></bdi>: تحالف الطيران المشترك <bdi>(Star Alliance, SkyTeam...)</bdi>.</div>
</div>
</div>
<div style="background: #0f172a; border: 1.5px solid #f59e0b; border-radius: 8px; padding: 14px;">
<div style="font-weight: 800; color: #fbbf24; font-size: 13.5px; margin-bottom: 8px; border-bottom: 1px solid rgba(245, 158, 11, 0.3); padding-bottom: 6px;">🧰 تعرفة الخدمات: <bdi><code>dbo.Com_ContractServices</code></bdi></div>
<div style="font-size: 12.5px; color: #ffffff; line-height: 1.85; font-weight: 500;">
<div>• <bdi style="color: #fbbf24; font-weight: 700;"><code>ContractServiceID (PK, bigint)</code></bdi>: معرف البند الفريد.</div>
<div>• <bdi style="color: #fbbf24; font-weight: 700;"><code>ServiceID (FK)</code></bdi>: يربط بفهرس خدمات المناولة <bdi>IATA SGHA</bdi>.</div>
<div>• <bdi style="color: #fbbf24; font-weight: 700;"><code>NegotiatedPrice</code></bdi>: السعر التعاقدي المتفق عليه للبند.</div>
<div>• <bdi style="color: #fbbf24; font-weight: 700;"><code>OvertimePrice</code></bdi>: سعر الساعة أو النصف ساعة الإضافية.</div>
<div>• <bdi style="color: #fbbf24; font-weight: 700;"><code>DefaultSupplierID (FK)</code></bdi>: المقاول المعتمد للخدمة.</div>
</div>
</div>
<div style="background: #0f172a; border: 1.5px solid #f43f5e; border-radius: 8px; padding: 14px; grid-column: 1 / -1;">
<div style="font-weight: 800; color: #fb7185; font-size: 13.5px; margin-bottom: 8px; border-bottom: 1px solid rgba(244, 63, 94, 0.3); padding-bottom: 6px;">🎯 نقطة الالتقاء التشغيلي والفوترة: <bdi><code>dbo.Opr_TurnaroundWorkOrders</code></bdi></div>
<div style="font-size: 13px; color: #ffffff; line-height: 1.85; font-weight: 500;">
يرتبط هذا الجدول الميداني بجميع المفاتيح لضمان التحقق الفوري: <bdi style="color: #38bdf8; font-weight: 700;"><code>ContractID</code></bdi> + <bdi style="color: #38bdf8; font-weight: 700;"><code>AirportID</code></bdi> + <bdi style="color: #38bdf8; font-weight: 700;"><code>AirlineID</code></bdi> + <bdi style="color: #38bdf8; font-weight: 700;"><code>RegistrationID (طراز الطائرة والوزن)</code></bdi> + <bdi style="color: #38bdf8; font-weight: 700;"><code>FlightTypeCode</code></bdi>. يتحكم بالمهبط ويولد الفاتورة التلقائية والمطابقة الثلاثية <bdi style="color: #4ade80; font-weight: 700;">(3-Way Matching)</bdi>.
</div>
</div>
</div>
</div>
---

## 📋 7. قائمة التحقق العملية عند إنشاء عقد جديد (Step-by-Step Contract Creation Checklist)

لضمان عدم إغفال أي محدد أو علاقة عند إدخال عقد جديد على شاشة TAS:

<div style="background: #0f172a; border: 1.5px solid #334155; border-radius: 12px; padding: 22px; margin: 24px 0; box-shadow: 0 6px 20px rgba(0,0,0,0.4);">
  <div style="display: flex; flex-direction: column; gap: 14px; font-size: 13.5px; color: #ffffff;">
  <div style="display: flex; align-items: center; gap: 12px;">
  <span style="background: #10b981; color: #ffffff; width: 24px; height: 24px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: 800; flex-shrink: 0;">1</span>
  <span><strong style="color: #38bdf8; font-weight: 800;">تحديد هوية العميل والناقلين:</strong> اختر العميل المالي المحاسبي، وحدد قائمة خطوط الطيران المشمولة في الاتفاقية.</span>
  </div>
  <div style="display: flex; align-items: center; gap: 12px;">
  <span style="background: #10b981; color: #ffffff; width: 24px; height: 24px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: 800; flex-shrink: 0;">2</span>
  <span><strong style="color: #38bdf8; font-weight: 800;">تحديد نطاق المحطات:</strong> علم على المطارات المعتمدة للناقل (CAI, HRG, SSH) وحدد شروط كل محطة.</span>
  </div>
  <div style="display: flex; align-items: center; gap: 12px;">
  <span style="background: #10b981; color: #ffffff; width: 24px; height: 24px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: 800; flex-shrink: 0;">3</span>
  <span><strong style="color: #38bdf8; font-weight: 800;">اعتماد مصفوفة أسطول الطائرات:</strong> ربط طرازات الطائرات المتوقعة للناقل والتأكد من أوزان MTOW وتصنيف البدن (Narrow vs Wide).</span>
  </div>
  <div style="display: flex; align-items: center; gap: 12px;">
  <span style="background: #10b981; color: #ffffff; width: 24px; height: 24px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: 800; flex-shrink: 0;">4</span>
  <span><strong style="color: #38bdf8; font-weight: 800;">ضبط سقف السماحية والوقت المجاني:</strong> حدد مدة المكوث القياسية (مثلاً 60 دقيقة للبدن الضيق) وسعر نصف ساعة الانتظار الإضافي.</span>
  </div>
  <div style="display: flex; align-items: center; gap: 12px;">
  <span style="background: #10b981; color: #ffffff; width: 24px; height: 24px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: 800; flex-shrink: 0;">5</span>
  <span><strong style="color: #38bdf8; font-weight: 800;">تحديد شروط الائتمان وسداد الـ Proforma:</strong> إذا كان الناقل يطير رحلات عارضة، فعل شرط "سداد الفاتورة المبدئية إلزامي قبل أمر العمل".</span>
  </div>
  <div style="display: flex; align-items: center; gap: 12px;">
  <span style="background: #10b981; color: #ffffff; width: 24px; height: 24px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: 800; flex-shrink: 0;">6</span>
  <span><strong style="color: #38bdf8; font-weight: 800;">تفعيل حائط صد الهامش السالب (Margin Shield):</strong> حدد نسبة عمولة المناولة لموردي الوقود والتموين (بحد أدنى 5%).</span>
  </div>
  <div style="display: flex; align-items: center; gap: 12px;">
  <span style="background: #10b981; color: #ffffff; width: 24px; height: 24px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: 800; flex-shrink: 0;">7</span>
  <span><strong style="color: #38bdf8; font-weight: 800;">اعتماد وحفظ العقد:</strong> بعد مراجعة الإدارة التجارية، يتم اعتماد العقد وتفعيله ليصبح جاهزاً لاستقبال طلبات الرحلات آلياً.</span>
  </div>
  </div>
</div>

---

*تم إعداد وتوثيق هذا الدليل المعماري كمرجع شامل لهندسة العقود وعلاقاتها في منظومة TAS Ground Handling Engine.*
