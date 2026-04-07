#!/bin/bash
set -euo pipefail

LOG_FILE="/var/log/user-data.log"
exec > >(tee -a "${LOG_FILE}") 2>&1

echo "=== USER-DATA START ==="

if command -v dnf >/dev/null 2>&1; then
    PKG_MANAGER="dnf"
else
    PKG_MANAGER="yum"
fi

echo "Using package manager: ${PKG_MANAGER}"

${PKG_MANAGER} update -y
${PKG_MANAGER} install -y httpd

systemctl enable httpd
systemctl start httpd

cat > /var/www/html/index.html <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EC2 Welcome App</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            color: #333333;
            text-align: center;
            margin-top: 60px;
        }
        .container {
            background: #ffffff;
            width: 60%;
            margin: auto;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 0 12px rgba(0, 0, 0, 0.10);
        }
        h1 {
            color: #2c3e50;
        }
        p {
            font-size: 18px;
        }
        .small {
            font-size: 14px;
            color: #777777;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>EC2 Welcome App</h1>
        <p>The Apache HTTP Server is running correctly.</p>
        <p>This page was created automatically through AWS user-data.</p>
        <div class="small">Project demo by Maurizio Morgano</div>
    </div>
</body>
</html>
EOF

systemctl restart httpd

echo "=== USER-DATA COMPLETED ==="