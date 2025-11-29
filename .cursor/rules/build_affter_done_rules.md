# Cursor Rules cho Focus Extension Project

## Build Automation
- Sau khi hoàn thành mỗi task hoặc thực hiện các thay đổi quan trọng, tự động chạy `npm run build:ext` để build lại extension
- Command build: `npm run build:ext` (bao gồm: build:flutter, copy:newtab, sync:metadata, copy:icons)

## Project Structure
- Đây là Flutter project kết hợp với Chrome Extension
- Flutter code ở `lib/`
- Extension files ở `extension/`
- Build output: Flutter web build → copy vào `extension/newtab/`

## Code Style
- Luôn trả lời bằng tiếng Việt
- Tuân thủ Dart/Flutter best practices
- Sử dụng easy_localization cho i18n
- Sử dụng MobX cho state management

## Important Notes
- Khi chỉnh sửa code Flutter, cần build lại extension để áp dụng thay đổi
- Luôn kiểm tra linter errors trước khi commit
- Extension manifest version được sync tự động qua `sync:metadata` script

