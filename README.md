# INSEE - Order &. Delivery Management Solution

The INSEE Order and Delivery Management cross-platform (iOS and android) mobile
applications and the web application will enable customers in Retail, B2B, SMP and
Building material segments to order products through the platform.
All these core functionalities will be governed by a back office web portal where the
INSEE staff members can log in and manage.

## Language localisations
https://en.wikipedia.org/wiki/Language_localisation#Language_tags_and_codes
flutter gen-l10n

## Build Command

```flutter build appbundle --flavor [env] -t lib/[dart target] --dart-define-from-file dotenv/[.env]```

### Android build commands
```
flutter build appbundle --flavor uat -t lib/main.dart --dart-define-from-file dotenv/.env.uat
```

```
flutter build apk --flavor uat -t lib/main_uat.dart --dart-define-from-file dotenv/.env.uat
```

```
flutter build appbundle --flavor production -t lib/main.dart --dart-define-from-file dotenv/.env.prod
```

```
flutter build apk --flavor prod -t lib/main_prod.dart --dart-define-from-file dotenv/.env.prod
```

### iOS build commands
```
flutter build ipa --flavor uat -t lib/main_uat.dart --dart-define-from-file dotenv/.env.uat
```

```
flutter build ipa --flavor prod -t lib/main_prod.dart --dart-define-from-file dotenv/.env.prod
```