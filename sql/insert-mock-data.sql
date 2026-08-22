-- ==============================================================================
-- سكريبت إضافة بيانات تجريبية شاملة وواقعية (Mock Data) لتطبيق ورشاتك (Warsha-360)
-- بيئة الـ Staging فقط
-- ==============================================================================

DO $$
DECLARE
    -- معرف المستخدم (يمكنك تغييره إلى الـ Firebase UID الخاص بك إذا أردت)
    v_user_id TEXT := 'staging_demo_user';
    
    -- معرفات الكيانات المنشأة
    v_kablan_id UUID;
    v_proj_amal UUID;
    v_proj_yasmeen UUID;
    v_proj_narjis UUID;
    
    v_w_ahmad UUID;
    v_w_khaled UUID;
    v_w_mahmoud UUID;
    v_w_samir UUID;
    v_w_yousef UUID;
    
    v_foreman_abu_fadi UUID;
    v_foreman_abu_omar UUID;
    
    v_sub_electric UUID;
    v_sub_plumb UUID;
    v_sub_gypsum UUID;
    
    v_acc_partners UUID;
    v_acc_petty_cash UUID;
BEGIN
    -- إذا كان هناك مستخدم سابق مسجل في قاعدة البيانات، سنربط المقاول بحسابه تلقائياً
    SELECT user_id INTO v_user_id FROM kablans LIMIT 1;
    IF v_user_id IS NULL THEN
        SELECT user_id INTO v_user_id FROM user_roles LIMIT 1;
    END IF;
    IF v_user_id IS NULL THEN
        v_user_id := 'test_owner_uid';
    END IF;

    RAISE NOTICE '👉 يتم الآن ربط البيانات بالمستخدم صاحب المعرف: %', v_user_id;

    -- 1. إنشاء المقاول التجريبي (Kablan)
    INSERT INTO kablans (name, description, user_id)
    VALUES (
        'شركة الأفق الحديثة للمقاولات (بيانات تجريبية)',
        'حساب تجريبي لاختبار كافة وظائف وتقارير النظام في بيئة الـ Staging',
        v_user_id
    ) RETURNING id INTO v_kablan_id;

    -- إضافة دور المالك في user_roles
    INSERT INTO user_roles (kablan_id, user_id, role, permissions, invited_by, status)
    VALUES (
        v_kablan_id,
        v_user_id,
        'owner',
        '{"workers": {"create": true, "read": true, "update": true, "delete": true, "export": true}, "projects": {"create": true, "read": true, "update": true, "delete": true, "export": true}, "daily_records": {"create": true, "read": true, "update": true, "delete": true, "export": true}, "foremen": {"create": true, "read": true, "update": true, "delete": true, "export": true}, "subcontractors": {"create": true, "read": true, "update": true, "delete": true, "export": true}, "payments": {"create": true, "read": true, "update": true, "delete": true, "export": true}, "personal_accounts": {"create": true, "read": true, "update": true, "delete": true, "export": true}, "cheques": {"create": true, "read": true, "update": true, "delete": true, "export": true}, "reports": {"create": true, "read": true, "update": true, "delete": true, "export": true}, "settings": {"manage_users": true, "manage_permissions": true}}'::jsonb,
        v_user_id,
        'active'
    );

    -- 2. إنشاء المشاريع (Projects)
    INSERT INTO projects (kablan_id, name, location, start_date, type, status, notes)
    VALUES (v_kablan_id, 'مشروع برج الأمل التجاري', 'رام الله - الماصيون', '2026-01-01', 'مبنى تجاري مكاتب', 'active', 'تشطيب وتسليم مرحلة العظم')
    RETURNING id INTO v_proj_amal;

    INSERT INTO projects (kablan_id, name, location, start_date, type, status, notes)
    VALUES (v_kablan_id, 'مشروع مجمع الياسمين السكني', 'نابلس - رفيديا', '2026-02-15', 'إسكان سكني 8 طوابق', 'active', 'أعمال القواطع والكهرباء')
    RETURNING id INTO v_proj_yasmeen;

    INSERT INTO projects (kablan_id, name, location, start_date, type, status, notes)
    VALUES (v_kablan_id, 'مشروع فيلا النرجس', 'بيت لحم - بيت جالا', '2025-11-01', 'فيلا خاصة مودرن', 'paused', 'بانتظار وصول توريد الحجر')
    RETURNING id INTO v_proj_narjis;

    -- 3. إنشاء المراقبين (Foremen / المعاليم)
    INSERT INTO foremen (kablan_id, name, phone, status, notes)
    VALUES (v_kablan_id, 'المعلم أبو فادي التكروري', '0599112233', 'active', 'مسؤول ورشة برج الأمل')
    RETURNING id INTO v_foreman_abu_fadi;

    INSERT INTO foremen (kablan_id, name, phone, status, notes)
    VALUES (v_kablan_id, 'المعلم أبو عمر النتشة', '0599445566', 'active', 'مسؤول ورشة مجمع الياسمين')
    RETURNING id INTO v_foreman_abu_omar;

    -- 4. إنشاء مقاولي الباطن (Subcontractors)
    INSERT INTO subcontractors (kablan_id, name, specialty, phone, status)
    VALUES (v_kablan_id, 'شركة الفارس للتمديدات الكهربائية', 'كهرباء وإنارة', '0598776655', 'active')
    RETURNING id INTO v_sub_electric;

    INSERT INTO subcontractors (kablan_id, name, specialty, phone, status)
    VALUES (v_kablan_id, 'مؤسسة الشلال للأعمال الصحية والصرف', 'سباكة وتدفئة', '0598112233', 'active')
    RETURNING id INTO v_sub_plumb;

    INSERT INTO subcontractors (kablan_id, name, specialty, phone, status)
    VALUES (v_kablan_id, 'ورشة النخبة للجبص والديكور', 'ديكورات وجبصين', '0598998877', 'active')
    RETURNING id INTO v_sub_gypsum;

    -- 5. إنشاء العمال (Workers) بأنماط رواتب مختلفة
    -- عامل يومية بنظام إضافي آلي
    INSERT INTO workers (
        kablan_id, name, surname, operating_number, role, phone, status, 
        payment_type, daily_rate, monthly_salary, hourly_rate, 
        overtime_system, division_factor, overtime_rate, default_project_id
    ) VALUES (
        v_kablan_id, 'أحمد', 'السعيد', 'WRK-101', 'معلم طوبار وبناء', '0597111222', 'active',
        'daily', 220.00, 0, 0,
        'automatic', 8.00, 0, v_proj_amal
    ) RETURNING id INTO v_w_ahmad;

    -- عامل يومية بنظام إضافي يدوي
    INSERT INTO workers (
        kablan_id, name, surname, operating_number, role, phone, status, 
        payment_type, daily_rate, monthly_salary, hourly_rate, 
        overtime_system, division_factor, overtime_rate, default_project_id
    ) VALUES (
        v_kablan_id, 'خالد', 'عبد الرحمن', 'WRK-102', 'مساعد بنا وتشطيب', '0597222333', 'active',
        'daily', 150.00, 0, 0,
        'manual', 0, 25.00, v_proj_amal
    ) RETURNING id INTO v_w_khaled;

    -- عامل راتب شهري
    INSERT INTO workers (
        kablan_id, name, surname, operating_number, role, phone, status, 
        payment_type, daily_rate, monthly_salary, hourly_rate, 
        overtime_system, division_factor, overtime_rate, default_project_id
    ) VALUES (
        v_kablan_id, 'محمود', 'الشناوي', 'WRK-103', 'مهندس موقع ومساح', '0597333444', 'active',
        'monthly', 0, 4800.00, 0,
        'automatic', 8.00, 0, v_proj_yasmeen
    ) RETURNING id INTO v_w_mahmoud;

    -- عامل بالساعة
    INSERT INTO workers (
        kablan_id, name, surname, operating_number, role, phone, status, 
        payment_type, daily_rate, monthly_salary, hourly_rate, 
        overtime_system, division_factor, overtime_rate, default_project_id
    ) VALUES (
        v_kablan_id, 'سمير', 'الجوهري', 'WRK-104', 'سائق باجر وآليات', '0597444555', 'active',
        'hourly', 0, 0, 35.00,
        'manual', 0, 40.00, v_proj_amal
    ) RETURNING id INTO v_w_samir;

    -- عامل يومية آخر
    INSERT INTO workers (
        kablan_id, name, surname, operating_number, role, phone, status, 
        payment_type, daily_rate, monthly_salary, hourly_rate, 
        overtime_system, division_factor, overtime_rate, default_project_id
    ) VALUES (
        v_kablan_id, 'يوسف', 'البياع', 'WRK-105', 'عامل باطون ونظافة', '0597555666', 'active',
        'daily', 130.00, 0, 0,
        'automatic', 8.00, 0, v_proj_yasmeen
    ) RETURNING id INTO v_w_yousef;

    -- 6. تسجيل سجلات اليوميات (Daily Records)
    INSERT INTO daily_records (kablan_id, worker_id, project_id, date, status, work_day, overtime_hours, advance, smoking, expense, notes)
    VALUES
        (v_kablan_id, v_w_ahmad, v_proj_amal, '2026-08-15', 'present', 1.00, 2.0, 50.00, 15.00, 0, 'صب سقف الطابق الثاني'),
        (v_kablan_id, v_w_ahmad, v_proj_amal, '2026-08-16', 'present', 1.00, 1.5, 0, 0, 0, 'فك طوبار الأعمدة'),
        (v_kablan_id, v_w_ahmad, v_proj_amal, '2026-08-17', 'present', 1.00, 0, 100.00, 20.00, 0, 'سلفة أسبوعية'),
        (v_kablan_id, v_w_ahmad, v_proj_amal, '2026-08-18', 'paid-leave', 1.00, 0, 0, 0, 0, 'إجازة رسمية مدفوعة'),
        (v_kablan_id, v_w_ahmad, v_proj_amal, '2026-08-19', 'present', 1.00, 3.0, 0, 0, 0, 'عمل إضافي لصب الأعمدة'),

        (v_kablan_id, v_w_khaled, v_proj_amal, '2026-08-15', 'present', 1.00, 2.0, 30.00, 0, 0, 'مساعدة المعلم أحمد'),
        (v_kablan_id, v_w_khaled, v_proj_amal, '2026-08-16', 'present', 1.00, 0, 0, 10.00, 0, ''),
        (v_kablan_id, v_w_khaled, v_proj_amal, '2026-08-17', 'absent', 0, 0, 0, 0, 0, 'غياب بدون إذن'),
        (v_kablan_id, v_w_khaled, v_proj_amal, '2026-08-18', 'present', 0.50, 0, 20.00, 0, 0, 'نصف يوم عمل'),

        (v_kablan_id, v_w_mahmoud, v_proj_yasmeen, '2026-08-15', 'present', 1.00, 0, 0, 0, 45.00, 'شراء أدوات قياس للموقع'),
        (v_kablan_id, v_w_mahmoud, v_proj_yasmeen, '2026-08-16', 'present', 1.00, 2.0, 0, 0, 0, 'استلام حديد التسليح'),
        (v_kablan_id, v_w_mahmoud, v_proj_yasmeen, '2026-08-17', 'present', 1.00, 0, 200.00, 0, 0, 'سلفة على الراتب'),

        (v_kablan_id, v_w_samir, v_proj_amal, '2026-08-15', 'present', 1.00, 4.0, 0, 0, 150.00, 'تعبئة ديزل للباقر'),
        (v_kablan_id, v_w_samir, v_proj_amal, '2026-08-16', 'present', 1.00, 3.0, 50.00, 0, 0, 'حفر أساسات المدخل'),

        (v_kablan_id, v_w_yousef, v_proj_yasmeen, '2026-08-15', 'present', 1.00, 1.0, 20.00, 10.00, 0, 'نقل طوب وباطون'),
        (v_kablan_id, v_w_yousef, v_proj_yasmeen, '2026-08-16', 'present', 1.00, 0, 0, 0, 0, 'تنظيف الموقع');

    -- 7. مصاريف وسلف المراقبين (Foreman Expenses)
    INSERT INTO foreman_expenses (kablan_id, foreman_id, project_id, date, type, amount, description)
    VALUES
        (v_kablan_id, v_foreman_abu_fadi, v_proj_amal, '2026-08-10', 'advance', 1500.00, 'عهدة نقدية أولية لمصاريف الورشة'),
        (v_kablan_id, v_foreman_abu_fadi, v_proj_amal, '2026-08-12', 'expense', 350.00, 'شراء خشب مرابيع ومسامير من منجرة السلام'),
        (v_kablan_id, v_foreman_abu_fadi, v_proj_amal, '2026-08-14', 'expense', 180.00, 'ضيافة مهندسي البلدية وفحص الباطون'),
        (v_kablan_id, v_foreman_abu_omar, v_proj_yasmeen, '2026-08-11', 'advance', 2000.00, 'عهدة تشغيل ورشة الياسمين'),
        (v_kablan_id, v_foreman_abu_omar, v_proj_yasmeen, '2026-08-15', 'expense', 420.00, 'تأجير ونش رفع مواد للبناء');

    -- 8. معاملات وفواتير مقاولي الباطن (Subcontractor Transactions)
    INSERT INTO subcontractor_transactions (kablan_id, subcontractor_id, project_id, foreman_id, date, type, amount, description)
    VALUES
        (v_kablan_id, v_sub_electric, v_proj_amal, v_foreman_abu_fadi, '2026-08-01', 'invoice', 12000.00, 'فاتورة إنجاز تمديد مواسير الطابق الأرضي والأول'),
        (v_kablan_id, v_sub_electric, v_proj_amal, v_foreman_abu_fadi, '2026-08-08', 'payment', 5000.00, 'دفعة نقدية تحت الحساب'),
        (v_kablan_id, v_sub_plumb, v_proj_amal, v_foreman_abu_fadi, '2026-08-05', 'invoice', 8500.00, 'فاتورة تأسيس خطوط المجاري والتغذية'),
        (v_kablan_id, v_sub_plumb, v_proj_amal, v_foreman_abu_fadi, '2026-08-12', 'payment', 3500.00, 'دفعة شيك مصرفي رقم 8812'),
        (v_kablan_id, v_sub_gypsum, v_proj_yasmeen, v_foreman_abu_omar, '2026-08-10', 'invoice', 6200.00, 'توريد ألواح جبصين مقاوم للرطوبة');

    -- 9. الحسابات الشخصية والمعاملات (Personal Accounts)
    INSERT INTO personal_accounts (kablan_id, name, parties, description, creation_date)
    VALUES (
        v_kablan_id,
        'حساب الشركاء (أبو فادي & أبو إبراهيم)',
        ARRAY['أبو فادي', 'أبو إبراهيم'],
        'حساب جاري لتسوية المصاريف والأرباح بين الشركاء',
        '2026-01-01'
    ) RETURNING id INTO v_acc_partners;

    INSERT INTO personal_accounts (kablan_id, name, parties, description, creation_date)
    VALUES (
        v_kablan_id,
        'صندوق الطوارئ والمصروفات النثرية',
        ARRAY['المدير العام', 'المحاسب'],
        'سجل النثريات والمصاريف الإدارية السريعة',
        '2026-02-01'
    ) RETURNING id INTO v_acc_petty_cash;

    -- معاملات الحسابات الشخصية
    INSERT INTO personal_account_transactions (
        kablan_id, account_id, date, description, amount, currency, 
        payer, payee, payment_method, transaction_type
    ) VALUES
        (v_kablan_id, v_acc_partners, '2026-08-01', 'تمويل دفعة مواد بناء بالعملة المحلية', 25000.00, 'ILS', 'أبو فادي', 'شركة مواد البناء الحديثة', 'cheque', 'standard'),
        (v_kablan_id, v_acc_partners, '2026-08-05', 'شراء معدات بالدينار الأردني', 3500.00, 'JOD', 'أبو إبراهيم', 'مؤسسة الاستيراد الهندسية', 'cash', 'standard'),
        (v_kablan_id, v_acc_petty_cash, '2026-08-10', 'سداد رسوم تراخيص بلدية واشتراك مياه', 1200.00, 'ILS', 'المحاسب', 'بلدية رام الله', 'cash', 'standard');

    -- 10. سجل الشيكات (Cheques)
    INSERT INTO cheques (
        kablan_id, type, issue_date, due_date, amount, cheque_number, 
        currency, bank, status, payee, notes
    ) VALUES
        (v_kablan_id, 'outgoing', '2026-08-01', '2026-09-15', 18500.00, 'CHK-450912', 'ILS', 'بنك فلسطين - فرع الماصيون', 'pending', 'شركة باطون القدس الجاهز', 'شيك مؤجل دفعة باطون صبة السقف'),
        (v_kablan_id, 'outgoing', '2026-07-20', '2026-08-10', 8000.00, 'CHK-450913', 'ILS', 'بنك القدس - فرع الإرسال', 'cashed', 'شركة الفارس للتمديدات الكهربائية', 'دفعة مقاول كهرباء مجمع الياسمين'),
        (v_kablan_id, 'incoming', '2026-08-05', '2026-08-25', 45000.00, 'CHK-902144', 'ILS', 'البنك العربي - فرع البلد', 'pending', 'مالك مشروع برج الأمل (السيد طارق)', 'دفعة مستخلص المرحلة الثانية'),
        (v_kablan_id, 'incoming', '2026-07-15', '2026-08-01', 3000.00, 'CHK-118902', 'JOD', 'البنك الإسلامي العربي', 'cashed', 'السيد رائد (دفعة فيلا النرجس)', 'دفعة حجر وديكورات');

    RAISE NOTICE '✅ تم بنجاح إنشاء كافة البيانات التجريبية للمقاول: % (ID: %)', 'شركة الأفق الحديثة للمقاولات', v_kablan_id;
END $$;
