# Nginx Log Analysis

This document describes how to analyze Nginx logs for troubleshooting purposes.

## Prerequisites

Make sure you have the necessary log files in your current directory.

## Steps

### 1. Decompress gzipped log files

```bash
gzip -dk *.gz
```

This command decompresses all `.gz` files in the current directory while keeping the original compressed files.

### 2. Find non-200 HTTP responses

```bash
grep -vP '(?<=HTTP/1\.1" )200 ' jnb.payeelink.com_nginx.log
```

This command filters out all HTTP 200 (success) responses, showing only the failed requests.

### 3. Identify duplicate requests

```bash
grep -o 'HD_TranId=[0-9]*' jnb.payeelink.com_nginx.log | sort | uniq -c | sort -nr | awk '$1>1'
```

This command:

- Extracts all `HD_TranId` values from the log
- Sorts them
- Counts occurrences of each ID
- Sorts by count in descending order to show the most frequent requests first
