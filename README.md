# dreport

dreport is a command-line tool for converting dart & flutter test and analysis results to reports supported by other tools.

## Features

- Convert dart analyzer results to GitLab Code Quality format

## Example

```bash
dart pub global activate dreport

# Convert to GitLab Code Quality format
dart analyze . | dreport convert --format gitlab --output report.json

# Or use input
dart analyze . > report.txt
dreport convert --format gitlab --output report.json --input report.txt
```
