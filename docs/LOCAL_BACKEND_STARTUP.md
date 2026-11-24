# تشغيل EGY DEVELOPMENT على الموبايل من اللابتوب

## شغّل الـ backend بأمر واحد

افتح PowerShell وشغّل الأمر ده من أي فولدر. سيب النافذة مفتوحة طول الاختبار.

```powershell
& 'D:\flutter\egy-ai\egy\scripts\start_local_backend.ps1'
```

الـ script بيستخدم الـ `.venv` والملفات الموجودة، وبيطبع عنوان الـ Wi‑Fi للـ API ويشغّل FastAPI على port 8000. لازم ملف Firebase Admin يكون موجود في `C:\Users\elshaf3y\firebase-secrets\egy-firebase-admin.json`، ومفتاح `GEMINI_API_KEY` يكون متظبط في `EGY_DEVELOPMENT_ai\.env`. خليك محتفظ بالاتنين في أماكنهم، وماتحطّش المفتاح في Flutter.

لو PowerShell منع تشغيل الـ script بسبب Execution Policy، شغّله في process منفصل. ده بيطبّق الإعداد على التشغيل ده بس.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File 'D:\flutter\egy-ai\egy\scripts\start_local_backend.ps1'
```

### لو عايز تشغّله يدوي

استخدم نافذة PowerShell منفصلة واقفلها بعد الاختبار. الأمر بيستخدم Python من جوه الـ `.venv` مباشرة، فمش محتاج تعمل Activate.

```powershell
Set-Location 'D:\flutter\egy-ai\egy\EGY_DEVELOPMENT_ai'
$env:GOOGLE_APPLICATION_CREDENTIALS = 'C:\Users\elshaf3y\firebase-secrets\egy-firebase-admin.json'
$env:CHAT_ENABLED = 'true'
$env:LLM_PROVIDER = 'gemini'
& '.\.venv\Scripts\python.exe' -m uvicorn app:app --host 0.0.0.0 --port 8000
```

الـ backend بيقرأ `.env` تلقائيًا. سيب `GEMINI_MODEL` على القيمة الموجودة فيه، وهي حاليًا `gemini-3.5-flash-lite`. موديل Price Prediction بيتحمّل أول ما السيرفر يشتغل. Hybrid Recommendations بيحمّل الـ dataset والـ indexes الجاهزة عند أول طلب مصادق عليه للـ catalog أو Recommendations. أدوات الشات بتحمّل الداتا بتاعتها وقت احتياجها. ده كله بيستخدم الملفات المتدرّبة الموجودة.

## اتأكد إن السيرفر شغّال

من نافذة PowerShell تانية:

```powershell
curl.exe -fsS http://127.0.0.1:8000/api/health
curl.exe -i http://127.0.0.1:8000/api/predict/options
```

- مع الشات شغّال، المتوقع إن `model_loaded` و`llm_client_ready` يكونوا `true` و`llm_backend` يكون `GeminiClient`. `/api/health` بيأكد حالة التشغيل، ونتيجة Recommendations بتتبان مع أول طلب من التطبيق.
- الطلب التاني المفروض يرجّع `401 Unauthorized` عشان اتبعت من غير Firebase ID token. سجّل دخول من التطبيق عشان تستخدم Price Prediction وRecommendations وChat.
- أوامر الفحص دي مابتولّدش ردود Gemini. تشغيل Gemini بيعمل فحص لقائمة الموديلات، وإرسال رسالة من التطبيق ممكن يتحسب عليه تكلفة. لو عايز تختبر باقي الـ API والشات مقفول، ضيف `-DisableChat` لأمر تشغيل الـ script. ساعتها `degraded` في الـ health متوقعة طالما `model_loaded: true`.
- لو port 8000 مشغول، افحص `/api/health` الأول. لو ده سيرفر EGY وشغّال بالإعداد المطلوب، استخدمه زي ما هو. لو بيطلع `401` من التطبيق رغم تسجيل الدخول، اتأكد إن ساعة Windows مظبوطة واعمل **Sync now** لو فيه فرق.
- لو عايز تراجع Python وملف Firebase والملفات المطلوبة من غير ما تبدأ سيرفر جديد، ضيف `-CheckOnly` لأمر تشغيل الـ script.

## وصّل الموبايل

1. وصّل الموبايل واللابتوب بشبكة موثوق فيها تسمح للأجهزة تكلم بعض. شبكة Guest ممكن تعزل الموبايل عن اللابتوب حتى لو الاتنين على نفس الـ Wi‑Fi.
2. خُد عنوان اللابتوب من `Wi-Fi API URL` اللي الـ script طبعه. لو محتاج تراجعه، شغّل `ipconfig` واختار `IPv4 Address` تحت كارت الـ Wi‑Fi اللي بتستخدمه.
3. افتح من **متصفح الموبايل** `http://192.168.1.8:8000/api/health` بعد ما تبدّل الـ IP بعنوان اللابتوب الحالي. لو ظهر JSON، افتح EGY وسجّل دخول.

الـ APK اللي اتعمل قبل كده فيه `API_BASE_URL=http://192.168.1.8:8000` و`ENABLE_LIVE_CHAT=true`. الاتنين بيتحددوا وقت الـ build. لو نفس الـ IP لسه موجود، افتح التطبيق المثبّت عادي. لو الـ IP اتغيّر، وصّل الموبايل بـ USB، فعّل USB debugging، ووافق على طلب السماح. بعد كده شغّل:

```powershell
Set-Location 'D:\flutter\egy-ai\egy'
flutter devices
$wifiIp = Read-Host 'Laptop Wi-Fi IPv4'
$androidId = Read-Host 'Android device ID from flutter devices'
flutter run --debug -d $androidId "--dart-define=API_BASE_URL=http://${wifiIp}:8000" --dart-define=ENABLE_LIVE_CHAT=true
```

`flutter run` بيبني نسخة debug ويثبّتها. لو الـ package والـ signing key نفس النسخة الموجودة، التثبيت بيعمل update ويحافظ على بيانات التطبيق. عشان العنوان يفضل ثابت على شبكتك، اعمل **DHCP reservation** للابتوب في الراوتر لو متاح.

## لو الموبايل مش قادر يوصل

لو `/api/health` شغّال من اللابتوب بس بيفشل من الموبايل، راجع الـ IP والشبكة الأول. لو محتاج Firewall rule على الـ Public profile زي الاختبار السابق، افتح PowerShell **كـ Administrator**. اكتب عنوان اللابتوب وعنوان الموبايل من تفاصيل الاتصال بالـ Wi‑Fi. غيّر `Wi-Fi` لو اسم الـ interface مختلف، وراجع إن `NetworkCategory` هي `Public` قبل إضافة القاعدة.

```powershell
Get-NetConnectionProfile -InterfaceAlias 'Wi-Fi'
$laptopIp = Read-Host 'Laptop Wi-Fi IPv4'
$phoneIp = Read-Host 'Phone Wi-Fi IPv4'
$rule = 'EGY-Local-Backend-Temporary'
foreach ($ip in @($laptopIp, $phoneIp)) {
    if ($ip -notmatch '^(10\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.)' -or
        $ip -notmatch '^\d{1,3}(\.\d{1,3}){3}$' -or -not [ipaddress]::TryParse($ip, [ref]$null)) {
        throw 'Enter one private IPv4 address for each device.'
    }
}
New-NetFirewallRule -Name $rule -DisplayName $rule -Direction Inbound -Action Allow `
    -Protocol TCP -LocalPort 8000 -LocalAddress $laptopIp -RemoteAddress $phoneIp `
    -InterfaceAlias 'Wi-Fi' -Profile Public
```

جرّب `/api/health` من الموبايل تاني. بعد الاختبار امسح القاعدة من نافذة الـ Administrator. استخدم الاتصال ده على شبكة موثوق فيها عشان الـ debug APK بيستخدم HTTP.

```powershell
Remove-NetFirewallRule -Name 'EGY-Local-Backend-Temporary'
```

اقرأ تفاصيل نطاق القاعدة في [Microsoft Learn](https://learn.microsoft.com/en-us/powershell/module/netsecurity/new-netfirewallrule).

## وقّف السيرفر

اضغط **Ctrl+C** في نافذة الـ backend، واستنى رسالة `Application shutdown complete`. بعد كده امسح الـ Firewall rule لو كنت أضفتها.
