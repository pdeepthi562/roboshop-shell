log=/tmp/roboshop.log
# /tmp/roboshop.log (is the file all the outputs are saved)

echo -e "\e[36m>>>>>>>>> Create Catalogue Service <<<<<<<<<<<<\e[0m" | tee -a /tmp/roboshop.log
cp catalogue.service /etc/systemd/system/catalogue.service &>>${log}

echo -e "\e[36m>>>>>>>>> Create MongoDB Repo  <<<<<<<<<<<<\e[0m" | tee -a /tmp/roboshop.log
cp mongo.repo /etc/yum.repos.d/mongo.repo &>>${log}

echo -e "\e[36m>>>>>>>>> Install NodeJS Repos  <<<<<<<<<<<<\e[0m" | tee -a /tmp/roboshop.log
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${log}

echo -e "\e[36m>>>>>>>>> Install NodeJS <<<<<<<<<<<<\e[0m" | tee -a /tmp/roboshop.log
yum install nodejs -y &>>${log}

echo -e "\e[36m>>>>>>>>> Create Application User  <<<<<<<<<<<<\e[0m" | tee -a /tmp/roboshop.log
useradd roboshop &>>${log}

echo -e "\e[36m>>>>>>>>> Removing old Application Directory <<<<<<<<<<<<\e[0m" | tee -a /tmp/roboshop.log
rm -rf /app &>>${log}

echo -e "\e[36m>>>>>>>>> Create Application Directory <<<<<<<<<<<<\e[0m" | tee -a /tmp/roboshop.log
mkdir /app &>>${log}

echo -e "\e[36m>>>>>>>>> Download Application Content  <<<<<<<<<<<<\e[0m" | tee -a /tmp/roboshop.log
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip &>>${log}

echo -e "\e[36m>>>>>>>>> Extract Application Content <<<<<<<<<<<<\e[0m" | tee -a /tmp/roboshop.log
cd /app
unzip /tmp/catalogue.zip &>>${log}
cd /app
echo -e "\e[36m>>>>>>>>> Download NodeJS Dependencies <<<<<<<<<<<<\e[0m" | tee -a /tmp/roboshop.log
npm install &>>${log}
echo -e "\e[36m>>>>>>>>> Install Mongo Client  <<<<<<<<<<<<\e[0m" | tee -a /tmp/roboshop.log
yum install mongodb-org-shell -y &>>${log}

echo -e "\e[36m>>>>>>>>> Load Catalogue Schema <<<<<<<<<<<<\e[0m" | tee -a /tmp/roboshop.log
mongo --host mongodb.pdevops562.online </app/schema/catalogue.js &>>${log}

echo -e "\e[36m>>>>>>>>> Start Catalogue Service <<<<<<<<<<<<\e[0m" | tee -a /tmp/roboshop.log
systemctl daemon-reload &>>${log}
systemctl enable catalogue &>>${log}
systemctl restart catalogue &>>${log}
