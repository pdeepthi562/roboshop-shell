log=/tmp/roboshop.log

func_apppreq() {
  echo -e "\e[36m>>>>>>>>> Create ${component} Service <<<<<<<<<<<<\e[0m" | tee -a /tmp/roboshop.log
    cp ${component}.service /etc/systemd/system/${component}.service &>>${log}
  echo -e "\e[36m>>>>>>>>> Create Application User  <<<<<<<<<<<<\e[0m" | tee -a /tmp/roboshop.log
    useradd roboshop &>>${log}

    echo -e "\e[36m>>>>>>>>> Removing old Application Directory <<<<<<<<<<<<\e[0m" | tee -a /tmp/roboshop.log
    rm -rf /app &>>${log}

    echo -e "\e[36m>>>>>>>>> Create Application Directory <<<<<<<<<<<<\e[0m" | tee -a /tmp/roboshop.log
    mkdir /app &>>${log}

    echo -e "\e[36m>>>>>>>>> Download Application Content  <<<<<<<<<<<<\e[0m" | tee -a /tmp/roboshop.log
    curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>${log}

    echo -e "\e[36m>>>>>>>>> Extract Application Content <<<<<<<<<<<<\e[0m" | tee -a /tmp/roboshop.log
    cd /app
    unzip /tmp/${component}.zip &>>${log}
    cd /app
}


func_systemd() {

echo -e "\e[36m>>>>>>>>> Start ${component} Service <<<<<<<<<<<<\e[0m" | tee -a /tmp/roboshop.log
  systemctl daemon-reload &>>${log}
  systemctl enable ${component} &>>${log}
  systemctl restart ${component} &>>${log}
}

func_schema_setup() {
  if [ "${schema_type}" == "mongodb" ]; then
  echo -e "\e[36m>>>>>>>>> Install MongoDB Client  <<<<<<<<<<<<\e[0m"
      yum install mongdb -y &>>${log}

   echo -e "\e[36m>>>>>>>>> Load User Schema  <<<<<<<<<<<<\e[0m"
   mongo --h mongodb.pdevops562.online  < /app/schema/${component}.sql &>>${log}
   fi
   if [ "${schema_type}" == "mysql" ]; then
   echo -e "\e[36m>>>>>>>>> Install MysQl Client  <<<<<<<<<<<<\e[0m"
       yum install mysql -y &>>${log}
       echo -e "\e[36m>>>>>>>>> Load Schema  <<<<<<<<<<<<\e[0m"
       mysql -h mysql.pdevops562.online -uroot -pRoboShop@1 < /app/schema/${component}.sql &>>${log}
       fi
      }

func_nodejs() {
  log=/tmp/roboshop.log
  # /tmp/roboshop.log (is the file all the outputs are saved)


  echo -e "\e[36m>>>>>>>>> Create MongoDB Repo  <<<<<<<<<<<<\e[0m" | tee -a /tmp/roboshop.log
  cp mongo.repo /etc/yum.repos.d/mongo.repo &>>${log}

  echo -e "\e[36m>>>>>>>>> Install NodeJS Repos  <<<<<<<<<<<<\e[0m" | tee -a /tmp/roboshop.log
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${log}

  echo -e "\e[36m>>>>>>>>> Install NodeJS <<<<<<<<<<<<\e[0m" | tee -a /tmp/roboshop.log
  yum install nodejs -y &>>${log}

func_apppreq

  echo -e "\e[36m>>>>>>>>> Download NodeJS Dependencies <<<<<<<<<<<<\e[0m" | tee -a /tmp/roboshop.log
  npm install &>>${log}

 func_schema_setup
  func_systemd
  }
  func_java() {

    echo -e "\e[36m>>>>>>>>> Install maven <<<<<<<<<<<<\e[0m"
    yum install maven -y &>>${log}

    func_apppreq

    echo -e "\e[36m>>>>>>>>> Build ${component} Service  <<<<<<<<<<<<\e[0m"
    mvn clean package &>>${log}
    mv target/${component}-1.0.jar ${component}.jar &>>${log}

 func_schema_setup
    func_systemd
    }


func_python() {

   echo -e "\e[36m>>>>>>>>> Install python <<<<<<<<<<<<\e[0m"
  yum install python36 gcc python3-devel -y &>>${log}

  func_apppreq

  echo -e "\e[36m>>>>>>>>> Build ${component} Service  <<<<<<<<<<<<\e[0m"
  pip3.6 install -r requirements.txt &>>${log}

  func_systemd

}

