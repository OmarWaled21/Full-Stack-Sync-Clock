#include <WiFi.h>
#include <HTTPClient.h>
#include <Preferences.h>
#include <LiquidCrystal_I2C.h>
#include <Wire.h>
#include <RTClib.h>
#include <ArduinoJson.h>

Preferences preferences;
LiquidCrystal_I2C lcd(0x27, 16, 4);
RTC_DS3231 rtc;

// ✏️ أدخل القيم لأول مرة هنا فقط:
const char* input_ssid = "Mohsen";
const char* input_password = "wsos1234";
const char* input_token = "ef5a859df1d6131e468155a1081010ebeba9d108";

String global_token = "";
String global_device_id = "";
unsigned long lastSendTime = 0;
const unsigned long interval = 30000;        // 30 ثواني
unsigned long lastTimeDisplayed = 0;         // الوقت الذي تم فيه عرض الحالة آخر مرة
const unsigned long displayDuration = 3000;  // مدة العرض 3 ثوانٍ
unsigned long lastTimeUpdate = 0;
const unsigned long timeUpdateInterval = 10000;  // تحديث الوقت من السيرفر كل دقيقة

String statusMessage = "";
float lastTemperature = 0.0;
int lastWifiStrength = 0;

String deviceName = "";
float battery_threshold = 20.0;
float temperature_min_threshold = 20.0;
float temperature_max_threshold = 40.0;
int rtc_update_counter = 0;

void setup() {
  Serial.begin(115200);
  delay(1000);

  // 🧠 حفظ القيم في Preferences إذا لم تكن موجودة
  preferences.begin("wifi-creds", false);

  if (!preferences.isKey("ssid")) {
    preferences.putString("ssid", input_ssid);
    preferences.putString("password", input_password);
    preferences.putString("token", input_token);
    Serial.println("✅ تم حفظ بيانات WiFi وToken لأول مرة.");
  }

  // 📥 قراءة القيم من Preferences
  String ssid = preferences.getString("ssid");
  String password = preferences.getString("password");
  String token = preferences.getString("token");
  preferences.end();


  // 🌐 الاتصال بالواي فاي
  Serial.println("🔌 جاري الاتصال بشبكة WiFi...");
  WiFi.begin(ssid.c_str(), password.c_str());

  lcd.init();       // تهيئة الشاشة
  lcd.backlight();  // تشغيل الإضاءة الخلفية
  lcd.setCursor(0, 0);
  lcd.print("Connecting WiFi");

  delay(100);

  Wire.begin();
  if (!rtc.begin()) {
    Serial.println("❌ RTC غير متصل!");
    while (1)
      ;
  }

  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.print(".");
  }

  Serial.println("\n✅ تم الاتصال!");
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Connected to");
  lcd.setCursor(0, 1);
  lcd.print(ssid);
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());

  String device_id = WiFi.macAddress();

  // إرسال البيانات إلى السيرفر
  sendDeviceDataToServer(device_id, token);

  global_token = token;  // تخزين التوكين للاستخدام في loop
  global_device_id = device_id;

  // الحصول على الوقت الأولي من السيرفر
  updateTimeFromServer();
}

void loop() {
  // تحديث الوقت من السيرفر كل فترة محددة
  if (millis() - lastTimeUpdate >= timeUpdateInterval) {
    lastTimeUpdate = millis();
    updateTimeFromServer();
  }

  // عرض الوقت الحالي من RTC
  displayCurrentTime();

  if (millis() - lastSendTime >= interval) {
    lastSendTime = millis();
    displayTemperatureAndWifi();
    sendData(global_device_id, global_token);
  }

  // عرض رسالة الحالة إن وجدت ولم تمر 3 ثوانٍ
  if (statusMessage != "") {
    if (millis() - lastTimeDisplayed < displayDuration) {
      lcd.setCursor(0, 3);
      lcd.print(statusMessage + String("                ").substring(statusMessage.length()));
    } else {
      lcd.setCursor(0, 3);
      lcd.print("                ");  // مسح السطر
      statusMessage = "";             // إفراغ الرسالة
    }
  }
}

// ✅ التحقق من وجود الجهاز في السيرفر
bool checkDeviceExists(const String& device_id, const String& token) {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    String serverUrl = "http://192.168.1.3:8000/api/device/" + device_id + "/";
    http.begin(serverUrl);
    http.addHeader("Authorization", "Token " + token);
    http.addHeader("Content-Type", "application/json");

    int httpResponseCode = http.GET();

    if (httpResponseCode == 200) {
      Serial.println("📡 الجهاز موجود في قاعدة البيانات");

      String payload = http.getString();

      // تحليل JSON
      const size_t capacity = 1024;
      DynamicJsonDocument doc(capacity);
      DeserializationError error = deserializeJson(doc, payload);
      if (error) {
        Serial.print("❌ خطأ في JSON: ");
        Serial.println(error.c_str());
        http.end();
        return false;
      }

      // استخراج البيانات من الـ results
      JsonObject results = doc["results"];

      deviceName = results["name"].as<String>();
      
      if (results.containsKey("temperature_min_threshold") && results.containsKey("temperature_max_threshold")) {
        float temperature_min_threshold = results["temperature_min_threshold"].as<float>();
        float temperature_max_threshold = results["temperature_max_threshold"].as<float>();

        Serial.print("اسم الجهاز: ");
        Serial.println(deviceName);
        Serial.print("🌡️ الحد الأدنى: ");
        Serial.println(temperature_min_threshold);
        Serial.print("🌡️ الحد الأقصى: ");
        Serial.println(temperature_max_threshold);
      } else {
        Serial.println("⚠️ لم يتم العثور على الحدود في البيانات");
      }

      http.end();
      return true;
    } else {
      Serial.println("❌ الجهاز غير موجود أو خطأ في التحقق");
      http.end();
      return false;
    }
  } else {
    Serial.println("📴 غير متصل بالواي فاي");
    return false;
  }
}

// 📤 إرسال بيانات الجهاز إلى السيرفر
void sendDeviceDataToServer(const String& device_id, const String& token) {
  if (checkDeviceExists(device_id, token)) {
    Serial.println("🔄 الجهاز موجود بالفعل.");
    return;
  }

  HTTPClient http;
  String serverUrl = "http://192.168.1.3:8000/api/new_device/";
  http.begin(serverUrl);
  http.addHeader("Authorization", "Token " + token);
  http.addHeader("Content-Type", "application/json");

  float temperature = random(200, 401) / 10.0;
  int wifi_strength = WiFi.RSSI();
  int battery_level = 80;
  DateTime now = rtc.now();
  unsigned long micros_part = micros() % 1000000;  // وهميًا لمطابقة التنسيق

  char timestamp[30];
  snprintf(timestamp, sizeof(timestamp), "%04d-%02d-%02d %02d:%02d:%02d.%06lu",
           now.year(), now.month(), now.day(),
           now.hour(), now.minute(), now.second(),
           micros_part);

  String last_update = String(timestamp);

  String jsonData = "{\"device_id\":\"" + device_id + "\", \"temperature\":\"" + String(temperature) + "\", \"wifi_strength\":" + String(wifi_strength) + ", \"last_update\":\"" + last_update + "\", \"battery_level\":" + String(battery_level) + "}";

  int httpResponseCode = http.POST(jsonData);

  lastTemperature = temperature;
  lastWifiStrength = wifi_strength;

  check_sensors(device_id, deviceName, lastTemperature, battery_level, token);
  if (httpResponseCode > 0) {
    Serial.println("📤 تم إرسال البيانات بنجاح");
  } else {
    Serial.println("❌ خطأ في إرسال البيانات: " + String(httpResponseCode));
  }

  http.end();
}

// بيجيب وقت السيرفر الحالي
String fetchCurrentTime(const String& token) {
  HTTPClient http;
  String serverUrl = "http://192.168.1.3:8000/api/";
  http.begin(serverUrl);

  http.addHeader("Authorization", "Token " + token);
  http.addHeader("Content-Type", "application/json");

  int httpResponseCode = http.GET();

  if (httpResponseCode == 200) {
    String payload = http.getString();

    int resultsIndex = payload.indexOf("\"results\":");
    if (resultsIndex != -1) {
      int timeIndex = payload.indexOf("\"current_time\":", resultsIndex);
      if (timeIndex != -1) {
        int startQuote = payload.indexOf("\"", timeIndex + 15);  // بعد "current_time":
        int endQuote = payload.indexOf("\"", startQuote + 1);
        if (startQuote != -1 && endQuote != -1) {
          String currentTime = payload.substring(startQuote + 1, endQuote);
          return currentTime;
        }
      }
    }

    Serial.println("⚠️ Couldn't find current_time field");
    http.end();
    return "";
  } else {
    Serial.println("❌ Error fetching current time: " + String(httpResponseCode));
    http.end();
    return "";
  }
}

// بيبعت ابديت للداتا ويحطها في السيرفر
void sendData(const String& device_id, const String& token) {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("📴 WiFi not connected");
    return;
  }
  if (!checkDeviceExists(device_id, token)) {
    Serial.println("🔄 Device not found, resetting Wi-Fi...");
    delay(1000);
    return;
  }

  HTTPClient http;
  Serial.println("device id:" + device_id);
  String serverUrl = "http://192.168.1.3:8000/api/new_device/device/" + device_id + "/update/";
  http.begin(serverUrl);
  http.addHeader("Authorization", "Token " + token);
  http.addHeader("Content-Type", "application/json");

  float temperature = random(201, 400) / 10.0;
  int wifi_strength = WiFi.RSSI();
  int battery_level = 85;
  DateTime now = rtc.now();
  unsigned long micros_part = micros() % 1000000;  // وهميًا لمطابقة التنسيق

  char timestamp[30];
  snprintf(timestamp, sizeof(timestamp), "%04d-%02d-%02d %02d:%02d:%02d.%06lu",
           now.year(), now.month(), now.day(),
           now.hour(), now.minute(), now.second(),
           micros_part);

  String last_update = String(timestamp);


  String jsonData = "{\"device_id\":\"" + device_id + "\", \"temperature\":\"" + String(temperature) + "\", \"wifi_strength\":" + String(wifi_strength) + ", \"last_update\":\"" + last_update + "\", \"battery_level\":" + String(battery_level) + "}";

  int httpResponseCode = http.sendRequest("PUT", jsonData);
  String currentTime = fetchCurrentTime(token);

  bool timeUpdated = false;
  bool timeFailed = false;

  if (httpResponseCode > 0) {
    Serial.println("📤 Periodic data sent successfully");
    Serial.println("Temperature: " + String(temperature) + " Battery Level: " + String(battery_level));

    lastTemperature = temperature;
    lastWifiStrength = wifi_strength;

    check_sensors(device_id, deviceName, lastTemperature, battery_level, token);

    if (currentTime == "") {
      Serial.println("❌ Failed to get current time");
      timeFailed = true;
    } else {
      Serial.println("🕒 Current server time: " + currentTime);
    }
  } else {
    Serial.println("❌ Error sending periodic data: " + String(httpResponseCode));
  }

  http.end();
}

void updateTimeFromServer() {
  String currentTime = fetchCurrentTime(global_token);
  if (currentTime == "") {
    Serial.println("❌ Failed to get current time");
    statusMessage = "Time Failed";
    lastTimeDisplayed = millis();
    return;
  }

  struct tm t;
  if (strptime(currentTime.c_str(), "%Y-%m-%d %H:%M:%S", &t)) {
    DateTime newTime = DateTime(t.tm_year + 1900, t.tm_mon + 1, t.tm_mday, t.tm_hour, t.tm_min, t.tm_sec);
    DateTime now = rtc.now();

    if (abs((int32_t)(newTime.unixtime() - now.unixtime())) >= 2) {
      rtc.adjust(newTime);
      Serial.println("✅ تم تحديث الوقت من السيرفر");
      statusMessage = "Time Updated";
      rtc_update_counter ++;
    } else {
      Serial.println("🕒 الوقت متزامن، لا حاجة للتحديث");
      statusMessage = "Time OK";
      rtc_update_counter = 0;
    }
    lastTimeDisplayed = millis();
  } else {
    Serial.println("❌ Failed to parse server time");
    statusMessage = "Time Failed";
    lastTimeDisplayed = millis();
  }
}

void updateRTCFromServerTime(const String& currentTime) {
  if (currentTime == "") return;

  struct tm t;
  if (strptime(currentTime.c_str(), "%Y-%m-%d %H:%M:%S", &t)) {
    DateTime newTime(t.tm_year + 1900, t.tm_mon + 1, t.tm_mday, t.tm_hour, t.tm_min, t.tm_sec);
    DateTime now = rtc.now();

    if (abs((int32_t)(newTime.unixtime() - now.unixtime())) >= 2) {  // فرق أكثر من ثانيتين
      rtc.adjust(newTime);
      Serial.println("✅ تم تحديث الوقت من السيرفر");
    } else {
      Serial.println("🕒 الوقت متزامن، لا حاجة للتحديث");
    }
  } else {
    Serial.println("❌ Failed to parse server time");
  }
}

// دالة عرض الحرارة وقوة الواي فاي
void displayTemperatureAndWifi() {
  float temperature = random(201, 400) / 10.0;
  int wifi_strength = WiFi.RSSI();

  // تحديث السطر الثالث بالحرارة وقوة الواي فاي
  lcd.setCursor(0, 2);
  char infoBuffer[17];  // 16 حرف + null
  snprintf(infoBuffer, sizeof(infoBuffer), "T:%.1fC W:%ddB", temperature, wifi_strength);
  lcd.print(infoBuffer);
}

void displayCurrentTime() {
  DateTime now = rtc.now();

  // char timeBuffer[9];  // HH:MM:SS
  // snprintf(timeBuffer, sizeof(timeBuffer), "%02d:%02d:%02d", now.hour(), now.minute(), now.second());

  // char dateBuffer[11];  // YYYY-MM-DD
  // snprintf(dateBuffer, sizeof(dateBuffer), "%02d-%02d", now.month(), now.day());

  char dateTimeBuffer[17];  // DD-MM HH:MM:SS = 14 + \0
  snprintf(dateTimeBuffer, sizeof(dateTimeBuffer), "%02d-%02d %02d:%02d:%02d",
           now.day(), now.month(), now.hour(), now.minute(), now.second());

  lcd.setCursor(0, 0);
  lcd.print("Clock Running     ");  // سطر ثابت

  lcd.setCursor(0, 1);
  lcd.print(dateTimeBuffer);
}

// Log structure
void add_device_log(const String& device_id, const String& device_name, const String& error_type, const String& message, const String& token) {
  String timestamp = rtc.now().timestamp(DateTime::TIMESTAMP_FULL); // Get timestamp from RTC
  String log = "{";
  log += "\"device_id\": \"" + device_id + "\",";
  log += "\"device_name\": \"" + device_name + "\",";
  log += "\"timestamp\": \"" + timestamp + "\",";
  log += "\"error_type\": \"" + error_type + "\",";
  log += "\"message\": \"" + message + "\",";
  log += "\"sent\": false";
  log += "}";

  Serial.println("Log created:");
  Serial.println(log);

  // إرسال الـ log إلى السيرفر عبر API
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    String serverUrl = "http://192.168.1.3:8000/api/logs/add_device_log/"; // رابط الـ API للإرسال
    http.begin(serverUrl);
    http.addHeader("Authorization", "Token " + token);  // إضافة التوكن للتحقق من الصلاحية
    http.addHeader("Content-Type", "application/json");

    // إرسال الـ POST request
    int httpResponseCode = http.POST(log);

    // التحقق من حالة الاستجابة
    if (httpResponseCode == 201) {
      Serial.println("✅ Log sent successfully.");
    } else {
      Serial.print("❌ Error sending log. HTTP Response Code: ");
      Serial.println(httpResponseCode);
    }

    http.end();
  } else {
    Serial.println("📴 غير متصل بالواي فاي");
  }
}

// Function to check for temperature and battery errors
void check_sensors(const String& device_id, const String& device_name, float temperature, int battery_level, const String& token) {
  // Temperature check
  if (isnan(temperature) || temperature < temperature_min_threshold || temperature > temperature_max_threshold) {
    String temp_msg = "Temperature sensor malfunction (Temp: " + String(temperature, 1) + " C)";
    add_device_log(device_id, device_name, "temp sensor", temp_msg, token);
  }

  // Battery check
  if (battery_level < battery_threshold) {
    String battery_msg = "Battery is low (Battery: " + String(battery_level) + " %)";
    add_device_log(device_id, device_name, "battery low", battery_msg, token);
  }

  // RTC check
   if (rtc_update_counter >= 3) {
    String rtc_msg = "Time has been updated more than limits. There is something wrong with the RTC.";
    add_device_log(device_id, device_name, "rtc error", rtc_msg, token);
    
    // Optionally reset the counter or keep increasing for continued logging
    rtc_update_counter = 0;
  }
}