#!/bin/bash
# This script will configure your LockSelf installation
# It will create a env file. This file will be mount in your container.
# Maintener: LockSelf SAS <contact@lockself.com>

if [ -f $PWD/env ]
then
  printf "You already have a LockSelf installation. Be careful to dont lose the '~/env' file. Without it, it will be impossible to access your datas. If you're sure to would reinstall LockSelf, delete the ~/env file and relaunch this script."
  exit 1
fi

printf " _                _     _____      _  __ \n"
printf "| |              | |   / ____|    | |/ _|\n"
printf "| |     ___   ___| | _| (___   ___| | |_ \n"
printf "| |    / _ \ / __| |/ /\___ \ / _ \ |  _|\n"
printf "| |___| (_) | (__|   < ____) |  __/ | |  \n"
printf "|______\___/ \___|_|\_\_____/ \___|_|_|  \n\n"

printf "Welcome to the LockSelf's on-premises installation program\n"
printf "First, we will configure the database informations (applicative account - step 5.3):\n\n"

while [[ $dbHost == "" ]]
do
    printf "DB Host: > " && read dbHost
done
while [[ $dbName == "" ]]
do
    printf "DB Name: > " && read dbName
done
while [[ $dbUser == "" ]]
do
    printf "DB User (applicative account): > " && read dbUser
done
while [[ $dbPassword == "" ]]
do
    printf "DB Password (applicative account): > " && read -s dbPassword
done
while [[ $dbPassword2 == "" ]]
do
    printf "\nVerify your DB Password (applicative account): > " && read -s dbPassword2
done
if [[ $dbPassword != $dbPassword2 ]]
then
    printf "\nThe two passwords are not corresponding. Please relaunch the installation."
    exit 1
fi

printf "\n\nNow, lets configure the database informations for the user lockself_migration: (step 5.3)\n"
while [[ $dbPasswordPhinx == "" ]]
do
    printf "DB Password lockself_migration: > " && read -s dbPasswordPhinx
done
while [[ $dbPassword2Phinx == "" ]]
do
    printf "\nVerify your DB Password lockself_migration: > " && read -s dbPassword2Phinx
done
if [[ $dbPasswordPhinx != $dbPassword2Phinx ]]
then
    printf "\nThe two passwords are not corresponding. Please relaunch the installation."
    exit 1
fi

printf "\n\nPlease now enter the passphrase choosen for the JWT: (step 6.2)\n"
while [[ $jwtPassphrase == "" ]]
do
    printf "Write your JWT Passphrase: > " && read -s jwtPassphrase
done
while [[ $jwtPassphrase2 == "" ]]
do
    printf "\nVerify your JWT Passphrase: > " && read -s jwtPassphrase2
done
if [[ $jwtPassphrase != $jwtPassphrase2  ]]
then
    printf "The two passwords are not corresponding. Please relaunch the installation."
    exit 1
fi

printf  "\n\nLet's configure the SMTP connexion (it will be used to send the system email):\n"
while [[ $smtpHost == "" ]]
do
    printf "SMTP Host: > " && read smtpHost
done
while [[ $smtpPort == "" ]]
do
    printf "SMTP Port: > " && read smtpPort
done
while [[ $smtpAuth == "" ]]
do
    printf "SMTP Auth: (true or false) > " && read smtpAuth
done
if [ $smtpAuth == "true" ]
then
    while [[ $smtpUsername == "" ]]
    do
        printf "SMTP Username: > " && read smtpUsername
    done
    while [[ $smtpPassword == "" ]]
    do
        printf "SMTP Password: > " && read smtpPassword
    done
else
    smtpUsername=""
    smtpPassword=""
fi
while [[ $smtpSsl == "" ]]
do
    printf "SMTP SSL: (ssl or tls or null) > " && read smtpSsl
done

if [ $smtpSsl == "null" ]
then
    smtpSsl=""
fi

while [[ $smtpNoReply == "" ]]
do
    printf "No-reply address: (ex: no-reply@company.com) > " && read smtpNoReply
done
printf `date`
printf "\nSMTP configuration terminated\n"

printf  "\n\nLast thing, specify the domain you want to use:"
while [[ $domain == "" ]]
do
    printf "\nDomain: (ex: lockself.company.com) > " && read domain
done

/bin/cat <<EOF > $PWD/env
###> symfony/framework-bundle ###
APP_ENV=prod
APP_DEBUG=0
APP_SECRET=62ab7ba420f13ef7f912d270c2a40ee0
###< symfony/framework-bundle ###

###> lexik/jwt-authentication-bundle ###
JWT_SECRET_KEY=%kernel.project_dir%/config/jwt/private.pem
JWT_PUBLIC_KEY=%kernel.project_dir%/config/jwt/public.pem
JWT_PASSPHRASE="$jwtPassphrase"
JWT_TTL=604800
###< lexik/jwt-authentication-bundle ###

###> doctrine/doctrine-bundle ###
DATABASE_URL='mysql://$dbUser:$dbPassword@$dbHost:3306/$dbName'
###< doctrine/doctrine-bundle ###

###> robmorgan/phinx ###
PHINX_USER='lockself_migration'
PHINX_PASSWORD='$dbPasswordPhinx'
PHINX_HOST='$dbHost'
PHINX_PORT='3306'
PHINX_DB_NAME='$dbName'
###< robmorgan/phinx ###

###> LockSelf ###
debug=0
domain=$domain
saltPassword1="$(LC_ALL=C tr -dc 'A-Za-z0-9!#%&()+,-./:;<=>?@[\]^_{|}~' </dev/urandom | head -c 16 ; echo)"
saltPassword2="$(LC_ALL=C tr -dc 'A-Za-z0-9!#%&()+,-./:;<=>?@[\]^_{|}~' </dev/urandom | head -c 16 ; echo)"
saltPin1="$(LC_ALL=C tr -dc 'A-Za-z0-9!#%&()+,-./:;<=>?@[\]^_{|}~' </dev/urandom | head -c 16 ; echo)"
saltPin2="$(LC_ALL=C tr -dc 'A-Za-z0-9!#%&()+,-./:;<=>?@[\]^_{|}~' </dev/urandom | head -c 16 ; echo)"
keyPin="$(LC_ALL=C tr -dc 'A-Za-z0-9!#%&()+,-./:;<=>?@[\]^_{|}~' </dev/urandom | head -c 32 ; echo)"
ivPin="$(LC_ALL=C tr -dc 'A-Za-z0-9!#%&()+,-./:;<=>?@[\]^_{|}~' </dev/urandom | head -c 16 ; echo)"
saltApiHash1="$(LC_ALL=C tr -dc 'A-Za-z0-9!#%&()+,-./:;<=>?@[\]^_{|}~' </dev/urandom | head -c 16 ; echo)"
saltApiHash2="$(LC_ALL=C tr -dc 'A-Za-z0-9!#%&()+,-./:;<=>?@[\]^_{|}~' </dev/urandom | head -c 16 ; echo)"
sampleHash="$(LC_ALL=C tr -dc 'A-Za-z0-9!#%&()+,-./:;<=>?@[\]^_{|}~' </dev/urandom | head -c 16 ; echo)"
blockConnexionInSecond=900
pinLength=6
saltTransfer1="$(LC_ALL=C tr -dc 'A-Za-z0-9!#%&()+,-./:;<=>?@[\]^_{|}~' </dev/urandom | head -c 16 ; echo)"
saltTransfer2="$(LC_ALL=C tr -dc 'A-Za-z0-9!#%&()+,-./:;<=>?@[\]^_{|}~' </dev/urandom | head -c 16 ; echo)"
saltTransferProtectedEmail1="$(LC_ALL=C tr -dc 'A-Za-z0-9!#%&()+,-./:;<=>?@[\]^_{|}~' </dev/urandom | head -c 16 ; echo)"
saltTransferProtectedEmail2="$(LC_ALL=C tr -dc 'A-Za-z0-9!#%&()+,-./:;<=>?@[\]^_{|}~' </dev/urandom | head -c 16 ; echo)"
saltDeposit1="$(LC_ALL=C tr -dc 'A-Za-z0-9!#%&()+,-./:;<=>?@[\]^_{|}~' </dev/urandom | head -c 16 ; echo)"
saltDeposit2="$(LC_ALL=C tr -dc 'A-Za-z0-9!#%&()+,-./:;<=>?@[\]^_{|}~' </dev/urandom | head -c 16 ; echo)"
saltMail1="$(LC_ALL=C tr -dc 'A-Za-z0-9!#%&()+,-./:;<=>?@[\]^_{|}~' </dev/urandom | head -c 16 ; echo)"
saltMail2="$(LC_ALL=C tr -dc 'A-Za-z0-9!#%&()+,-./:;<=>?@[\]^_{|}~' </dev/urandom | head -c 16 ; echo)"
bucket=
providerAccessKey=
providerSecretKey=
providerRegion=
providerEndpoint=
provider=LOCAL
depositTokenTime=15
noReplyEmail='$smtpNoReply'
colorBtn='#39499b'
companyName="LockSelf"
nameDepositBox="Access to a deposit box"
newFileDeposit="New file uploaded"
newTransfer="New protected file received"
apiVersion=3
intercoAd=0
intercoAdPrefix=''
importOrganization=0
importOrganizationSendEmail=0
intercoAdOrganizations=0
###< LockSelf ###

###> symfony/swiftmailer-bundle ###
MAILER_URL=smtp://$smtpHost:$smtpPort?encryption=$smtpSsl&username=$smtpUsername&password=$smtpPassword
###< symfony/swiftmailer-bundle ###

###> ovh/ovh ###
smsApplicationKey=
smsApplicationSecret=
smsConsumerKey=
smsEndpoint=
###< ovh/ovh ###

###> knplabs/knp-snappy-bundle ###
WKHTMLTOPDF_PATH=/usr/local/bin/wkhtmltopdf
WKHTMLTOIMAGE_PATH=/usr/local/bin/wkhtmltoimage
###< knplabs/knp-snappy-bundle ###

EOF

printf "\n\nStep 6.3 terminated. If you want to review your config file, like your smtp or database configuration, you can check the 'env' file which is created by this script or you can continue the deployment guide."