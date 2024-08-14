#!/bin/sh

# Check if the 'app' directory exists
if [ ! -d app ]; then
    export COMPOSER_PROCESS_TIMEOUT=600
    composer create-project laravel/laravel new-app
    mv new-app/* .
    cp new-app/.* .
    rm -rf new-app

    # Ensure the trustProxies is configured in bootstrap/app.php
    APP_FILE="bootstrap/app.php"

    if [ -f "$APP_FILE" ]; then
        echo "Setting trusted proxies..."

        # Define the new trustProxies configuration with proper indentation
        NEW_TRUST_PROXIES="\t\t\$middleware->trustProxies(at: [\n\t\t\t\"10.42.0.0/16\",\n\t\t\t\"10.8.0.0/16\",\n\t\t\t\"10.1.0.0/16\"\n\t\t]);"

        # Remove the existing trustProxies configuration if it exists
        if grep -q '\$middleware->trustProxies(at:' "$APP_FILE"; then
            sed -i "/\$middleware->trustProxies(at:/,/]);/d" "$APP_FILE"
            echo "Removed existing trustProxies configuration from bootstrap/app.php."
        fi

        # Add the new trustProxies configuration
        sed -i "/->withMiddleware(function (Middleware \$middleware) {/a\\
$NEW_TRUST_PROXIES" "$APP_FILE"
        echo "Added trustProxies configuration to bootstrap/app.php."
    else
        echo "App configuration file bootstrap/app.php not found!"
    fi

    # Ensure the logging configuration is updated for both new and existing projects
    LOGGING_FILE="config/logging.php"

    if [ -f "$LOGGING_FILE" ]; then
        echo "Updating logging configuration..."

        # Update 'default' => 'stack'
        sed -i "s/'default' =>.*/'default' => 'stack',/" "$LOGGING_FILE"

        # Remove existing 'stack' block completely, without removing surrounding lines
        sed -i "/'stack' => \[/,/^\s*],\?/c\\
        'stack' => [\\
            'driver' => 'stack',\\
            'channels' => ['daily', 'stderr'],\\
            'ignore_exceptions' => false,\\
        ]," "$LOGGING_FILE"

        echo "Logging configuration updated."
    else
        echo "Logging configuration file not found!"
    fi

    # Ensure the cache configuration is updated for both new and existing projects
    CACHING_FILE="config/cache.php"

    if [ -f "$CACHING_FILE" ]; then
        echo "Updating caching configuration..."

        # Update 'default' => 'file'
        sed -i "s/'default' =>.*/'default' => 'file',/" "$CACHING_FILE"

        echo "Caching set to file"
    else
        echo "Caching configuration file not found!"
    fi

    # Additional configuration based on deploy-plan.json

    # Extract the first database in the "databases" array from deploy-plan.json
    DB_CONNECTION=$(php -r "echo json_decode(file_get_contents('deploy-plan.json'), true)['image']['databases'][0];")
    echo "Extracted DB_CONNECTION: $DB_CONNECTION"

    # Set default database connection in config/database.php
    if [ -f "config/database.php" ]; then
        # Use sed to update the 'default' setting for the database connection
        sed -i "s/'default' => env('DB_CONNECTION', '[^']*')/'default' => env('DB_CONNECTION', '$DB_CONNECTION')/" "config/database.php"
        echo "Default database set to $DB_CONNECTION in config/database.php."

        # Update or create DB_CONNECTION in .env file
        if grep -q '^DB_CONNECTION=' ".env"; then
            sed -i "s/^DB_CONNECTION=.*/DB_CONNECTION=$DB_CONNECTION/" ".env"
        else
            echo "DB_CONNECTION=$DB_CONNECTION" >> ".env"
        fi
        echo "DB_CONNECTION set to $DB_CONNECTION in .env file."

        # Check if "oracle" exists in the databases array and install its driver if it does
        if php -r "echo json_encode(json_decode(file_get_contents('deploy-plan.json'), true)['image']['databases']);" | grep -q '"oracle"'; then
            echo "Installing Oracle driver."

            # Install yajra/laravel-oci8 package
            composer require yajra/laravel-oci8
        fi
    else
        echo "Database configuration file not found!"
    fi

else
    echo "You already have a Laravel project!"
fi
