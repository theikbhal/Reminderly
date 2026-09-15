# Reminderly

A beautiful macOS app for managing reminders with flexible repeat options.

## Features

- **Flexible Repeat**: One-time, Daily, Weekly, Monthly, Yearly
- **Exact Date & Time**: Set precise reminder times
- **Categories**: Work, Personal, Health, Finance, Family
- **Search**: Find reminders instantly
- **Notifications**: Open app directly from notification
- **Export**: JSON, CSV, Markdown, SQL formats
- **Onboarding**: Beautiful welcome flow

## Installation

### Download
1. Go to Releases
2. Download `Reminderly.app.zip`
3. Move to Applications folder

### Build from Source
```bash
git clone https://github.com/ikbhal/Reminderly.git
cd Reminderly
./build.sh
cp -R build/Reminderly.app /Applications/
```

## Usage

1. Click **+** to add a new reminder
2. Set title, notes, date/time
3. Choose repeat type (None/Daily/Weekly/Monthly/Yearly)
4. Assign a category
5. Receive notifications at the scheduled time
6. Swipe to complete or delete reminders
7. Search across all reminders

## Categories

- General (blue)
- Work (orange)
- Personal (purple)
- Health (red)
- Finance (green)
- Family (pink)

## Notification Types

| Type | Description |
|------|-------------|
| None | One-time notification |
| Daily | Repeats every day at same time |
| Weekly | Repeats same day each week |
| Monthly | Repeats same date each month |
| Yearly | Repeats same date each year |

## Export Formats

- **JSON**: Structured backup
- **CSV**: Spreadsheet compatible
- **Markdown**: Human-readable report
- **SQL**: Database with schema

## License

MIT License
