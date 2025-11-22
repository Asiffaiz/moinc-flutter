# Reports Dummy Data

## Overview

Added dummy reports data to the `ReportsRepositoryImpl` to allow the client to view the Reports screen without a working API connection.

## Changes Made

### 1. Reports Repository (`reports_repository_impl.dart`)

- **Method**: `getReportsData()`
- **Change**: Commented out the actual API call to `_reportsService.getReportsData()`.
- **Addition**: Added a hardcoded list of 5 dummy `ReportsModel` objects with various statuses ("Completed", "Processing", "Pending") and dates.
- **Simulation**: Added a 1-second delay to simulate network latency.

## Usage

The app will now display these dummy reports on the Reports screen. To revert to API data, uncomment the lines in `getReportsData()` and remove the dummy data block.
