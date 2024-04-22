#!/bin/bash

GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}DEPLOYING LARAVEL APP TO SERVER USING LAMP STACK${NC}"
echo
echo -e "${PURPLE}----- Script by Nuel - https://github.com/AaRonStaRK019 -----${NC}"
echo
sleep 1
echo -e "${BLUE}Grab a coffee and let the magic happen . . .${NC}"

# --- update repos ---
echo
echo -e "${BLUE}----- running apt update -----${NC}"
echo
sudo apt update -y


#-- install and start apache web service --
echo
echo -e "${BLUE}----- installing ApacheWeb Server -----${NC}"
echo
sudo apt install apache2 -y
sudo systemctl restart apache2
echo
echo -e "${GREEN} ===== Apache Web server installed and started =====${NC}"
echo
sleep 1


# -- add apt repo for pHp8.2 and install required pHp extensions --
echo -e "${BLUE}----- adding necessary php8.2 repository to apt list -----${NC}"
echo
sudo add-apt-repository ppa:ondrej/php --yes  && sudo apt update -y
echo
# --- install php8.2 and necessary extensions ---
echo -e "${BLUE}----- installing php8.2 and php extensions -----${NC}"
echo
sudo apt install php8.2 php8.2-curl php8.2-ctype php8.2-dom php8.2-mbstring php8.2-xml php8.2-mysql zip unzip -y
echo
echo -e "${GREEN} ===== php and php extensions installed successfully =====${NC}"

#-- enable URL rewriting and restart apache --
echo
echo -e "${BLUE}----- enabling URL rewrite -----${NC}"
echo
sudo a2enmod rewrite
echo
sudo systemctl restart apache2


#-- install composer (for laravel dependencies) --
cd /usr/bin
echo
echo -e "${BLUE}----- getting Composer dependencies needed for Laravel -----${NC}"
echo
sudo curl -sS https://getcomposer.org/installer | sudo php -q
#--shorten phparchive name--
sudo mv composer.phar composer
echo
#--run composer--
#composer
# -- automate response [Enter] --


#--get laravel app from GitHub and clone to apache directory--
cd /var/www/

echo
echo -e "${BLUE}----- cloning Laravel app from Github -----${NC}"
echo
sudo git clone https://github.com/laravel/laravel.git
echo
sudo chown -R $USER:$USER /var/www/laravel
echo
echo -e "${GREEN}===== Laravel application cloned to /var/www/laravel ===== ${NC}"


#-------Get Composer dependencies---------
cd laravel
echo
echo -e "${BLUE}----- adding Composer dependencies to Laravel app -----${NC}"
echo
# export COMPOSER_ALLOW_SUPERUSER=1
composer install --optimize-autoloader --no-dev --no-interaction
composer update --no-interaction
echo

#-----define environment variables------
echo -e "${BLUE}===== Configuring environment variables =====${NC}"
echo
sudo cp .env.example .env
sudo sed -i '6s/APP_URL=http:\/\/localhost/APP_URL=192.168.56.4/' /var/www/laravel/.env

echo
echo "${BLUE}===== generating app key ... =====${NC}"
echo
sudo php artisan key:generate
echo
echo -e "${GREEN}===== app key generated and inserted =====${NC}"

#----------set permissions for application folders----------
sudo chown -R www-data storage
sudo chown -R www-data bootstrap/cache


#---------configure site---------
echo
echo "${BLUE}===== configuring site for use =====${NC}"
echo
sudo touch /etc/apache2/sites-available/laravel.conf
# -- edit conf file (ServerName, Document root, Directory)
sudo tee /etc/apache2/sites-available/laravel.conf <<EOF
<VirtualHost *:80>
    ServerName 192.168.56.4
    DocumentRoot /var/www/laravel/public

    <Directory /var/www/laravel/public>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/laravel-error.log
    CustomLog ${APACHE_LOG_DIR}/laravel-access.log combined
</VirtualHost>
EOF

echo
echo -e "${GREEN}===== application site configured to machine =====${NC}"
echo

#-- activate laravel.conf file and restart apache service--
sudo a2ensite laravel.conf

sudo apache2ctl -t

sudo systemctl restart apache2


# ------ CONFIGURE MySQL Server --------
echo
echo -e "${BLUE}----- Laravel application is almost ready to go... -----${NC}"
echo
echo -e "${BLUE}----- configuring mySQL database for Laravel application ------${NC}"
echo

sudo apt-get update -y
sudo apt-get install mysql-server -y 

# Start MySQL service
sudo systemctl start mysql
echo
echo -e "${GREEN}===== MySQL installed. Wait while we configure your Database =====${NC}"
echo
# Wait for MySQL to start
sleep 3

# Create the database 'laravel'
echo -e "${BLUE}----- creating database -----${NC}"
echo
sudo mysql -e "CREATE DATABASE laravel;"

# Create the user 'laravelAdmin' with password 'laravel-pass' and grant full permissions to 'laravel' database
echo -e "${BLUE}----- creating Admin for new MySQL Database -----${NC}"

sudo mysql -e "CREATE USER 'laravelAdmin'@'localhost' IDENTIFIED BY 'laravel-pass';"
sudo mysql -e "GRANT ALL PRIVILEGES ON laravel . * TO 'laravelAdmin'@'localhost';"

# Flush privileges for changes to take effect
echo
echo "${BLUE}----- enabling admin privileges -----${NC}"
echo
sudo mysql -e "FLUSH PRIVILEGES;"

cd /var/www/laravel
echo
echo "${BLUE}----- messing around with the Laravel environment variables -----${NC}"
echo
echo "${BLUE}----- making final touches -----${NC}"
echo

sudo sed -i '22s/DB_CONNECTION=sqlite/DB_CONNECTION=mysql/' /var/www/laravel/.env
sudo sed -i '23s/# DB_HOST=127.0.0.1/DB_HOST=127.0.0.1/' /var/www/laravel/.env
sudo sed -i '24s/# DB_PORT=3306/DB_PORT=3306/' /var/www/laravel/.env
sudo sed -i '25s/# DB_DATABASE=laravel/DB_DATABASE=laravel/' /var/www/laravel/.env
sudo sed -i '26s/# DB_USERNAME=root/DB_USERNAME=laravelAdmin/' /var/www/laravel/.env
sudo sed -i '27s/# DB_PASSWORD=/DB_PASSWORD=laravel-pass/' /var/www/laravel/.env

echo "${BLUE}----- migrating new Database settings into laravel application -----${NC}"
sudo php artisan migrate
echo

sudo php artisan db:seed

echo
echo -e "${GREEN}===== MySQL installation and database setup complete. =====${NC}"
echo 
echo -e "${GREEN}===== Laravel application is ready to go. =====${NC}"
echo
echo -e "${BLUE}===== Happy Coding =====${NC}"
echo
echo
echo -e "${PURPLE}----- Script by Nuel - https://github.com/AaRonStaRK019 -----${NC}"
echo
