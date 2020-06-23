# Google Permission Checker

[![Build Status](https://travis-ci.com/place-labs/google-permission-checker.svg?branch=master)](https://travis-ci.com/github/place-labs/google-permission-checker)

## Usage

```
crystal build ./src/checker.cr

# Check we can list the users calendars
checker -f auth.json -u user@domain.com

# Check we can get events from a resource calendar
checker -f auth.json -u user@domain.com -r domain.com_1884i1fih@resource.calendar.google.com

# Check the service user
checker -f auth.json -s admin@admin.domain.com -d domain.com
```
