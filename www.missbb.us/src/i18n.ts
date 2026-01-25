import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';

// Detect user's browser language
const browserLanguage = navigator.language.split('-')[0]; // e.g., 'en' from 'en-US'

i18n
  .use(initReactI18next)
  .init({
    resources: {
      en: {
        translation: {
          "personalInformation": "Personal Information",
          "age": "Age",
          "yearsOld": "years old",
          "nationality": "Nationality",
          "height": "Height",
          "weight": "Weight",
          "bloodType": "Blood Type",
          "bust": "Bust",
          "frequentlyActiveLocations": "Frequently Active Locations",
          "description": "Description",
          "gallery": "Gallery",
          "lineContact": "LINE Contact",
          "telegramContact": "Telegram Contact",
          "scanQrCode": "Scan the QR code with your {{app}} app"
        }
      },
      zh: {
        translation: {
          "personalInformation": "个人信息",
          "age": "年龄",
          "yearsOld": "岁",
          "nationality": "国籍",
          "height": "身高",
          "weight": "体重",
          "bloodType": "血型",
          "bust": "胸围",
          "frequentlyActiveLocations": "常活动地点",
          "description": "描述",
          "gallery": "相册",
          "lineContact": "LINE 联系方式",
          "telegramContact": "Telegram 联系方式",
          "scanQrCode": "使用 {{app}} 应用扫描二维码"
        }
      },
      ja: {
        translation: {
          "personalInformation": "個人情報",
          "age": "年齢",
          "yearsOld": "歳",
          "nationality": "国籍",
          "height": "身長",
          "weight": "体重",
          "bloodType": "血液型",
          "bust": "バスト",
          "frequentlyActiveLocations": "よく活動する場所",
          "description": "説明",
          "gallery": "ギャラリー",
          "lineContact": "LINE 連絡先",
          "telegramContact": "Telegram 連絡先",
          "scanQrCode": "{{app}}アプリでQRコードをスキャンしてください"
        }
      }
    },
    lng: browserLanguage, // Use browser language
    fallbackLng: 'en', // Fallback to English
    
    interpolation: {
      escapeValue: false // React already safes from XSS
    }
  });

export default i18n;