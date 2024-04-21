#!/bin/bash

GREEN='\033[0;32m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo 'Deploying Laravel app to server using LAMP Stack'

echo "${PURPLE}----- Script by Nuel - https://github.com/AaRonStaRK019 -----${NC}"

echo 'Grab a coffee and let the magic happen . . .'

# --- update repos ---
echo 'running apt update'
sudo apt update


#-- install and start apache web service --
echo 'installing ApacheWeb Server'
sudo apt install apache2 -y
sudo systemctl restart apache2

echo -e "${GREEN} ===== Apache Web server installed and started =====${NC}"

sleep 1


# -- add apt repo for pHp8.2 and install required pHp extensions --
echo 'adding necessary php8.2 repository to apt list'
sudo add-apt-repository ppa:ondrej/php -y && sudo apt update

# --- install php8.2 and necessary extensions ---
echo 'installing php8.2 and php extensions'
sudo apt install php8.2 php8.2-curl php8.2-ctype php8.2-dom php8.2-mbstring php8.2-xml php8.2-mysql zip unzip -y

echo -e "${GREEN} ===== php and php extensions installed successfully =====${NC}"

#-- enable URL rewriting and restart apache --
echo 'enabling URL rewrite'
sudo a2enmod rewrite
sudo systemctl restart apache2


#-- install composer (for laravel dependencies) --
cd /usr/bin

echo 'getting Composer dependencies needed for Laravel'
sudo curl -sS https://getcomposer.org/installer | sudo php
#--shorten phparchive name--
sudo mv composer.phar composer
#--run composer--
composer
# -- automate response [Enter] --


#--get laravel app from GitHub and clone to apache directory--
cd /var/www/

echo 'cloning Laravel app from Github'
sudo git clone https://github.com/laravel/laravel.git

echo -e "${GREEN}===== Laravel application cloned to /var/www/laravel ===== ${NC}"


#-------Get Composer dependencies---------
cd laravel

echo 'adding Composer dependencies to Laravel app'
# export COMPOSER_ALLOW_SUPERUSER=1
sudo COMPOSER_ALLOW_SUPERUSER=1 composer install --optimize-autoloader --no-dev -n

#-----define environment variables------
echo '===== Configuring environment variables ====='
sudo cp .env.example .env
sudo sed -i '6s/APP_URL=http:\/\/localhost/APP_URL=192.168.56.5/' /var/www/laravel/.env

echo '===== generating app key ... ====='
sudo php artisan key:generate
echo -e "${GREEN}===== app key generated and inserted =====${NC}"

#----------set permissions for application folders----------
sudo chown -R www-data storage
sudo chown -R www-data bootstrap/cache


#---------configure site---------
echo 'configuring site for use'
sudo touch /etc/apache2/sites-available/laravel.conf
# -- edit conf file (ServerName, Document root, Directory)
sudo tee /etc/apache2/sites-available/laravel.conf <<EOF
<VirtualHost *:80>
    ServerName 192.168.56.5
    DocumentRoot /var/www/laravel/public

    <Directory /var/www/laravel/public>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/laravel-error.log
    CustomLog ${APACHE_LOG_DIR}/laravel-access.log combined
</VirtualHost>
EOF

echo -e "${GREEN}===== application site configured to machine =====${NC}"
#-- activate laravel.conf file and restart apache service--
sudo a2ensite laravel.conf

sudo apache2ctl -t

sudo systemctl restart apache2


# ------ CONFIGURE MySQL Server --------
echo '----- Laravel application is almost ready to go... -----'
echo
echo '----- configuring mySQL database for Laravel application ------'
echo

sudo apt-get update
sudo apt-get install -y mysql-server

# Start MySQL service
sudo systemctl start mysql
echo -e "${GREEN}===== MySQL installed. Wait while we configure your Database =====${NC}"
# Wait for MySQL to start
sleep 3

# Create the database 'laravel'
echo '----- creating database -----'
sudo mysql -e "CREATE DATABASE laravel;"

# Create the user 'laravelAdmin' with password 'laravel-pass' and grant full permissions to 'laravel' database
echo '----- creating Admin for new MySQL Database -----'

sudo mysql -e "CREATE USER 'laravelAdmin'@'localhost' IDENTIFIED BY 'laravel-pass';"
sudo mysql -e "GRANT ALL PRIVILEGES ON laravel . * TO 'laravelAdmin'@'localhost';"

# Flush privileges for changes to take effect
echo '----- enabling admin privileges -----'
sudo mysql -e "FLUSH PRIVILEGES;"

cd /var/www/laravel

echo '----- messing around with the Laravel environment variables -----'
echo '----- making final touches -----'

sudo sed -i '22s/DB_CONNECTION=sqlite/DB_CONNECTION=mysql/' /var/www/laravel/.env
sudo sed -i '23s/# DB_HOST=127.0.0.1/DB_HOST=127.0.0.1/' /var/www/laravel/.env
sudo sed -i '24s/# DB_PORT=3306/DB_PORT=3306/' /var/www/laravel/.env
sudo sed -i '25s/# DB_DATABASE=laravel/DB_DATABASE=laravel/' /var/www/laravel/.env
sudo sed -i '26s/# DB_USERNAME=root/DB_USERNAME=laravelAdmin/' /var/www/laravel/.env
sudo sed -i '27s/# DB_PASSWORD=/DB_PASSWORD=laravel-pass/' /var/www/laravel/.env

echo '----- migrating new Database settings into laravel application -----'
sudo php artisan migrate

sudo php artisan db:seed

echo -e "${GREEN}===== MySQL installation and database setup complete. =====${NC}"
echo 
echo -e "${GREEN}===== Laravel application is ready to go. =====${NC}"
echo
echo
echo "${PURPLE}----- Script by Nuel - https://github.com/AaRonStaRK019 -----${NC}"
